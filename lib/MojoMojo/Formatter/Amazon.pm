package MojoMojo::Formatter::Amazon;

use Net::Amazon;

sub format_content_order { 5}
sub format_content {
    my ($self,$content,$base)=@_;
    my @lines=split /\n/,$$content;
    my $pod;$$content="";
    warn "Running amazon formatter";
    foreach my $line (@lines) {
      if ($line =~ m/^\=amazon\s+(\w+)\s*$/) { 
         $$content.=$self->blurb($1);
      } else {
        $$content .=$line."\n";
      }
    }
    warn "content is now ".$$content;

}

sub blurb {
  my ($self,$id)=@_;
  warn "Formatting $id";
  my $amazon=Net::Amazon->new(token=>'D13HRR2OQKD1Y5');
  my $response=$amazon->search(asin=>$id);
  return "Unable to connect to amazon." unless $response->is_success;
  my ($property)=$response->properties;
  return "<div class=\"amazon\">!<".$property->ImageUrlSmall.
  '!:http://www.amazon.com/exec/obidos/ASIN/'.$id."/feed-20\n\n".
  "h1. ".$property->ProductName."\n\n".
  '"buy at amazon for '.$property->OurPrice.'":'.
  'http://www.amazon.com/exec/obidos/ASIN/'.$id."/feed-20".
  ( ref $property eq 'Net::Amazon::Property::DVD' ?
  "-- ??".join(',',$property->directors).'?? ('.$property->year .')'
  :
  " -- ??".join(',',$property->authors).'?? ('.$property->year .")\n\n</div>");

}

1;
