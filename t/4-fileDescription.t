#!perl

use strict;
use warnings;
use Test::More;
use Cwd 'realpath';
use Data::Dumper;    #debugging only
use Try::Tiny;
use_ok('File::Dedupe::FileDescription');


my $file = File::Dedupe::FileDescription->new(path => $0);

ok($file, 'new succeeds');
is($file->path,     realpath($0));
is($file->writable, -w $0);
is($file->size,  (stat($0))[7]);
is($file->mtime, (stat($0))[9]);
ok($file->fingerprint, 'fp exists');

try {

#what happens if a file doesn't exist
    $file = File::Dedupe::FileDescription->new(path => '/non-existing/file');
}
catch { pass "FileDescription fails on non-existing file as expected" };

print Dumper $file;
done_testing;
