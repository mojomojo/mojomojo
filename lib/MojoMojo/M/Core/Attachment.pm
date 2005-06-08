package MojoMojo::M::Core::Attachment;
use File::MimeInfo::Magic;

__PACKAGE__->has_a(
    uploaded => 'DateTime',
    inflate => sub {
        DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);

sub filename {
    my $self=shift;
    my $c=MojoMojo->context;
    return "uploads/" . $self->id unless $c;
    return $c->config->{home} . "/uploads/" . $self->id;
}

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


sub make_photo {
  my $self = shift;
  my $photo=MojoMojo::M::Core::Photo->create({
    id=>$self->id,
    title=>$self->name});
  $photo->extract_exif($self) if $self->contenttype eq 'image/jpeg';
}

1;
