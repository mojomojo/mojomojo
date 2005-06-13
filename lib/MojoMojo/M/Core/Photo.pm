package MojoMojo::M::Core::Photo;

use Image::EXIF;

__PACKAGE__->has_a(
    taken => 'DateTime',
    inflate => sub {
        DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);

__PACKAGE__->set_sql('page', <<"");
SELECT __ESSENTIAL__ 
FROM __TABLE__,attachment 
wHERE __TABLE__.id=attachment.id AND attachment.page=? 


__PACKAGE__->might_have('attachment' => 'MojoMojo::M::Core::Attachment', qw/uploaded/);

sub create_from_attachment {
    my ($class,$attachment) = @_;
    my $self=$class->create({
        id=>$attachment->id,
        name=>$attachment->name
    });
}

sub others_tags {
    my ( $self, $user ) = @_;
    my (@tags) = MojoMojo::M::Core::Tag->search_others_photo_tags( $self->id, $user );
    return @tags;
}

sub user_tags {
    my ( $self, $user ) = @_;
    my (@tags) =
      MojoMojo::M::Core::Tag->search( person => $user, photo => $self );
    return @tags;
}

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

sub exif2datetime {
    my ($self,$datetime)=@_;
    return undef unless $datetime;
    my ($date,$time)=split(' ',$datetime);
    my ($y,$M,$d) = split ':',$date;
    my ($h,$m,$s) = split ':',$time;
    return DateTime->new(year=>$y,month =>$M,   day=>$d,
                         hour=>$h,minute=>$m,second=>$s);
}

sub prev_by_tag {
    my  ($self,$tag)=@_;
    return $self->retrieve_previous('tags.tag'=>$tag, {order_by=>'taken DESC'})->next;
}

sub next_by_tag {
    my  ($self,$tag)=@_;
    return $self->retrieve_next('tags.tag'=>$tag, {order_by=>'taken DESC'})->next;
}

1;

