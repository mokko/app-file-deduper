#!perl

use strict;
use warnings;
use Test::More;
use FindBin;
use File::Spec;

use_ok ('File::Dedupe::Store::One');

my $dbfile=File::Spec->catfile ($FindBin::Bin,'tmp', 'sqlite.db');
mkdir File::Spec->catfile ($FindBin::Bin,'tmp') or die "Cant mkdir";

my $store=File::Dedupe::Store::One->new (dbfile=>$dbfile);
ok ($store, 'new succeeds');

my $file={
  id=>'bla'
    
};


done_testing;