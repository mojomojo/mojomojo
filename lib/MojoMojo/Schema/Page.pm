package MojoMojo::Schema::Page;

use strict;
use warnings;
use Carp qw/croak/;

use base qw/Class::Accessor::Fast DBIx::Class/;

__PACKAGE__->load_components("ResultSetManager","PK::Auto", "Core");
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
__PACKAGE__->add_unique_constraint("page_unique_child_index", ["parent", "name"]);
__PACKAGE__->has_many(
  "wantedpages",
  "WantedPage",
  { "foreign.from_page" => "self.id" },
);
__PACKAGE__->belongs_to("parent", "Page", { id => "parent" });
__PACKAGE__->has_many("children", "Page", { "foreign.parent" => "self.id" });
__PACKAGE__->belongs_to(
  "content",
  "Content",
  { page => "id", version => "content_version" },
);
__PACKAGE__->has_many("versions", "Content", { "foreign.page" => "self.id" });
__PACKAGE__->belongs_to(
  "page_version",
  "PageVersion",
  { page => "id", version => "version" },
);
__PACKAGE__->has_many("tags", "Tag", { "foreign.page" => "self.id" });
__PACKAGE__->has_many(
  "links_from",
  "Link",
  { "foreign.from_page" => "self.id" },
);
__PACKAGE__->has_many("links_to", "Link", { "foreign.to_page" => "self.id" });
__PACKAGE__->has_many(
  "roleprivileges",
  "RolePrivilege",
  { "foreign.page" => "self.id" },
);
__PACKAGE__->has_many("attachments", "Attachment", { "foreign.page" => "self.id" });
__PACKAGE__->has_many("comments", "Comment", { "foreign.page" => "self.id" });
__PACKAGE__->has_many("journals", "Journal", { "foreign.pageid" => "self.id" });

=head2 path_pages

Accepts a path in url/unix directory format, e.g. "/page1/page2".
Paths are assumed to be absolute, so a leading slash (/) is not 
required.
Returns an array of any pages that exist in the path, starting with "/",
and an additional array of "proto page" hahses for any pages at the end
of the path that do not exist. All paths include the root (/), which 
must exist, so a path of at least one element will always be returned. 
The "proto page" hash keys are:

=cut

sub path_pages :ResultSet {
    my ( $self, $path, $id ) = @_;

    # avoid recursive path resolution, if possible:
    my @path_pages;
    if ($path eq '/') {
	@path_pages = $self->search({ lft => 1 })->all;
    }
    elsif ($id) {
        # this only works if depth is at least 1
	@path_pages = $self->path_pages_by_id( $id );
    }
    return (\@path_pages, []) if (@path_pages > 0);
    
    my @proto_pages = $self->parse_path($path);
    
    my $depth      = @proto_pages - 1;          # depth starts at 0
    
    
    my @depths;
    for my $proto ( @proto_pages )  {
	push @depths, -and => [ depth => $proto->{depth},
                                name  => $proto->{name},
                              ];
        
    }
    
    my @pages = $self->search({ -or => [ @depths ] },{} ); 
    
    my @query_pages;
    for (@pages) {
	$query_pages[ $_->depth ] ||= [];
	push @{ $query_pages[ $_->depth ] }, $_;
    }

    my $resolved = $self->
      resolve_path(path_pages    => \@path_pages,
                   proto_pages   => \@proto_pages,
                   query_pages   => \@query_pages,
                   current_depth => 0,
                   final_depth   => $depth,
                  );
    
    # If there are any proto pages, put the original
    # page names back into the paths, so they will
    # be preserved upon page creation:
    if (@proto_pages) {
	my $proto_path = $path_pages[ @path_pages - 1 ]->{path};
	for (@proto_pages) {
	    ($proto_path =~ /\/$/) || ($proto_path .= '/');
	    $proto_path .= $_->{name_orig};
	    $_->{path} = $proto_path;
	}
    }
    return ( \@path_pages, \@proto_pages );
} # end sub get_path

=item path_pages_by_id

@path_pages = __PACKAGE__->path_pages_by_id( $id );

Returns all the pages in the path to a page, given that page's id.

=cut

sub path_pages_by_id : ResultSet {
my ($self,$id)=@_;
return $self->search({
    'start_page.lft' => 1,
    'end_page.id' => $id,
    'me.lft'       =>  \'BETWEEN start_page.lft AND start_page.rgt',
    'end_page.lft' =>  'BETWEEN me.lft AND me.rgt',
},
{
    from=>"page AS start_page, page AS me, page AS end_page ",
    order_by => 'me.lft'
});
}

=head2 parse_path <path>

Create prototype page objects for each level in a given path.

=cut

