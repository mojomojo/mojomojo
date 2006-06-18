package MojoMojo::M::Core::Preference;

__PACKAGE__->columns(Essential=>qw/prefvalue/);
__PACKAGE__->default_search_attributes( { use_resultset_cache => 1 });

=head1 NAME

MojoMojo::M::Core::Preference - Preference settings.

=head1 DESCRIPTION

This class represents preference settings for MojoMojo.

=head1 SEE ALSO

L<MojoMojo>, L<MojoMojo::M::CDBI>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
