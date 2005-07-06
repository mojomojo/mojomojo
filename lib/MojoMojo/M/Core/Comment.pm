package MojoMojo::M::Core::Comment;

use Text::Textile2();


=head1 NAME

MojoMojo::M::Core::Attachment - Page attachments

=head1 DESCRIPTION

This class represents comments, either attached to pages or pictures.

=cut

my $textile=Text::Textile2->new(
    disable_html=>1,
    flavor=>'xhtml2', 
    charset=>'utf8', 
    char_encoding=>1
);

__PACKAGE__->has_a(
    posted => 'DateTime',
    inflate => sub {
        DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);
MojoMojo::M::Core::Comment->has_a( 'poster' => 'MojoMojo::M::Core::Person' );
MojoMojo::M::Core::Comment->has_a( 'page' => 'MojoMojo::M::Core::Page' );
MojoMojo::M::Core::Comment->has_a( 'picture' => 'MojoMojo::M::Core::Photo' );

=over 4

=item formatted

Returns a textile formatted version of the given comment.

=cut

sub formatted {
  my $self=shift;
  return $textile->process($self->body);
};

=back

=head1 SEE ALSO

L<Class::DBI::Sweet>, L<Catalyst>, L<MojoMojo>

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
