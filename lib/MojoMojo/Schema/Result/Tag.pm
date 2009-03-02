package MojoMojo::Schema::Result::Tag;

use strict;
use warnings;

use base qw/MojoMojo::Schema::Base::Result/;
use Carp qw/croak/;

__PACKAGE__->load_components( "PK::Auto", "UTF8Columns", "Core" );
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
__PACKAGE__->belongs_to( "person", "MojoMojo::Schema::Result::Person", { id => "person" } );
__PACKAGE__->belongs_to( "page",   "MojoMojo::Schema::Result::Page",   { id => "page" } );
__PACKAGE__->belongs_to( "photo",  "MojoMojo::Schema::Result::Photo",  { id => "photo" } );
__PACKAGE__->utf8_columns(qw/tag/);


=head1 NAME

MojoMojo::Schema::Result::Tag

=head1 METHODS

=over 4

=item refcount

Convenience method to return get_column('refcount') if this column
is available.

=cut

sub refcount {
    my $self = shift;
    return $self->get_column('refcount') if $self->has_column_loaded('refcount');
    croak 'Tried to call refcount on resultset without column';
}

=back

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
