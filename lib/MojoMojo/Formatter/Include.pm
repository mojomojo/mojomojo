package MojoMojo::Formatter::Include;

use base qw/MojoMojo::Formatter/;

eval "use LWP::Simple;use URI::Fetch;";
my $eval_res = $@;
sub module_loaded { $eval_res ? 0 : 1 }

=head1 NAME

MojoMojo::Formatter::Include - Include files in your content.

=head1 DESCRIPTION

Include files verbatim in your content, by writing {{<url>}}.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Include formatter runs on 6

=cut

sub format_content_order { 6 }

=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;
    return unless $class->module_loaded;
    my $re=$class->gen_re(qr/(http\:\/\/[^}]+)/);
    $$content =~ s|$re|$class->include( $c, $1 )|meg;
}

=item include <c> <url>

returns the content of url. Will store a cached version in
$c->cache

=cut

sub include {
    my ( $class, $c, $url ) = @_;
    $url = URI->new($url);
    return "$url ".$c->loc('is not a valid url') unless $url;
    my $rel = $url->rel( $c->req->base );
    unless ($rel->scheme) {
        #warn "Trying to get ".$rel;
        return $c->subreq( '/inline', { path => '/'.$rel } );
    }
    my $res = URI::Fetch->fetch( $url, Cache => $c->cache );
    return $res->content if defined $res;
    return $c->loc('Could not retrieve')." $url.\n";
}

=back

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>,L<URI::Fetch>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 License

This module is licensed under the same terms as Perl itself.

=cut

1;
