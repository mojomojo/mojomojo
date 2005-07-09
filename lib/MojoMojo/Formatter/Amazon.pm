package MojoMojo::Formatter::Amazon;

use Net::Amazon;


=head1 NAME

MojoMojo::Formatter::Amazon - Include Amazon objects on your page.

=head1 DESCRIPTION

This is an url formatter. it takes urls containing amazon and 
/-/ or /ASIN/ and make a pretty formatted link to that object 
in the amazon web store.

It automatically handles books/movies/dvds and formats them as
apropriate. You can also pass 'small' as a parameter after the 
url, and it will make a thumb link instead of a blurb.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Amazon formatter runs on 5

=cut

sub format_content_order { 5}

=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ($self,$content,$c)=@_;
    my @lines=split /\n/,$$content;
    my $pod;$$content="";
    foreach my $line (@lines) {
      if ($line =~ m{^\=http\S+amazon\S+/(?:-|ASIN)/([^/]+)/(?:.+\s+(\w+))?}) { 
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

=item get <asin>

Connects to amazon and retrieves a L<Net::Amazon> object 
based on the supplied ASIN number

=cut

sub get {
  my ($self,$id)=@_;
  #FIXME: devel token should be set in formatter config.
  my $amazon=Net::Amazon->new(token=>'D13HRR2OQKD1Y5');
  my $response=$amazon->search(asin=>$id);
  return "Unable to connect to amazon." unless $response->is_success;
  ($property)=$response->properties;
  return "No property object" unless $property;
  return $property;
}

=item small <property>

renders a small version of the formatter.

=cut

sub small {
  my ($self,$property)=@_;
  return "!".$property->ImageUrlMedium.
  '!:http://www.amazon.com/exec/obidos/ASIN/'.$id."/feed-20\n";
}

=item blurb <property>

renders a full width blurb of the product, suitable for reviews and
such.

=cut

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

=item DVD <property>

Product information suitable for DVD movies.

=cut

sub DVD {
  my ($self,$property) = @_;
  return "-- ??".join(',',$property->directors).'?? ('.$property->year .')';
}

=item Book <property>

Product information suitable for books.

=cut

sub Book {
  my ($self,$property) = @_;
  return " -- ??".join(',',$property->authors).'?? ('.$property->year .")\n\n</div>";
}

=item Music <property>

Product information suitable for music cds.

=cut

sub Music {
  my ($self,$property) = @_;
  return " -- ??".join(',',$property->artists).'?? ('.$property->year .")\n\n</div>";
}

=back

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>,L<Net::Amazon>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
