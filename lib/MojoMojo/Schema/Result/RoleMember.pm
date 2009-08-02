package MojoMojo::Schema::Result::RoleMember;

use strict;
use warnings;

use parent qw/MojoMojo::Schema::Base::Result/;

__PACKAGE__->load_components( "Core" );
__PACKAGE__->table("role_member");
__PACKAGE__->add_columns(
    "role",   { data_type => "INTEGER", is_nullable => 0, size => undef },
    "person", { data_type => "INTEGER", is_nullable => 0, size => undef },
    "admin",  { data_type => "INTEGER", is_nullable => 0, size => undef, default => 0 },
);
__PACKAGE__->set_primary_key( "role", "person" );
__PACKAGE__->belongs_to( "role",   "MojoMojo::Schema::Result::Role",   { id => "role" } );
__PACKAGE__->belongs_to( "person", "MojoMojo::Schema::Result::Person", { id => "person" } );

=head1 NAME

MojoMojo::Schema::Result::RoleMember

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
