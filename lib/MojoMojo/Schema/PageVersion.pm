package MojoMojo::Schema::PageVersion;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("page_version");
__PACKAGE__->add_columns(
  "page",
  "version",
  "parent",
  "parent_version",
  "name",
  "name_orig",
  "depth",
  "creator",
  "created",
  "status",
  "release_date",
  "remove_date",
  "comments",
  "content_version_first",
  "content_version_last",
);
__PACKAGE__->set_primary_key("page", "version");
__PACKAGE__->has_many(
  "pages",
  "Page",
  { "foreign.id" => "self.page", "foreign.version" => "self.version" },
);
__PACKAGE__->belongs_to("creator", "Person", { id => "creator" });
__PACKAGE__->belongs_to(
  "page",
  "Page",
  { page => "page" },
);
__PACKAGE__->belongs_to(
  "content",
  "Content",
  { page => "page", version => "content_version_first" },
);
__PACKAGE__->belongs_to(
  "content",
  "Content",
  { page => "page", version => "content_version_last" },
);
__PACKAGE__->belongs_to(
  "page_version",
  "PageVersion",
  { page => "parent", version => "parent_version" },
);
__PACKAGE__->has_many(
  "page_versions",
  "PageVersion",
  {
    "foreign.parent"         => "self.page",
    "foreign.parent_version" => "self.version",
  },
);

1;

