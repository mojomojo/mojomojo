package MojoMojo::Schema::Entry;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("entry");
__PACKAGE__->add_columns(
  "id",
  "journal",
  "author",
  "title",
  "content",
  "posted",
  "location",
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("journal", "Journal", { pageid => "journal" });
__PACKAGE__->belongs_to("author", "Person", { id => "author" });

1;

