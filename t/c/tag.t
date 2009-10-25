#!/usr/bin/perl -w
use Test::More tests => 16;

BEGIN{
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG}  = 0;
};
use_ok('Test::WWW::Mechanize::Catalyst', 'MojoMojo' );

my $mech = Test::WWW::Mechanize::Catalyst->new;
my $uniq = time();

# login as admin so we can add tags
ok $mech->get('/.login');
$mech->submit_form(
    fields => {
        login => 'admin',
        pass => 'admin',
    }
);
ok $mech->success, 'logged in as admin via form';

# add three 'foo' tags
ok $mech->get("/.jsrpc/tag/foo_$uniq");
ok $mech->get("/help.jsrpc/tag/foo_$uniq");
ok $mech->get("/admin.jsrpc/tag/foo_$uniq");

# add two 'bar' tags
ok $mech->get("/.jsrpc/tag/bar_$uniq");
ok $mech->get("/help.jsrpc/tag/bar_$uniq");

# add one 'baz' tags
ok $mech->get("/.jsrpc/tag/baz_$uniq");

# fetch tags page
ok $mech->get('/.tags'), "got tags page";
ok $mech->success, "page ok";
my $content = $mech->content;

# check that the tags appear in the cloud successfully
my %cloud_class;
my @lines = split (/\n/, $content);
foreach my $line (@lines) {
   # <span class="tagcloud0"><a href="http://localhost/.list/foo_1250070923">foo_1250070923</a></span>
  my ($level, $tag) = $line =~ /tagcloud(\d+).*\>(\w+)_${uniq}\</;
  next unless (defined $level && $tag);

  # fail if we doubled up on tags somehow
  fail "we already saw $tag" if defined $cloud_class{$tag};
  $cloud_class{$tag} = $level;
}

ok defined $cloud_class{foo}, 'saw foo tag';
ok defined $cloud_class{bar}, 'saw bar tag';
ok defined $cloud_class{baz}, 'saw baz tag';

ok $cloud_class{bar} > $cloud_class{baz}, 'bar > baz';
ok $cloud_class{foo} == $cloud_class{bar}, 'foo = bar';

