package MojoMojo::Formatter::RSS;

use LWP::Simple;
use XML::Feed;
sub format_content_order { 4 }

sub format_content {
    my ($self,$content,$c)=@_;
    my @lines=split /\n/,$$content;
    undef $$content;
    foreach my $line (@lines) {
                if ($line =~ m/^=(feed.+)(\s+\d+)?\s*$/) { 
            $$content.=MojoMojo::Formatter::RSS->include_rss($1,$2);
        } elsif ($line =~ m/^=feed/) {
            $$content .= $line."did not match.\n";
        } else {
            $$content .=$line."\n";	
        }
   }   
}

sub include_rss {
    my ($self,$url,$entries)=@_;
    $entries ||= 1;
    $url =~ s/^feed/http/;
    my $feed=XML::Feed->parse(URI->new($url)) or
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
