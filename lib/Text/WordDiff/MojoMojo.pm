package Text::WordDiff::MojoMojo;

# based on Text::WordDiff, but with many differences.

use strict;
use HTML::Entities;
use base qw(Exporter);
use Algorithm::Diff;

our @EXPORT = qw(word_diff);

sub split_html_str {
  my $str = shift;
  my @array;
  my @tags = split qr/(?:(?<=>)|(?=<))/msx, $str;
  foreach(@tags) {
    if(length($_) == 0) {
      next;
    }
    if($_ =~ /^</) {
      push @array, $_;
    } else {
      my $tmp_str = decode_entities($_);
      my @tmp_arr = split qr/(?:(?<!\p{IsWord})(?=\p{IsWord})|(?<!\p{IsSpace})(?=\p{IsSpace})|(?<!\p{IsPunct})(?=\p{IsPunct}))/msx, $tmp_str;
      @tmp_arr = map {$_ = encode_entities($_)} @tmp_arr;
      push @array, @tmp_arr;
    }
  }
  return @array;
}

sub word_diff {
  my @args = map {my @a = split_html_str($_); \@a;} @_;
  my $diff = Algorithm::Diff->new(@args);
  my $out = "";
  while ($diff->Next) {
    if (my @same = $diff->Same) {
      $out .= (join '', @same);
    }
    else {
      if (my @del = $diff->Items(1)) {
        $out .= '<del>' . (join '', @del) . '</del>';
      }
      if (my @ins = $diff->Items(2)) {
        $out .= '<ins>' . (join '', @ins) . '</ins>';
      }
    }
  }
  return $out;
}

1;
