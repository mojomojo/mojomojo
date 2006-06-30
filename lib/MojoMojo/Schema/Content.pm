package MojoMojo::Schema::Content;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';

use DateTime::Format::Mail;

use Algorithm::Diff;

__PACKAGE__->load_components(qw/ResultSetManager DateTime::Epoch UTF8Columns PK::Auto Core/);
__PACKAGE__->table("content");
__PACKAGE__->add_columns(
  "page",
  "version",
  "creator",
  "status",
  "created",      => {data_type=>'bigint',epoch=>'ctime'},
  "release_date", => {data_type=>'bigint',epoch=>'1'},
  "remove_date",  => {data_type=>'bigint',epoch=>'1'},
  "type",
  "abstract",
  "comments",
  "body",
  "precompiled",
);
__PACKAGE__->utf8_columns(qw/body precompiled/);
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

=item formatted_diff <context> <old_content>

Compare this content version to <old_content>, using
Algorithm::Diff. Show added lines in with diffins css class
and deleted with diffdel css class.

=cut

sub formatted_diff {
my ( $self, $c, $to ) = @_;
my $this = [ split /\n\n/, $self->formatted($c) ];
my $prev = [ split /\n\n/, $to->formatted($c) ];
my @diff = Algorithm::Diff::sdiff( $prev, $this );
my $diff;
for my $line (@diff) {
    if ( $$line[0] eq "+" ) {
	$diff .= qq(<div class="diffins">) . $$line[2] . "</div>";
    }
    elsif ( $$line[0] eq "-" ) {
	$diff .= qq(<div class="diffdel">) . $$line[1] . "</div>";
    }
    elsif ( $$line[0] eq "c" ) {
	$diff .= qq(<div class="diffdel">) . $$line[1] . "</div>";
	$diff .= qq(<div class="diffins">) . $$line[2] . "</div>";
    }
    elsif ( $$line[0] eq "u" ) { $diff .= $$line[1] }
    else { $diff .= "Unknown operator " . $$line[0] }
}
return $diff;
}

=item formatted [<content>]

Return content after being run through MojoMojo::Formatter::* ,
either own content or passed <content>

=cut

sub format_content : ResultSet {
my ( $self, $c, $content,$page ) = @_;
$c       ||= MojoMojo->instance();
warn "Starting formatting";
$Devel::Trace::TRACE=1;
MojoMojo->call_plugins( "format_content", \$content, $c, $page) if ($content);
$Devel::Trace::TRACE=0;
warn "Done formatting";
return $content;
}
sub formatted {
my ( $self, $c) = @_;
    my $result=$self->result_source->resultset->format_content($c,$self->body,$self);
    return $result;
}

# create_proto: create a "proto content version" that may
# be the basis for a new revision

=item create_proto <page>

Create a content prototype object, as the basis for a new revision.

=cut

sub create_proto : ResultSet {
my ( $class, $page ) = @_;
my %proto_content;
my @columns = __PACKAGE__->columns;
eval { $page->isa('MojoMojo::Schema::Page'); $page->content->isa('MojoMojo::Schema::Content') };
if ($@) {

    # assume page is a simple "proto page" hashref,
    # or the page has no content yet
    %proto_content = map { $_ => undef } @columns;
    $proto_content{version} = 1;
}
else {
    my $content = $page->content;
    %proto_content = map { $_ => $content->$_ } @columns;
    @proto_content{qw/ creator created comments /} = (undef) x 3;
    $proto_content{version}++;
}
return \%proto_content;
}

=item max_version 

Return the highest numbered revision.

=cut

sub max_version {
my $self=shift;
my $max=$self->result_source->resultset->search({page=>$self->page->id},{
    select => [ {max=>'me.version'}],
    as     => ['max_ver']
});
return 0 unless $max->count;
return $max->next->get_column('max_ver');
}

=item previous

Return previous version of this content, or undef for first version.

=cut

sub previous {
my $self = shift;
return $self->result_source->resultset->search({
	page    => $self->page->id,
	version => $self->version-1
          })->next;
}

=item  pub_date

return publish date of this version in a format suitable for RSS 2.0

=cut

sub pub_date {
    my $self=shift;
    return DateTime::Format::Mail->format_datetime($self->created);
}


1;
