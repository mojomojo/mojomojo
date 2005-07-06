package MojoMojo::M::Core::Tag;
use strict;

__PACKAGE__->columns( Essential => qw/tag/);
__PACKAGE__->columns( TEMP      => qw/refcount photocount pagecount/ );
__PACKAGE__->columns( Stringify => qw/tag/ );

MojoMojo::M::Core::Tag->has_a( 'person' => 'MojoMojo::M::Core::Person' );
MojoMojo::M::Core::Tag->has_a( 'page' => 'MojoMojo::M::Core::Page' );
MojoMojo::M::Core::Tag->has_a( 'photo' => 'MojoMojo::M::Core::Photo' );


__PACKAGE__->set_sql('path_tags' => qq{
SELECT tag.tag as tag, count(tag) AS refcount 
 FROM __TABLE__ 
 WHERE tag.page IN (
 select descendant.id
 FROM page as ancestor, page as descendant
 WHERE ancestor.id = ?
  AND ((descendant.lft > ancestor.lft
  AND descendant.rgt < ancestor.rgt) OR ancestor.id=descendant.id)
 )
 GROUP by tag
 ORDER BY tag.tag
});

sub pathtags {
    my ( $self,$page ) = @_;
    return ($self->search_path_tags($page));
}

__PACKAGE__->set_sql(
    'most_used' => qq[
SELECT __ESSENTIAL__, count(tag) AS refcount 
FROM tag 
WHERE page IS NOT NULL
GROUP BY tag ORDER by REFCOUNT DESC LIMIT 10
]
);

__PACKAGE__->set_sql(
    'related_tags' => qq{
SELECT  tag,count(tag) as refcount 
FROM tag WHERE page IN (select page from tag where tag=?) and tag != ?
GROUP BY tag ORDER by REFCOUNT DESC LIMIT 10
}
);
__PACKAGE__->set_sql(
    'others_tags' => qq{
SELECT  id,tag,count(tag) as pagecount from tag WHERE page=? and person != ? GROUP BY tag order by pagecount
}
);

__PACKAGE__->set_sql(
    'others_photo_tags' => qq{
SELECT  id,tag,count(tag) as photocount from tag WHERE photo=? and person != ? GROUP BY tag order by photocount
}
);

sub normalize_column_values {
  my ($self,$data) = @_;
  $data->{tag} =~ s/[^\w]//g;
}

sub related_to {
    my ( $self, $tag ) = @_;
    $tag ||= $self->tag;
    return $self->search_related_tags( $tag, $tag );
}

1;
