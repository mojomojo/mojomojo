package MojoMojo::Formatter::DocBook;


use strict;
use warnings;
use base qw/MojoMojo::Formatter/;

use XML::LibXSLT;
use XML::SAX::ParserFactory (); # loaded for simplicity;
use XML::LibXML::Reader;
use MojoMojo::Formatter::DocBook::Colorize;

my $xsltfile="/usr/share/sgml/docbook/stylesheet/xsl/nwalsh/xhtml/docbook.xsl";
my $debug=0;

=head1 NAME

MojoMojo::Formatter::DocBook - format part of content as DocBook

=head1 DESCRIPTION

This formatter will format content between two =docbook blocks as 
DocBook document.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The DocBook formatter runs on 10

=cut

sub format_content_order { 10 }

=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;

    my @lines = split /\n/, $$content;
    my $dbk;
    $$content = "";
    foreach my $line (@lines) {

        if ($dbk) {
            if ( $line =~ m/^=docbook\s*$/ ) {
                $$content .= MojoMojo::Formatter::File::DocBook->to_xhtml( $dbk );
                $dbk = "";
            }
            else { $dbk .= $line . "\n"; }
        }
        else {
            if ( $line =~ m/^=docbook\s*$/ ) {
                $dbk = " ";    # make it true :)
            }
            else { $$content .= $line . "\n"; }
        }
    }

    return $$content;
}




=back

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>

=head1 AUTHORS

Daniel Brosseau <dab@catapulse.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
