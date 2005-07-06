package MojoMojo::M::Core::Entry;

MojoMojo::M::Core::Entry->has_a( 'journal' => 'MojoMojo::M::Core::Journal' );
MojoMojo::M::Core::Entry->has_a( 'author' => 'MojoMojo::M::Core::Person' );

=head1 AUTHORS

Marcus Ramberg C<marcus@thefeed.no>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
