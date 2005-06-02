package MojoMojo::Formatter::Emote;

use Text::Emoticon::MSN;

sub format_content_order { 95 }
sub format_content {
    my ($self,$content,$c)=@_;
    my $emoticon = Text::Emoticon::MSN->new(
      imgbase => $c->req->base.'/.static/emote',
      strict => 1);
    # Let textile handle the rest
    $$content= $emoticon->filter( $$content );
}
1;
