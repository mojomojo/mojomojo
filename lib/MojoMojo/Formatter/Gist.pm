package MojoMojo::Formatter::Gist;
use strict;
use warnings;
use parent qw/MojoMojo::Formatter/;

=head1 NAME

MojoMojo::Formatter::Gist - Embed Gist script

=head1 DESCRIPTION

Embed Gist script by writing {{gist <id>}}.

if you write:

    {{gist 618402}}

it will be formatted, like this

    <script src="https://gist.github.com/618402.js"></script>

then you can see the syntax highlighted source code.

=head1 METHODS

=head2 format_content_order

The Gist formatter has no special requirements
in terms of the order it gets run in, so it has a priority of 17.

=cut

sub format_content_order { 17 }

=head2 format_content

Calls the formatter. Takes a ref to the content as well as the context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;

    return unless $$content;

    my @lines = split /\n/, $$content;
    $$content = '';

    my $re = $class->gen_re( qr/gist\s+(\d+)/ );

    for my $line (@lines) {
        if ( $line =~ m/$re/ ) {
            $line = $class->process($c, $line, $re, $1);
        }
        $$content .= $line . "\n";
    }

}

=head2 process

Here the actual formatting is done.

=cut
sub process {
    my ( $class, $c, $line, $re, $id) = @_;

    my $gist = $c->loc('Gist Script');

    if (!$id || $id !~ /^\d+$/){
        $line =~ s/$re/"$gist: $id ". $c->loc('is not a valid id')/e;
        return $line;
    }

    my $url = "https://gist.github.com/$id";

    my $ar = $c->action->reverse;
    if ( $ar && ($ar eq 'pageadmin/edit' || $ar eq 'jsrpc/render') ){
        $line =~ s!$re!<div style='width: 95%;height: 90px; border: 1px black dotted;'>$gist - <a href="$url">gist:$id</a></div>!;
        $c->stash->{precompile_off} = 1;
    } else {
        $line =~ s!$re!<script src="$url.js"></script>!;
    }

    return $line;
}


=head1 SEE ALSO

L<MojoMojo> and L<Module::Pluggable::Ordered>.
Gist is <https://gist.github.com/>.

=head1 AUTHORS

Dai Okabayashi, L<bayashi at cpan . org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
