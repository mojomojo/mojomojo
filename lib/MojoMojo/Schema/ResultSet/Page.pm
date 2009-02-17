package MojoMojo::Schema::ResultSet::Page;

use strict;
use warnings;
use base qw/MojoMojo::Schema::Base::ResultSet/;
use Encode ();
use URI::Escape ();

=head1 NAME

MojoMojo::Schema::ResultSet::Page

=head1 METHODS

=over 4

=cut

=item path_pages

Accepts a path in url/unix directory format, e.g. "/page1/page2".
Paths are assumed to be absolute, so a leading slash (/) is not 
required.
Returns an array of any pages that exist in the path, starting with "/",
and an additional array of "proto page" hashes for any pages at the end
of the path that do not exist. All paths include the root (/), which 
must exist, so a path of at least one element will always be returned. 
The "proto page" hash keys are:

=cut

sub path_pages {
    my ( $self, $path, $id ) = @_;

    # avoid recursive path resolution, if possible:
    my @path_pages;
    if ( $path eq '/' ) {
        @path_pages = $self->search( { lft => 1 } )->all;
    }
    elsif ($id) {

        # this only works if depth is at least 1
        @path_pages = $self->path_pages_by_id($id);
    }
    return ( \@path_pages, [] ) if ( @path_pages > 0 );

    my @proto_pages = $self->parse_path($path);

    my $depth = @proto_pages - 1;    # depth starts at 0

    my @depths;
    for my $proto (@proto_pages) {
        push @depths, -and => [
            depth => $proto->{depth},
            name  => $proto->{name},
        ];

    }

    my @pages = $self->search( { -or => [@depths] }, {} );

    my @query_pages;
    for (@pages) {
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

    # If there are any proto pages, put the original
    # page names back into the paths, so they will
    # be preserved upon page creation:
    if (@proto_pages) {
        my $proto_path = $path_pages[ @path_pages - 1 ]->{path};
        for (@proto_pages) {
            ( $proto_path =~ /\/$/ ) || ( $proto_path .= '/' );
            $proto_path .= $_->{name_orig};
            $_->{path} = $proto_path;
        }
    }
    return ( \@path_pages, \@proto_pages );
}    # end sub get_path

=item path_pages_by_id

@path_pages = __PACKAGE__->path_pages_by_id( $id );

Returns all the pages in the path to a page, given that page's id.

=cut

sub path_pages_by_id {
    my ( $self, $id ) = @_;
    return $self->search(
        {
            'start_page.lft' => 1,
            'end_page.id'    => $id,
            'me.lft'         => \'BETWEEN start_page.lft AND start_page.rgt',
            'end_page.lft'   => \'BETWEEN me.lft AND me.rgt',
        },
        {
            from     => "page AS start_page, page AS me, page AS end_page ",
            order_by => 'me.lft'
        }
    );
}

=item parse_path <path>

Create prototype page objects for each level in a given path.

=cut

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
        ( $_->{name_orig}, $_->{name} ) = $self->normalize_name( $_->{name_orig} );
        $page_path .= '/' . $_->{name};
        $_->{path}  = $page_path;
        $_->{depth} = $depth;
        $depth++;
    }

    # assume that all paths are absolute:
    unshift @proto_pages, { name => '/', name_orig => '/', path => '/', depth => 0 };

    return @proto_pages;

}    # end sub parse_path

=item normalize_name <orig_name>

Strip superfluos spaces, and convert the rest to _,
and lowercase the result.

=cut

sub normalize_name {
    my ( $self, $name_orig ) = @_;

    $name_orig =~ s/^\s+//;
    $name_orig =~ s/\s+$//;
    $name_orig =~ s/\s+/ /g;

    my $name = $name_orig;
    $name =~ s/\s+/_/g;
    $name = lc($name);
    return (
        Encode::decode_utf8(URI::Escape::uri_unescape($name_orig)), 
        Encode::decode_utf8(URI::Escape::uri_unescape($name)), 
    );
}

=item resolve_path <%args>

Takes the following args:

=over 8

=item path_pages

=item proto_pages

=item query_pages

=item current_depth

=item final_depth

=back

returns true if path can be resolved, or false otherwise.

=cut

sub resolve_path {
    my ( $class, %args ) = @_;

    my ( $path_pages, $proto_pages, $query_pages, $current_depth, $final_depth ) =
        @args{ qw/ path_pages proto_pages query_pages current_depth final_depth/ };

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

}    # end sub resolve_path

=item set_paths

__PACKAGE__->set_paths( @pages );

Sets the path TEMP columns for multiple pages, either a subtree or a group of non-adjacent pages.

=cut

sub set_paths {
    my ( $class, @pages ) = @_;
    return @pages
        if ( scalar @pages == 1 )
        && $pages[0]->depth == 0;
    return unless ( scalar @pages );
    my %pages = map { $_->id => $_ } @pages;

    # Preserve the original sort order, because the pages
    # passed in may have been sorted differently than we
    # need them sorted to set paths:
    my @lft_sorted_pages = sort { $a->lft <=> $b->lft } @pages;

    # In some cases, e.g. retrieving descendants, we
    # may not have passed in the root of the subtree:
    unless ( $lft_sorted_pages[0]->name eq '/' ) {
        my $parent = $lft_sorted_pages[0]->parent;
        $pages{ $parent->id } = $parent;
    }

    # Sorting by the rgt column ensures that we always set
    # paths for parents before their children, allowing us
    # to avoid recursion.
    for (@lft_sorted_pages) {
        if ( $_->name eq '/' ) {
            $_->path('/');
            next;
        }
        if ( $_->depth == 1 ) {
            $_->path( '/' . $_->name );
            next;
        }
        my $parent = $pages{ $_->parent->id };
        if ( ref $parent ) {
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

}    # end sub set_paths

=item create_path_pages

find or creates a list of path_pages

=cut

sub create_path_pages {
    my ( $self, %args ) = @_;
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

        my $page_version = $self->related_resultset('page_version')->create( \%version_data );
        for ( $page->columns ) {
            next if $_ eq 'id';                 # page already exists
            next if $_ eq 'content_version';    # no content yet
            next unless $page_version->can($_);
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

}    # end sub create_path_pages

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

sub open_gap {
    my ( $self, $parent, $new_page_count ) = @_;
    my ( $gap_increment, $parent_rgt, $parent_id ) =
        ( $new_page_count * 2, $parent->rgt, $parent->id );
    $self->result_source->schema->storage->dbh->do(
        qq{ UPDATE page 
    SET rgt = rgt + ?, lft = CASE
    WHEN lft > ? THEN lft + ?
    ELSE lft
    END
    WHERE rgt >= ? }, undef,
        $gap_increment, $parent_rgt, $gap_increment, $parent_rgt
    );

    # get the new nested set numbers for the parent
    $parent = $self->find($parent_id);
    return $parent;
}

1;