package MojoMojo::Formatter::Include;

use LWP::Simple;
sub format_content_order { 6 }
sub format_content {
    my ($self,$content,$base)=@_;

    my @lines=split /\n/,$$content;
    my $pod;$$content="";
    foreach my $line (@lines) {
	if ($line =~ m/^=(http\:\/\/\S+)$/) { 
         		$$content.=MojoMojo::Formatter::Include->include($1);
	} else {
	    $$content .=$line."\n";	
	}
    }
}

sub include {
    my ($self,$url)=@_;
    my $content=get($url);
    return $content if defined $content;
    return "Could not retrieve $url .\n";
}



1;
