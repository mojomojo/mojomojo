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
	page => { '!=',undef },
    },{
             select   => [ 'tag', { count => 'id' } ],
             group_by => [qw/ tag /],
	     order_by => 'count(id)',
    })
}

1;
