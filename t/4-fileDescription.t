#!perl

use strict;
use warnings;
use Test::More;
use Cwd 'realpath';
use Data::Dumper;    #debugging only
use Try::Tiny;
use_ok('File::Dedupe::FileDescription');


my $file = File::Dedupe::FileDescription->describe(path => $0);

ok($file, 'new succeeds');
is($file->path,     realpath($0));
is($file->writable, -w $0);
is($file->size,  (stat($0))[7]);
is($file->mtime, (stat($0))[9]);
ok($file->fingerprint, 'fp exists');

print Dumper $file;

#what happens if a file doesn't exist?
try {
    my $file2 =
      File::Dedupe::FileDescription->new(path => '/non-existing/file');
}
catch { pass "FileDescription fails on non-existing file as expected" };

try {
    my $file2 =
      File::Dedupe::FileDescription->describe(path => '/non-existing/file');
}
catch { pass "FileDescription fails on non-existing file as expected" };


#
# the other way around: read stuff from db and make a FileDescription object
#

my $file2 = File::Dedupe::FileDescription->new(
    checksum_type => $file->checksum_type,
    fingerprint   => $file->fingerprint,
    lastSeen      => $file->lastSeen,
    mtime         => $file->mtime,
    path          => $file->path,
    size          => $file->size,
    writable      => $file->writable,
);


print Dumper $file2;

done_testing;
