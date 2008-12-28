package MojoMojo::Schema::Result::Tag;

use strict;
use warnings;

use base qw/MojoMojo::Schema::Base::Result/;
use Carp qw/croak/;

__PACKAGE__->load_components( "PK::Auto", "Core" );
__PACKAGE__->table("tag");
__PACKAGE__->add_columns(
    "id",
    { data_type => "INTEGER", is_nullable => 0, size => undef, is_auto_increment => 1 },
    "person",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "page",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "photo",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "tag",
    { data_type => "VARCHAR", is_nullable => 0, size => 100 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to( "person", "Person", { id => "person" } );
__PACKAGE__->belongs_to( "page",   "Page",   { id => "page" } );
__PACKAGE__->belongs_to( "photo",  "Photo",  { id => "photo" } );

sub refcount {
    my $self = shift;
    return $self->get_column('refcount') if $self->has_column_loaded('refcount');
    croak 'Tried to call refcount on resultset without column';
}

1;
