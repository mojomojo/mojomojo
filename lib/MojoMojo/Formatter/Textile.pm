package MojoMojo::Formatter::Textile;

use Text::Textile2;
use Text::SmartyPants;
my $textile = Text::Textile2->new(flavor=>"xhtml1",charset=>'utf-8');

sub format_content_order { 15 }
sub format_content {
    my ($self,$content,$c)=@_;
    # Let textile handle the rest
    $$content= $textile->process( $$content );
    $$content= Text::SmartyPants->process( $$content );
}
1;
