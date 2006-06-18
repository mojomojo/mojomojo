package MojoMojo::Schema::Journal;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("journal");
__PACKAGE__->add_columns("pageid", "name", "dateformat", "defaultlocation");
__PACKAGE__->set_primary_key("pageid");
__PACKAGE__->has_many("entries", "Entry", { "foreign.journal" => "self.pageid" });
__PACKAGE__->belongs_to("pageid", "Page", { id => "pageid" });

1;

