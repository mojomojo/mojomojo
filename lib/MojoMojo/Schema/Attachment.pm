package MojoMojo::Schema::Attachment;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("attachment");
__PACKAGE__->add_columns("id", "uploaded", "page", "name", "size", "contenttype");
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("page", "Page", { id => "page" });

1;

