package MojoMojo::Formatter::Redirect;

use base qw/MojoMojo::Formatter/;

=head1 NAME

MojoMojo::Formatter::Redirect - Handles =redirect /path.

=head1 DESCRIPTION

Redirect to another page. Useful if your URL changes and
you want to make sure bookmarked URLs will still work:
C</help/tutrial> could contain:
C<=redirect /help/tutorial>

To edit a page that redirects, surf to $page_URL . '.edit'
See also http://mojomojo.ideascale.com/akira/dtd/6415-2416

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Redirect formatter runs first.

=cut

sub format_content_order { 1 }

=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ( $class, $content, $c ) = @_;

    if ( my ($page) = $$content =~ m/^=redirect\s((?:\/\w*)+)/ ) {
        if ($c->action->name eq 'view' && !$c->ajax) {
            $c->flash->{'redirect'}=$c->stash->{'path'};;
            $c->res->redirect( $c->uri_for($page) );
        }
    }
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
