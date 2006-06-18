package MojoMojo::Schema::RoleMember;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("role_member");
__PACKAGE__->add_columns("role", "person", "admin");
__PACKAGE__->set_primary_key("role", "person");
__PACKAGE__->belongs_to("role", "Role", { id => "role" });
__PACKAGE__->belongs_to("person", "Person", { id => "person" });

1;

