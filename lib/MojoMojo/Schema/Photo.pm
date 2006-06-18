package MojoMojo::Schema::Photo;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("photo");
__PACKAGE__->add_columns(
  "id",
  "title",
  "description",
  "camera",
  "taken",
  "iso",
  "lens",
  "aperture",
  "flash",
  "height",
  "width",
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many("tags", "Tag", { "foreign.photo" => "self.id" });
__PACKAGE__->has_many("comments", "Comment", { "foreign.picture" => "self.id" });

1;

