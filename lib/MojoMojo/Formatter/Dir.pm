package MojoMojo::Formatter::Dir;

use strict;
use warnings;
use base qw/MojoMojo::Formatter/;
use Path::Class ();

my $debug=0;

=head1 NAME

MojoMojo::Formatter::Dir - format local directory as XHTML

=head1 DESCRIPTION

This formatter will format the directory argument as XHTML.
Usage:

    {{dir directory}}


=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The File formatter runs on 92.

=cut

sub format_content_order { 92 }

=item format_content

Calls the formatter. Takes a ref to the content as well as the
context object.

=cut


sub format_content {
  my ( $self, $content, $c ) = @_;


  # TODO : Add cache if directory is not modified

  my @lines = split /\n/, $$content;

  $$content = "";
  foreach my $line (@lines) {

    if ( $line =~ m|<p>{{dir\s(.*)}}</p>| ) {
      my $dir=$1;

      if ( -d $dir ){
      # format with plugin
          $$content .= $self->format($dir, $c);
      }
      else {
          $$content .= "'$dir' is not a directory !\n";
      }
    }
    else{
      $$content .= $line  . "\n";
    }
  }
  return $content;
}



=item format

Return the content formatted

=cut

sub format {
  my $self = shift;
  my $dir  = shift;
  my $c    = shift;


  my $baseuri = $c->base_uri;

  my $path    = $c->stash->{path};

  return $self->to_xhtml($dir, $baseuri, $path);
}


=item format

Return Directory and files lists in xhtml

=cut
sub to_xhtml{
  my ($self,$dir, $baseuri, $path) = @_;


  my $pcdir = Path::Class::dir->new("$dir");

  my @subdirs;
  my @files;
  while (my $file = $pcdir->next) {
    next if ($file =~ m/^$dir\/?\.*$/ );

    if ( -d $file ){
      push @subdirs , $file;
    }
    else{
      push @files, $file;
    }
  }

  my $url = "${baseuri}${path}";

  my $ret = '<div id="dirs"><ul>';
  foreach my $d (@subdirs){
    next if ( ! -r $d);
    $d =~ s/$dir\///;
    $ret .= "<li><a href=\"$url/$d\">[$d]</a></li>";
  }
  $ret .= "</ul></div>\n";

  $ret .= '<div id="files"><ul>';
  foreach my $f (@files){
    next if ( ! -r $f);
    $f =~ s/$dir\///;
    $f =~ s/\./_/;
    $ret .= "<li><a href=\"$url/$f\">$f</a></li>";
  }
  $ret .= "</ul></div>\n";

  return $ret;
}



=back

=head1 SEE ALSO

L<MojoMojo>

=head1 AUTHORS

Daniel Brosseau <dab@catapulse.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
