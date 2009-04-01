package MojoMojo::Formatter::File;

use strict;
use warnings;
use base qw/MojoMojo::Formatter/;
use File::Slurp;
use Module::Pluggable (
    search_path => ['MojoMojo::Formatter::File'],
);
my $debug=0;

=head1 NAME

MojoMojo::Formatter::File - format file as xhtml

=head1 DESCRIPTION

This formatter will format file as xhtml 


=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Pod formatter runs on 10

=cut

sub format_content_order { 96 }

=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut


 sub format_content {
   my ( $self, $content, $c ) = @_;


   # XXX : Add cache if file is not modified


   my @lines = split /\n/, $$content;

   $$content = "";
   my $findplug;
   foreach my $line (@lines) {

     if ( $line =~ m|<p>=file\s(\w+)\s*(.*)</p>| ) {
       my $type=$1; # DocBook, Pod, ...
       my $file=$2; # Attachment

       return "$file doesn't exist !\n" if ( ! -e $file);

       # format with plugin
       $$content .= $self->format($type,$file);

     }
     else{
       $$content .= $line  . "\n";
     }
   }
   return $content;
}


sub format {
  my $self = shift;
  my $type = shift;
  my $file = shift;


  my $result;
  my $findplug;
  foreach my $plugin ( plugins() ) {
    if ( $plugin->can('can_format') && $plugin->can_format($type) ) {
      my $text = read_file( $file );# or die "Can't read $file : $!\n"; ;
      $result = $plugin->to_xhtml($text) . "\n";
      $findplug=1;
      last;
    }
  }
  return "Can't find plugin " . __PACKAGE__ . "::$type" 
    . " for  file '$file'" if ! $findplug;
  return $result;
}

=back

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>

=head1 AUTHORS

Daniel Brosseau <dab@catapulse.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
