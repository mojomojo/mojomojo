package MojoMojo::M::Core::Page;

=head1 NAME

MojoMojo::M::Core::Page - Page model

=head1 SYNOPSIS

=head1 DESCRIPTION

This class models only "live" MojoMojo pages.

=cut

use strict;
use Algorithm::Diff;
use DateTime;

__PACKAGE__->columns( Essential => qw/name name_orig parent depth/ );
__PACKAGE__->columns( TEMP      => qw/path/ );

# automatically set the path TEMP column on select:
__PACKAGE__->add_trigger( select => \&set_path);

__PACKAGE__->has_many(
    links_to => [ 'MojoMojo::M::Core::Link' => 'from_page' ],
    "to_page"
);
__PACKAGE__->has_many(
    links_from => [ 'MojoMojo::M::Core::Link' => 'to_page' ],
    "from_page"
);

=head1 METHODS

=over 4

=item search_by_tag

=cut

__PACKAGE__->set_sql(
    'by_tag' => qq{
SELECT DISTINCT name, page.id as id, content.created, content.creator
FROM page, tag, content WHERE page.id=content.page AND page.content_version=content.version AND page.id=tag.page AND tag=? ORDER BY name
}
);
__PACKAGE__->set_sql(
    'by_tag_and_date' => qq{
SELECT DISTINCT name, page.id as id, content.created, content.creator
FROM page, tag, content WHERE page.id=content.page AND page.content_version=content.version AND page.id=tag.page AND tag=? ORDER BY content.created
}
);

__PACKAGE__->set_sql(
    'recent' => qq{
SELECT DISTINCT page.name, page.id as id,page_version.release_date,
creator
FROM page,page_version WHERE page_version.page=page.id
ORDER BY page_version.release_date DESC
}
);

__PACKAGE__->set_sql(
    'path_pages_by_id' => qq{
SELECT path_page.*
FROM __TABLE__ AS start_page, __TABLE__ AS path_page, __TABLE__ AS end_page
WHERE start_page.lft = 1 AND end_page.id = ?
 AND path_page.lft BETWEEN start_page.lft AND start_page.rgt
 AND end_page.lft  BETWEEN path_page.lft AND path_page.rgt
ORDER BY path_page.lft
}
);

=item open_gap

Opens a gap in the nested set numbers to allow the inserting
of new pages into the tree. Since nested sets number each node
twice, the size of the gap is always twice the number of new
pages. Also, since nested sets number the nodes from left to
right, we determine what nodes to re-number according to the
C<rgt> column of the parent of the top-most new node.

Returns a new parent object that is updated with the new C<lft>
C<rgt> nested set numbers.

=cut

__PACKAGE__->set_sql('open_gap' => qq{
UPDATE __TABLE__
SET
rgt = rgt + ?,
lft = CASE
 WHEN lft > ? THEN lft + ?
 ELSE lft
END
WHERE rgt >= ?
});

sub open_gap {
    my ($class, $parent, $new_page_count) = @_;
    my ($gap_increment, $parent_rgt, $parent_id)
        = ($new_page_count * 2, $parent->rgt, $parent->id);
    my $sth = $class->sql_open_gap;
    $sth->execute( $gap_increment, $parent_rgt, $gap_increment, $parent_rgt );

    # allow more than one copy of this object in memory.
    # do we really want to do this? if so, when and why???
    $parent->remove_from_object_index;

    # get the new nested set numbers for the parent
    $parent = $class->retrieve( $parent_id );
    return $parent;
}

=item children

  @children = $page->children;

Returns a list of the page's immediate children, i.e. it does not return
the entire subtree rooted by the page. In order to get the entire subtree,
use L<descendants>.

=cut

__PACKAGE__->set_sql('children' => qq{
 SELECT __ESSENTIAL__
 FROM __TABLE__
 WHERE parent = ?
 ORDER BY name
});

sub children {
    return $_[0]->search_children( $_[0]->id );
}

=item descendants

  @descendants = $page->descendants;

Returns the entire subtree of pages rooted by the page. In order to get
only the immediate children, and not the entire subtree, use L<children>.

=cut

__PACKAGE__->set_sql('descendants' => qq{
 SELECT descendant.id,descendant.name,descendant.name_orig,
        descendant.parent,descendant.depth
 FROM __TABLE__ as ancestor, __TABLE__ as descendant
 WHERE ancestor.id = ?
  AND descendant.lft > ancestor.lft
  AND descendant.rgt < ancestor.rgt
 ORDER BY descendant.name
});

