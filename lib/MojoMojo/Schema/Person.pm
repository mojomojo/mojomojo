package MojoMojo::Schema::Person;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("person");
__PACKAGE__->add_columns(
  "id",
  "active",
  "registered",
  "views",
  "photo",
  "login",
  "name",
  "email",
  "pass",
  "timezone",
  "born",
  "gender",
  "occupation",
  "industry",
  "interests",
  "movies",
  "music",
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many("entries", "Entry", { "foreign.author" => "self.id" });
__PACKAGE__->has_many("tags", "Tag", { "foreign.person" => "self.id" });
__PACKAGE__->has_many("comments", "Comment", { "foreign.poster" => "self.id" });
__PACKAGE__->has_many(
  "role_members",
  "RoleMember",
  { "foreign.person" => "self.id" },
);
__PACKAGE__->has_many(
  "page_versions",
  "PageVersion",
  { "foreign.creator" => "self.id" },
);
__PACKAGE__->has_many("contents", "Content", { "foreign.creator" => "self.id" });

1;

