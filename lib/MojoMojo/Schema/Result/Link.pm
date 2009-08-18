package MojoMojo::Schema::Result::Link;

use strict;
use warnings;

use parent 'MojoMojo::Schema::Base::Result';

=head1 NAME

MojoMojo::Schema::Result::Link - Links among pages

=head1 ATTRIBUTES

=head2 from_page

L<MojoMojo::Schema::Result::Page> object being the source of a link

=head2 to_page

L<MojoMojo::Schema::Result::Page> object being the target of a link

=cut

__PACKAGE__->load_components( "Core" );
__PACKAGE__->table("link");
__PACKAGE__->add_columns(
    "id",
    { data_type => "INTEGER", is_nullable => 0, size => undef, is_auto_increment => 1 },
    "from_page",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "to_page",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to( "from_page", "MojoMojo::Schema::Result::Page", { id => "from_page" } );
__PACKAGE__->belongs_to( "to_page",   "MojoMojo::Schema::Result::Page", { id => "to_page" } );

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
