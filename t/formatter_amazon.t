#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Data::Dumper::Concise;

BEGIN {
    use MojoMojo::Formatter::Amazon;

    plan skip_all => 'Requirements not installed for Amazon Formatter'
        unless MojoMojo::Formatter::Amazon->module_loaded;
    plan skip_all => 'Set AMAZON_TOKEN to your amazon API token (access key, not the secret one) to run Amazon tests'
        unless $ENV{AMAZON_TOKEN};
    plan skip_all => 'Set AMAZON_SECRET_KEY to your amazon API secret access key to run Amazon tests'
        unless $ENV{AMAZON_SECRET_KEY};
    plan tests => 8;
};

# Formatter basics
can_ok('MojoMojo::Formatter::Amazon', qw/format_content format_content_order/);

my $prop=MojoMojo::Formatter::Amazon->get(1558607013,$ENV{AMAZON_TOKEN}, $ENV{AMAZON_SECRET_KEY});
isa_ok($prop,'Net::Amazon::Property');
is($prop->title, 'Higher-Order Perl: Transforming Programs with Programs', 'object title');

SKIP: {
    eval { use Test::MockObject };
    skip ('Test::MockObject not installed', 3) if $@;
    my $o = Test::MockObject->new();
    $o->set_true(qw/artists authors directors year/);
    is(MojoMojo::Formatter::Amazon->DVD($o),  " -- ??1?? (1)\n\n", 'DVD formatter');
    is(MojoMojo::Formatter::Amazon->Book($o), " -- ??1?? (1)\n\n", 'Book formatter');
    is(MojoMojo::Formatter::Amazon->Music($o)," -- ??1?? (1)\n\n", 'Music formatter');
}

like(MojoMojo::Formatter::Amazon->blurb($prop), qr/^\<div class="amazon"/, 'blurb format' );
like(MojoMojo::Formatter::Amazon->small($prop), qr/^\!.+jpg\!.+ASIN/, 'small format' );
