use warnings;
use LWP::Simple qw/getstore/;
use Text::Emoticon::MSN;
my @files = map {$Text::Emoticon::MSN::EmoticonMap{$_}}
            keys %Text::Emoticon::MSN::EmoticonMap;
for my $file (@files) {
   getstore("http://messenger.msn.com/Resource/emoticons/$file",$file);
}
