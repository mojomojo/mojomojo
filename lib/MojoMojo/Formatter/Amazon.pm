package MojoMojo::Formatter::Amazon;

use Net::Amazon;

sub format_content_order { 5}
sub format_content {
    my ($self,$content,$c)=@_;
    my @lines=split /\n/,$$content;
    my $pod;$$content="";
    foreach my $line (@lines) {
      if ($line =~ m{^\=http\S+amazon\S+/(?:-|ASIN)/([^/]+)/(?:.+\s+(\w+))?}) { 
          warn "line is $line";
          warn "action is".$2;
          my $item=$self->get($1);
          unless (ref($item)) {
              $$content.=$item."\n";
              next;
          }
          if ($2) {
            next unless $self->can($2);
            $$content.=$self->$2($item);
          } else {
            $$content.=$self->blurb($item);
          }
      } else {
        $$content .=$line."\n";
      }
    }

}

sub get {
  my ($self,$id)=@_;
  my $amazon=Net::Amazon->new(token=>'D13HRR2OQKD1Y5');
  my $response=$amazon->search(asin=>$id);
  return "Unable to connect to amazon." unless $response->is_success;
  ($property)=$response->properties;
  return "No property object" unless $property;
  return $property;
}


sub small {
  my ($self,$property)=@_;
  return "!".$property->ImageUrlMedium.
  '!:http://www.amazon.com/exec/obidos/ASIN/'.$id."/feed-20\n";
}

sub blurb {
  my ($self,$property)=@_;
  my $method=ref $property; 
  $method =~ s/.*:://;
  return "<div class=\"amazon\">!<".$property->ImageUrlSmall.
  '!:http://www.amazon.com/exec/obidos/ASIN/'.$id."/feed-20\n\n".
  "h1. ".$property->ProductName."\n\n".
  '"buy at amazon for '.$property->OurPrice.'":'.
  'http://www.amazon.com/exec/obidos/ASIN/'.$id."/feed-20\n\n".
  ($method && $self->can($method) && $self->$method($property));
}

sub DVD {
  my ($self,$property) = @_;
  return "-- ??".join(',',$property->directors).'?? ('.$property->year .')';
}

sub Book {
  my ($self,$property) = @_;
  return " -- ??".join(',',$property->authors).'?? ('.$property->year .")\n\n</div>";
}

sub Music {
  my ($self,$property) = @_;
  return " -- ??".join(',',$property->artists).'?? ('.$property->year .")\n\n</div>";
}

1;
