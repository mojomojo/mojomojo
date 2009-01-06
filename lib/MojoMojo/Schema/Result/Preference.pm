package MojoMojo::Schema::Result::Preference;

use strict;
use warnings;

use base qw/MojoMojo::Schema::Base::Result/;

__PACKAGE__->load_components( "PK::Auto", "Core" );
__PACKAGE__->table("preference");
__PACKAGE__->add_columns(
    "prefkey",   { data_type => "VARCHAR", is_nullable => 0, size => 100 },
    "prefvalue", { data_type => "VARCHAR", is_nullable => 1, size => 100 },
);
__PACKAGE__->set_primary_key("prefkey");

=head1 NAME

MojoMojo::Schema::Result::Preference

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
