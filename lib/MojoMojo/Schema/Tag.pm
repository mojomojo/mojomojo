package MojoMojo::Schema::Tag;

use strict;
use warnings;

use base 'DBIx::Class';
use Carp qw/croak/;

__PACKAGE__->load_components( "ResultSetManager", "PK::Auto", "Core" );
__PACKAGE__->table("tag");
__PACKAGE__->add_columns(
    "id",
    { data_type => "INTEGER", is_nullable => 0, size => undef, is_auto_increment => 1 },
    "person",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "page",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "photo",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "tag",
    { data_type => "VARCHAR", is_nullable => 0, size => 100 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to( "person", "Person", { id => "person" } );
__PACKAGE__->belongs_to( "page",   "Page",   { id => "page" } );
__PACKAGE__->belongs_to( "photo",  "Photo",  { id => "photo" } );

sub most_used : ResultSet {
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

sub by_page : ResultSet {
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
            group_by => ['me.tag'],
            order_by => ['refcount'],
        }
    );
}

=head2 by_photo

Tags on photos with counts. Used to make the tag cloud for the gallery. 

=cut

sub by_photo : ResultSet {
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

sub related_to : ResultSet {
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

sub refcount {
    my $self = shift;
    return $self->get_column('refcount') if $self->has_column_loaded('refcount');
    croak 'Tried to call refcount on resultset without column';
}

1;
