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

# automatically set the path TEMP column on select: deprecated
# in favor of set_paths (NOT set_path)
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

=item path_pages_by_id

  @path_pages = __PACKAGE__->path_pages_by_id( $id );

Returns all the pages in the path to a page, given that page's id.

=cut

__PACKAGE__->set_sql('path_pages_by_id' => qq{
 SELECT path_page.*
 FROM __TABLE__ AS start_page, __TABLE__ AS path_page, __TABLE__ AS end_page
 WHERE start_page.lft = 1 AND end_page.id = ?
  AND path_page.lft BETWEEN start_page.lft AND start_page.rgt
  AND end_page.lft  BETWEEN path_page.lft AND path_page.rgt
 ORDER BY path_page.lft
});

sub path_pages_by_id {
    my @pages = __PACKAGE__->search_path_pages_by_id( $_[1] );
    my $path = '/';
    for (@pages)
    {
        next if ($_->name eq '/');
        if ($path eq '/')
        {
            $_->path( $path . $_->name );
            next;
        }
        $_->path( $path . '/' . $_->name );
    }
    return @pages;
}

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

=item rename

  $page->rename( 'new name', $creator );

Renames the page opon which it's called, and increments the version numbers
of the page and all its descendants.

=cut

sub rename {
    my ($self, $new_name_orig, $creator) = @_;
    my ($old_name, $old_path, $old_page_version) = $self->get(qw/name path page_version/);
    my ($new_name_orig, $new_name) = __PACKAGE__->normalize_name( $new_name_orig );
    my $new_path = $self->parent->path . '/' . $new_name;

    # will probably need to do somehting different here if/when we support workflow...
    my $new_version_number = $self->version + 1;

    my $new_page_version = $old_page_version->copy
        ({
	  page    => $self->id,
          version => $new_version_number,
	 });
    my $now = DateTime->now;
    my $content_version = $old_page_version->content_version_last;
    $new_page_version->set
	(
	 name         => $new_name,
	 name_orig    => $new_name_orig,
	 creator      => $creator,
         created      => $now,
         release_date => $now,
         comments     => "Changed name from $old_name to $new_name.",
         content_version_first => $content_version,
         content_version_last  => $content_version,
	);
    $new_page_version->update;

    $old_page_version->status('removed');
    $old_page_version->update;

    $self->set
        (
	 name      => $new_name,
         name_orig => $new_name_orig,
         version   => $new_version_number,
	);
    $self->update;

    # update version numbers of all descendants
    for my $descendant ($self->descendants_by_lft)
    {
	my $old_descendant_version = $descendant->page_version;
        my $new_version_number = $old_descendant_version->version + 1;
	my $new_descendant_version = $old_descendant_version->copy
            ({
	      page    => $descendant->id,
              version => $new_version_number,
	     });
	my $content_version = $old_descendant_version->content_version_last;
	$new_descendant_version->set
	    (
	     creator      => $creator,
	     created      => $now,
	     release_date => $now,
	     comments     => "Ancestor page path changed from $old_path to $new_path.",
             parent_version        => $descendant->parent->version,
	     content_version_first => $content_version,
	     content_version_last  => $content_version,
	    );
	$new_descendant_version->update;

	$old_descendant_version->status('removed');
	$old_descendant_version->update;

	$descendant->version( $new_version_number );
        $descendant->update;
    }
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
    my @pages = $_[0]->search_children( $_[0]->id );
    return __PACKAGE__->set_paths( @pages );
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
     my @pages = $_[0]->search_descendants( $_[0]->id );
     return __PACKAGE__->set_paths( @pages );
}

=item descendants_by_lft

  @descendants = $page->descendants_by_lft;

Like L<descendants>, but returns pages sorted by the nested set C<lft>
column, which means a depth-first, left-to-right order. This is often
necessary for operations that must be performed on parents before being
performed on their children.

=cut

__PACKAGE__->set_sql('descendants_by_lft' => qq{
 SELECT descendant.id,descendant.name,descendant.name_orig,
        descendant.parent,descendant.depth
 FROM __TABLE__ as ancestor, __TABLE__ as descendant
 WHERE ancestor.id = ?
  AND descendant.lft > ancestor.lft
  AND descendant.rgt < ancestor.rgt
 ORDER BY descendant.lft
});

sub descendants_by_lft {
     my @pages = $_[0]->search_descendants_by_lft( $_[0]->id );
     return __PACKAGE__->set_paths( @pages );
}

=item descendants_by_date

  @descendants = $page->descendants_by_date;

Like L<descendants>, but returns pages sorted by the dates of their
last content release dates.

=cut

__PACKAGE__->set_sql('descendants_by_date' => qq{
 SELECT __ESSENTIAL__ FROM
 (
  SELECT descendant.id as id, descendant.name as name, descendant.name_orig as name_orig,
         descendant.parent as parent ,descendant.depth as depth, content.created
  FROM __TABLE__ as ancestor, __TABLE__ as descendant, content
  WHERE ancestor.id = ?
   AND descendant.lft > ancestor.lft
   AND descendant.rgt < ancestor.rgt
   AND content.page = descendant.id
   AND content.version = descendant.content_version
  ORDER BY content.release_date DESC
 )
});

sub descendants_by_date {
    my @pages = $_[0]->search_descendants_by_date( $_[0]->id );
    return __PACKAGE__->set_paths( @pages );
}

=item tagged_descendants

  @descendants = $page->tagged_descendants('mytag');

Returns the subtree of pages rooted by the page with a given tag.

=cut

