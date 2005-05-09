package MojoMojo::Formatter::Textile;

use Text::Textile2;
my $textile = Text::Textile2->new(flavor=>"xhtml1");
#charset=>'utf-8');

sub format_content_order { 90 }
sub format_content {
    my ($self,$content,$base)=@_;
    # Let textile handle the rest
    $$content= $textile->process( $$content );
}
1;