sub parse_path : ResultSet {
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

=head2 normalize_name <orig_name>

Strip superfluos spaces, and convert the rest to _,
and lowercase the result.

=cut

sub normalize_name : ResultSet {
my ( $self, $name_orig ) = @_;

$name_orig =~ s/^\s+//;
$name_orig =~ s/\s+$//;
$name_orig =~ s/\s+/ /g;

my $name = $name_orig;
$name =~ s/\s+/_/g;
$name = lc($name);
return ( $name_orig, $name );
}

=head2 resolve_path <%args>

Takes the following args:

=over 4

=item path_pages

=item proto_pages

=item query_pages

=item current_depth

=item final_depth

=back

returns true if path can be resolved, or false otherwise.

=cut

sub resolve_path :ResultSet {
my ( $class, %args ) = @_;

my ( $path_pages, $proto_pages, $query_pages, $current_depth, $final_depth )
  = @args{qw/ path_pages proto_pages query_pages current_depth final_depth/
  };

while ( my $page = shift @{ $query_pages->[$current_depth] } ) {
    unless ( $current_depth == 0 ) {
	my $parent = $path_pages->[ $current_depth - 1 ];
	next unless $page->parent && $page->parent->id == $parent->id;
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

sub tagged_descendants_by_date {
    my ($self,$tag) = @_;
    my (@pages)=$self->result_source->resultset->search({
	    'ancestor.id'=>$self->id,
	    'tag' => $tag,
	    -or => [
		'me.id' => \'=ancestor.id', 
		-and => [
		    'me.lft', \'> ancestor.lft',
		    'me.rgt', \'< ancestor.rgt',
		],
	    ],
	    'me.id',  => \'=tag.page',
	    'content.page'    => \'=me.id',
	    'content.version' => \'=me.content_version',
	    },{
        group_by => [('me.id')],
	    from     => "page as me, page as ancestor, tag, content",
	    order_by => 'content.release_date DESC',
	    });
    return $self->result_source->resultset->set_paths(@pages);
}

sub tagged_descendants {
    my ($self,$tag) = @_;
    my(@pages)=$self->result_source->resultset->search({
	    'ancestor.id'=>$self->id,
	    'tag' => $tag,
	    -or => [
		'me.id' => \'=ancestor.id', 
		-and => [
		    'me.lft', \'> ancestor.lft',
		    'me.rgt', \'< ancestor.rgt',
		],
	    ],
	    
	    'me.id',  => \'=tag.page',
	    'content.page'    => \'=me.id',
	    'content.version' => \'=me.content_version',
	    },{
	    group_by => [('me.id')],
        from     => "page as me, page as ancestor, tag, content",
	    order_by => 'me.name',
	    })->all;
    return $self->result_source->resultset->set_paths(@pages);
}

# update_content: this whole method may need work to deal with workflow.
# maybe it can't even be called if the site uses workflow...
# may need fixing for better conflict handling, too. maybe use a transaction?

=item update_content <%args>

Create a new content version for this page.

args is each column of L<MojoMojo::M::Core::Content>.
=cut

sub update_content {
    my ( $self, %args ) = @_;

    my $content_version = ( $self->content ? 
	    $self->content->max_version() : 
	    undef );
    my %content_data = map { $_ => $args{$_} } 
	$self->result_source->related_source('content')->columns;
    my $now = DateTime->now;
    @content_data{qw/page version status release_date/} =
	($self->id,
	 ($content_version ? $content_version + 1 : 1),
	 'released',
	 $now,
	);
    my $content = $self->result_source->related_source('content')
	->resultset->create( \%content_data );
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
    } else {
	$self->result_source->resultset->set_paths($self);
    }

} # end sub update_content

=item set_paths

__PACKAGE__->set_paths( @pages );

Sets the path TEMP columns for multiple pages, either a subtree or a group of non-adjacent pages.

=cut


sub set_paths :ResultSet {
    my ($class, @pages) = @_;
    return @pages if (scalar @pages == 1) && 
	$pages[0]->depth == 0 ;
    return unless (scalar @pages);
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
#my $current_page = pop @path_pages;
#$_->path( $current_page->path );
	}
    }
    return @pages;

} # end sub set_paths
=item descendants_by_date

  @descendants = $page->descendants_by_date;

Like L<descendants>, but returns pages sorted by the dates of their
last content release dates.

=cut


sub descendants_by_date {
    my $self=shift;
    my @pages=$self->result_source->resultset->search({
	'ancestor.id' => $self->id,
	'content.page' => \'= me.id',
	'content.version' => \'= me.content_version',
	-or => [
	  -and => [
	    'me.lft' =>  \'> ancestor.lft' ,
	    'me.rgt' =>  \'< ancestor.rgt' ],
	    'ancestor.id' => \'= me.id',  ]
	}, {
	from     => 'page as me, page as ancestor, content',
	order_by => 'content.release_date DESC'
	});
        return $self->result_source->resultset->set_paths( @pages );
}

sub descendants {
    my ($self) = @_;
    my (@pages)=$self->result_source->resultset->search({
	'ancestor.id'=>$self->id,
	-or => [
	    'ancestor.id' => \'=me.id',
	    -and => [
		'me.lft' => \'> ancestor.lft',
		'me.rgt' => \'< ancestor.rgt',
	    ]
	],
    },{
	from     => 'page me, page ancestor',
	order_by => [ 'me.name' ] 
    });
    return $self->result_source->resultset->set_paths( @pages );
}


=item others_tags <user>

Return popular tags for this page used by other people than <user>.

=cut

sub user_tags {
    my ( $self, $user ) = @_;
    my (@tags) = $self->result_source->related_source('tags')->resultset
	->search({ 
	    page=>$self->id, 
	    person=> $user,
	},{
             select   => [ 'me.id','me.tag', 'count(me.tag) as refcount' ],
             as       => [ 'id','tag','refcount' ],
             order_by => [ 'refcount' ],
	     group_by => [ 'tag' ],
	});
    return @tags;
}

sub others_tags {
    my ( $self, $user ) = @_;
    my (@tags) = $self->result_source->related_source('tags')->resultset
	->search({ 
	    page=>$self->id, 
	    person=> {'!=', $user}
	},{
             select   => [ 'me.id','me.tag', 'count(me.tag) as refcount' ],
             as       => [ 'id','tag','refcount' ],
             order_by => [ 'refcount' ],
	     group_by => [ 'tag' ],
	});
    return @tags;
}
sub tags_with_counts {
    my ( $self, $user ) = @_;
    my (@tags) = $self->result_source->related_source('tags')->resultset
	->search({ 
	    page=>$self->id, 
	},{
             select   => [ 'me.id','me.tag', 'count(me.tag) as refcount' ],
             as       => [ 'id','tag','refcount' ],
             order_by => [ 'refcount' ],
	     group_by => [ 'tag' ],
	});
    return @tags;
}

=item create_path_pages

find or creates a list of path_pages

=cut

sub create_path_pages :ResultSet {
    my ( $self,      %args )        = @_;
    my ( $path_pages, $proto_pages, $creator ) = @args{qw/path_pages proto_pages creator/};

    # find the deepest existing page in the path, and save
    # some of its data for later use
    my $parent = $path_pages->[ @$path_pages - 1 ];
    my %original_ancestor = ( id => $parent->id, rgt => $parent->rgt );

    # open a gap in the nested set numbers to accommodate the new pages
    $parent = $self->open_gap( $parent, scalar @$proto_pages );

    my @version_columns = $self->related_resultset('page_version')->result_source->columns;

    # create all missing pages in the path
    for my $proto_page (@$proto_pages) {

        # since SQLite doesn't support sequences, just cheat
        # for now and get the next id by creating a page record
        my $page = $self->create( { parent => $parent->id } );
        my %version_data = map { $_ => $proto_page->{$_} } @version_columns;

        @version_data{qw/page version parent parent_version creator status release_date/} = (
            $page->id,
            1,
            $page->parent->id,
            # why this? we should always have a parent...
            ( $page->parent ? $page->parent->version : undef ),
            $creator,
            'released',
            DateTime->now,
        );

        my $page_version = 
	    $self->related_resultset('page_version')->create( \%version_data );
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

sub open_gap :ResultSet {
    my ($self, $parent, $new_page_count) = @_;
    my ($gap_increment, $parent_rgt, $parent_id)
        = ($new_page_count * 2, $parent->rgt, $parent->id);
    $self->result_source->schema->storage->dbh->do(qq{ UPDATE page 
    SET rgt = rgt + ?, lft = CASE
    WHEN lft > ? THEN lft + ?
    ELSE lft
    END
    WHERE rgt >= ? }, undef,
    $gap_increment, $parent_rgt, $gap_increment, $parent_rgt );

    # get the new nested set numbers for the parent
    $parent = $self->find( $parent_id );
    return $parent;
}


sub path {
    my ($self,$path) = @_;
    require Carp;
    if(defined $path) { 
	$self->{path}=$path;
    }
    unless( defined $self->{path} ) {
	return '/' if( $self->depth == 0 );
	#croak 'path is not set on the page object:'.$self->name;
    }
    return $self->{path};
}

=item has_photos

return the number of photos attached to this page. use for galleries.

=cut

sub has_photos {
  my $self=shift;
  return $self->result_source->schema->resultset('Photo')->search({'attachment.page'=>$self->id},{join=>[qw/attachment/]})->count;
}

1;
