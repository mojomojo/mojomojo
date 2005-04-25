package MojoMojo::M::Core::Page;

=head1 NAME

MojoMojo::M::Core::Page - Page model

=head1 SYNOPSIS

=head1 DESCRIPTION

This class models only "live" MojoMojo pages. Revisions (page histories)
are accessible via Page objects, however.

=cut



use strict;
use Time::Piece;
use Algorithm::Diff;

__PACKAGE__->columns( Essential => qw/name name_orig parent depth/ );
__PACKAGE__->columns( TEMP => qw/path/ );
__PACKAGE__->add_trigger(
    after_set_content => sub {
       my $self =shift;
       $self->created(localtime->datetime);
       $self->update();
    }
);

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

__PACKAGE__->set_sql('by_tag' => qq{
SELECT DISTINCT name, page.id as id, content.created, content.creator
FROM page, tag, content WHERE page.content=content.id AND page.id=tag.page AND tag=? ORDER BY name
});
__PACKAGE__->set_sql('by_tag_and_date' => qq{
SELECT DISTINCT name, page.id as id, content.created, content.creator
FROM page, tag, content WHERE content.id=page.content AND page.id=tag.page AND tag=? ORDER BY content.created
});

# FIX: this one needs work...
__PACKAGE__->set_sql('recent' => qq{
SELECT DISTINCT node, page.id as id,revision. updated, owner
FROM page,revision WHERE revision.id=page.revision
ORDER BY revision.updated DESC
});

# do we need these  ???
sub content_raw { $_[0]->content && $_[0]->content->body; }
sub updated { $_[0]->content && $_[0]->content->created; }

# should this go to Revision.pm ???
sub formatted_diff {
    my ( $self,$base,$to ) = @_;
    my $this=[ split /\n/, $self->content->formatted($base) ];
    my $prev=[ split /\n/, $to->content->formatted($base)   ];
    my @diff = Algorithm::Diff::sdiff( $prev, $this );
    my $diff;
    for my $line (@diff) {
      if    ($$line[0] eq "+") { 
	$diff .= qq(<ins class="diffins">).$$line[2]."</ins>" }
      elsif ($$line[0] eq "-") {
	$diff .= qq(<del class="diffdel">).$$line[1]."</del>" }
      elsif ($$line[0] eq "c") {
	$diff .= qq(<del class="diffdel">).$$line[1]."</del>"; 
	$diff .= qq(<ins class="diffins">).$$line[2]."</ins>" }
      elsif ($$line[0] eq "u") { $diff .=  $$line[1] }
      else{ $diff .= "Unknown operator ".$$line[0] }
    }
    return $diff;
}

# should this go to Revision.pm ???
sub highlight {
    my ( $self,$base, ) = @_;
    my $this=[ split /\n/, $self->content->formatted($base) ];
    my $prev=[ split /\n/, $self->revision->previous->content->formatted($base)];
    my @diff = Algorithm::Diff::sdiff( $prev, $this );
    my $diff;
    my $hi=0;
    for my $line (@diff) {
      $hi++;
      if    ($$line[0] eq "+") { 
	$diff .= qq(<div id="hi$hi" class="fade">).$$line[2]."</div>" }
      elsif ($$line[0] eq "c") {
	$diff .= qq(<div id="hi$hi"class="fade">).$$line[2]."</div>" }
      else { $diff .=  $$line[1] }
    }
    return $diff;
}

=item get_page

returns the actual page object for a path

=cut

sub get_page {
    my ( $self,$pagepath )=@_;
    #return $self->search_where(name=>$page)->next();
    my ($path, $proto_pages) = $self->get_path( $pagepath);
    return pop @$path;
}

=item path_pages

Accepts a path in url/unix directory format, e.g. "/page1/page2".
Paths are assumed to be absolute, so a leading slash (/) is not required.
Returns an array of any pages that exist in the path, starting with "/",
and an additional array of "proto page" hahses for any pages at the end
of the path that do not exist. All paths include the root (/), which must
exist, so a path of at least one element will always be returned. The "proto
page" hash keys are:

=over

=item 4

=item name_orig

The page name submitted by the user, with minor cleaning, e.g. leading and trailing
spaces trimmed.

=item name

The normalized page name, all lower case, with spaces replaced by underscores (_).

=item path

The partial, absolute path to the current page.

=item depth

The depth in the page hierarchy, or generation, of the current page.

=back

Notice that these fields all exist in the page objects, also. All are page table columns,
with the exception of path, which is a Class::DBI TEMP column.

=cut

