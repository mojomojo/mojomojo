package MojoMojo::Model::Search;

use strict;

use base 'Catalyst::Model';

use KinoSearch::InvIndexer;
use KinoSearch::Searcher;
use KinoSearch::Analysis::PolyAnalyzer;
use KinoSearch::Index::Term;
use KinoSearch::Search::Query;
use KinoSearch::QueryParser::QueryParser;

__PACKAGE__->config->{index_dir} ||= MojoMojo->path_to('/index');

=head1 NAME

MojoMojo::Controller::Search

=head1 ACTIONS

=over 4

=cut

my $invindexer;
my $analyzer = KinoSearch::Analysis::PolyAnalyzer->new( language => 'en' );

sub indexer {
    my $self       = shift;
    my $invindexer = KinoSearch::InvIndexer->new(
        invindex => __PACKAGE__->config->{index_dir},
        create =>
          ( -f __PACKAGE__->config->{index_dir} . '/segments' ? 0 : 1 ),
        analyzer => $analyzer,
    );
    $invindexer->spec_field( name => 'path', analyzed => 0 );
    $invindexer->spec_field( name => 'text' );
    $invindexer->spec_field( name => 'author' );
    $invindexer->spec_field( name => 'date', analyzed => 0 );
    $invindexer->spec_field( name => 'tags' );
    return $invindexer;
}

sub searcher {
    my $self = shift;
    $self->prepare_search_index
      unless -f __PACKAGE__->config->{index_dir} . '/segments';
    return KinoSearch::Searcher->new(
        invindex => __PACKAGE__->config->{index_dir},
        analyzer => $analyzer,
    );
}

=item prepare_search_index

Create a new search index from all pages in the database.
Will do nothing if the index already exists.

=cut

sub prepare_search_index {
    my $self = shift;

    MojoMojo->log->info("Initializing search index...")
      if MojoMojo->debug;

    # loop through all latest-version pages
    my $count = 0;
    my $it    = MojoMojo->model('DBIC::Page')->search;
    while ( my $page = $it->next ) {
        $page->result_source->resultset->set_paths($page);
        $self->index_page($page);
        $count++;
    }

    MojoMojo->log->info("Indexed $count pages") if MojoMojo->debug;
}

=item index_page <page>

Create/update the search index with data from a MojoMojo page.

=cut

# updates the search index when page data changes
sub index_page {
    my ( $self, $page ) = @_;
    my $index = $self->indexer;
    $page->discard_changes();
    return unless ( $page && $page->content );

    my $content = $page->content;
    my $key     = $page->path;

    my $text = $content->body;
    $text .= " " . $content->abstract if ( $content->abstract );
    $text .= " " . $content->comments if ( $content->comments );

# translate the path into plain text so we can use it in the search query later
    my $fixed_path = $key;
    $fixed_path =~ s{/}{X}g;

    my $term = KinoSearch::Index::Term->new( path => $fixed_path );
    $index->delete_docs_by_term($term);
    my $doc = $index->new_doc();
    $doc->set_value( author => $content->creator->login );
    $doc->set_value( path   => $fixed_path );
    $doc->set_value(
        date => ( $content->created ) ? $content->created->ymd : '' );
    $doc->set_value( tags => join( ' ', map { $_->tag } $page->tags ) );
    $doc->set_value( text => $text );
    $index->add_doc($doc);
    $index->finish( optimize => 1 );
}

sub search {
    my ( $self, $q ) = @_;
    my $qp = KinoSearch::QueryParser::QueryParser->new(
        analyzer       => $analyzer,
        fields         => [ 'text', 'tags' ],
        default_boolop => 'AND'
    );
    my $query = $qp->parse($q);
    my $hits = $self->searcher->search( query => $query );
    return $hits;
}

1;
