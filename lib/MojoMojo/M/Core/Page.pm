package MojoMojo::M::Core::Page;

use strict;
use Time::Piece;
use Algorithm::Diff;

__PACKAGE__->columns( Essential => qw/owner node/ );
__PACKAGE__->columns( TEMP      => 'content_utf8' );
__PACKAGE__->add_trigger(
    select => sub {
        my $self    = shift;
        my $content = $self->content;
        utf8::decode($content);
        $self->content_utf8($content);
    }
);
__PACKAGE__->add_trigger(
    after_set_content => sub {
       my $self =shift;
       $self->updated(localtime->datetime);
       $self->update();
    }
);

#__PACKAGE__->has_a(
#    updated => 'Time::Piece',
#    inflate => sub { Time::Piece->strptime( shift, "%FT%H:%M:%S" ) },
#    deflate => 'datetime'
#);
__PACKAGE__->has_many(
    links_to => [ 'MojoMojo::M::Core::Link' => 'from_page' ],
    "to_page"
);
__PACKAGE__->has_many(
    links_from => [ 'MojoMojo::M::Core::Link' => 'to_page' ],
    "from_page"
);

__PACKAGE__->set_sql('by_tag' => qq{
SELECT page.id as id,node,revision.updated,owner 
FROM page,tag WHERE page.revision=revision.id AND page.id=tag.page AND tag=? ORDER BY node
});
__PACKAGE__->set_sql('by_tag_and_date' => qq{
SELECT page.id as id,node,revison.updated,owner 
FROM page,tag WHERE revision.id=page.revision AND page.id=tag.page AND tag=? ORDER BY revision.updated
});

sub content { $_[0]->revision->content; }
sub updated { $_[0]->revision->updated; }
sub formatted_content {
    my ( $self,$base, $content ) = @_;
    $content ||= $self->content_utf8;
    MojoMojo->call_plugins("format_content", \$content, $base) if ($content);
    return $content;
}

sub formatted_diff {
    my ( $self,$base,$to ) = @_;
    my $this=[ split /\n/, $self->content_utf8() ];
    my $prev=[ split /\n/, $to->content_utf8()   ];
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
    return $self->formatted_content($base,$diff);
}

sub get_page {
    my ( $self,$page )=@_;
    return $self->search_where(node=>$page)->next();
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

1;
