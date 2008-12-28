package MojoMojo::Schema::Result::WantedPage;

use strict;
use warnings;

use base qw/MojoMojo::Schema::Base::Result/;

__PACKAGE__->load_components( "PK::Auto", "Core" );
__PACKAGE__->table("wanted_page");
__PACKAGE__->add_columns(
    "id",
    { data_type => "INTEGER", is_nullable => 0, size => undef, is_auto_increment => 1 },
    "from_page",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "to_path",
    { data_type => "TEXT", is_nullable => 0, size => 4000 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to( "from_page", "Page", { id => "from_page" } );

1;
