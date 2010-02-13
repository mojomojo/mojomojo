package MojoMojo::Formatter::File;

use strict;
use warnings;
use base qw/MojoMojo::Formatter/;
use File::Slurp;
use Encode;
use MojoMojo::Formatter::Dir;
use File::Basename;
use Module::Pluggable (
    search_path => ['MojoMojo::Formatter::File'],
    require => 1,
);
my $debug=0;

=head1 NAME

MojoMojo::Formatter::File - format file as XHTML

=head1 DESCRIPTION

This formatter will format the file argument as XHTML.

Usage: {{file TYPE filename}}


       {{file Text uploads/Files/test.txt}}


TYPE is a plugin present in Formatter/File/ directory.

Currently there are only three: Pod, DocBook and Text

The plugin TYPE format only the file which the extension match with 'can_format' method. Respectively pod, xml and txt for existing plugins.

For security reasons the path of file must be include in 'whitelisting' directory. You can use path_to(DIR) to describe directory in mojomojo.conf:


Just an example to view the test pod file t/var/files/test.pod :

Add this to mojomojo.conf :

<Formatter::Dir>
    prefix_url /myfiles
    whitelisting __path_to(t/var/files)__
</Formatter::Dir>

To see the pod content formatted in xhtml, write in the text area:

{{file Pod path_to(t/var/files)test.pod}}


To show recursively all files of directory see script/util/dir2mojomojo.pl script. To test it:

# start mojomojo

./script/mojomojo_server.pl

# run dir2mojomojo script

./script/util/dir2mojomojo.pl --dir=~/dev/mojomojo/t/var/files/ --url=/myfiles


Connect to http://server:3000/myfiles/


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


  # TODO : Add cache if file is not modified


  my @lines = split /\n/, $$content;

  $$content = "";
  my $is_image = 0;
  foreach my $line (@lines) {

    if ( $line =~ m|{{\s*file\s*(\w+)\s*(.*)}}.*| ) {
      my $plugin=$1; # DocBook, Pod, ...
      my $file=$2;   # File, Attachment

      $is_image = 1 if ( $plugin eq 'Image' );

      # use path_to(dir)/filename ?
      my $path_to = $c->path_to();
      $file =~ s/path_to\([\s|\/]*(\S*)[\s|\/]*\)\s*(\S*)\s*/${path_to}\/$1\/$2/;

      my $error;
      if ( $error = checkplugin($plugin, $file)){
        $$content .= $error;
      }
      if ( ! $error && ( $error = $self->checkfile($file, $c))){
        $$content .= $error;
      }

      if ( ! $error ){
	# format with plugin
        $$content .= $self->format($plugin,$file);
      }
    }
    else{
      # Image have not more content
      if ( ! $is_image ){
        $$content .= $line  . "\n";
      }
    }
  }
  return $content;
}


=item plugin

Return the plugin to use with file attachment

=cut

sub plugin {
  my $self     = shift;
  my $filename = shift;

  my ($name,$extension) = $filename =~ /(.*)\.(.*)/;

  foreach my $plugin ( plugins() ) {
    if ( $plugin->can('can_format') && $plugin->can_format($extension)){
      my $pluginname = $plugin;
      $pluginname =~ s/.*:://;

      return $pluginname;
    }
  }
}


=item format

Return the content formatted

=cut

sub format {
  my $self       = shift;
  my $pluginname = shift;
  my $file       = shift;

  my $error;
  if ( $error = checkplugin($pluginname)){
    return $error;
  }

  my $text = read_file( $file );
  utf8::decode($text);
  $text = encode('utf-8', $text);
  $text = Encode::decode('utf-8', $text);

  my $plugin = __PACKAGE__ . "::$pluginname";
  return $plugin->to_xhtml($text,$file) . "\n";
}


=item checkplugin

Return 0 if plugin exist

=cut
sub checkplugin{
  my $pluginname = shift;
  my $file       = shift;

  my $plugin = __PACKAGE__ . "::$pluginname";

  return 0 if $plugin->can('can_format');

  return "Can't find plugin for $file !";
}

=item checkfile

Directory must be include in whitelisting

=cut
sub checkfile{
  my ($self, $file, $c) = @_;

  return "Append a file after 'file'"
    if ( ! $file );

  return "You can't use '..' in the name of file"
    if ( $file =~ /\.\./ );

  my $dir = dirname($file);

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

  return "Can not read '$file' !\n"
    if ( ! -r $file );

  return 0;
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
