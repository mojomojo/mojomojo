package MojoMojo::Formatter::DocBook;

use strict;
use warnings;
use parent qw/MojoMojo::Formatter/;

eval
  "use XML::LibXSLT;use XML::SAX::ParserFactory (); use XML::LibXML::Reader;";
my $eval_res = $@;
use MojoMojo::Formatter::DocBook::Colorize;

my $xsltfile =
  "/usr/share/sgml/docbook/stylesheet/xsl/nwalsh/xhtml/docbook.xsl";

=head2 module_loaded

Return true if the module is loaded.

=cut

sub module_loaded
{
    return 0 unless -f $xsltfile;
    return $eval_res ? 0 : 1;
}

my $debug = 0;

=head1 NAME

MojoMojo::Formatter::DocBook - format part of content as DocBook

=head1 DESCRIPTION

This formatter will format content between two =docbook blocks as
DocBook document.

=head1 METHODS

=head2 format_content_order

Format order can be 1-99. The DocBook formatter runs on 10.

=cut

sub format_content_order { 10 }

=head2 format_content

Calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content
{
    my ($class, $content, $c) = @_;

    my @lines = split /\n/, $$content;
    my $dbk;
    $$content = "";
    my $start_re = $class->gen_re(qr/docbook/);
    my $end_re   = $class->gen_re(qr/end/);
    foreach my $line (@lines)
    {
        if ($dbk)
        {
            if ($line =~ m/^(.*)$end_re(.*)$/)
            {
                $$content .= $class->to_xhtml($dbk);
                $dbk = "";
            }
            else { $dbk .= $line . "\n"; }
        }
        else
        {
            if ($line =~ m/^(.*)$start_re(.*)$/)
            {
                $$content .= $1;
                $dbk = " " . $2;    # make it true :)
            }
            else { $$content .= $line . "\n"; }
        }
    }
}

=head2 to_xhtml <dbk>

Takes DocBook documentation and renders it as XHTML.

=cut

sub to_xhtml
{
    my ($class, $dbk) = @_;
    my $result;

    # Beurk
    $dbk =~ s/&/_-_amp_-_;/g;

    $dbk =~ s/^\s+//;
    $dbk =~ s/^\n+//;

    # 1 - Mark lang
    # <programlisting lang="..."> to <programlisting lang="...">[lang=...] code [/lang]
    my $my_Handler = MojoMojo::Formatter::DocBook::Colorize->new($debug);
    $my_Handler->step('marklang');

    my $parsersax = XML::SAX::ParserFactory->parser(Handler => $my_Handler,);

    my @markeddbk = eval { $parsersax->parse_string($dbk) };
    if ($@)
    {
        return "\nDocument malformed : $@\n";
    }

    # 2 - Transform with xslt
    my $parser = XML::LibXML->new();
    my $xslt   = XML::LibXSLT->new();

    my $source = eval { $parser->parse_string("@markeddbk") };

    if ($@)
    {
        return "\nDocument malformed : line $@\n";
    }

    my $style_doc = $parser->parse_file($xsltfile);
    my $stylesheet = eval { $xslt->parse_stylesheet($style_doc); };

    #    warn "@_" if @_;

    #return "XHTML XHTML XHTML";

    # C'est ici que l'on peut ajouter le css, LANG ...
    # voir http://docbook.sourceforge.net/release/xsl/current/doc/html/index.html
    # et   http://www.sagehill.net/docbookxsl
    my $results = $stylesheet->transform(
        $source,
        XML::LibXSLT::xpath_to_string(
            'section.autolabel'   => '1',
            'chapter.autolabel'   => '1',
            'suppress.navigation' => '1',
            'generate.toc'        => '0'
        )
    );

    my $format = 0;

    my $string = eval { $results->toString($format); };

    # 3 - Colorize Code [lang=...] ... code ... [/lang]
    $my_Handler->step('colorize');

    my @colorized = $parsersax->parse_string($string);

    $string = "@colorized";
    $string =~ s/_-_amp_-_;/&/g;

    # 4 - filter
    # To adapt to mojomojo
    # delete <?xml version ...>, <html>,</html>,<head>,</head>,<body>,</body>
    $string =~ s/^.*<body>//s;
    $string =~ s/<\/body>.*<\/html>//s;
    $string =~ s/<a id=\"id\d*\"><\/a>//g;
    $string =~ s/clear:\sboth//g;

    return $string;
}

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered>

=head1 AUTHORS

Daniel Brosseau <dab@catapulse.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
