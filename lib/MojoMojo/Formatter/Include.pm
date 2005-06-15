package MojoMojo::Formatter::Include;

use LWP::Simple;
use URI::Fetch;
sub format_content_order { 6 }
sub format_content {
    my ($self,$content,$c)=@_;

    my @lines=split /\n/,$$content;
    my $pod;$$content="";
    foreach my $line (@lines) {
	if ($line =~ m/^=(http\:\/\/\S+)$/) { 
         		$$content.=MojoMojo::Formatter::Include->include($c,$1);
	} else {
	    $$content .=$line."\n";	
	}
    }
}

sub include {
    my ($self,$c,$url)=@_;
    my $res=URI::Fetch->fetch($url,Cache=>$c->cache);
    return $res->content if defined $res;
    return "Could not retrieve $url .\n";
}



1;
