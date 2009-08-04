package MojoMojo::Formatter::File::Pod;

use parent qw/MojoMojo::Formatter/;

use MojoMojo::Formatter::Pod;

sub formatter_loaded { 
    return MojoMojo::Formatter::DocBook->formatter_loaded;
}


=head1 NAME

MojoMojo::Formatter::File::Pod - format Pod File in xhtml

=head1 DESCRIPTION


=head1 METHODS

=over 4

=item can_format

Can format Pod File

=cut

sub can_format { 
  my $self = shift;
  my $type = shift;

  return 1 if ( $type eq "pod" );
  return 0;
}


=item to_xhtml

takes Pod text and renders it as XHTML.

=cut

sub to_xhtml {
    my ( $self, $text ) = @_;
    my $result;
    return MojoMojo::Formatter::Pod->to_pod( $text );
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
