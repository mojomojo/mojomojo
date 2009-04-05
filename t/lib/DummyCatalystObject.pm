package DummyCatalystObject;
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

sub stash {
    my $self = shift;
    return { page => $self,
         page_path => 'http://example.com/',
    };
}

sub flash {
    my $self = shift;
    return { page => $self,
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
    my ($self,$path) = @_;
    $path =~ s|^/||;
    if ($path =~ /Existing/) {
        my $page = DummyCatalystObject->new;
        $page->{path} = $path;
        return [$page], undef;
    } else {
        return [], [{path => $path}];
    }
}

sub pref { return 1; }

sub cache {
    my ($self,$c)=@_;
    return undef;
}


sub redirect {
    my ($self,$url)=@_;
    $self->{url}=$url if $url;
    return $self->{url};
}

sub uri_for {
    my ($self,$url)=@_;
    return $url;
}

1;
