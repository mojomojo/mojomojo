package MojoMojo::Schema::Result::PageVersion;

use strict;
use warnings;

use parent qw/MojoMojo::Schema::Base::Result/;

=head1 NAME

MojoMojo::Schema::Result::PageVersion - Versioned page metadata

=head1 DESCRIPTION

This table implements versioning of page metadata (not content, see
L<MojoMojo::Schema::Result::Content> for that). It has a composite
primary key C<(page, version)>.

When renaming a page, a new version is created in this table, with
C<version> set to 1 + the maximum version for that C<page>. The
C<status> of the new C<page_version> is set to "released", its 
C<release_date> is set to C<< DateTime->now >>, while the old
C<page_version>'s status is set to 'removed' and its C<remove_date>
is set to C<< DateTime->now >>.

=head2 TODO

=over 4

=item * document the relationships

=item * in order to support proper rollback, meaning creating a new
version for the rollback operation itself, a C<content_version>
field needs to be added.

=item * C<created> is apparently unused: set to 0 for pages populated when
creating the database, and NULL for all normal pages.

=back

=cut

__PACKAGE__->load_components( "Core" );
__PACKAGE__->table("page_version");
__PACKAGE__->add_columns(
    "page",                  { data_type => "INTEGER", is_nullable => 0, size => undef },
    "version",               { data_type => "INTEGER", is_nullable => 0, size => undef },
    "parent",                { data_type => "INTEGER", is_nullable => 1, size => undef },
    "parent_version",        { data_type => "INTEGER", is_nullable => 1, size => undef },
    "name",                  { data_type => "VARCHAR", is_nullable => 0, size => 200 },
    "name_orig",             { data_type => "VARCHAR", is_nullable => 0, size => 200 },
    "depth",                 { data_type => "INTEGER", is_nullable => 0, size => undef },
    "creator",               { data_type => "INTEGER", is_nullable => 0, size => undef },
    "created",               { data_type => "VARCHAR", is_nullable => 1, size => 100 },
    "status",                { data_type => "VARCHAR", is_nullable => 0, size => 20 },
    "release_date",          { data_type => "VARCHAR", is_nullable => 0, size => 100 },
    "remove_date",           { data_type => "VARCHAR", is_nullable => 1, size => 100 },
    "comments",              { data_type => "TEXT",    is_nullable => 1, size => 4000 },

    # FIXME: in a wiki in which I had never rolled back a page (that is, never made a second
    # revision current, I see in the page_version table that some pages have
    # content_version_first and content_version_last (1, 1) and others (NULL, NULL). --dandv
    "content_version_first", { data_type => "INTEGER", is_nullable => 1, size => undef },
    "content_version_last",  { data_type => "INTEGER", is_nullable => 1, size => undef },
);
__PACKAGE__->set_primary_key( "page", "version" );
__PACKAGE__->has_many(
    pages => "MojoMojo::Schema::Result::Page",
    { 
        "foreign.id" => "self.page", 
        "foreign.version" => "self.version" 
    },
);
__PACKAGE__->belongs_to( "creator", "MojoMojo::Schema::Result::Person", { id => "creator" } );
__PACKAGE__->belongs_to( "page",    "MojoMojo::Schema::Result::Page",   { id => "page" }, );
__PACKAGE__->belongs_to(
    content => "MojoMojo::Schema::Result::Content",
    { 
        page => "page",
        version => "content_version_first" 
    },
);
__PACKAGE__->belongs_to(
    content => "MojoMojo::Schema::Result::Content",
    { 
        page => "page", 
        version => "content_version_last"
    },
);
__PACKAGE__->belongs_to(
    page_version => "MojoMojo::Schema::Result::PageVersion",
    { 
        page => "parent", 
        version => "parent_version" 
    },
);
__PACKAGE__->has_many(
    "page_versions",
    "MojoMojo::Schema::Result::PageVersion",
    {
        "foreign.parent"         => "self.page",
        "foreign.parent_version" => "self.version",
    },
);

=head1 METHODS

=cut

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
