package MojoMojo::Schema::Page;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("page");
__PACKAGE__->add_columns(
  "id",
  "version",
  "parent",
  "name",
  "name_orig",
  "depth",
  "lft",
  "rgt",
  "content_version",
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "wantedpages",
  "WantedPage",
  { "foreign.from_page" => "self.id" },
);
__PACKAGE__->belongs_to("parent", "Page", { id => "parent" });
__PACKAGE__->has_many("children", "Page", { "foreign.parent" => "self.id" });
__PACKAGE__->belongs_to(
  "content",
  "Content",
  { page => "id", version => "content_version" },
);
__PACKAGE__->belongs_to(
  "page_version",
  "PageVersion",
  { page => "id", version => "version" },
);
__PACKAGE__->has_many("tags", "Tag", { "foreign.page" => "self.id" });
__PACKAGE__->has_many(
  "links_from",
  "Link",
  { "foreign.from_page" => "self.id" },
);
__PACKAGE__->has_many("links_to", "Link", { "foreign.to_page" => "self.id" });
__PACKAGE__->has_many(
  "roleprivileges",
  "RolePrivilege",
  { "foreign.page" => "self.id" },
);
__PACKAGE__->has_many("attachments", "Attachment", { "foreign.page" => "self.id" });
__PACKAGE__->has_many("comments", "Comment", { "foreign.page" => "self.id" });
__PACKAGE__->has_many("journals", "Journal", { "foreign.pageid" => "self.id" });

1;

