package MojoMojo::Formatter::Redirect;

use base qw/MojoMojo::Formatter/;


=head1 NAME

MojoMojo::Formatter::Comment - Include comments on your page.

=head1 DESCRIPTION

Include files verbatim in your content, by writing =<url>.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Comment formatter runs on 91

=cut

sub format_content_order { 1 }


=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ($class,$content,$c)=@_;

    if (my ($page)=$$content =~ m/^=redirect\s((?:\/\w*)+)$/) {
        $c->res->redirect($c->uri_for($page)) if 
        $c->action->name eq 'view' && ! $c->ajax;
    }
}

=item include <c> <url>

returns the content of url. Will store a cached version in 
$c->cache

=cut

sub include {
    my ($class,$c,$url)=@_;
    $url=URI->new($url);
    return "$url is not a valid url." unless $url;
    my $rel=$url->rel($c->req->base);
    return "$url is part of own site, cannot include." unless $rel->scheme;
    my $res=URI::Fetch->fetch($url,Cache=>$c->cache);
    return $res->content if defined $res;
    return "Could not  retrieve $url.\n";
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
