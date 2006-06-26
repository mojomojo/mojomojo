package MojoMojo::Schema::Content;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/DateTime::Epoch PK::Auto Core/);
__PACKAGE__->table("content");
__PACKAGE__->add_columns(
  "page",
  "version",
  "creator",
  "created" => {data_type=>'bigint',epoch=>'ctime'},
  "status",
  "release_date" => {data_type=>'bigint',epoch=>'1'},
  "remove_date"  => {data_type=>'bigint',epoch=>'1'},
  "type",
  "abstract",
  "comments",
  "body",
  "precompiled",
);
__PACKAGE__->set_primary_key("page", "version");
__PACKAGE__->has_many(
  "pages",
  "Page",
  {
    "foreign.content_version" => "self.version",
    "foreign.id" => "self.page",
  },
);
__PACKAGE__->has_many(
  "page_version_page_content_version_firsts",
  "PageVersion",
  {
    "foreign.content_version_first" => "self.version",
    "foreign.page" => "self.page",
  },
);
__PACKAGE__->has_many(
  "page_version_page_content_version_lasts",
  "PageVersion",
  {
    "foreign.content_version_last" => "self.version",
    "foreign.page" => "self.page",
  },
);
__PACKAGE__->belongs_to("creator", "Person", { id => "creator" });
__PACKAGE__->belongs_to("page", "Page", { id => "page" });

sub highlight {
    my ( $self, $c ) = @_;
    my $this_content = $self->formatted($c);

    # FIXME: This may return undef. What do we do then?
    my $previous_content = (
        defined $self->previous
        ? $self->previous->formatted($c)
        : $this_content );
    my $this = [ split /\n\n/,                  $this_content ];
    my $prev = [ split /\n\n/,                  $previous_content ];
    my @diff = Algorithm::Diff::sdiff( $prev, $this );
    my $diff;
    my $hi = 0;
    for my $line (@diff) {
        $hi++;
        if ( $$line[0] eq "+" ) {
            $diff .= qq(<div id="hi$hi" class="fade">) . $$line[2] . "</div>";
        }
        elsif ( $$line[0] eq "c" ) {
            $diff .= qq(<div id="hi$hi"class="fade">) . $$line[2] . "</div>";
        } elsif ( $$line[0] eq "-" ) { }
        else { $diff .= $$line[1] }
    }
    return $diff;
}



1;

