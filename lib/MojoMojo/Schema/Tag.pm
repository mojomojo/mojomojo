package MojoMojo::Schema::Tag;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';


__PACKAGE__->load_components("ResultSetManager","PK::Auto", "Core");
__PACKAGE__->table("tag");
__PACKAGE__->add_columns("id", "person", "page", "photo", "tag");
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("person", "Person", { id => "person" });
__PACKAGE__->belongs_to("page", "Page", { id => "page" });
__PACKAGE__->belongs_to("photo", "Photo", { id => "photo" });

sub most_used : ResultSet {
    my ($self,$count) = @_;
    return $self->search({
	page => { '!=', undef },
    },{
             select   => [ 'me.tag', 'count(me.tag)' ],
             as       => [ 'tag','refcount' ],
             group_by => [ 'me.tag' ],
	     order_by => [ 'count(me.tag)' ],
    });
}

sub by_page :ResultSet {
    my ( $self,$page ) = @_;
    return $self->search({
        'ancestor.id' => $page,	
        'me.page'    => \'=descendant.id',
        -or => [
           -and => [
               'descendant.lft' => \'> ancestor.lft',
               'descendant.rgt' => \'< ancestor.rgt',
           ],
               'ancestor.id' => \'=descendant.id',
        ],
    }, { 
        from=> 'page as ancestor, page as descendant, tag as me',
        select => [ 'me.page', 'me.tag','count(me.tag)' ],
	as     => [ 'page','tag','refcount' ],
        group_by => ['me.tag'],
        order_by => ['me.tag'],
    });
}

=item related_to [<tag>] [<count>]

Returns popular tags related to this.
defaults to self.

=cut

sub related_to : ResultSet {
    my ( $self, $tag, $count ) = @_;
    $tag   ||= $self->tag;
    $count ||= 10;
    return $self->search({
	'me.tag'=>$tag,
	'other.tag'=>{'!=',$tag},
	'me.page'=>\'other.page',
    },{
	select     => [ 'me.tag', 'count(me.tag)' ],
	as         => [ 'tag','refcount' ],
	'group_by' => ['me.tag'],
        'from'     => 'tag me, tag other',
        'order_by' => \'count(tag)',
	'rows'	   => $count,
    })
}

sub refcount { shift->get_column('refcount') };
sub photocount { shift->get_column('photocount') };
sub pagecount { shift->get_column('pagecount') };

1;
