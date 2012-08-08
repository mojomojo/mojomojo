package MojoMojo::Formatter::WikipediaLink;
use strict;
use warnings;
use parent qw/MojoMojo::Formatter/;
use utf8;

=head1 NAME

MojoMojo::Formatter::WikipediaLink - Linked Wikipedia by writing {{wikipedia:<lang> <word>}}

=head1 DESCRIPTION

Normally, to hyperlink to the Wikipedia, you'd write:

    [wikipedia Hello](http://en.wikipedia.org/wiki/Hello)

This plugin lets you write just

    {{wikipedia Hello}}

not just Link to Wikipedia in English page, you can use many languages

    {{wikipedia:ja こんにちは}}
    {{wikipedia:fr Salut}}

Actually, if you wrote this without a language ex.{{wikipedia Foo}},
select location of Wikipedia Link
is getting default-language setting of MojoMojo.

=head1 METHODS

=head2 format_content_order

The WikipediaLink formatter has no special requirements
in terms of the order it gets run in, so it has a priority of 17.

=cut

sub format_content_order { 17 }

=head2 format_content

Calls the formatter. Takes a ref to the content as well as the context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;

    my @lines = split /\n/, $$content;
    $$content = '';

    my $re   = $class->gen_re( qr/[wW]ikipedia(?::([^\s]+))?\s+(.+)/ );
    my $lang = $c->sessionid
                ? $c->session->{lang} : $c->pref('default_lang') || 'en';

    for my $line (@lines) {
        if ( $line =~ m/$re/ ) {
            $line = $class->process($c, $line, $re, $lang);
        }
        $$content .= $line . "\n";
    }

}

=head2 process

Here the actual formatting is done.

=cut
sub process {
    my $class = shift;
    my ($c, $line, $re, $lang) = @_;

    $line =~ m/$re/;
    my $wikipedia_lang = $1 || $c->pref('default_lang') || 'en';
    my $keyword        = $2;

    my $uri = URI->new("http://$wikipedia_lang.wikipedia.org/");
    $uri->path("/wiki/$keyword");

    $line =~ s!$re!<a href="$uri">$keyword</a>!;
    $c->stash->{precompile_off} = 1;

    return $line;
}


=head1 SEE ALSO

L<MojoMojo> and L<Module::Pluggable::Ordered>.

=head1 AUTHORS

Dai Okabayashi, L<bayashi at cpan . org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
