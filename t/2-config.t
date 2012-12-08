#!perl

use strict;
use warnings;
use Test::More;
use Try::Tiny;
use FindBin;
use File::Spec;
use Data::Dumper;
use Scalar::Util qw(blessed);
use File::Dedupe2;

package TrialConfig;
use Moose;
#shouldn't work because Types are not loaded...
with 'File::Dedupe::Role::Config';
1;

package main;
#positive
my $file = File::Spec->catfile($FindBin::Bin, '..', 'profiles.yml');

my $obj1 = TrialConfig->new(config_file => $file, debug => 1);
my $obj2 = File::Dedupe2->new(config_file => $file, debug => 1);

foreach my $self ($obj1, $obj2) {

#positive

    ok($self->config, 'config hashref exists');

#negative
    try {
        $self->new(config_file => 'nonexisting');
    }
    catch {
        ok($_, 'fails on non-existing file');
    };
    try {
        $self = File::Dedupe::Config->new();
    }
    catch {
        ok($_, 'fails without file');
    };
}

#print Dumper $self->config;

done_testing();

