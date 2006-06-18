package MojoMojo::Schema::Comment;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("comment");
__PACKAGE__->add_columns("id", "poster", "page", "picture", "posted", "body");
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("poster", "Person", { id => "poster" });
__PACKAGE__->belongs_to("page", "Page", { id => "page" });
__PACKAGE__->belongs_to("picture", "Photo", { id => "picture" });

1;

