package MojoMojo::Formatter::RSS;

use strict;
use parent 'MojoMojo::Formatter';

eval {require LWP::Simple; require URI::Fetch; require XML::Feed};
my $dependencies_installed = !$@;

=head2 module_loaded

Return true if the module is loaded.

=cut

sub module_loaded { $dependencies_installed }

our $VERSION = '0.01';

=head1 NAME

MojoMojo::Formatter::RSS - Include RSS feeds on your page.

=head1 DESCRIPTION

This formatter takes a feed in the format {{feed <url>}}, and
passes it through L<XML::Feed> to get a formatted feed suitable
for inclusion in your page. It also caches them in the chosen
Catalyst cache. By default it will render the first element in
the feed, but it can take a numeric parameter to choose number of
elements.

=head1 METHODS

=head2 format_content_order

Format order can be 1-99. The RSS formatter runs on 6, after the
L<Include|MojoMojo::Formatter::Include>), so that transcluding
a page from the wiki that brings in a feed, will display the feed
in the transcluded section as well.

=cut


sub format_content_order { 6 }

=head2 format_content

Calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;
    return unless $class->module_loaded;
    # Regexp::Common::URI is overkill
    my $re = $class->gen_re(qr(
        feed \s+ (\S+)  # feed URL
        (?: \s+ (\d+))?  # optional maximum number of entries
    )x);
    if ( $$content =~ s/$re/$class->include_rss( $c, $1, $2 )/eg ) {
        # we don't want to precompile a page with comments so turn it off
        $c->stash->{precompile_off} = 1;
    }
}

=head2 include_rss <c> <url> [<entries>]

Returns HTML-formatted feed content for inclusion, up to a specified
number of entries. Will store a cached version in C<< $c->cache >>.

=cut

sub include_rss {
    my ($class, $c, $url, $entries) = @_;
    $entries ||= 1;
    $url = URI->new($url);
    return $c->loc('x is not a valid URL', $url) unless $url;
    
    my $result = URI::Fetch->fetch( $url, Cache => $c->cache );
    return $c->loc('Could not retrieve x', $url)
        if not defined $result;
    my $feed = XML::Feed->parse(\$result->content) or
        return $c->loc('Could not parse feed x', $url);
        
    my $count = 0;
    my $content = '';
    foreach my $entry ($feed->entries) {
        $count++;
        $content .= '<div class="feed">'
          . '<h3><a href="'.$entry->link.'">'
          . ($entry->title||"no title").'</a></h3>'
          . ($entry->content->body||$entry->summary->body||"")."</div>\n";
        return $content if $count==$entries;
    }
    return $content;
}

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered>, L<XML::Feed>, L<URI::Fetch>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
