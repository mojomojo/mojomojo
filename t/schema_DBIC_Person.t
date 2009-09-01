#!/usr/bin/perl -w
use strict;
use warnings;
use Test::More;

BEGIN {
    eval 'use DBD::SQLite';
    plan skip_all => 'need DBD::SQLite' if $@;

    eval 'use SQL::Translator';
    plan skip_all => 'need SQL::Translator' if $@;

    plan tests => 5;
}

use lib qw(t/lib);
use MojoMojoTestSchema;

my $schema = MojoMojoTestSchema->init_schema(populate => 1);

#is(ref $schema->resultset('Person')->registration_profile, 'HASH', 'very basic registration_profile test');
# Make sure we can't insert second person with the same login or email
my $admin=$schema->resultset('Person')->get_person('admin');
isa_ok($admin ,'MojoMojo::Schema::Result::Person'); 
my $person    = $schema->resultset('Person')->find({id => 1});
my $person_id = $person->id;
my $login     = $person->login;
my $email     = $person->email;
ok( $person_id, 'Person with id 1 exists' );
ok( $login,     'Person 1 has a login' );
ok( $email,     'Person 1 has an email' );
eval { $schema->resultset('Person')->create(
        {
            login => $login,
            email => $email,
            name => 'Wacław Sierpiński',
            pass => 'Hasło',       
        }
    ); };
    
ok($@, 'Can not create duplicate user.' );