sub descendants {
    return $_[0]->search_descendants( $_[0]->id );
}

__PACKAGE__->set_sql('descendants_by_date' => qq{
 SELECT descendant.id,descendant.name,descendant.name_orig,
        descendant.parent,descendant.depth
 FROM __TABLE__ as ancestor, __TABLE__ as descendant,
 page_version
 WHERE ancestor.id = ?
  AND descendant.lft > ancestor.lft
  AND descendant.rgt < ancestor.rgt
  AND page_version.page=descendant.id
 ORDER BY page_version.release_date DESC
});

sub descendants_by_date {
    return $_[0]->search_descendants_by_date( $_[0]->id );
}
=item tagged_descendants

  @descendants = $page->tagged_descendants('mytag');

Returns the subtree of pages rooted by the page with a given tag.

=cut

__PACKAGE__->set_sql('tagged_descendants' => qq{
 SELECT descendant.id,descendant.name,descendant.name_orig,
        descendant.parent,descendant.depth
 FROM __TABLE__ as ancestor, __TABLE__ as descendant,tag
 WHERE ancestor.id = ?
  AND descendant.lft > ancestor.lft
  AND descendant.rgt < ancestor.rgt
  AND descendant.id = tag.page
  AND tag=?
 ORDER BY descendant.name
});

sub tagged_descendants {
    return $_[0]->search_tagged_descendants( $_[0]->id, $_[1] );
}

__PACKAGE__->set_sql('tagged_descendants_by_date' => qq{
 SELECT descendant.id,descendant.name,descendant.name_orig,
        descendant.parent,descendant.depth
 FROM __TABLE__ as ancestor, __TABLE__ as descendant,
 tag, page_version
 WHERE ancestor.id = ?
  AND descendant.lft > ancestor.lft
  AND descendant.rgt < ancestor.rgt
  AND page_version.page=descendant.id
  AND descendant.id = tag.page
  AND tag=?
 ORDER BY page_version.release_date DESC
});

sub tagged_descendants_by_date {
    return $_[0]->search_descendants_by_date( $_[0]->id );
}

sub set_path {
     my $self = shift;
     return if (defined $self->path);
     return unless ($self->name);
     if ($self->name eq '/') {
         $self->path( '/' );
         return;
     }
     unless ($self->depth && $self->depth > 1) {
         $self->path( '/' . $self->name );
         return;
     }
     my $path = $self->name;
     my $page = $self;
     while ( my $parent = $page->parent ) {
         last if $parent->name eq '/';
         $path = $parent->name . '/' . $path;
         $page = $parent;
     }
     $self->path( '/' . $path );
}

=item get_page

returns the actual page object for a path

=cut

sub get_page {
    my ( $self, $pagepath ) = @_;

    #return $self->search_where(name=>$page)->next();
    my ( $path_pages, $proto_pages ) = $self->path_pages($pagepath);
    return pop @$path_pages;
}

=item path_pages

Accepts a path in url/unix directory format, e.g. "/page1/page2".
Paths are assumed to be absolute, so a leading slash (/) is not 
required.
Returns an array of any pages that exist in the path, starting with "/",
and an additional array of "proto page" hahses for any pages at the end
of the path that do not exist. All paths include the root (/), which 
must exist, so a path of at least one element will always be returned. 
The "proto page" hash keys are:

=over

=item 4

=item name_orig

The page name submitted by the user, with minor cleaning, e.g. leading
and trailing
spaces trimmed.

=item name

The normalized page name, all lower case, with spaces replaced by 
underscores (_).

=item path

The partial, absolute path to the current page.

=item depth

The depth in the page hierarchy, or generation, of the current page.

=back

Notice that these fields all exist in the page objects, also. All are page table columns,
with the exception of path, which is a Class::DBI TEMP column.

=cut

