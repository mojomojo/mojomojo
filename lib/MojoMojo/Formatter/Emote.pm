package MojoMojo::Formatter::Emote;

use Text::Emoticon::MSN;
my $emoticon = Text::Emoticon::MSN->new(
      imgbase => "/.static/emote/");

sub format_content_order { 95 }
sub format_content {
    my ($self,$content,$base)=@_;
    # Let textile handle the rest
    $$content= $emoticon->filter( $$content );
}
1;
