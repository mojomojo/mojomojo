package MojoMojo::Schema::Result::Attachment;

use strict;
use warnings;

use parent qw/MojoMojo::Schema::Base::Result/;

use Number::Format qw( format_bytes );

__PACKAGE__->load_components(
    qw/DateTime::Epoch TimeStamp Core/);
__PACKAGE__->table("attachment");
__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "INTEGER",
        is_nullable       => 0,
        size              => undef,
        is_auto_increment => 1
    },
    "uploaded",
    {
        data_type        => "BIGINT",
        is_nullable      => 0,
        size             => undef,
        inflate_datetime => 'epoch',
        set_on_create    => 1
    },
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
__PACKAGE__->belongs_to(
    "page",
    "MojoMojo::Schema::Result::Page",
    { id => "page" }
);
__PACKAGE__->might_have( "photo", "MojoMojo::Schema::Result::Photo" );

=head1 NAME

MojoMojo::Schema::Result::Attachment - store attachments

=head1 METHODS

=head2 delete

Delete the inline and thumbnail versions but keep the original version
(C<$self->filename>).

=cut

sub delete {
    my ($self) = @_;

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
    die "MojoMojo::Schema->attachment_dir must be set to a writable directory (Current: $attachment_dir)\n"
        unless -d $attachment_dir && -w $attachment_dir;
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

sub is_image {
    my $self = shift;

    return $self->contenttype =~ m{^image/};
}

sub is_text {
    my $self = shift;

    return $self->contenttype =~ m{^text/};
}

sub human_size {
    my $self = shift;

    return format_bytes( $self->size, precision => 1 );
}

# It would be nice to find an external module/data source for this data,
# e.g. http://en.kioskea.net/contents/courrier-electronique/mime.php3
# and/or bundle it into a separate module for CPAN.
my %mime_type_to_description = (
    'application/javascript' => 'Javascript',
    'application/json'       => 'JSON data',
    'application/pdf'        => 'PDF document',
    'application/xhtml+xml'  => 'Web page',

    'audio/mpeg'   => 'Sound file',
    'audio/ogg'    => 'Sound file',
    'audio/vorbis' => 'Sound file',

    'text/css'   => 'Cascading style sheet',
    'text/csv'   => 'Comma separated values',
    'text/html'  => 'Web page',
    'text/plain' => 'Plain text file',
    'text/xml'   => 'XML file',

    'image/gif'  => 'GIF image',
    'image/jpeg' => 'JPEG image',
    'image/png'  => 'PNG image',
);

sub human_type {
    my $self = shift;

    return $mime_type_to_description{ $self->contenttype }
        || $self->contenttype;
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
