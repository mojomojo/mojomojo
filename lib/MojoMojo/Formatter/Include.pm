package MojoMojo::Formatter::Include;

use parent qw/MojoMojo::Formatter/;

eval "use LWP::Simple;use URI::Fetch;";
my $eval_res = $@;
sub module_loaded { $eval_res ? 0 : 1 }

=head1 NAME

MojoMojo::Formatter::Include - Include files in your content.

=head1 DESCRIPTION

Include files verbatim in your content, by writing {{<url>}}. Can be used for
transclusion from the same wiki, in which case the
L<inline|MojoMojo::Controller::Page/inline> version of the page is pulled.

=head1 METHODS

=head2 format_content_order

Format order can be 1-99. The Include formatter runs on 6

=cut

sub format_content_order { 6 }

=head2 format_content

Calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;
    return unless $class->module_loaded;
    my $re=$class->gen_re(qr/(http\:\/\/[^}]+)/);
    if ( $$content =~ s|$re|$class->include( $c, $1 )|meg ) {
        # We don't want to precompile a page with comments so turn it off
        $c->stash->{precompile_off} = 1;
    }
}

=head2 include <c> <url>

Returns the content of URL. Will store a cached version in
C<< $c->cache >>.

=cut

sub include {
    my ( $class, $c, $url ) = @_;
    $url = URI->new($url);
    return $c->loc('x is not a valid URL', $url) unless $url;
    # check if we're including a page from the same wiki
    my $rel = $url->rel( $c->req->base );
    if (not $rel->scheme) {
        # if so, then return the inline version of the page is requests
        return $c->subreq( '/inline', { path => '/'.$rel } );
    }
    my $res = URI::Fetch->fetch( $url, Cache => $c->cache );
    return $res->content if defined $res;
    return $c->loc('Could not retrieve x', $url);
}

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered>, L<URI::Fetch>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