__PACKAGE__->set_sql('tagged_descendants' => qq{
 SELECT descendant.id, descendant.name, descendant.name_orig,
        descendant.parent, descendant.depth
 FROM __TABLE__ as ancestor, __TABLE__ as descendant, tag
 WHERE ancestor.id = ?
  AND descendant.lft > ancestor.lft
  AND descendant.rgt < ancestor.rgt
  AND descendant.id = tag.page
  AND tag=?
 ORDER BY descendant.name
});

sub tagged_descendants {
    my @pages = $_[0]->search_tagged_descendants( $_[0]->id, $_[1] );
    return __PACKAGE__->set_paths( @pages );
}

__PACKAGE__->set_sql('tagged_descendants_by_date' => qq{
 SELECT __ESSENTIAL__ FROM
 (
  SELECT descendant.id as id, descendant.name as name, descendant.name_orig as name_orig,
         descendant.parent as parent, descendant.depth as depth
  FROM __TABLE__ as ancestor, __TABLE__ as descendant, tag, content
  WHERE ancestor.id = ?
   AND descendant.lft > ancestor.lft
   AND descendant.rgt < ancestor.rgt
   AND descendant.id = tag.page
   AND tag=?
   AND content.page = descendant.id
   AND content.version = descendant.content_version
  ORDER BY content.release_date DESC
 )
});

sub tagged_descendants_by_date {
    my @pages = $_[0]->search_tagged_descendants_by_date( $_[0]->id, $_[1] );
    return __PACKAGE__->set_paths( @pages );
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

=item set_paths

  __PACKAGE__->set_paths( @pages );

Sets the path TEMP columns for multiple pages, either a subtree or a group of non-adjacent pages.

=cut

sub set_paths {
    my ($class, @pages) = @_;
    return () unless (scalar @pages >= 1);
    my %pages = map { $_->id => $_ } @pages;

    # Preserve the original sort order, because the pages
    # passed in may have been sorted differently than we
    # need them sorted to set paths:
    my @lft_sorted_pages = sort { $a->lft <=> $b->lft } @pages;

    # In some cases, e.g. retrieving descendants, we
    # may not have passed in the root of the subtree:
    unless ($lft_sorted_pages[0]->name eq '/') {
        my $parent = $lft_sorted_pages[0]->parent;
        $pages{ $parent->id } = $parent;
    }

    # Sorting by the rgt column ensures that we always set
    # paths for parents before their children, allowing us
    # to avoid recursion.
    for (@lft_sorted_pages) {
	if ($_->name eq '/') {
	    $_->path('/');
             next;
	}
	if ($_->depth == 1) {
	    $_->path( '/' . $_->name );
	    next;
	}
	my $parent = $pages{ $_->parent->id };
	if (ref $parent) {
	    $_->path( $parent->path . '/' . $_->name );
	}
         # unless all pages were adjacent, i.e. a whole subtree,
         # we still may not have the parent:
         else {
	    my @path_pages = $class->path_pages_by_id( $_->id );
             # store these in case they're parents of other pages
	    for my $path_page (@path_pages) {
                 $pages{ $path_page->id } = $path_page;
	    }
             # don't know if this is necessary, but just in case
             my $current_page = pop @path_pages;
             $_->path( $current_page->path );
	}
    }
    return @pages;

} # end sub set_paths

=item get_page

returns the actual page object for a path

=cut

sub get_page {
    my ( $self, $pagepath ) = @_;

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
    my ( $class, $path, $id ) = @_;

    # avoid recursive path resolution, if possible:
    my @path_pages;
    if ($path eq '/')
    {
        @path_pages = $class->search( lft => 1 );
        $path_pages[0]->path( '/' );
    }
    elsif ($id)
    {
        # this only works if depth is at least 1
        @path_pages = $class->path_pages_by_id( $id );
    }
    return (\@path_pages, []) if (@path_pages > 0);

    my @proto_pages = $class->parse_path($path);

    my $depth      = @proto_pages - 1;          # depth starts at 0
    my $query_name = "get_path_depth_$depth";

    unless ( $class->can($query_name) ) {
        my $where = join ' OR ',
          ('( depth = ? AND name = ? )') x ( $depth + 1 );
        $class->add_constructor( $query_name => $where );
    }

    # store query results by depth:
    my @bind = map { $_->{depth}, $_->{name} } @proto_pages;
    my @query_pages;
    for ( $class->$query_name(@bind) ) {
        $query_pages[ $_->depth ] ||= [];
        push @{ $query_pages[ $_->depth ] }, $_;
    }

    my $resolved = $class->resolve_path(
        path_pages    => \@path_pages,
        proto_pages   => \@proto_pages,
        query_pages   => \@query_pages,
        current_depth => 0,
        final_depth   => $depth,
    );
    return ( \@path_pages, \@proto_pages );

} # end sub get_path

sub resolve_path {
    my ( $class, %args ) = @_;

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
            ( ++$args{current_depth} && $class->resolve_path(%args) )
          );
    }
    return 0;

} # end sub resolve_path

sub parse_path {
    my ( $class, $path ) = @_;

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
          $class->normalize_name( $_->{name_orig} );
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
    my ( $class, $name_orig ) = @_;

    $name_orig =~ s/^\s+//;
    $name_orig =~ s/\s+$//;
    $name_orig =~ s/\s+/ /g;

    my $name = $name_orig;
    $name =~ s/\s+/_/g;
    $name = lc($name);
    return ( $name_orig, $name );

} # end sub normalize_name


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

    my $content_version = ($self->content ? $self->content->max_version() : 0) ;
    my %content_data =
      map { $_ => $args{$_} } MojoMojo::M::Core::Content->columns;
    my $now = DateTime->now;
    @content_data{qw/page version status release_date/} =
      ($self->id,
         $content_version+1,
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
