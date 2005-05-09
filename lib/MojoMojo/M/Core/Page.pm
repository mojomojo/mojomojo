package MojoMojo::M::Core::Page;

=head1 NAME

MojoMojo::M::Core::Page - Page model

=head1 SYNOPSIS

=head1 DESCRIPTION

This class models only "live" MojoMojo pages.

=cut

use strict;
use Time::Piece;
use Algorithm::Diff;

__PACKAGE__->columns( Essential => qw/name name_orig parent depth/ );
__PACKAGE__->columns( TEMP      => qw/path/ );

# automatically set the path TEMP column on select:
__PACKAGE__->add_trigger( select => sub {
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
});

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

# FIX: this one needs work...
__PACKAGE__->set_sql(
    'recent' => qq{
SELECT DISTINCT page.name, page.id as id,page_version.release_date, 
creator
FROM page,page_version WHERE page_version.page=page.id
ORDER BY page_version.release_date DESC
}
);

# do we need these  ???
sub content_raw { $_[0]->content && $_[0]->content->body; }
sub updated     { $_[0]->content && $_[0]->content->created; }

sub formatted_diff {
    my ( $self, $base, $to ) = @_;
    my $this = [ split /\n/, $self->content->formatted($base) ];
    my $prev = [ split /\n/, $to->content->formatted($base) ];
    my @diff = Algorithm::Diff::sdiff( $prev, $this );
    my $diff;
    for my $line (@diff) {
        if ( $$line[0] eq "+" ) {
            $diff .= qq(<ins class="diffins">) . $$line[2] . "</ins>";
        }
        elsif ( $$line[0] eq "-" ) {
            $diff .= qq(<del class="diffdel">) . $$line[1] . "</del>";
        }
        elsif ( $$line[0] eq "c" ) {
            $diff .= qq(<del class="diffdel">) . $$line[1] . "</del>";
            $diff .= qq(<ins class="diffins">) . $$line[2] . "</ins>";
        }
        elsif ( $$line[0] eq "u" ) { $diff .= $$line[1] }
        else { $diff .= "Unknown operator " . $$line[0] }
    }
    return $diff;
}

sub highlight {
    my ( $self, $base ) = @_;
    my $this_content = $self->content->formatted($base);

    # FIX: This may return undef. What do we do then????
    my $previous_content = (
        defined $self->content->previous
        ? $self->content->previous->formatted($base)
        : $this_content );
    my $this = [ split /\n/,                  $this_content ];
    my $prev = [ split /\n/,                  $previous_content ];
    my @diff = Algorithm::Diff::sdiff( $prev, $this );
    my $diff;
    my $hi = 0;
    for my $line (@diff) {
        $hi++;
        if ( $$line[0] eq "+" ) {
            $diff .= qq(<div id="hi$hi" class="fade">) . $$line[2] . "</div>";
        }
        elsif ( $$line[0] eq "c" ) {
            $diff .= qq(<div id="hi$hi"class="fade">) . $$line[2] . "</div>";
        } elsif ( $$line[0] eq "-" ) { }
        else { $diff .= $$line[1] }
    }
    return $diff;
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
    my ( $self, $path ) = @_;

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

    my @path_pages;
    my $resolved = $self->resolve_path(
        path_pages    => \@path_pages,
        proto_pages   => \@proto_pages,
        query_pages   => \@query_pages,
        current_depth => 0,
        final_depth   => $depth,
    );
    return ( \@path_pages, \@proto_pages );

}    # end sub get_path

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

}    # end sub resolve_path

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

}    # end sub parse_path

sub normalize_name {
    my ( $self, $name_orig ) = @_;

    $name_orig =~ s/^\s+//;
    $name_orig =~ s/\s+$//;
    $name_orig =~ s/\s+/ /g;

    my $name = $name_orig;
    $name =~ s/\s+/_/g;
    $name = lc($name);
    return ( $name_orig, $name );

}    # end sub normalize_name

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

        # should we ever get here???
        die "Error in calculating content version";
    }
    my %content_data =
      map { $_ => $args{$_} } MojoMojo::M::Core::Content->columns;
    @content_data{qw/page version/} = ( $self->id, $content_version );
    my $content = MojoMojo::M::Core::Content->create( \%content_data );
    $self->content_version( $content->version );
    $self->update;
    $self->page_version->content_version_last($content_version);
    $self->page_version->update;

}    # end sub update_content

sub create_path_pages {
    my ( $class,      %args )        = @_;
    my ( $path_pages, $proto_pages ) = @args{qw/path_pages proto_pages/};
    my @version_columns = MojoMojo::M::Core::PageVersion->columns;

    my $parent = $path_pages->[ @$path_pages - 1 ];

    # create the missing parent pages
    for my $proto_page (@$proto_pages) {

        # since SQLite doesn't support sequences, just cheat
        # for now and get the next id by creating a page record
        my $page = __PACKAGE__->create( { parent => $parent } );
        my %version_data = map { $_ => $proto_page->{$_} } @version_columns;

        # FIX: Ugly hack: set creator to 1 for now
        @version_data{qw/ page version parent parent_version creator /} = (
            $page, 1, $page->parent,
            ( $page->parent ? $page->parent->version : undef ), 1
        );

        my $page_version =
          MojoMojo::M::Core::PageVersion->create( \%version_data );
        for ( $page->columns ) {
            next if $_ eq 'id';                 # page already exists
            next if $_ eq 'content_version';    # no content yet
            $page->$_( $page_version->$_ );
        }
        $page->update;
        push @$path_pages, $page;
        $parent = $page;
    }
    return $path_pages;

}    # end sub create_path_pages

1;
