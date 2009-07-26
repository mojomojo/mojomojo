package MojoMojo::Schema::Result::PageVersion;

use strict;
use warnings;

use parent qw/MojoMojo::Schema::Base::Result/;

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

    # FIXME: consider for 2 simple pages that both have only 1 revision, and there has been no
    # making a second revision current. In the page_version table, some such pages have
    # content_version_first and content_version_last (1, 1) and others (NULL, NULL)
    "content_version_first", { data_type => "INTEGER", is_nullable => 1, size => undef },
    "content_version_last",  { data_type => "INTEGER", is_nullable => 1, size => undef },
);
__PACKAGE__->set_primary_key( "version", "page" );
__PACKAGE__->has_many( "pages", "MojoMojo::Schema::Result::Page",
    { "foreign.id" => "self.page", "foreign.version" => "self.version" },
);
__PACKAGE__->belongs_to( "creator", "MojoMojo::Schema::Result::Person", { id => "creator" } );
__PACKAGE__->belongs_to( "page",    "MojoMojo::Schema::Result::Page",   { id => "page" }, );
__PACKAGE__->belongs_to( "content", "MojoMojo::Schema::Result::Content",
    { page => "page", version => "content_version_first" },
);
__PACKAGE__->belongs_to( "content", "MojoMojo::Schema::Result::Content",
    { page => "page", version => "content_version_last" },
);
__PACKAGE__->belongs_to( "page_version", "MojoMojo::Schema::Result::PageVersion",
    { page => "parent", version => "parent_version" },
);
__PACKAGE__->has_many(
    "page_versions",
    "MojoMojo::Schema::Result::PageVersion",
    {
        "foreign.parent"         => "self.page",
        "foreign.parent_version" => "self.version",
    },
);

=head1 NAME

MojoMojo::Schema::Result::PageVersion

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
