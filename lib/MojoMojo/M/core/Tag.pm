package MojoMojo::M::Core::Tag;
use strict;

__PACKAGE__->columns(TEMP=>qw/refcount/);
__PACKAGE__->columns(Stringify=>qw/tag/);


__PACKAGE__->set_sql('most_used'=> qq[
SELECT tag, count(tag) AS refcount 
FROM tag 
GROUP BY tag ORDER by REFCOUNT DESC LIMIT 10
]);

__PACKAGE__->set_sql('related_tags' => qq{
SELECT  tag,count(tag) as refcount 
FROM tag WHERE page IN (select page from tag where tag=?) and tag != ?
GROUP BY tag ORDER by REFCOUNT DESC LIMIT 10
});

sub related_to {
    my ($self,$tag) = @_;
    $tag ||= $self->tag;
    return $self->search_related_tags($tag,$tag);
}

1;
