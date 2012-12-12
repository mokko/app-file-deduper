#!perl

use strict;
use warnings;
use Test::More;
use FindBin;
use File::Spec;

#preparation & cleanup
my $tmp_dir = File::Spec->catfile($FindBin::Bin, 'tmp');
my $dbfile  = File::Spec->catfile($tmp_dir,      'sqlite.db');

if (!-d $tmp_dir) {
    mkdir File::Spec->catfile($FindBin::Bin, 'tmp') or die "Cant mkdir";
}
if (-e $dbfile) {
    unlink $dbfile;
}

#testing
use_ok('File::Dedupe::Store::One');

my $store = File::Dedupe::Store::One->new(dbfile => $dbfile);
ok($store, 'new succeeds');

ok ($store->create($0), 'simple create');
ok ($store->create($dbfile), 'another simple create');

my $file=$store->read($0);
is_deeply($file, File::Dedupe::FileDescription->describe(path=>$0), 'read result looks good');

ok ($store->update($0), 'simple update');
ok ($store->delete($dbfile), 'simple delete');

done_testing;
