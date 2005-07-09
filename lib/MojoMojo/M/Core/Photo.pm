package MojoMojo::M::Core::Photo;

use Image::EXIF;

=head1 NAME

MojoMojo::M::Core::Photo - Photo attributes of an Attachment

=head1 DESCRIPTION

This class contents Photo-specific information for 
L<MojoMojo::M::Core::Attachment>.

=head1 METHODS

=over 4

=cut

__PACKAGE__->columns(Essential=>qw/title description taken/);

__PACKAGE__->has_a(
    taken => 'DateTime',
    inflate => sub {
        DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);
__PACKAGE__->has_many( 'tags' => 'MojoMojo::M::Core::Tag' );


=item search_page <page>

Returns all Photo objects for a given page.

=cut

#FIXME: Isn't this obsolete? ::Sweet can do joins.
__PACKAGE__->set_sql('page', <<"");
SELECT __ESSENTIAL__ 
FROM __TABLE__,attachment 
wHERE __TABLE__.id=attachment.id AND attachment.page=? 


__PACKAGE__->might_have('attachment' => 'MojoMojo::M::Core::Attachment', qw/uploaded/);
MojoMojo::M::Core::Photo->has_many( 'comments' => 'MojoMojo::M::Core::Comment' )
;

=item create_from_attachment <attachments>

Extracts image information from an attachment and creates a Photo
object.

=cut

sub create_from_attachment {
    my ($class,$attachment) = @_;
    my $self=$class->create({
        id=>$attachment->id,
        name=>$attachment->name
    });
}

=item others_tags <user>

Tags other users have given to this Photo.

=cut

sub others_tags {
    my ( $self, $user ) = @_;
    my (@tags) = MojoMojo::M::Core::Tag->search_others_photo_tags( $self->id, $user );
    return @tags;
}

=item user_tags <user>

Tags this user have given to this photo.

=cut

sub user_tags {
    my ( $self, $user ) = @_;
    my (@tags) =
      MojoMojo::M::Core::Tag->search( person => $user, photo => $self );
    return @tags;
}

=item extract_exif

Extracts EXIF information from a given Attachment and
populates the Photo object.

=cut

sub extract_exif {
    my ($self,$att)=@_;
    my $exif=new Image::EXIF;
    $exif->file_name($att->filename);
    my $info=$exif->get_all_info();
    $self->camera($info->{camera}->{'Camera Model'});
    $self->lens($info->{image}->{'Focal Length'});
    $self->iso($info->{image}->{'ISO Speed Rating'});
    $self->aperture($info->{image}->{'Lens Aperture'});
    $self->description($info->{image}->{'ImageDescription'});
    $self->taken($self->exif2datetime($info->{image}->{'Image Created'}));
    $self->update();
}

=item exif2datetime datetime

Creates a L<DateTime> object from a EXIF timestamp.

=cut

sub exif2datetime {
    my ($self,$datetime)=@_;
    return undef unless $datetime;
    my ($date,$time)=split(' ',$datetime);
    my ($y,$M,$d) = split ':',$date;
    my ($h,$m,$s) = split ':',$time;
    return DateTime->new(year=>$y,month =>$M,   day=>$d,
                         hour=>$h,minute=>$m,second=>$s);
}

=item prev_by_tag <tag>

Return previous image when browsing by a given tag.

=cut

sub prev_by_tag {
    my  ($self,$tag)=@_;
    return $self->retrieve_previous('tags.tag'=>$tag, {order_by=>'taken DESC'})->next;
}

=item next_by_tag <tag>

Return next image object after this when browsing by the given tag.

=cut


sub next_by_tag {
    my  ($self,$tag)=@_;
    return $self->retrieve_next('tags.tag'=>$tag, {order_by=>'taken DESC'})->next;
}

=back

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;

