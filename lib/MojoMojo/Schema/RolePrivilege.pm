package MojoMojo::Schema::RolePrivilege;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("role_privilege");
__PACKAGE__->add_columns("page", "role", "privilege");
__PACKAGE__->set_primary_key("page", "role", "privilege");
__PACKAGE__->belongs_to("page", "Page", { id => "page" });
__PACKAGE__->belongs_to("role", "Role", { id => "role" });

1;

