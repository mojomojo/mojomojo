use Test::More;


BEGIN {
    use MojoMojo::Formatter::Amazon;

    plan skip_all => 'Requirements not installed for Amazon Formatter'
        unless MojoMojo::Formatter::Amazon->module_loaded;
    plan skip_all => 'Set AMAZON_TOKEN to your amazon API token to run Amazon tests'
        unless $ENV{AMAZON_TOKEN};
    plan tests => 7;
};

# Formatter basics
can_ok('MojoMojo::Formatter::Amazon', qw/format_content format_content_order/);

my $prop=MojoMojo::Formatter::Amazon->get(1558607013,$ENV{AMAZON_TOKEN});
isa_ok($prop,'Net::Amazon::Property');

SKIP: {
    eval { use Test::MockObject };
    skip ('Test::MockObject not installed', 3) if $@;
    my $o = Test::MockObject->new();
    $o->set_true(qw/artists authors directors year/);
    is(MojoMojo::Formatter::Amazon->DVD($o),  " -- ??1?? (1)\n\n");
    is(MojoMojo::Formatter::Amazon->Book($o), " -- ??1?? (1)\n\n");
    is(MojoMojo::Formatter::Amazon->Music($o)," -- ??1?? (1)\n\n");
}

like(MojoMojo::Formatter::Amazon->blurb($prop), qr/^\<div class="amazon"/ );
like(MojoMojo::Formatter::Amazon->small($prop), qr/$\!.+jpg\!.+ASIN/ );
