package MojoMojo::Formatter::RSS;


our $VERSION='0.01';
eval "use LWP::Simple;use URI::Fetch;use XML::Feed";
my $eval_res=$@;
sub module_loaded { $eval_res ? 0 : 1 }


=head1 NAME

MojoMojo::Formatter::RSS - Include rss feeds on your page.

=head1 DESCRIPTION

This formatter takes a feed in the format {{feed://<url>}}, and
passes it through L<XML::Feed> to get a formatted feed suitable
for inclusion in your page. It also caches them in the chosen
Catalyst Cache. By default it will render the first element in
the feed, but it can take a numeric parameter to choose number of
elements.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The RSS formatter runs on 4

=cut


sub format_content_order { 4 }

=item format_content

Calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ($class, $content, $c) = @_;
    return unless $class->module_loaded;
    my @lines=split /\n/, $$content;
    undef $$content;
    my $result;
    foreach my $line (@lines) {
        if ($line =~ m/^\{\{(feed\:\/\/\S+)\s*(\d+)?\s*\}\}/) {
            $$content .= $class->include_rss($c,$1,$2);
        } else {
            $$content .= $line."\n";
        }
   }
}

=item include_rss  <c> <url> [<entries>]

Returns HTML formatted content for inclusion.

=cut

sub include_rss {
    my ($class, $c, $url, $entries)=@_;
    $entries ||= 1;
    $url =~ s/^feed/http/;
    my $result = URI::Fetch->fetch($url,Cache=>$c->cache)->content;
    my $feed = XML::Feed->parse(\$result) or
        return "Could not retrieve $url .\n";
    my $count = 0;
    my $content = '';
    foreach my $entry ($feed->entries){
        $count++;
        $content .= '<div class="feed">'
          .'<h3><a href="'.$entry->link.'">'
          .($entry->title||"no title").'</a></h3>'
          .($entry->content->body||"")."</div>\n";
        return $content if $count==$entries;
    }
    return $content;
}

=back

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered>, L<XML::Feed>, L<URI::Fetch>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 License

This module is licensed under the same terms as Perl itself.

=cut

1;
