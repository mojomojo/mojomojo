package MojoMojo::M::Core::Link;

=head1 NAME

MojoMojo::M::Core::Link - Inter-page links

=head1 DESCRIPTION

This class represents links between pages.

=cut

__PACKAGE__->has_a( 'from_page' => 'MojoMojo::M::Core::Page' );
__PACKAGE__->has_a( 'to_page'   => 'MojoMojo::M::Core::Page' );

=head1 SEE ALSO

L<Class::DBI::Sweet>, L<Catalyst>, L<MojoMojo>

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