sub path_pages {
    my ($self, $path) = @_;

    my @proto_pages = $self->parse_path( $path );

    my $depth = @proto_pages - 1; # depth starts at 0
    my $query_name = "get_path_depth_$depth";

    unless ( __PACKAGE__->can($query_name) ) {
        my $where = join ' OR ', ('( depth = ? AND name = ? )') x ($depth + 1);
        __PACKAGE__->add_constructor( $query_name => $where );
    }

    # store query results by depth:
    my @bind = map { $_->{depth}, $_->{name} } @proto_pages;
    my @query_pages;
    for (__PACKAGE__->$query_name( @bind )) {
        $query_pages[ $_->depth ] ||= [];
        push @{$query_pages[ $_->depth ]}, $_;
    }

    my @path_pages;
    my $resolved = $self->resolve_path
	(
	 path_pages    => \@path_pages,
	 proto_pages   => \@proto_pages,
	 query_pages   => \@query_pages,
	 current_depth => 0,
	 final_depth   => $depth,
	);
    return (\@path_pages, \@proto_pages);

} # end sub get_path

sub resolve_path {
    my ($self, %args) = @_;

    my ($path_pages, $proto_pages, $query_pages, $current_depth, $final_depth) =
        @args{qw/ path_pages proto_pages query_pages current_depth final_depth/};

    while ( my $page = shift @{$query_pages->[$current_depth]} )
    {
        unless ($current_depth == 0) {
            my $parent = $path_pages->[ $current_depth - 1 ];
            next unless $page->parent == $parent->id;
        }
        my $proto_page = shift @{$proto_pages};
        $page->path( $proto_page->{path} );
        push @{$path_pages}, $page;
        return 1 if
             ( $current_depth == $final_depth ||
               # must pre-icrement for this to work when current_depth == 0
               ( ++$args{current_depth} && $self->resolve_path(%args) )
             );
    }
    return 0;

} # end sub resolve_path

sub parse_path {
    my ($self, $path) = @_;

    # Remove leading and trailing slashes to make
    # split happy. We'll add the root (/) back later...
    $path =~ s/^[\/]+//;
    $path =~ s/[\/]+$//;

    my @proto_pages = map { {name_orig => $_} } (split /\/+/, $path);
    if (@proto_pages == 0 && $path =~ /\S/) {
	@proto_pages = ($path);
    }

    my $depth = 1;
    my $page_path = '';
    for (@proto_pages) {
        ($_->{name_orig}, $_->{name}) = $self->normalize_name( $_->{name_orig} );
        $page_path .= '/' . $_->{name};
        $_->{path} = $page_path;
        $_->{depth} = $depth;
        $depth++;
    }
    # assume that all paths are absolute:
    unshift @proto_pages, { name => '/', name_orig => '/', path => '/', depth => 0 };

    return @proto_pages;

} # end sub parse_path

sub normalize_name
{
    my ($self, $name_orig) = @_;

    $name_orig =~ s/^\s+//;
    $name_orig =~ s/\s+$//;
    $name_orig =~ s/\s+/ /g;

    my $name = $name_orig;
    $name =~ s/\s+/_/g;
    $name = lc($name);
    return ($name_orig, $name);

} # end sub normalize_name

sub revision
{
    my ($self) = @_;
    return MojoMojo::M::Core::Revision->retrieve
    (
     page    => $self->id,
     version => $self->version
    );
}

# This is probably defunct in favor of "revision" above...
sub get_revision {
    my ( $self,$revnum)=@_;
    return MojoMojo::M::Core::Revision->search_where(
              page=>$self, 
              revnum=>$revnum)->next();
}

sub orphans {
    grep {$_->links_to->count == 0 }
	      __PACKAGE__->retrieve_all_sorted_by("name");
}

sub wikiwords {
    my $self=shift;
    my $content  = $self->content;
    my @links;
    while ( $content =~ m/(?<![\?\\\/])(\b[A-Z][a-z]+[A-Z]\w*)/g ) {
      push @links, $1;
    }
    while ( $content =~ m{\[\[\s*([^\]]+)\s*\]\]}g) {
      push @links,MojoMojo->fixw( $1 );
    }
    return @links;
}

sub others_tags {
  my ($self,$user)=@_;
  my (@tags)=MojoMojo::M::Core::Tag->search_others_tags($self->id,$user);
  return @tags;
}

sub user_tags {
  my ($self,$user)=@_;
  my (@tags)=MojoMojo::M::Core::Tag->search(person=>$user,page=>$self);
  return @tags;
}
1;
