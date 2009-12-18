package MojoMojo::Formatter::Include;

use strict;
use parent 'MojoMojo::Formatter';

eval {
    require URI::Fetch;
    require LWP::Simple;  # LWP::Simple is indeed required, and URI::Fetch doesn't depend on it
};
my $dependencies_installed = !$@;
sub module_loaded { $dependencies_installed }

our $VERSION = '0.01';

=head1 NAME

MojoMojo::Formatter::Include - Include files in your content.

=head1 DESCRIPTION

Include files verbatim in your content, by writing {{include <url>}}. Can
be used for transclusion from the same wiki, in which case the
L<inline|MojoMojo::Controller::Page/inline> version of the page is pulled.

=head1 METHODS

=head2 format_content_order

Format order can be 1-99. The Include formatter runs on 5, before all
formatters (except L<Redirect|MojoMojo::Formatter::Redirect>), so that
included content (most often from the same wiki) can be parsed for markup.
To avoid markup interpretation, surround the {{include <url>}} with a
C<< <div> >>:

    <div>Some uninterpreted Markdown: {{include http://mysite.com/rawmarkdown.txt}}</div>

=cut

sub format_content_order { 5 }

=head2 format_content

Calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;
    return unless $class->module_loaded;
    # Regexp::Common::URI is overkill
    my $re = $class->gen_re(qr(
        include \s+ (\S+)
    )x);
    if ( $$content =~ s/$re/$class->include( $c, $1 )/eg ) {
        # we don't want to precompile a page with comments so turn it off
        $c->stash->{precompile_off} = 1;
    }
}

=head2 include <c> <url>

Returns the content at the URL. Will store a cached version in
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
        return $c->subreq( '/inline', { path => $rel.'' eq './' ? '/' : '/'.$rel } );
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