sub path_pages {
    my ( $self, $path, $id ) = @_;

    # avoid recursive path resolution, if possible:
    my @path_pages;
    if ($path eq '/')
    {
	@path_pages = $self->search( lft => 1 );
    }
    elsif ($id)
    {
        # this only works if depth is at least 1
        @path_pages = $self->search_path_pages_by_id( $id );
    }
    return (\@path_pages, []) if (@path_pages > 0);

    my @proto_pages = $self->parse_path($path);

    my $depth      = @proto_pages - 1;          # depth starts at 0
    my $query_name = "get_path_depth_$depth";

    unless ( __PACKAGE__->can($query_name) ) {
        my $where = join ' OR ',
          ('( depth = ? AND name = ? )') x ( $depth + 1 );
        __PACKAGE__->add_constructor( $query_name => $where );
    }

    # store query results by depth:
    my @bind = map { $_->{depth}, $_->{name} } @proto_pages;
    my @query_pages;
    for ( __PACKAGE__->$query_name(@bind) ) {
        $query_pages[ $_->depth ] ||= [];
        push @{ $query_pages[ $_->depth ] }, $_;
    }

    my $resolved = $self->resolve_path(
        path_pages    => \@path_pages,
        proto_pages   => \@proto_pages,
        query_pages   => \@query_pages,
        current_depth => 0,
        final_depth   => $depth,
    );
    return ( \@path_pages, \@proto_pages );

} # end sub get_path

sub resolve_path {
    my ( $self, %args ) = @_;

    my ( $path_pages, $proto_pages, $query_pages, $current_depth, $final_depth )
      = @args{qw/ path_pages proto_pages query_pages current_depth final_depth/
      };

    while ( my $page = shift @{ $query_pages->[$current_depth] } ) {
        unless ( $current_depth == 0 ) {
            my $parent = $path_pages->[ $current_depth - 1 ];
            next unless $page->parent == $parent->id;
        }
        my $proto_page = shift @{$proto_pages};
        $page->path( $proto_page->{path} );
        push @{$path_pages}, $page;
        return 1
          if (
            $current_depth == $final_depth
            ||

            # must pre-icrement for this to work when current_depth == 0
            ( ++$args{current_depth} && $self->resolve_path(%args) )
          );
    }
    return 0;

} # end sub resolve_path

sub parse_path {
    my ( $self, $path ) = @_;

    # Remove leading and trailing slashes to make
    # split happy. We'll add the root (/) back later...
    $path =~ s/^[\/]+//;
    $path =~ s/[\/]+$//;

    my @proto_pages = map { { name_orig => $_ } } ( split /\/+/, $path );
    if ( @proto_pages == 0 && $path =~ /\S/ ) {
        @proto_pages = ($path);
    }

    my $depth     = 1;
    my $page_path = '';
    for (@proto_pages) {
        ( $_->{name_orig}, $_->{name} ) =
          $self->normalize_name( $_->{name_orig} );
        $page_path .= '/' . $_->{name};
        $_->{path}  = $page_path;
        $_->{depth} = $depth;
        $depth++;
    }

    # assume that all paths are absolute:
    unshift @proto_pages,
      { name => '/', name_orig => '/', path => '/', depth => 0 };

    return @proto_pages;

} # end sub parse_path

sub normalize_name {
    my ( $self, $name_orig ) = @_;

    $name_orig =~ s/^\s+//;
    $name_orig =~ s/\s+$//;
    $name_orig =~ s/\s+/ /g;

    my $name = $name_orig;
    $name =~ s/\s+/_/g;
    $name = lc($name);
    return ( $name_orig, $name );

} # end sub normalize_name

# create a proto page, would could be
# the basis for a new page
# sub create_proto
# {
#     my ($class, $page) = @_;
#     my %proto_rev;
#     my @columns = __PACKAGE__->columns;
#     eval { $page->isa('MojoMojo::M::Core::Page') };
#     if ($@)
#     {
#         # assume page is a simple "proto page" hashref
#         %proto_rev = map { $_ => $page->{$_} } @columns;
#         $proto_rev{version} = 1;
#         $proto_rev{path} = $page->{path};
#     }
#     else
#     {
#         my $revision = $page->revision;
#         %proto_rev = map { $_ => $revision->$_ } @columns;
#         @proto_rev{qw/ creator created /} = (undef) x 2;
#         $proto_rev{version}++;
#         $proto_rev{path} = $page->path;
#     }
#     return \%proto_rev;
# }

sub content {
    my ($self) = @_;
    return MojoMojo::M::Core::Content->retrieve(
        page    => $self->id,
        version => $self->content_version,
    );
}

sub page_version {
    my ($self) = @_;
    return MojoMojo::M::Core::PageVersion->retrieve(
        page    => $self->id,
        version => $self->version,
    );
}

