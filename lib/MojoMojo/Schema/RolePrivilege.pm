package MojoMojo::Schema::RolePrivilege;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components( "PK::Auto", "Core" );
__PACKAGE__->table("role_privilege");
__PACKAGE__->add_columns(
    "page",      { data_type => "INTEGER", is_nullable => 0, size => undef },
    "role",      { data_type => "INTEGER", is_nullable => 0, size => undef },
    "privilege", { data_type => "VARCHAR", is_nullable => 0, size => 20 },
);
__PACKAGE__->set_primary_key( "page", "role", "privilege" );
__PACKAGE__->belongs_to( "page", "Page", { id => "page" } );
__PACKAGE__->belongs_to( "role", "Role", { id => "role" } );

1;
