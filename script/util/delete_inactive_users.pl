#!/usr/bin/perl 
=head1 NAME

delete_inactive_users.pl - Delete inactive users and their revisions. Use as a mass antispam tool,
if you haven't deactivated users via /admini/.users for other reasons. Read the usage.

=head1 AUTHOR

Dan Dascalescu (dandv), http://dandascalescu.com

=cut

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";
use MojoMojo;

die "Delete inactive users and their page revisions.

These users are of two sorts: users that an admin has disabled from
/.admin/user (most probably spammers) and unconfirmed users (they haven't
confirmed their e-mail yet). The latter are again most probably spammers, 
but theoretically, a user who's changed their valid e-mail address and 
didn't confirm the new one would fall in that category too.

This script will delete all unconfirmed and disabled users who've never
edited pages, and will prompt you to delete disabled users who have edited
pages. All their edits (page revisions) will also be deleted.

To run this script, call it with an argument (meaning you've read this).
" if not @ARGV;

my $users;
my $users_deleted = 0;

$users = MojoMojo->model('DBIC::Person')->search(
    {   active => {'!=' => 1},
        'page_versions.creator' => undef  # IS NULL
    },
    {join => 'page_versions'}
);
my $users_count = $users->count;
if ($users_count > 0) {
    print "Unconfirmed and disabled users without pages: $users_count. Delete? ('yes'/anything else): ";
    my $answer = <STDIN>; chomp $answer;
    if ($answer eq 'yes') {
        $users_deleted += $users_count;
        $users->delete;
    }
};

# disabled users (active = 0, set so from the admin interface) who've edited pages are probably spammers
$users = MojoMojo->model('DBIC::Person')->search(
    {
        active => 0,
        'page_versions.creator' => \'IS NOT NULL'  # necessary because this is a LEFT JOIN
    },    
    {join => 'page_versions'}
);
$users_count = $users->count;

if ($users_count > 0) {
    print "$users_count users disabled by an admin (probably spammers) have edited at least one page each. Delete (A)ll / (I)ndividually / (N)one? ";
    my $answer = <STDIN>; chomp $answer;
    if (uc $answer eq 'A') {
        $users_deleted += $users_count;
        $users->delete;
    } elsif (uc $answer eq 'I') {
        # delete the fuckers individually
        while (my $user = $users->next) {
            my @user_pages = $user->pages;
            print "User ", $user->name, "has been disabled, and they edited ", scalar @user_pages, " pages:\n";
            print map {'    ' . $_->path . "\n" } @user_pages;
            print "Delete this user? ('yes'/anything else) ";
            my $answer = <STDIN>; chomp $answer;
            if ($answer eq 'yes') {
                # this nicely cascades to delete the revisions authored by the user in Content, 
                # and the Page and PageVersion if they are left without any Content revision
                $user->delete;  
                $users_deleted++;
            }
        }
    }
}    

# Unconfirmed users (active = -1) who have edited pages are left alone. This can only mean that the user was
# once active, but then changed their e-mail address and hasn't confirmed the new one.

print "Deleted $users_deleted inactive users.\n";
