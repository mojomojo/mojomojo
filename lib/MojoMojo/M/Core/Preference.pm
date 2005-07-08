package MojoMojo::M::Core::Preference;

__PACKAGE__->columns(Essential=>qw/prefvalue/);
__PACKAGE__->default_search_attributes( { use_resultset_cache => 1 });

=head1 NAME

MojoMojo::M::Core::Preference - Preference settings.

=head1 DESCRIPTION

This class represents preference settings for MojoMojo.

=item SEE ALSO

L<MojoMojo>, L<MojoMojo::M::CDBI>

=item AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 License

This module is licensed under the same terms as Perl itself.

=cut

1;
