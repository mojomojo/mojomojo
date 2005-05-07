package MojoMojo::Search::Plucene;

use strict;
use base 'Plucene::Simple';
use Plucene::Plugin::Analyzer::SnowballAnalyzer;

# TODO:
# I can't find a way to index the path data such that we can search only a subsection of
#   the path tree.  For now, we can simply get all search results and ignore those that don't
#   have a key that matches the path we are looking for.

# Not all analyzers are created equal...the SnowballAnalyzer appears to work the best
sub _parsed_query {
	my ($self, $query, $default) = @_;
	my $parser = Plucene::QueryParser->new({
			analyzer => Plucene::Plugin::Analyzer::SnowballAnalyzer->new(),
			default  => $default
		});
	$parser->parse($query);
}

sub _writer {
	my $self = shift;
	return Plucene::Index::Writer->new(
		$self->_dir,
		Plucene::Plugin::Analyzer::SnowballAnalyzer->new(),
		0
	);
}

# updates the search index when page data changes
sub update_index {
    my ($self, $page) = @_;
    return undef unless ($page && $page->content);
    
    my $content = $page->content;
    my $key = $page->full_path;
    
    $self->delete_document($key) if ($self->indexed($key));

    # Q: should we be indexing the abstract, comments, and tags?           
    my $text = $content->body;
    $text .= " " . $content->abstract if ($content->abstract);
    $text .= " " . $content->comments if ($content->comments);
    
    # translate the path into plain text so we can use it in the search query later
    my $fixed_path = $key;
    $fixed_path =~ s/\//X/g;
    
    my %data = (
        $key => {
            _author => $content->creator->login,
            _path => $fixed_path,
            date => ($content->created) ? $content->created->ymd : "",
            tags => join (" ", map { $_->tag } $page->tags ),
            text => $text,
        },
    );
    {
        # This throws some warnings...
        local $^W = 0;
        $self->add( %data );
    }
    return 1;
}

1;
