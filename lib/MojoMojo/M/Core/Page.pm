package MojoMojo::M::Core::Page;

use strict;
use Time::Piece;
use Algorithm::Diff;
use Data::Dumper;

__PACKAGE__->columns( Essential => qw/owner node/ );
__PACKAGE__->add_trigger(
    after_set_content => sub {
       my $self =shift;
       $self->updated(localtime->datetime);
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
SELECT DISTINCT node, page.id as id,revision.updated,owner 
FROM page,tag,revision WHERE page.revision=revision.id AND page.id=tag.page AND tag=? ORDER BY node
});
__PACKAGE__->set_sql('by_tag_and_date' => qq{
SELECT DISTINCT node, page.id as id,revision.updated,owner 
FROM page,tag,revision WHERE revision.id=page.revision AND page.id=tag.page AND tag=? ORDER BY revision.updated
});
__PACKAGE__->set_sql('recent' => qq{
SELECT DISTINCT node, page.id as id,revision.updated,owner 
FROM page,revision WHERE revision.id=page.revision 
ORDER BY revision.updated
});

sub content_utf8 { $_[0]->revision && $_[0]->revision->content_utf8; }
sub content { $_[0]->revision && $_[0]->revision->content; }
sub updated { $_[0]->revision && $_[0]->revision->updated; }
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
    return $self->search_where(node=>$page)->next();
}

sub get_revision {
    my ( $self,$revnum)=@_;
    return MojoMojo::M::Core::Revision->search_where(
              page=>$self, 
              revnum=>$revnum)->next();
}

sub orphans {
    grep {$_->links_to->count == 0 }
	      __PACKAGE__->retrieve_all_sorted_by("node");
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
