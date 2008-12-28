package MojoMojo::Schema::ResultSet::Tag;

use strict;
use warnings;
use base qw/MojoMojo::Schema::Base::ResultSet/;

sub most_used {
    my ( $self, $count ) = @_;
    return $self->search(
        { page => { '!=', undef }, },
        {
            select   => [ 'me.tag', 'count(me.tag) as refcount' ],
            as       => [ 'tag',    'refcount' ],
            group_by => ['me.tag'],
            order_by => ['refcount desc'],
        }
    );
}

sub by_page {
    my ( $self, $page ) = @_;
    return $self->search(
        {
            'ancestor.id' => $page,
            'me.page'     => \'=descendant.id',
            -or           => [
                -and => [
                    'descendant.lft' => \'> ancestor.lft',
                    'descendant.rgt' => \'< ancestor.rgt',
                ],
                'ancestor.id' => \'=descendant.id',
            ],
        },
        {
            from     => 'page as ancestor, page as descendant, tag as me',
            select   => [ 'me.page', 'me.tag', 'count(me.tag) as refcount' ],
            as       => [ 'page', 'tag', 'refcount' ],
            group_by => [ 'me.page','me.tag'],
            order_by => ['refcount'],
        }
    );
}

=head2 by_photo

Tags on photos with counts. Used to make the tag cloud for the gallery. 

=cut

sub by_photo {
    my ($self) = @_;
    return $self->search(
        { photo => { '!=' => undef } },
        {
            select   => [ 'me.photo', 'me.tag', 'count(me.tag) as refcount' ],
            as       => [ 'photo',    'tag',    'refcount' ],
            group_by => ['me.tag'],
            order_by => ['me.tag'],
        }
    );
}

=item related_to [<tag>] [<count>]

Returns popular tags related to this.
defaults to self.

=cut

sub related_to {
    my ( $self, $tag, $count ) = @_;
    $tag   ||= $self->tag;
    $count ||= 10;
    return $self->search(
        {
            'me.tag'    => $tag,
            'other.tag' => { '!=', $tag },
            'me.page'   => \'=other.page',
        },
        {
            select     => [ 'me.tag', 'count(me.tag) as refcount' ],
            as         => [ 'tag',    'refcount' ],
            'group_by' => ['me.tag'],
            'from'     => 'tag me, tag other',
            'order_by' => \'refcount',
            'rows'     => $count,
        }
    );
}

1;