package MojoMojo::M::Core::WantedPage;

=head1 NAME

MojoMojo::M::Core::WantedPage - A missing linked to page

=head1 DESCRIPTION

This object requests paths that have been linked to from a given
page, but does not exists anymore.

=cut

__PACKAGE__->has_a( 'from_page' => 'MojoMojo::M::Core::Page' );

=head1 SEE ALSO

L<Class::DBI::Sweet>, L<Catalyst>, L<MojoMojo>

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
