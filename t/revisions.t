#!/usr/bin/perl -w
# Revision tests
use Test::More tests => 2;
use Test::Differences;

my $original_formatter;    # current formatter set up in mojomojo.db
my $c;                     # the Catalyst object of this live server
my $test;                  # test description
my $body;                  # the MojoMojo page body as fetched by get()

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG}  = 0;
    use_ok 'Catalyst::Test', 'MojoMojo';
}


#-------------------------------------------------------------------------------
$test = "specific error message: no revision x for x";
$body = get('/?rev=9999');
like $body, qr'No revision 9999 for <span class="error_detail"><a href="/">/</a></span>', $test;
