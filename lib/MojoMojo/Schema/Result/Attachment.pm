package MojoMojo::Schema::Result::Attachment;

use strict;
use warnings;

use base qw/MojoMojo::Schema::Base::Result/;

__PACKAGE__->load_components(qw/DateTime::Epoch PK::Auto Core/);
__PACKAGE__->table("attachment");
__PACKAGE__->add_columns(
    "id",
    "id",
    { data_type => "INTEGER", is_nullable => 0, size => undef, is_auto_increment => 1 },
    "uploaded",
    { data_type => "BIGINT", is_nullable => 0, size => undef, epoch => 'ctime' },
    "page",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "name",
    { data_type => "VARCHAR", is_nullable => 0, size => 100 },
    "size",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "contenttype",
    { data_type => "VARCHAR", is_nullable => 1, size => 100 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to( "page", "Page", { id => "page" } );
__PACKAGE__->might_have( "photo", "MojoMojo::Schema::Result::Photo" );

sub delete {
    my ($self) = @_;
    unlink( $self->filename )        if -f $self->filename;
    unlink( $self->inline_filename ) if -f $self->inline_filename;
    unlink( $self->thumb_filename )  if -f $self->thumb_filename;
    $self->next::method();
}

=head2 filename

Full path to this attachment.

=cut

sub filename {
    my $self           = shift;
    my $attachment_dir = $self->result_source->schema->attachment_dir;
    die(
        "MojoMojo::Schema->attachment must be set to a writeable directory (Current:$attachment_dir)\n"
    ) unless -d $attachment_dir && -w $attachment_dir;
    return ( $attachment_dir . '/' . $self->id );
}

sub inline_filename { shift->filename . '.inline'; }

sub thumb_filename { shift->filename . '.thumb'; }

sub make_photo {
    my $self  = shift;
    my $photo = $self->result_source->related_source('photo')->resultset->new(
        {
            id    => $self->id,
            title => $self->name,
        }
    );
    $photo->description('Set your description');
    $photo->extract_exif($self) if $self->contenttype eq 'image/jpeg';
    $photo->insert();
}

1;

