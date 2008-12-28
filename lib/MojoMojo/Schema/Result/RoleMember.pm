package MojoMojo::Schema::Result::RoleMember;

use strict;
use warnings;

use base qw/MojoMojo::Schema::Base::Result/;

__PACKAGE__->load_components( "PK::Auto", "Core" );
__PACKAGE__->table("role_member");
__PACKAGE__->add_columns(
    "role",   { data_type => "INTEGER", is_nullable => 0, size => undef },
    "person", { data_type => "INTEGER", is_nullable => 0, size => undef },
    "admin",  { data_type => "INTEGER", is_nullable => 0, size => undef, default => 0 },
);
__PACKAGE__->set_primary_key( "role", "person" );
__PACKAGE__->belongs_to( "role",   "Role",   { id => "role" } );
__PACKAGE__->belongs_to( "person", "Person", { id => "person" } );

1;
