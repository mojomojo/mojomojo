package MojoMojo::Formatter::GoogleSearch;
use strict;
use warnings;
use parent qw/MojoMojo::Formatter/;

=head1 NAME

MojoMojo::Formatter::GoogleSearch - Linked Google Search Engine by writing {{google:<search kind> <keyword>}}

=cut

my $CONF = {
    web => {
        base => 'http://www.google.com/search',
    },
    image  => {
        base => 'http://www.google.com/images',
    },
    movie  => {
        base => 'http://www.google.com/search',
        param => {
            tbs => 'vid:1',
        },
    },
};

=head1 DESCRIPTION

Normally, to hyperlink to a Search Engine, you'd write:

    [google SearchWord](http://www.google.com/search?q=SearchWord)

This plugin lets you write just

    {{google SearchWord}}

not just Search Web, you can search images and movies

    {{google:image SearchWord}}
    {{google:movie SearchWord}}

=head1 METHODS

=head2 format_content_order

The SearchEngine formatter has no special requirements
in terms of the order it gets run in, so it has a priority of 16.

=cut

sub format_content_order { 16 }

=head2 format_content

Calls the formatter. Takes a ref to the content as well as the context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;

    return unless $class->module_loaded;

    my @lines = split /\n/, $$content;
    $$content = '';

    my $re   = $class->gen_re( qr/google:?([^\s]+)?\s+(.+)/ );
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

    my $google_search = $c->loc('Google Search Link');

    $line =~ m/$re/;
    my $kind    = $1 || 'web';
    my $keyword = $2;

    unless ($CONF->{$kind}->{base}) {
        $line =~ s/$re/"$google_search: ". $c->loc('invalid Kind of Search')/e;
        return $line;
    }

    my %param;
    $param{q} = $keyword;
    if ($CONF->{$kind}->{param}) {
        for my $key (keys %{ $CONF->{$kind}->{param} }) {
            $param{$key} = $CONF->{$kind}->{param}->{$key};
        }
    }

    my $uri = URI->new($CONF->{$kind}->{base});
    $uri->query_form( %param );

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
