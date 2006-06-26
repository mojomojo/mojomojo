package MojoMojo::Schema::Photo;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("photo");
__PACKAGE__->add_columns(
  "id",
  "title",
  "description",
  "camera",
  "taken",
  "iso",
  "lens",
  "aperture",
  "flash",
  "height",
  "width",
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many("tags", "Tag", { "foreign.photo" => "self.id" });
__PACKAGE__->has_many("comments", "Comment", { "foreign.picture" => "self.id" });
__PACKAGE__->has_one('attachment','Attachment',{'foreign.id' => 'self.id' });

sub make_inline {
    my ($self)=shift;
    my $img=Imager->new();
    $img->open(file=>$self->attachment->filename,type=>'jpeg') 
        or die $img->errstr;
    my ($image,$result);
    $image=$img->scale(xpixels=>700);
    $image->write(file=>$self->attachment->filename.'.inline',type=>'jpeg')
        or die $img->errstr;
}

=item make_thumb

create a thumbnail version of a photo, for gallery views and linking to pages

=cut

sub make_thumb {
    my ($self)=shift;
    my $img=Imager->new();
    $img->open(file=>$self->attachment->filename,type=>'jpeg') 
        or die $img->errstr;
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
    $result->write(file=>$self->attachment->filename.'.thumb',type=>'jpeg') 
        or die $img->errstr;
}


1;

