package MojoMojo::Model::DBIC;

use strict;
use parent 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config( schema_class => 'MojoMojo::Schema' );

=head1 NAME

MojoMojo::Model::DBIC - L<DBIC::Schema> Catalyst model

=head1 SYNOPSIS

See L<MojoMojo>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema in L<MojoMojo::Schema>.

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
