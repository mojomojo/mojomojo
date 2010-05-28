package MojoMojo::Schema::Result::Page;

use strict;
use warnings;
use Carp qw/croak/;

use parent qw/MojoMojo::Schema::Base::Result/;

__PACKAGE__->load_components( "Core" );
__PACKAGE__->table("page");
__PACKAGE__->add_columns(
    "id",
    { data_type => "INTEGER", is_nullable => 0, size => undef, is_auto_increment => 1 },
    "version",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "parent",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "name",
    { data_type => "VARCHAR", is_nullable => 1, size => 200 },
    "name_orig",
    { data_type => "VARCHAR", is_nullable => 1, size => 200 },
    "depth",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "lft",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "rgt",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "content_version",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( "page_unique_child_index", [ "parent", "name" ] );
__PACKAGE__->has_many( "wantedpages", "MojoMojo::Schema::Result::WantedPage", { "foreign.from_page" => "self.id" } );
__PACKAGE__->belongs_to( "parent", "MojoMojo::Schema::Result::Page", { id => "parent" } );
__PACKAGE__->has_many( "children", "MojoMojo::Schema::Result::Page", { "foreign.parent" => "self.id" } );
__PACKAGE__->belongs_to( "content", "MojoMojo::Schema::Result::Content", { page => "id", version => "content_version" } );
__PACKAGE__->has_many( "versions", "MojoMojo::Schema::Result::Content", { "foreign.page" => "self.id" }, { order_by => 'version desc' } );
__PACKAGE__->belongs_to( "page_version", "MojoMojo::Schema::Result::PageVersion", { page => "id", version => "version" } );
__PACKAGE__->has_many( "tags",       "MojoMojo::Schema::Result::Tag",  { "foreign.page"      => "self.id" } );
__PACKAGE__->has_many( "links_from", "MojoMojo::Schema::Result::Link", { "foreign.from_page" => "self.id" } );
__PACKAGE__->has_many( "links_to",   "MojoMojo::Schema::Result::Link", { "foreign.to_page"   => "self.id" } );
__PACKAGE__->has_many( "roleprivileges", "MojoMojo::Schema::Result::RolePrivilege", { "foreign.page"   => "self.id" } );
__PACKAGE__->has_many( "attachments",    "MojoMojo::Schema::Result::Attachment",    { "foreign.page"   => "self.id" }, {order_by=>'name asc' } );
__PACKAGE__->has_many( "comments",       "MojoMojo::Schema::Result::Comment",       { "foreign.page"   => "self.id" } );
__PACKAGE__->has_many( "journals",       "MojoMojo::Schema::Result::Journal",       { "foreign.pageid" => "self.id" } );

=head1 NAME

MojoMojo::Schema::Result::Page - store pages

=head1 METHODS

=cut

=head2 update_content <%args>

Create a new content version for this page.

%args is each column of L<MojoMojo::Schema::Result::Content>.

=cut

# update_content: this whole method may need work to deal with workflow.
# maybe it can't even be called if the site uses workflow...
# may need fixing for better conflict handling, too. maybe use a transaction?

sub update_content {
    my ( $self, %args ) = @_;

    my $content_version = (
          $self->content
        ? $self->content->max_version()
        : undef
    );
    my %content_data =
        map { $_ => $args{$_} } $self->result_source->related_source('content')->columns;
    my $now = DateTime->now;
    @content_data{qw/page version status release_date/} =
        ( $self->id, ( $content_version ? $content_version + 1 : 1 ), 'released', $now, );
    my $content =
        $self->result_source->related_source('content')->resultset->create( \%content_data );
    $self->content_version( $content->version );
    $self->update;
    
    $self->page_version->content_version_first($content_version)
        unless defined $self->page_version->content_version_first;
    $self->page_version->content_version_last($content_version);
    $self->page_version->update;

    if ( my $previous_content = $content->previous ) {
        $previous_content->remove_date($now);
        $previous_content->status('removed');
        $previous_content->comments("Replaced by version $content_version.");
        $previous_content->update;
    }
    else {
        $self->result_source->resultset->set_paths($self);
    }
    foreach my $want_me ($self->result_source->schema->resultset('WantedPage')
                              ->search( { to_path => $self->path } ) ) {
        my $wantme_page = $want_me->from_page;

        # convert the wanted into links
        $self->result_source->schema->resultset('Link')->create({
            from_page => $wantme_page,
            to_page   => $self,
        });

        # clear the precompiled (will be recompiled on view)
        if ( my $wantme_content = $wantme_page->content ) {
            $wantme_content->precompiled(undef);
            $wantme_content->update;
        }

        # ok, she don't want me anymore ;)
        $want_me->delete();
    }

}    # end sub update_content

=head2 add_version

    my $page_version_new = $page->add_version(
        creator => $user_id,
        name_orig => $page_new_name,
    );

Arguments: %replacementdata

Returns: The new L<PageVersion|MojoMojo::Schema::Result::PageVersion>
object.
    
Creates a new page version by cloning the latest version (hence pointing
to the same content), and replacing its values with data in the replacement
hash.

Used for renaming pages.

=cut

sub add_version {
    my ( $self, %args ) = @_;
    my $now = DateTime->now;

    my $page_version_last = $self->page_version->latest_version();
    
    # clone the last version and update fields passed in %args
    my %page_version_data = map {
        exists $args{$_}
      ? ( $_ => $args{$_} )
      : ( $_ => $page_version_last->$_ )
    } $self->result_source->related_source('page_version')->columns;
    
    delete $args{creator};  # creator is a field in page_version, not in page

    # for the new version, set the version number, status, and release date
    @page_version_data{qw/
          version                           status     release_date/} =
        ( $page_version_last->version + 1, 'released', $now );

    my $page_version_new;
    # commit the new version to the database and update the previously last version to indicate its removal
    $self->result_source->schema->txn_do(sub {
    
        $page_version_new = 
            $self->result_source->related_source('page_version')->resultset->create( \%page_version_data );
        
        $page_version_last->update({
            remove_date => $now,
            status => 'removed',
            comments => 'Replaced by version ' . $page_version_data{version}
        });
        
        $self->update(\%args);
    });
    
    return $page_version_new;
}

=head2 tagged_descendants($tag)

Return descendants with the given tag, ordered by name.

=cut

sub tagged_descendants {
    my ( $self, $tag ) = @_;
    my (@pages) = $self->result_source->resultset->search(
        {
            'ancestor.id' => $self->id,
            'tag'         => $tag,
            -or           => [
                'me.id' => \'=ancestor.id',
                -and    => [ 'me.lft', \'> ancestor.lft', 'me.rgt', \'< ancestor.rgt', ],
            ],

            'me.id'           => \'=tag.page',
            'content.page'    => \'=me.id',
            'content.version' => \'=me.content_version',
        },
        {
            distinct => 1,
            from     => "page as me, page as ancestor, tag, content",
            order_by => 'me.name',
        }
    )->all;
    return $self->result_source->resultset->set_paths(@pages);
}

=head2 tagged_descendants_by_date

Return descendants with the given tag, ordered by creation time, most
recent first.

=cut

sub tagged_descendants_by_date {
    my ( $self, $tag ) = @_;
    my (@pages) = $self->result_source->resultset->search(
        {
            'ancestor.id' => $self->id,
            'tag'         => $tag,
            -or           => [
                'me.id' => \'=ancestor.id',
                -and    => [ 'me.lft', \'> ancestor.lft', 'me.rgt', \'< ancestor.rgt', ],
            ],
            'me.id'           => \'=tag.page',
            'content.page'    => \'=me.id',
            'content.version' => \'=me.content_version',
        },
        {
            distinct => 1,
            from     => "page as me, page as ancestor, tag, content",
            order_by => 'content.created DESC',
        }
    );
    return $self->result_source->resultset->set_paths(@pages);
}



=head2 descendants

  @descendants = $page->descendants( [$resultset_page] );

In list context, returns all descendants of this page (no paging), including 
the page itself. In scalar context, returns the resultset object.

If the optional $resultset_page is passed, returns that page from the
L<resultset|DBIx::Class::ResultSet>.

=cut

sub descendants {
    my ($self, $resultset_page)  = @_;
    
    my $rs = $self->result_source->resultset->search(
        {
            'ancestor.id' => $self->id,
            -or           => [
                'ancestor.id' => \'=me.id',
                -and          => [
                    'me.lft' => \'> ancestor.lft',
                    'me.rgt' => \'< ancestor.rgt',
                ]
            ],
        },
        {
            $resultset_page? (page => $resultset_page || 1, rows => 20) : (),
            from     => 'page me, page ancestor',
            order_by => ['me.name']
        }
    );  # an empty arrayref if there are no results because we'll dereference in the 'return'

    return wantarray?
        $self->result_source->resultset->set_paths($rs->all)
      : $rs
}


=head2 descendants_by_date

  @descendants = $page->descendants_by_date;

Like L</descendants>, but returns pages sorted by the dates of their
last content release dates and pages results (20 per page).

=cut

sub descendants_by_date {
    my $self  = shift;
    my @pages = $self->result_source->resultset->search(
        {
            'ancestor.id'     => $self->id,
            'content.page'    => \'= me.id',
            'content.version' => \'= me.content_version',
            -or               => [
                -and => [
                    'me.lft' => \'> ancestor.lft',
                    'me.rgt' => \'< ancestor.rgt'
                ],
                'ancestor.id' => \'= me.id',
            ]
        },
        {
            rows     => 20,
            page     => 1,
            from     => 'page as me, page as ancestor, content',
            order_by => 'content.created DESC'
        }
    );
    return $self->result_source->resultset->set_paths(@pages);
}


=head2 user_tags($user)

Return popular tags for this page used C<$user>.

=cut

sub user_tags {
    my ( $self, $user ) = @_;
    my (@tags) = $self->result_source->related_source('tags')->resultset->search(
        {
            page   => $self->id,
            person => $user,
        },
        {
            select   => [ 'me.id', 'me.tag', 'count(me.tag) as refcount' ],
            as       => [ 'id',    'tag',    'refcount' ],
            order_by => ['refcount'],
            group_by => [ 'me.id','me.tag'],
        }
    );
    return @tags;
}

=head2 others_tags($user)

Return popular tags for this page used by other people than C<$user>.

=cut

sub others_tags {
    my ( $self, $user ) = @_;
    my (@tags) = $self->result_source->related_source('tags')->resultset->search(
        {
            page   => $self->id,
            person => { '!=', $user }
        },
        {
            select   => [ 'me.id', 'me.tag', 'count(me.tag) as refcount' ],
            as       => [ 'id',    'tag',    'refcount' ],
            order_by => ['refcount'],
            group_by => ['me.tag','me.id'],
        }
    );
    return @tags;
}

=head2 tags_with_counts($user)

Return an array of {id, tag, refcount} for the C<$user>'s tags.

=cut

sub tags_with_counts {
    my ( $self, $user ) = @_;
    my (@tags) = $self->result_source->related_source('tags')->resultset->search(
        { page => $self->id, },
        {
            select   => [ 'me.id', 'me.tag', 'count(me.tag) as refcount' ],
            as       => [ 'id',    'tag',    'refcount' ],
            order_by => ['refcount'],
            group_by => [ 'me.id', 'me.tag'],
        }
    );
    return @tags;
}

=head2 path( [$path] )

TODO Accessor?

=cut

sub path {
    my ( $self, $path ) = @_;
    require Carp;
    if ( defined $path ) {
        $self->{path} = $path;
    }
    unless ( defined $self->{path} ) {
        return '/' if ( $self->depth == 0 );
        $self->result_source->resultset->set_paths($self);

        # croak 'path is not set on the page object: ' . $self->name;
    }
    return $self->{path};
}

=head2 has_photos

Return the number of photos attached to this page. Use for galleries.

=cut

sub has_photos {
    my $self = shift;
    return $self->result_source->schema->resultset('Photo')->search(
        { 'attachment.page' => $self->id },
        { join => [qw/attachment/] }
    )->count;
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
