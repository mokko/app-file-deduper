#!perl

use strict;
use warnings;
use Test::More;
use FindBin;
use File::Spec;
use Data::Dumper;    #debugging

#preparation & cleanup: this test uses its own db file
my $tmp_dir = File::Spec->catfile($FindBin::Bin, 'tmp');
my $dbfile  = File::Spec->catfile($tmp_dir,      'sqlite.db');

if (!-d $tmp_dir) {
    mkdir File::Spec->catfile($FindBin::Bin, 'tmp') or die "Cant mkdir";
}
if (-e $dbfile) {
    unlink $dbfile;
}

#testing
use_ok('File::Dedupe::Plugin::Store::One');

my $store =
  File::Dedupe::Plugin::Store::One->new(dbfile => $dbfile, debug => 1);
ok($store, 'new succeeds');

#print Dumper $store;
ok($store->create($0),      'simple create');           #relative path?
ok($store->create($dbfile), 'another simple create');

{
    my $file = $store->read($0);
    my $new_file = File::Dedupe::FileDescription->describe(path => $0);
    delete $file->{'created'};
    delete $new_file->{'created'};
    is_deeply($file, $new_file, 'read result looks good');
}
ok($store->update($0),      'simple update');
ok($store->delete($dbfile), 'simple delete');

note "iterate";

ok($store->iterate, 'iterate');

done_testing;
