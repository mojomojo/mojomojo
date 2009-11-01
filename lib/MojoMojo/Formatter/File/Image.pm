package MojoMojo::Formatter::File::Image;

use base qw/MojoMojo::Formatter/;



=head1 NAME

MojoMojo::Formatter::File::Image - Image formatter

=head1 DESCRIPTION


Image is not formatted in xhtml. The controller Image is used instead.


=head1 METHODS

=over 4

=item can_format

Can format Pod File

=cut

sub can_format { 
  my $self = shift;
  my $type = shift;

  return 1 if ( $type =~ /png|jpg|gif|tiff/ );
  return 0;
}


=item to_xhtml

takes Text and renders it as XHTML.

=cut

sub to_xhtml {
    my ( $self, $text ) = @_;
    my $result;

    return "Image can not be formatted in XHTML";
}




=back

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>

=head1 AUTHORS

Daniel Brosseau <dab@catapulse.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
