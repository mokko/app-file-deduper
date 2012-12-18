#!perl

use strict;
use warnings;
use Test::More;
use File::Dedupe;
use FindBin;

#use Scalar::Util qw(blessed);
use Data::Dumper;

my $file = File::Spec->catfile($FindBin::Bin, '..', 'profiles.yml');
my $dedupe = File::Dedupe->new(debug => 1, config_file => $file);
ok($dedupe->scan_input);
#print Dumper $dedupe;
done_testing;
