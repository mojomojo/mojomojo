#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 19;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
};

use_ok( 'Catalyst::Test', 'MojoMojo' );
use_ok( 'Test::WWW::Mechanize::Catalyst', 'MojoMojo' );
my $m = Test::WWW::Mechanize::Catalyst->new;

my(undef, $c) = ctx_request('/');

my $anon_login = $c->pref('anonymous_user');
my $anonymous = $c->model('DBIC::Person') ->search( {login => $anon_login} )->first;

# Test check_permissions on page ------------------------------------
# Anonymous on '/'
check_perms('/', $anonymous, [qw/create attachment view edit/], [ 'delete' ]);

# Anonymous on subpage /foo/bar
check_perms('/foo/bar', $anonymous, [qw/create attachment view edit/], [ 'delete' ]);


my $admin = $c->model('DBIC::Person') ->search( {login => 'admin'} )->first;

# Admin on '/'
check_perms('/', $admin, [qw/create attachment view edit delete/], []);

# Add person 'test' (role User)
use lib qw(t/lib);
use MojoMojoTestSchema;
my $schema = MojoMojoTestSchema->get_schema;
ok(my $usertest = $schema->resultset('Person')->create(
        {
         active => 1,
         login => 'test',
         email => 'test@test.org',
         name => 'Gaston Lagaffe',
         pass => 'test',
        }
    ), "User test is created");

# Person test is a User
ok($schema->resultset('RoleMember')->create(
        {
         role   => 2,
         person => 3,
         admin  => 0,
        }
    ), "test is a User");

# Create page /foo and /foo/bar
my $person = $schema->resultset('Person')->find( 1 );
my ($child_path_pages, $child_proto_pages) = $schema->resultset('Page')->path_pages('/foo/bar');
ok($schema->resultset('Page')->create_path_pages(
    path_pages => $child_path_pages,
    proto_pages => $child_proto_pages,
    creator => $person->id,
), "Create page /foo and /foo/bar");



 # # User have no permission on /foo only
  ok( $schema->resultset('PathPermissions')->create(
          {
           path                => '/foo',
           role                => 2,
           apply_to_subpages   => 'no',
           create_allowed      => 'no',
           delete_allowed      => 'no',
           edit_allowed        => 'no',
           view_allowed        => 'no',
           attachment_allowed  => 'no',
          }
      ), "User test have no permission on '/foo'");

  ok( $schema->resultset('PathPermissions')->create(
          {
           path                => '/foo',
           role                => 2,
           apply_to_subpages   => 'yes',
           create_allowed      => 'yes',
           delete_allowed      => 'yes',
           edit_allowed        => 'yes',
           view_allowed        => 'yes',
           attachment_allowed  => 'yes',
          }
      ), "User test have all permissions on subpages '/foo'");

# Admin on '/'
check_perms('/foo', $usertest, [qw/create attachment view edit delete/], []);


sub check_perms{
  my $path    = shift;
  my $user    = shift;
  my $allowed = shift;
  my $denied  = shift;

  my $username = $user->login;

  my $perms = $c->check_permissions( $path,  $user );
  use Data::Dumper;
  print Dumper($perms);

  foreach my $p (@$allowed){
    is($$perms{$p}, 1, "$username can $p on $path");
  }
  foreach my $p (@$denied){
    is($$perms{$p}, 0, "$username can not $p on $path");
  }
}



sub login{
   my $mech  = shift;
   my $login = shift;
   my $pass  = shift;

   $mech->post('/.login', {
                           login => $login,
                           pass  => $pass 
                          });
   ok $mech->success, "logging in as $login"
 }

END{
  # Delete user test
  $schema->resultset('Person')->find(3)->delete;
  $schema->resultset('PathPermissions')->search({ path => '/foo'})->delete;

  #$m->get( '/foo/bar.delete');
  #$m->get( '/foo.delete');

  $schema->resultset('Page')->search({ name => 'bar'})->delete;
  $schema->resultset('Page')->search({ name => 'foo'})->delete;
  $schema->resultset('PageVersion')->search({ name => 'bar'})->delete;
  $schema->resultset('PageVersion')->search({ name => 'foo'})->delete;
}

# use_ok( 'Test::WWW::Mechanize::Catalyst', 'MojoMojo' );

# my $m = Test::WWW::Mechanize::Catalyst->new;
# my $user = 'anonymous';

# is_denied('/.admin');

# is_allowed('/');

# #login($m, 'admin', 'admin');
# ## Make sure Logged out
# #$mech->get_ok('/.logout');




 
# sub is_denied {
#     my $path = shift;
#     $m->get("$path");
#     $m->content_contains('Error', "$user is denied to '$path'");
#     #is($m->res->code, '401', "$user is denied to '$path'");
# }

# sub is_allowed {
#     my $path = shift;
#     $m->get_ok("$path");
# }


