package MojoMojo::Schema::Result::Journal;

use strict;
use warnings;

use base qw/MojoMojo::Schema::Base::Result/;

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
__PACKAGE__->has_many( "entries", "MojoMojo::Schema::Result::Entry", { "foreign.journal" => "self.pageid" } );
__PACKAGE__->belongs_to( "pageid", "MojoMojo::Schema::Result::Page", { id => "pageid" } );

=head1 NAME

MojoMojo::Schema::Result::Journal

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;

