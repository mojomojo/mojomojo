package MojoMojo::Schema::PageVersion;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("page_version");
__PACKAGE__->add_columns(
  "page",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
  "version",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
  "parent",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
  "parent_version",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
  "name",
    { data_type => "VARCHAR", is_nullable => 0, size => 200 },
  "name_orig",
    { data_type => "VARCHAR", is_nullable => 0, size => 200 },
  "depth",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
  "creator",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
  "created",
    { data_type => "VARCHAR", is_nullable => 1, size => 100 },
  "status",
    { data_type => "VARCHAR", is_nullable => 0, size => 20 },
  "release_date",
    { data_type => "VARCHAR", is_nullable => 0, size => 100 },
  "remove_date",
    { data_type => "VARCHAR", is_nullable => 1, size => 100 },
  "comments",
    { data_type => "TEXT", is_nullable => 1, size => 4000 },
  "content_version_first",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
  "content_version_last",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
);
__PACKAGE__->set_primary_key("version", "page");
__PACKAGE__->has_many(
  "pages",
  "Page",
  { "foreign.id" => "self.page", "foreign.version" => "self.version" },
);
__PACKAGE__->belongs_to("creator", "Person", { id => "creator" });
__PACKAGE__->belongs_to(
  "page",
  "Page",
  { id => "page" },
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
