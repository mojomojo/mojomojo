# See the difference among Dummy, Stub, Fake and Mock objects at
# http://xunitpatterns.com/Mocks,%20Fakes,%20Stubs%20and%20Dummies.html
package FakeCatalystObject;
use URI;
my $reverse;
my %prefs = (
    main_formatter => 'MojoMojo::Formatter::Markdown',
);

sub new {
    my $class = shift;
    bless {}, $class;
}

sub req {
    return $_[0];
}

sub res {
    return $_[0];
}

sub base {
    $_[0]->{path} ||= '/';
    return URI->new("http://example.com/");
}

sub reverse {
    return $reverse;
}

sub set_reverse {
    $reverse=$_[1];
}

sub stash {
    my $self = shift;
    return {
        page => $self,
        page_path => 'http://example.com/',
    };
}

sub flash {
    my $self = shift;
    return {
        page => $self,
        page_path => 'http://example.com/',
    };
}

sub path {
    my $self = shift;
    $path = $self->{path};
    return $path;
}

sub model {
    return $_[0];
}

sub result_source {
    return $_[0];
}

sub resultset {
    return $_[0];
}

sub ajax {}

sub action {
    return $_[0];
}

sub name { 'view' }


sub path_pages {
    my ($self, $path) = @_;
    $path =~ s|^/||;
    if ($path =~ /existing/i && $path !~ /#new/) {
        my $page = FakeCatalystObject->new;
        $page->{path} = $path;
        return [$page], undef;
    } else {
        return [], [{path => $path}];
    }
}

sub cache {
    my ($self, $c) = @_;
    return undef;
}


sub redirect {
    my ($self, $url) = @_;
    $self->{url}=$url if $url;
    return $self->{url};
}

sub uri_for {
    my ($self, $url) = @_;
    return $url;
}

sub loc {
    my ($self, $text) = @_;
    return "Faking localization... $text ...fake complete.";
}

sub session {
    my ($self, $c) = @_;
    return '';
}

sub pref {
    my ($self, $c, $setting, $value) = @_;
    return '' if not defined $setting;
    return $prefs{$setting} || '' if not defined $value;
    $prefs{$setting} = $value;
}

1;
