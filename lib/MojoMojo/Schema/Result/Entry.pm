package MojoMojo::Schema::Result::Entry;

use strict;
use warnings;

use parent qw/MojoMojo::Schema::Base::Result/;

__PACKAGE__->load_components( "Core" );
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
__PACKAGE__->belongs_to( "journal", "MojoMojo::Schema::Result::Journal", { pageid => "journal" } );
__PACKAGE__->belongs_to( "author",  "MojoMojo::Schema::Result::Person",  { id     => "author" } );

=head1 NAME

MojoMojo::Schema::Result::Entry

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
