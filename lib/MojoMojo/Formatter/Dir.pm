package MojoMojo::Formatter::Dir;

use strict;
use warnings;
use base qw/MojoMojo::Formatter/;
use Path::Class ();
use MojoMojo::Formatter::File::Image;

my $debug=0;

=head1 NAME

MojoMojo::Formatter::Dir - format local directory as XHTML

=head1 DESCRIPTION

This formatter will format the directory argument as XHTML.
Usage:

    {{dir directory exclude=exclude_regex}}


For security reasons the directory must be include in 'whitelisting'. You can use path_to(DIR) to describe directory in mojomojo.conf:

<Formatter::Dir>
    prefix_url /myfiles
    whitelisting __path_to(uploads)__
</Formatter::Dir>


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

    if ( $line =~ m|<p>{{dir\s*(\S*)\s*(\S*)}}</p>| ) {
      my $dir     = $1;
      my $exclude = $2;

      $exclude =~ s/exclude=//;

      my $path_to = $c->path_to();
      # use path_to(dir) ?
      $dir =~ s/path_to\((\S*)\)/${path_to}\/$1/;
      $dir =~ s/\/$//;

      my $error;
      if ( $error = $self->checkdir($dir, $c)){
        $$content .= $error;
      }

      if ( ! $error ){
        # format with plugin
        $$content .= $self->format($dir, $exclude, $c);
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
  my $self    = shift;
  my $dir     = shift;
  my $exclude = shift;
  my $c       = shift;

  my $baseuri = $c->base_uri;
  my $path    = $c->stash->{path};

  return $self->to_xhtml($dir, $exclude, $baseuri, $path);
}


=item format

Return Directory and files lists in xhtml

=cut
sub to_xhtml{
  my ($self, $dir, $exclude, $baseuri, $path) = @_;

  my $pcdir = Path::Class::dir->new("$dir");

  my @subdirs;
  my @files;
  while (my $file = $pcdir->next) {
    next if ($file =~ m/^$dir\/?\.*$/ );
    next if ( "$exclude" && grep(/$exclude/, $file ));

    if ( -d $file ){
      push @subdirs , $file;
    }
    else{
      push @files, $file;
    }
  }

  #-mxh Sort the array for predictable ordering in formatter_dir.t
  @subdirs = sort @subdirs;
  @files   = sort @files;

  $path =~ s/^\///;
  $path =~ s/\/$//;
  my $url = "${baseuri}/${path}";

  my $ret;
  if ( $subdirs[0] ){
    $ret = '<div id="dirs"><ul>';
    $ret .= "<li><a href=\"$url\">..</a></li>" if ( $url =! "/$path");
    foreach my $d (@subdirs){
      next if ( ! -r $d);
      $d =~ s/$dir\///;

      $ret .= "<li><a href=\"$url/$path/$d\">[$d]</a></li>";
    }
    $ret .= "</ul></div>\n";
  }

  if ( $files[0] ){
    $ret .= '<div id="files"><ul>';
    foreach my $f (@files){
      next if ( ! -r $f);
      $f =~ s/$dir\///;
      $f =~ s/^\///;

      # Use Image controller if it is a image
      $f =~ /.*\.(.*)$/;

      # replace dot with '_' if it's not a image
      $f =~ s/\./_/
        if ( ! MojoMojo::Formatter::File::Image->can_format($1) );

      $ret .= "<li><a href=\"$url/$f\">$f</a></li>";
    }
    $ret .= "</ul></div>\n";
  }
  return $ret;
}


=item checkdir

Directory must be include in whitelisting

=cut
sub checkdir{
  my ($self,$dir,$c) = @_;

  return "Append a directory after 'dir'"
    if ( ! $dir );

  return "You can't use '..' in the name of directory"
    if ( $dir =~ /\.\./ );

  my $confwl = $c->config->{'Formatter::Dir'}{whitelisting};
  my @whitelist = ref $confwl eq 'ARRAY' ?
                       @$confwl : ( $confwl );
  # Add '/' if not exist at the end of whitelist directories
  my @wl =  map { $_ . '/' }            # Add '/'
                  ( map{ /(\S*[^\/])/ } # Delete '/' if exist
                    @whitelist );

  # Add '/' if not exist at the end of dierctory
  $dir =~ s|^(\S*[^/])$|$1\/|;

  # if $dir is not include in whitelisting
  if ( ! map ( $dir =~ m|^$_| , @wl) ){
    return "Directory '$dir' must be include in whitelisting ! see Formatter::Dir:whitelisting in mojomojo.conf"
  }


  return "'$dir' is not a directory !\n"
    if ( ! -d $dir );

  return 0;
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
