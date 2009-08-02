package MojoMojo::Schema::Result::Photo;

use strict;
use warnings;

use parent qw/MojoMojo::Schema::Base::Result/;

use DateTime;
use Image::ExifTool;
use Image::Math::Constrain;
my $exif = Image::ExifTool->new();

__PACKAGE__->load_components(
    qw/DateTime::Epoch TimeStamp Ordered Core/);

__PACKAGE__->position_column("position");
__PACKAGE__->table("photo");
__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "INTEGER",
        is_nullable       => 0,
        size              => undef,
        is_auto_increment => 1
    },
    "position",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "title",
    { data_type => "TEXT", is_nullable => 0, size => undef },
    "description",
    { data_type => "TEXT", is_nullable => 1, size => undef },
    "camera",
    { data_type => "TEXT", is_nullable => 1, size => undef },
    "taken",
    {
        data_type                 => "INTEGER",
        is_nullable               => 1,
        size                      => undef,
        default_value             => undef,
        inflate_datetime          => 'epoch',
        datetime_undef_if_invalid => 1,
    },
    "iso",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "lens",
    { data_type => "TEXT", is_nullable => 1, size => undef },
    "aperture",
    { data_type => "TEXT", is_nullable => 1, size => undef },
    "flash",
    { data_type => "TEXT", is_nullable => 1, size => undef },
    "height",
    { data_type => "INT", is_nullable => 1, size => undef },
    "width",
    { data_type => "INT", is_nullable => 1, size => undef },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
    "tags",
    "MojoMojo::Schema::Result::Tag",
    { "foreign.photo" => "self.id" }
);
__PACKAGE__->has_many(
    "comments",
    "MojoMojo::Schema::Result::Comment",
    { "foreign.picture" => "self.id" }
);
__PACKAGE__->has_one( "attachment", "MojoMojo::Schema::Result::Attachment" );

=head1 NAME

MojoMojo::Schema::Result::Photo

=head1 METHODS

=cut

=head2 extract_exif

Extracts EXIF information from a given Attachment and
populates the Photo object.

=cut

sub extract_exif {
    my ( $self, $att ) = @_;
    my $info = $exif->ImageInfo( $att->filename );
    $self->camera( $info->{'Model'} );
    $self->lens( $info->{'FocalLength'} );
    $self->iso( $info->{'ISO'} );
    $self->aperture( $info->{'Aperture'} );
    $self->description( $info->{'UserComment'} );
    $self->taken( $self->exif2datetime( $info->{'DateTimeOriginal'} ) );
}

=head2 exif2datetime datetime

Creates a L<DateTime> object from an EXIF timestamp.

=cut

sub exif2datetime {
    my ( $self, $datetime ) = @_;
    return undef unless $datetime;
    my ( $date, $time ) = split( ' ', $datetime );
    my ( $y, $M, $d ) = split ':', $date;
    my ( $h, $m, $s ) = split ':', $time;
    my $dto;
    eval {
        $dto = DateTime->new(
            year   => $y,
            month  => $M,
            day    => $d,
            hour   => $h,
            minute => $m,
            second => $s
        );
    };
    return $dto;
}

=head2 prev_by_tag <tag>

Return previous image when browsing by the given tag.

=cut

sub prev_by_tag {
    my ( $self, $tag ) = @_;
    return $self->retrieve_previous(
        'tags.tag' => $tag,
        { order_by => 'taken DESC' }
    )->next;
}

=head2 next_by_tag <tag>

Return the next image when browsing by the given tag.

=cut

sub next_by_tag {
    my ( $self, $tag ) = @_;
    return $self->result_source->resultset - _search(
        { id => { '>', $self->id }, 'tags.tag' => $tag },
        { order_by => 'taken DESC', join => [qw/tags/], rows => 1 }
    )->next;
}

=head2 others_tags <user>

Tags other users have given to this photo.

=cut

sub others_tags {
    my ( $self, $user ) = @_;
    my (@tags) = $self->related_resultset('tags')->search(
        {
            photo  => $self->id,
            person => { '!=', $user },
        },
        {
            select     => [ 'me.tag', 'count(me.tag) AS refcount' ],
            as         => [ 'tag',    'refcount' ],
            'group_by' => ['me.tag'],
            'order_by' => 'refcount',
        }
    );
    return @tags;
}

=head2 user_tags <user>

Tags this user has given to this photo.

=cut

sub user_tags {
    my ( $self, $user ) = @_;
    my (@tags) = $self->related_resultset('tags')->search(
        {
            photo  => $self->id,
            person => $user,
        },
        { 'order_by' => ['me.tag'] }
    );
    return @tags;
}

=head2 make_inline

Create a resized version of a photo suitable for inline usage.

=cut

sub make_inline {
    my ($self) = shift;
    my $img    = Imager->new();
    my $att    = $self->attachment;
    $img->open( file => $att->filename ) or die $img->errstr;
    my $constrain = Image::Math::Constrain->new( 800, 600 );
    my $image = $img->scale( constrain => $constrain );

    $image->write( file => $att->filename . '.inline', type => 'jpeg' )
      or die $img->errstr;
}

=head2 make_thumb

Create a thumbnail version of a photo, for gallery views and linking to pages.

=cut

sub make_thumb {
    my ($self) = shift;
    my $img    = Imager->new();
    my $att    = $self->attachment;
    $img->open( file => $att->filename ) or die $img->errstr;
    my $h = $img->getheight;
    my $w = $img->getwidth;
    my ( $image, $result );
    if ( $h > $w ) {
        $image  = $img->scale( xpixels => 80 );
        $h      = $image->getheight;
        $result = $image->crop(
            top => int( ( $h - 80 ) / 2 ),
            left   => 0,
            width  => 80,
            height => 80
        );
    }
    else {
        $image  = $img->scale( ypixels => 80 );
        $w      = $image->getwidth;
        $result = $image->crop(
            left => int( ( $w - 80 ) / 2 ),
            top => 0,
            width  => 80,
            height => 80
        );
    }
    $result->write( file => $att->filename . '.thumb', type => 'jpeg' )
      or die $img->errstr;
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
