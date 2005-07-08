package MojoMojo::M::Core::Tag;
use strict;


=head1 NAME

MojoMojo::M::Core::Tag - Tags support for MojoMojo

=head1 DESCRIPTION

This class contains the data model for tags in MojoMojo. You can
tag pages as well as pictures in the gallery.

=head1 METHODS

=over 4

=cut

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

=item path_tags <page_id>

return all tags ordered by tag name within a given page tree. 
include tag count.

=cut

sub pathtags {
    my ( $self,$page ) = @_;
    return ($self->search_path_tags($page));
}


__PACKAGE__->set_sql(
    'most_used' => qq[
SELECT __ESSENTIAL__, count(tag) AS refcount 
FROM tag 
WHERE page IS NOT NULL
GROUP BY tag ORDER by REFCOUNT DESC LIMIT ?
]
);

=item most_used <count>

returns the I<count> most popular tags, and counts.
I<count> defaults to 10.

=cut

sub most_used {
    my $self  = shift;
    my $count = shift || 10;
    return $self->search_most_used($count);
}

__PACKAGE__->set_sql(
    'related_tags' => qq{
SELECT  tag,count(tag) as refcount 
FROM tag WHERE page IN (select page from tag where tag=?) and tag != ?
GROUP BY tag ORDER by REFCOUNT DESC LIMIT ?
}
);

# Used by others_tag in Page.

__PACKAGE__->set_sql(
    'others_tags' => qq{
SELECT  id,tag,count(tag) as pagecount from tag WHERE page=? and person != ? GROUP BY tag order by pagecount
}
);

# Used by Photo

__PACKAGE__->set_sql(
    'others_photo_tags' => qq{
SELECT  id,tag,count(tag) as photocount from tag WHERE photo=? and person != ? GROUP BY tag order by photocount
}
);

=normalize_column_values

overriden so tags can only contain \w+
=cut

sub normalize_column_values {
  my ($self,$data) = @_;
  $data->{tag} =~ s/[^\w]//g;
}

=item related_to [<tag>] [<count>]

Returns popular tags related to this.
defaults to self.

=cut

sub related_to {
    my ( $self, $tag, $count ) = @_;
    $tag   ||= $self->tag;
    $count ||= 10;
    return $self->search_related_tags( $tag, $tag, $count );
}

=back

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
