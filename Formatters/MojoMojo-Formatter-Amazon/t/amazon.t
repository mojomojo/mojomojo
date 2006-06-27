use Test::More tests => 8;

# Formatter basics
use_ok('MojoMojo::Formatter::Amazon');
can_ok('MojoMojo::Formatter::Amazon', qw/format_content format_content_order/);

my $prop=MojoMojo::Formatter::Amazon->get(1558607013);
isa_ok($prop,'Net::Amazon::Property');

SKIP: {
	  eval { use Test::MockObject };
	  skip ('Test::MockObject not installed',3) if $@;
	  my $o=Test::MockObject->new();
	  $o->set_true(qw/artists authors directors year/);
	  is(MojoMojo::Formatter::Amazon->DVD($o),  " -- ??1?? (1)\n\n");
	  is(MojoMojo::Formatter::Amazon->Book($o), " -- ??1?? (1)\n\n");
	  is(MojoMojo::Formatter::Amazon->Music($o)," -- ??1?? (1)\n\n");
      }

like(MojoMojo::Formatter::Amazon->blurb($prop),qr/^\<div class="amazon"/ );
like(MojoMojo::Formatter::Amazon->small($prop),qr/$\!.+jpg\!.+ASIN/ );
