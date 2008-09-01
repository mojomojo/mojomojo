package MojoMojo::Schema::Entry;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components( "PK::Auto", "Core" );
__PACKAGE__->table("entry");
__PACKAGE__->add_columns(
    "id",
    { data_type => "INTEGER", is_nullable => 0, size => undef, is_auto_increment => 1 },
    "journal",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "author",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "title",
    { data_type => "VARCHAR", is_nullable => 0, size => 150 },
    "content",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "posted",
    { data_type => "VARCHAR", is_nullable => 0, size => 100 },
    "location",
    { data_type => "VARCHAR", is_nullable => 0, size => 100 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to( "journal", "Journal", { pageid => "journal" } );
__PACKAGE__->belongs_to( "author",  "Person",  { id     => "author" } );

1;

