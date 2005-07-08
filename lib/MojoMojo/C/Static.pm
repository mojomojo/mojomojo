package MojoMojo::C::Static;

use strict;
use base 'Catalyst::Base';

=head1 NAME

MojoMojo::C::Static - Catalyst component

=head1 SYNOPSIS

See L<MojoMojo>

=head1 DESCRIPTION

Catalyst component.

=head1 METHODS

=over 4

=item begin

Overrides begin to avoid loading page objects.

=cut

sub begin : Private { }

=item ico (/favicon.ico)

serve favicon.ico statically.

=cut

sub ico : Global {
    my ( $self, $c ) = @_;
    $c->req->path('/favicon.ico');
    $c->serve_static;
}

=item static

serve all files under /.static in the root as static files.

=cut

sub static : Global {
    my ( $self, $c ) = @_;
    $c->res->headers->header( 'Cache-Control' => 'max-age=86400' );
      $c->serve_static;
}

=back

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
