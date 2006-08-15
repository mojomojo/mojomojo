package MojoMojo::Schema::Link;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("link");
__PACKAGE__->add_columns(
  "id",
    { data_type => "INTEGER", is_nullable => 0, size => undef, is_auto_increment => 1 },
  "from_page",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
  "to_page",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("from_page", "Page", { id => "from_page" });
__PACKAGE__->belongs_to("to_page", "Page", { id => "to_page" });

1;

