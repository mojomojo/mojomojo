package MojoMojo::M::Core::Attachment;

use File::MimeInfo::Magic;

=head1 NAME

MojoMojo::M::Core::Attachment - Page attachments

=head1 DESCRIPTION

This class handles the business model for Page attachments.
attachments are represented in the database by the 'attachment'
table.

=head1 METHODS

=over 4

=cut

__PACKAGE__->columns(Essential=>qw/page name uploaded/);

__PACKAGE__->has_a( 'page' => 'MojoMojo::M::Core::Page' );
__PACKAGE__->has_a(
    uploaded => 'DateTime',
    inflate => sub {
        DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);

=item filename

returns a full path to the attachment on the filesystem. This function
uses the MojoMojo config, so requires Catalyst to function.

=cut

sub filename {
    my $self=shift;
    my $c=MojoMojo->context;
    return "uploads/" . $self->id unless $c;
    return $c->config->{home} . "/uploads/" . $self->id;
}

=item create_from_file (page,filename,storage_callback)

function to create an instance from a given file. Takes a filename,
a page to attach to, and a storage callback. The storage-callback will
be called with a full path to where the file should be stored

=cut

sub create_from_file {
  my ($class,$page,$filename, $storage_callback)=@_;
  my $self=$class->create(
                 { name => $filename,
                 page => $page } );
  die "Could not attach $filename to $page"  unless $self;
  &$storage_callback($self->filename);
  unless  (-f $self->filename) {
      warn $self->filename." not found";
      $self->delete();
      return undef;
  }
  $self->contenttype( mimetype($self->filename) );
  $self->size( -s $self->filename );
  $self->update();
  $self-> make_photo if ($self->contenttype =~ m|^image/|);
  return $self;
}

=item make_photo

analyzes the attachment, and makes a photo column based on the current 
attachment. Should only be called with image/* mimetype attachments.
=cut

sub make_photo {
  my $self = shift;
  my $photo=MojoMojo::M::Core::Photo->create({
    id=>$self->id,
    title=>$self->name});
  $photo->extract_exif($self) if $self->contenttype eq 'image/jpeg';
}

=item make_inline

create a resized version of a photo suitable for inline usage
FIXME: should this be moved to photo?

=cut

sub make_inline {
    my ($self)=shift;
    my $img=Imager->new();
    $img->open(file=>$self->filename,type=>'jpeg') or die $img->errstr;
    my ($image,$result);
    $image=$img->scale(xpixels=>700);
    $image->write(file=>$self->filename.'.inline',type=>'jpeg') or die $img->errstr;
}


=item make_thumb

create a thumbnail version of a photo, for gallery views and linking to pages

=cut

sub make_thumb {
    my ($self)=shift;
    my $img=Imager->new();
    $img->open(file=>$self->filename,type=>'jpeg') or die $img->errstr;
    my $h=$img->getheight;
    my $w=$img->getwidth;
    my ($image,$result);
    if ($h>$w) {
        $image=$img->scale(xpixels=>80);
            $h=$image->getheight;
        $result =$image->crop(
                            top=> int(($h-80)/2),
                            left=>0,
                          width=>80,
                            height=>80);
    } else {
        $image=$img->scale(ypixels=>80);
            $w=$image->getwidth;
        $result  =$image->crop(
                          left=> int(($w-80)/2),
                          top=>0,
                            width=>80,
                            height=>80);
    }
    $result->write(file=>$self->filename.'.thumb',type=>'jpeg') or die $img->errstr;
}

=back 

=head1 SEE ALSO

L<Class::DBI::Sweet>, L<Catalyst>, L<MojoMojo>

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
