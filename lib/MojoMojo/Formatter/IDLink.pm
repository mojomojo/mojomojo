package MojoMojo::Formatter::IDLink;
use strict;
use warnings;
use parent qw/MojoMojo::Formatter/;

=head1 NAME

MojoMojo::Formatter::IDLink - Linked {{id:<service name> <word>}}

=cut

my $CONF = {
    tw   => 'http://twitter.com/%s',
    htb  => 'http://b.hatena.ne.jp/%s',
    htd  => 'http://d.hatena.ne.jp/%s',
    cpan => 'http://search.cpan.org/~%s/',
    fb   => 'http://facebook.com/%s',
};

my $DEFAULT = 'tw';

=head1 DESCRIPTION

if you write:

    {{id bayashi}}

it will format like this

    <a href="http://twitter.com/bayashi">bayashi</a>

you can write:

    {{id:cpan bayashi}}

it will format like this

    <a href="http://search.cpan.org/~bayashi/">bayashi</a>

=head1 METHODS

=head2 format_content_order

The IDLink formatter has no special requirements
in terms of the order it gets run in, so it has a priority of 10.

=cut

sub format_content_order { 10 }

=head2 format_content

Calls the formatter. Takes a ref to the content as well as the context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;

    return unless $$content;

    my @lines = split /\n/, $$content;
    $$content = '';

    my $re   = $class->gen_re( qr/id(?::([^\s]+))?\s+(.+)/ );

    for my $line (@lines) {
        if ( $line =~ m/$re/ ) {
            $line = $class->process($c, $line, $re, $1, $2);
        }
        $$content .= $line . "\n";
    }

}

=head2 process

Here the actual formatting is done.

=cut
sub process {
    my $class = shift;
    my ($c, $line, $re, $site, $id) = @_;

    $site ||= $DEFAULT;

    unless ($CONF->{$site}) {
        my $sites = join ',', keys %{$CONF};
        $line =~ s/$re/"IDLink: ". $c->loc('identifier is wrong.'). " use [$sites]"/e;
        return $line;
    }

    my $url = sprintf($CONF->{$site}, $id);

    $line =~ s!$re!<a href="$url">$id</a>!;

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
