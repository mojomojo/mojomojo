package MojoMojo::View::Email;

use parent 'Catalyst::View::Email::Template';

__PACKAGE__->config(
    stash_key       => 'email',
    template_prefix => 'mail',
    sender          => { mailer => 'SMTP' },
    default         => {
        content_type => 'text/plain',
        charset      => 'utf-8',
        view         => 'TT',
    },
);

1;

__END__

=head1 Name

MojoMojo::View::Email - Email Templates

=cut
