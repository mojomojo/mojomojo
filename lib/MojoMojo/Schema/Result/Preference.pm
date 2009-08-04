package MojoMojo::Schema::Result::Preference;

use strict;
use warnings;

use parent qw/MojoMojo::Schema::Base::Result/;

__PACKAGE__->load_components( "UTF8Columns", "Core" );
__PACKAGE__->table("preference");
__PACKAGE__->add_columns(
    "prefkey",   { data_type => "VARCHAR", is_nullable => 0, size => 100 },
    "prefvalue", { data_type => "VARCHAR", is_nullable => 1, size => 100 },
);
__PACKAGE__->set_primary_key("prefkey");
__PACKAGE__->utf8_columns(qw/prefvalue/);


=head1 NAME

MojoMojo::Schema::Result::Preference

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
