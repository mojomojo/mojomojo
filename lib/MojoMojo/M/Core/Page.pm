package MojoMojo::M::Core::Page;

use strict;
use Time::Piece;
use Algorithm::Diff;

__PACKAGE__->columns( Essential => qw/owner name name_orig parent depth/ );
__PACKAGE__->columns( TEMP => qw/path_string/ );
__PACKAGE__->add_trigger(
    after_set_content => sub {
       my $self =shift;
       $self->modified_date(localtime->datetime);
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

__PACKAGE__->set_sql('by_tag' => qq{
SELECT DISTINCT name, page.id as id,content.modified_date,content.modified_by
FROM page,tag,content WHERE page.content=content.id AND page.id=tag.page AND tag=? ORDER BY name
});
__PACKAGE__->set_sql('by_tag_and_date' => qq{
SELECT DISTINCT name, page.id as id,content.modified_date,content.modified_by
FROM page,tag,content WHERE content.id=page.content AND page.id=tag.page AND tag=? ORDER BY content.modified_by
});
__PACKAGE__->set_sql('recent' => qq{
SELECT DISTINCT node, page.id as id,revision.updated,owner 
FROM page,revision WHERE revision.id=page.revision 
ORDER BY revision.updated DESC
});

sub content_utf8 { $_[0]->content && $_[0]->content->content_utf8; }
sub content_raw { $_[0]->content && $_[0]->content->content; }
sub updated { $_[0]->content && $_[0]->content->modified_date; }
sub formatted_content {
    my ( $self,$base, $content ) = @_;
    $content ||= $self->content_utf8;
    MojoMojo->call_plugins("format_content", \$content, $base) if ($content);
    return $content;
}

sub formatted_diff {
    my ( $self,$base,$to ) = @_;
    my $this=[ split /\n/, $self->formatted_content($base) ];
    my $prev=[ split /\n/, $to->formatted_content($base)   ];
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

sub highlight {
    my ( $self,$base, ) = @_;
    my $this=[ split /\n/, $self->formatted_content($base) ];
    my $prev=[ split /\n/, $self->revision->previous->formatted_content($base)];
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

sub get_page {
    my ( $self,$page )=@_;
    #return $self->search_where(name=>$page)->next();
    my ($path, $proto_pages) = $self->get_path( $page );
    return ($path, $proto_pages);
}

sub get_path {
    my ($self, $path_string) = @_;

    my @proto_pages = $self->parse_path_string( $path_string );

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

    my @path;
    my $resolved = $self->resolve_path
	(
	 path          => \@path,
	 proto_pages   => \@proto_pages,
	 query_pages   => \@query_pages,
	 current_depth => 0,
	 final_depth   => $depth,
	);
    return (\@path, \@proto_pages);

} # end sub get_path

sub resolve_path {
    my ($self, %args) = @_;

    my ($path, $proto_pages, $query_pages, $current_depth, $final_depth) =
        @args{qw/ path proto_pages query_pages current_depth final_depth/};

    while ( my $page = shift @{$query_pages->[$current_depth]} )
    {
        unless ($current_depth == 0) {
            my $parent = $path->[ $current_depth - 1 ];
            next unless $page->parent == $parent->id;
        }
        my $proto_page = shift @{$proto_pages};
        $page->path_string( $proto_page->{path_string} );
        push @{$path}, $page;
        return 1 if
             ( $current_depth == $final_depth ||
               # must pre-icrement for this to work when current_depth == 0
               ( ++$args{current_depth} && $self->resolve_path(%args) )
             );
    }
    return 0;

} # end sub resolve_path

sub parse_path_string {
    my ($self, $path_string) = @_;

    # Remove leading and trailing slashes to make
    # split happy. We'll add the root (/) back later...
    die "Page path must be absolute"
        unless $path_string =~ s/^(\/)+//;
    $path_string =~ s/(\/)+$//;

    my @proto_pages = map { {name_orig => $_} } (split /\/+/, $path_string);
    if (@proto_pages == 0 && $path_string =~ /\S/) {
	@proto_pages = ($path_string);
    }

    my $depth = 1;
    my $page_path = '';
    for (@proto_pages) {
        ($_->{name_orig}, $_->{name}) = $self->normalize_name( $_->{name_orig} );
        $page_path .= '/' . $_->{name};
        $_->{path_string} = $page_path;
        $_->{depth} = $depth;
        $depth++;
    }
    unshift @proto_pages, { name => '/', name_orig => '/', path_string => '/', depth => 0 };

    return @proto_pages;

} # end sub parse_path_string

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
  my (@tags)=MojoMojo::M::Core::Tag->search(user=>$user,page=>$self);
  return @tags;
}
1;
