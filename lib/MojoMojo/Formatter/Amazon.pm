package MojoMojo::Formatter::Amazon;

eval "use Net::Amazon";
my $eval_res=$@;
sub module_loaded { $eval_res ? 0 : 1 }


our $VERSION='0.01';

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
    my ($class,$content,$c)=@_;
    return unless $class->module_loaded;
    my @lines=split /\n/,$$content;
    my $pod;$$content="";
    foreach my $line (@lines) {
      if ($line =~ m/(\{\{?:http:\/\/(?:www\.){0,1}amazon\.com(?:\/.*){0,1}(?:\/dp\/|\/gp\/product\/))(.*?)(?:\/.*|$)\}\}/) { 
          my $item=$class->get($1,$c->config->{amazon_id});
          unless (ref($item)) {
              $$content.=$line."\n";
              next;
          }
          if ($2) {
            next unless $class->can($2);
            $$content.=$class->$2($item);
          } else {
            $$content.=$class->blurb($item);
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
  my ($class,$id,$amazon_id)=@_;
  #FIXME: devel token should be set in formatter config.
  my $amazon=Net::Amazon->new(token=>$amazon_id);
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
  my ($class,$property)=@_;
  return "!".$property->ImageUrlMedium.
  '!:http://www.amazon.com/exec/obidos/ASIN/'.$property->Asin."/feed-20\n";
}

=item blurb <property>

renders a full width blurb of the product, suitable for reviews and
such.

=cut

sub blurb {
  my ($class,$property)=@_;
  my $method=ref $property; 
  $method =~ s/.*:://;
  return "<div class=\"amazon\">!<".$property->ImageUrlSmall.
  '!:http://www.amazon.com/exec/obidos/ASIN/'.$property->Asin."/feed-20\n\n".
  "h1. ".$property->ProductName."\n\n".
  '"buy at amazon for '.$property->OurPrice.'":'.
  'http://www.amazon.com/exec/obidos/ASIN/'.$property->Asin."/feed-20\n\n".
  ($method && ($class->can($method) ? $class->$method($property) :"<br/>\n\n")).
  "</div>";
}

=item DVD <property>

Product information suitable for DVD movies.

=cut

sub DVD {
  my ($class,$property) = @_;
  return " -- ??".join(',',$property->directors).'?? ('.$property->year .")\n\n";
}

=item Book <property>

Product information suitable for books.

=cut

sub Book {
  my ($class,$property) = @_;
  return " -- ??".join(',',$property->authors).'?? ('.$property->year .")\n\n";
}

=item Music <property>

Product information suitable for music cds.

=cut

sub Music {
  my ($class,$property) = @_;
  return " -- ??".join(',',$property->artists).'?? ('.$property->year .")\n\n";
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