sub orphans {
    grep { $_->links_to->count == 0 }
      __PACKAGE__->retrieve_all_sorted_by("name");
}

sub wikiwords {
    my $self    = shift;
    my $content = $self->content;
    my @links;
    while ( $content =~ m/(?<![\?\\\/])(\b[A-Z][a-z]+[A-Z]\w*)/g ) {
        push @links, $1;
    }
    while ( $content =~ m{\[\[\s*([^\]]+)\s*\]\]}g ) {
        push @links, MojoMojo->fixw($1);
    }
    return @links;
}

sub others_tags {
    my ( $self, $user ) = @_;
    my (@tags) = MojoMojo::M::Core::Tag->search_others_tags( $self->id, $user );
    return @tags;
}

sub user_tags {
    my ( $self, $user ) = @_;
    my (@tags) =
      MojoMojo::M::Core::Tag->search( person => $user, page => $self );
    return @tags;
}

# update_content: this whole method may need work to deal with workflow.
# maybe it can't even be called if the site uses workflow...
# may need fixing for better conflict handling, too. maybe use a transaction?

sub update_content {
    my ( $self, %args ) = @_;
    my $content_version;

    # FIX: don't think this needs to be so complicated.
    # should be able to just catch exceptions upon insert
    if ( $args{version} ) {
        $content_version = $args{version};
        my $existing_version = MojoMojo::M::Core::Content->retrieve(
            page    => $self->id,
            version => $content_version + 1
        );
        die "Content update conflict" if $existing_version;
    }
    elsif ( $self->content_version eq undef ) {
        $content_version = 1;
    }
    else {
        # Something went wrong.
        die "Error in calculating content version";
    }
    my %content_data =
      map { $_ => $args{$_} } MojoMojo::M::Core::Content->columns;
    my $now = DateTime->now;
    @content_data{qw/page version status release_date/} =
	($self->id,
         $content_version,
         'released',
         $now,
	);
    my $content = MojoMojo::M::Core::Content->create( \%content_data );
    $self->content_version( $content->version );
    $self->update;
    $self->page_version->content_version_first( $content_version )
	unless defined $self->page_version->content_version_first;
    $self->page_version->content_version_last($content_version);
    $self->page_version->update;

    if (my $previous_content = $content->previous) {
        $previous_content->remove_date( $now );
	$previous_content->status( 'removed' );
	$previous_content->comments( "Replaced by version $content_version." );
        $previous_content->update;
    }

} # end sub update_content

sub create_path_pages {
    my ( $class,      %args )        = @_;
    my ( $path_pages, $proto_pages, $creator ) = @args{qw/path_pages proto_pages creator/};

    # find the deepest existing page in the path, and save
    # some of its data for later use
    my $parent = $path_pages->[ @$path_pages - 1 ];
    my %original_ancestor = ( id => $parent->id, rgt => $parent->rgt );

    # open a gap in the nested set numbers to accommodate the new pages
    $parent = $class->open_gap( $parent, scalar @$proto_pages );

    my @version_columns = MojoMojo::M::Core::PageVersion->columns;

    # create all missing pages in the path
    for my $proto_page (@$proto_pages) {

        # since SQLite doesn't support sequences, just cheat
        # for now and get the next id by creating a page record
        my $page = __PACKAGE__->create( { parent => $parent } );
        my %version_data = map { $_ => $proto_page->{$_} } @version_columns;

        @version_data{qw/page version parent parent_version creator status release_date/} = (
            $page,
            1,
            $page->parent,
            # why this? we should always have a parent...
            ( $page->parent ? $page->parent->version : undef ),
            $creator,
            'released',
            DateTime->now,
        );

        my $page_version =
          MojoMojo::M::Core::PageVersion->create( \%version_data );
        for ( $page->columns ) {
            next if $_ eq 'id'; # page already exists
            next if $_ eq 'content_version'; # no content yet
            next unless $page_version->can( $_ );
            $page->$_( $page_version->$_ );
        }
        # set the nested set columns:
        ## we always create the first page as a right child,
        ## so if this is the first new page, its left number
        ## will be the same as the parent's old right number
        $page->lft(
            $parent->id == $original_ancestor{id}
            ? $original_ancestor{rgt}
            : $parent->lft + 1
        );
        $page->rgt( $parent->rgt - 1 );
        $page->update;
        push @$path_pages, $page;
        $parent = $page;
    }
    return $path_pages;

} # end sub create_path_pages

1;
