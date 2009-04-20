package MojoMojo::Formatter::File::DocBook;

use base qw/MojoMojo::Formatter/;

use MojoMojo::Formatter::DocBook;

sub module_loaded { 
    return MojoMojo::Formatter::DocBook->module_loaded();
}

=head1 NAME

MojoMojo::Formatter::File::DocBook - format Docbook in xhtml

=head1 DESCRIPTION


=head1 METHODS

=over 4

=item can_format

Can format DocBook (xml)

=cut

sub can_format { 
  my $self = shift;
  my $type = shift;

  return 1 if ( $type eq "xml" );
  return 0;
}


=item to_xhtml <dbk>

takes DocBook documentation and renders it as XHTML.

=cut

sub to_xhtml {
    my ( $class, $dbk ) = @_;
    my $result;

    return MojoMojo::Formatter::DocBook->to_xhtml($dbk);
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
