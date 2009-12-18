package MojoMojo::WordDiff;

# based on Text::WordDiff, but with many differences.

use strict;
use HTML::Entities;
use base qw(Exporter);
use Algorithm::Diff;

our @EXPORT = qw(word_diff);

sub _split_html_str {
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
  my @args = map {my @a = _split_html_str($_); \@a;} @_;
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

=head1 NAME

MojoMojo::WordDiff - generate inline word-based HTML diffs

=head1 DESCRIPTION

Creates a word by word line diff for lines that are changed.

=head1 METHODS

=head2 word_diff

Takes two conflicting lines, and returns a line with the diff in HTML.

=head2 

=cut

1;
