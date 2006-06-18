package MojoMojo::Schema::WantedPage;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("wanted_page");
__PACKAGE__->add_columns("id", "from_page", "to_path");
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("from_page", "Page", { id => "from_page" });

1;

