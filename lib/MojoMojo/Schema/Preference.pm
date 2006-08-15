package MojoMojo::Schema::Preference;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("preference");
__PACKAGE__->add_columns(
  "prefkey",
    { data_type => "VARCHAR", is_nullable => 0, size => 100 },
  "prefvalue",
    { data_type => "VARCHAR", is_nullable => 1, size => 100 },
);
__PACKAGE__->set_primary_key("prefkey");

1;
