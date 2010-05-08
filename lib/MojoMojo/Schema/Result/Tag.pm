package MojoMojo::Schema::Result::Tag;

use strict;
use warnings;

use parent qw/MojoMojo::Schema::Base::Result/;
use Carp qw/croak/;

__PACKAGE__->load_components( "Core" );
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

=head1 NAME

MojoMojo::Schema::Result::Tag - store page tags

=head1 METHODS

=head2 refcount

Convenience method to return get_column('refcount') if this column
is available.

=cut

sub refcount {
    my $self = shift;
    return $self->get_column('refcount') if $self->has_column_loaded('refcount');
    croak 'Tried to call refcount on resultset without column';
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
