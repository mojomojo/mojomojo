package MojoMojo::Schema::ResultSet::Role;

use strict;
use warnings;
use base qw/MojoMojo::Schema::Base::ResultSet/;

=head2 active_roles

Filter inactive roles.

=cut

sub active_roles {
    shift->search( { active => 1 } );
}

1;