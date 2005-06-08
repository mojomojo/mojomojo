package MojoMojo::Formatter::RSS;

use LWP::Simple;

use URI::Fetch;
use XML::Feed;
sub format_content_order { 4 }

sub format_content {
    my ($self,$content,$c)=@_;
    my @lines=split /\n/,$$content;
    undef $$content;
    my $result;
    foreach my $line (@lines) {
        if ($line =~ m/^=(feed.+)(\s+\d+)?\s*$/) { 
            $$content.=MojoMojo::Formatter::RSS->include_rss($c,$1,$2);
        } else {
            $$content .=$line."\n";	
        }
   }   
}

sub include_rss {
    my ($self,$c,$url,$entries)=@_;
    $entries ||= 1;
    $url =~ s/^feed/http/;
    my $result=URI::Fetch->fetch($url,Cache=>$c->cache)->content;
    my $feed=XML::Feed->parse(\$result) or
        return "Could not retrieve $url .\n";
    my $count=0;
    my $content='';
    foreach my $entry ($feed->entries){
        $count++;
        $content.='<div class="feed">'
        .'<h3><a href="'.$entry->link.'">'.
        $entry->title.'</a></h3>'
        .$entry->content->body."</div>\n";
        return $content if $count==$entries;
    }
    return $content;
}



1;
