package File::Dedupe::Plugin::ScanCompare;
use strict;
use warnings;
use Data::Dumper; #debugging
use Carp 'confess';
#use Cwd qw(realpath);
#use Scalar::Util qw(blessed);
use Moose;
with 'File::Dedupe::Role::Plugin';

sub BUILD {
}

1;