package MojoMojo::Formatter::File;

use strict;
use warnings;
use parent qw/MojoMojo::Formatter/;
use File::Slurp;
use Module::Pluggable (
    search_path => ['MojoMojo::Formatter::File'],
    require => 1,
);
my $debug=0;

=head1 NAME

MojoMojo::Formatter::File - format file as XHTML

=head1 DESCRIPTION

This formatter will format the file argument as XHTML. Usage:

    =file filename


=head1 METHODS

=head2 format_content_order

Format order can be 1-99. The File formatter runs on 92.

=cut

sub format_content_order { 92 }

=head2 format_content

Calls the formatter. Takes a ref to the content as well as the
context object.

=cut


sub format_content {
  my ( $self, $content, $c ) = @_;


  # TODO : Add cache if file is not modified


  my @lines = split /\n/, $$content;

  $$content = "";
  foreach my $line (@lines) {

    if ( $line =~ m|<p>{{file\s(\w+)\s*(.*)}}</p>| ) {
      my $plugin=$1; # DocBook, Pod, ...
      my $file=$2; # Attachment

      if ( -f $file ){
      # format with plugin
          $$content .= $self->format($plugin,$file);
      }
      else {
          $$content .= "Can not read '$file' !\n";
      }
    }
    else{
      $$content .= $line  . "\n";
    }
  }
  return $content;
}


=head2 plugin

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


=head2 format

Return the content formatted

=cut

sub format {
  my $self       = shift;
  my $pluginname = shift;
  my $file       = shift;

  my $plugin = __PACKAGE__ . "::$pluginname";

  if ( $plugin->can('can_format') ) {

    my $text = read_file( $file );
    return $plugin->to_xhtml($text) . "\n";
  }
  else{
    return "Can't find plugin '$plugin' for file '$file'";
  }
}

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered>

=head1 AUTHORS

Daniel Brosseau <dab@catapulse.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
