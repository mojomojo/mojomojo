package MojoMojo::Formatter::Wiki;

sub format_content_order { 30 }
sub format_content {
    my ($self,$content,$base)=@_;
    # Extract wikiwords, avoiding escaped and part of urls
    $$content =~ s{(?<![\?\\\/\[])(\b[A-Z][a-z]+[A-Z]\w*)}
                 {MojoMojo->wikiword($1,$base)}ge;
    # Remove escapes
    $$content =~ s{\\(\b[A-Z][a-z]+[A-Z]\w*)}
	         {$1}g;
    # do explicit links, replace spaces with +
    $$content =~ s{\[\[\s*([^\]]+)\s*\]\]}
		 {MojoMojo->wikiword(MojoMojo->fixw($1),$base)}ge;
}
1;
