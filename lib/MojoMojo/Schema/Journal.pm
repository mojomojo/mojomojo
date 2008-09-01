package MojoMojo::Schema::Journal;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components( "PK::Auto", "Core" );
__PACKAGE__->table("journal");
__PACKAGE__->add_columns(
    "pageid",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "name",
    { data_type => "VARCHAR", is_nullable => 0, size => 100 },
    "dateformat",
    { data_type => "VARCHAR", is_nullable => 0, size => 20, default => "%F" },
    "defaultlocation",
    { data_type => "VARCHAR", is_nullable => 0, size => 100 },
);
__PACKAGE__->set_primary_key("pageid");
__PACKAGE__->has_many( "entries", "Entry", { "foreign.journal" => "self.pageid" } );
__PACKAGE__->belongs_to( "pageid", "Page", { id => "pageid" } );

1;

