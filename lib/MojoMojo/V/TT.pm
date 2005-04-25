package MojoMojo::V::TT;

use strict;
use base 'Catalyst::View::TT';
use Template::Constants qw( :debug );


#__PACKAGE__->config->{DEBUG}       = DEBUG_UNDEF;
__PACKAGE__->config->{PRE_CHOMP}   = 2;
__PACKAGE__->config->{POST_CHOMP}  = 2;

=head1 MojoMojo::V::TT - Template Toolkit views for MojoMojo

=head1 SYNOPSIS

  # in some action
  $c->forward('MojoMojo::V::TT');

=head1 DESCRIPTION

Subclass of L<Catalyst::View::TT>.

=head1 METHODS

=over 4

=item process

MojoMojo uses paths with leading slashes (/). Therefore, we remove any trailing
slashes from base, to avoid double slashes when concatenating base and page
paths, then re-dispatch to Catalyst::View::TT::process.

=back

=cut

sub process {
    my ($self, $c) = @_;
    my $base = $c->req->base;
    $base =~ s/[\/]+$//g;
    $c->stash->{base} = $base;
    $self->NEXT::process( $c );
}

1;

=head1 SEE ALSO

L<Catalyst::View::TT>

=head1 AUTHOR

Marcus Ramberg C<marcus@thefeed.no>
David Naughton C<naughton@umn.edu>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
