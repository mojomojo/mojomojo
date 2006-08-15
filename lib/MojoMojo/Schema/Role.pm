package MojoMojo::Schema::Role;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("role");
__PACKAGE__->add_columns(
  "id",
    { data_type => "INTEGER", is_nullable => 0, size => undef, is_auto_increment => 1 },
  "name",
    { data_type => "VARCHAR", is_nullable => 0, size => 200 },
  "active",
    { data_type => "INTEGER", is_nullable => 0, size => undef, default => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("name_unique", ["name"]);
__PACKAGE__->has_many(
  "role_privileges",
  "RolePrivilege",
  { "foreign.role" => "self.id" },
);
__PACKAGE__->has_many("role_members", "RoleMember", { "foreign.role" => "self.id" });

1;
