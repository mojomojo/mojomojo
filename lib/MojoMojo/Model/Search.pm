package MojoMojo::Model::Search;

use strict;

use parent 'Catalyst::Model';

use KinoSearch1::InvIndexer;
use KinoSearch1::Searcher;
use KinoSearch1::Analysis::PolyAnalyzer;
use KinoSearch1::Index::Term;
use KinoSearch1::Search::Query;
use KinoSearch1::QueryParser::QueryParser;

__PACKAGE__->config->{index_dir} ||= MojoMojo->config->{index_dir};
# Fall back just in case MojoMojo->config->{index_dir} doesn't exist
# but it should.  See MojoMojo.pm to verify that we will short circuit
# on this next line.
__PACKAGE__->config->{index_dir} ||= MojoMojo->path_to('/index');

=head1 NAME

MojoMojo::Model::Search - support for searching pages

=head1 METHODS

=cut

my $invindexer;
my $analyzer = KinoSearch1::Analysis::PolyAnalyzer->new( language => _get_language() );

=head2 indexer

Index the search data

=cut

sub indexer {
    my $self       = shift;
    my $invindexer = KinoSearch1::InvIndexer->new(
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

=head2 searcher

Used by search() to do the grunt work.

=cut

sub searcher {
    my $self = shift;
    $self->prepare_search_index
      unless -f __PACKAGE__->config->{index_dir} . '/segments';
    return KinoSearch1::Searcher->new(
        invindex => __PACKAGE__->config->{index_dir},
        analyzer => $analyzer,
    );
}

=head2 prepare_search_index

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

=head2 index_page <page>

Create/update the search index with data from a MojoMojo page when it changes.

=cut

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

    my $term = KinoSearch1::Index::Term->new( path => $fixed_path );
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

=head2 search

Search for a term or phrase.

=cut

sub search {
    my ( $self, $q ) = @_;
    my $qp = KinoSearch1::QueryParser::QueryParser->new(
        analyzer       => $analyzer,
        fields         => [ 'text', 'tags' ],
        default_boolop => 'AND'
    );
    my $query = $qp->parse($q);
    my $hits = $self->searcher->search( query => $query );

    return $hits;
}

=head2 delete_page <page>

Removes a page from the search index.

=cut

sub delete_page {
    my ( $self, $page ) = @_;

    return unless $page;

    my $index = $self->indexer;
    my $path  = $page->path;
    $path  =~ s{/}{X}g;

    my $term = KinoSearch1::Index::Term->new( path => $path );
    $index->delete_docs_by_term($term);
    $index->finish( optimize => 1 );
}

sub _get_language {
    my %supported_lang = map { $_ => 1 } qw( en da de es fi fr it nl no pt ru sv );
    my $default_lang   = __PACKAGE__->config->{default_lang} || MojoMojo->config->{default_lang} || 'en';

    return exists $supported_lang{$default_lang} ? $default_lang : 'en'; 
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
