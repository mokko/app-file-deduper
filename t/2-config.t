#!perl

use strict;
use warnings;
use Test::More;
use Try::Tiny;
use FindBin;
use File::Spec;
use Data::Dumper;
use Scalar::Util qw(blessed);
use File::Dedupe;

package TrialConfig;
use Moose; 
with 'File::Dedupe::Role::Config';
1;

package main;
#positive
my $file = File::Spec->catfile($FindBin::Bin, '..', 'profiles.yml');
#could be two different config files, so it's good to load twice
my $obj1 = TrialConfig->new(config_file => $file, debug => 1);
my $obj2 = File::Dedupe->new(config_file => $file, debug => 1);

foreach my $self ($obj2, $obj1) {
    
#positive

    is ($self->active_profile, 'default', 'active profile default');
    ok($self->config, 'config hashref exists');
    my $aconf=$self->active_config;
    ok ($aconf->{input}, 'aconf looks good');

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

