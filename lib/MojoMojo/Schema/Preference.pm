package MojoMojo::Schema::Preference;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("preference");
__PACKAGE__->add_columns("prefkey", "prefvalue");
__PACKAGE__->set_primary_key("prefkey");

1;

