package MojoMojo::Schema::Attachment;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ResultSetManager DateTime::Epoch PK::Auto Core/);
__PACKAGE__->table("attachment");
__PACKAGE__->add_columns("id", 
    "uploaded" => {data_type=>'bigint',epoch=>'ctime'},
    "page", 
    "name", 
    "size", 
    "contenttype");
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("page", "Page", { id => "page" });
__PACKAGE__->might_have("photo", "Photo", { id => "id" });

=item create_from_file (page,filename,storage_callback)

function to create an instance from a given file. Takes a filename,
a page to attach to, and a storage callback. The storage-callback will
be called with a full path to where the file should be stored

=cut

sub create_from_file :ResultSet {
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

=head2 filename

Full path to this attachment. Can only be called from within an
active mojomojo context.

sub filename {
    my $self=shift;
    my $c=MojoMojo->context;
    return "uploads/" . $self->id unless ref $c;
    return $c->path_to('uploads', $self->id);
}

sub make_photo {
  my $self = shift;
  my $photo=$self->result_source->related_resultset('photo')->new({
    id=>$self->id,
    title=>$self->name});
  $photo->extract_exif($self) if $self->contenttype eq 'image/jpeg';
  $photo->insert();
}





1;

