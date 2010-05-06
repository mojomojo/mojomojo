#!/usr/bin/env perl
use Test::More;

eval 'use Test::NoTabs';
if ($@) {
     plan skip_all => "need Test::NoTabs to run this test\n";
}
else {
    all_perl_files_ok('lib', 'script', 't');
    done_testing();
}


