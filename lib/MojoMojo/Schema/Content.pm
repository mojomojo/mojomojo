package MojoMojo::Schema::Content;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("content");
__PACKAGE__->add_columns(
  "page",
  "version",
  "creator",
  "created",
  "status",
  "release_date",
  "remove_date",
  "type",
  "abstract",
  "comments",
  "body",
  "precompiled",
);
__PACKAGE__->set_primary_key("page", "version");
__PACKAGE__->has_many(
  "pages",
  "Page",
  {
    "foreign.content_version" => "self.version",
    "foreign.id" => "self.page",
  },
);
__PACKAGE__->has_many(
  "page_version_page_content_version_firsts",
  "PageVersion",
  {
    "foreign.content_version_first" => "self.version",
    "foreign.page" => "self.page",
  },
);
__PACKAGE__->has_many(
  "page_version_page_content_version_lasts",
  "PageVersion",
  {
    "foreign.content_version_last" => "self.version",
    "foreign.page" => "self.page",
  },
);
__PACKAGE__->belongs_to("creator", "Person", { id => "creator" });

1;

