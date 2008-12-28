package MojoMojo::View::TT;

use strict;
use base 'Catalyst::View::TT';
use Template::Constants qw( :debug );

#__PACKAGE__->config->{DEBUG}       = DEBUG_UNDEF;
__PACKAGE__->config->{PRE_CHOMP}          = 2;
__PACKAGE__->config->{POST_CHOMP}         = 2;
__PACKAGE__->config->{CONTEXT}            = undef;
__PACKAGE__->config->{TEMPLATE_EXTENSION} = '.tt';
__PACKAGE__->config->{PRE_PROCESS}        = 'global.tt';

1;

=head1 MojoMojo::V::TT - Template Toolkit views for MojoMojo

=head1 SYNOPSIS

  # in some action
  $c->forward('MojoMojo::V::TT');

=head1 DESCRIPTION

Subclass of L<Catalyst::View::TT>.


=head1 SEE ALSO

L<Catalyst::View::TT>

=head1 AUTHOR

Marcus Ramberg C<marcus@thefeed.no>
David Naughton C<naughton@umn.edu>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
