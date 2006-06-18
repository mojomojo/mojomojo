package MojoMojo::Schema::Role;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("role");
__PACKAGE__->add_columns("id", "name", "active");
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("name_unique", ["name"]);
__PACKAGE__->has_many(
  "role_privileges",
  "RolePrivilege",
  { "foreign.role" => "self.id" },
);
__PACKAGE__->has_many("role_members", "RoleMember", { "foreign.role" => "self.id" });

1;

