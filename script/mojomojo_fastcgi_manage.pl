#!/usr/bin/perl

eval { use FCGI::Engine::Manager };
if ($@) { die "You need to install FCGI::Engine to run this script\n"; }

my $m =
  FCGI::Engine::Manager->new( conf => 'script/mojomojo_fastcgi_manage.yml' );

my ( $command, $server_name ) = @ARGV;
$m->start($server_name)        if $command eq 'start';
$m->stop($server_name)         if $command eq 'stop';
$m->restart($server_name)      if $command eq 'restart';
$m->graceful($server_name)     if $command eq 'graceful';
print $m->status($server_name) if $command eq 'status';

=head1 Usage

NOTE: Run this script from the parent directory so path to configuration is correct.

  perl script/mojomojo_fastcgi_manage.pl start
  perl script/mojomojo_fastcgi_manage.pl stop
  perl script/mojomojo_fastcgi_manage.pl restart mojomojo.server 
  

=head1 Web Server Configuration

=head2 Apache

In an apache conf file:

FastCgiExternalServer /tmp/mojomojo.fcgi -socket /tmp/mojomojo.socket
Alias /wiki /tmp/mojomojo.fcgi/
