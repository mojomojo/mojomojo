#!/usr/bin/env perl
use strict;
use warnings;
use Locale::PO;
use JSON::Syck;
$JSON::Syck::ImplicitUnicode = 1;
use IO::All;
use HTML::Entities;
use Encode;
use utf8;
use encoding 'utf8';

sub po2json {
    my ($in, $out) = @_;
    my $po = new Locale::PO();
    my $po_href = Locale::PO->load_file_ashash( $in );
    my %h;
    for my $msgid (keys %$po_href) {
        my ($k, $v) = map {
            my $s = $po->dequote($_);
            $s =~ s/(.)/encode_entities($1)/ge;
            $s
           } ($msgid, $po_href->{$msgid}->{msgstr});
        next unless $k && $v;
        $h{ $k } = $v;
    }
    io($out)->assert->print( JSON::Syck::Dump(\%h) )
}

if(! $ARGV[1] ) {
    die <<USAGE
Usage: $0 po_file json_file
USAGE
}

po2json(@ARGV);


