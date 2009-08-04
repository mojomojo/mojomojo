package MojoMojo::Schema::ResultSet::Role;

use strict;
use warnings;
use parent qw/MojoMojo::Schema::Base::ResultSet/;

=head2 active_roles

Filter inactive roles.

=cut

sub active_roles {
    shift->search( { active => 1 } );
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
