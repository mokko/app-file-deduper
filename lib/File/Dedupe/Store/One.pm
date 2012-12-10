#ABSTRACT: Straight-foward no-frills store implementation with SQLite
package File::Dedupe::Store::One;
use strict;
use warnings;
use Carp 'confess';
use DBI ':sql_types';
use Digest::file qw(digest_file_hex);
use Moose;
use File::Dedupe::FileDescription; #??? 

#use DBD::SQLite;

has 'dbfile' => (is => 'ro', isa => 'Str', required => 1);
has 'dbh' => (is => 'ro', isa => 'Object');

=head1 SYNOPSIS

  here $file to exist already and has to be well-formed
  alternatively, it could just make it in this class then i wd need only
  ids here. I wd call 
   $file=File::Dedupe::FileDescription->new ($id) 
  internally
  
  my $store=File::Dedupe::Store::One->new(%args);
  $store->create ($id|$file);
  my $file=$store->retrieve ($id); #returns undef if id doesn't exist
  $store->update ($id|$file);
  $store->delete ($id);

=cut

sub BUILD {
    my $self = shift;
    $self->_initDB;

}

sub retrieve {
    my $self = shift;
    my $id = shift or return;

}

sub create {
    my $self = shift;
    my $id=shift or return
    my $file = File::Dedupe::FileDescription->new (path=>$id);
    #should I check if file has the right content? No, I will just use Moose to do that
    #File::Dedupe::FileDescription?

}

sub update {
    my $self = shift;
    my $id=shift or return
    my $file = File::Dedupe::FileDescription->new (path=>$id);


}

sub delete {
    my $self = shift;
    my $id = shift or return;


}


#
# PRIVATE
#

sub _initDB {
    my $self=shift;
    my $dbfile = $self->dbfile or confess 'Need dbfile!';

    #it's perfectly ok if $dbfile doesn't exist. In that case sqlite will
    #create it. We are in trouble only if that file can't be created.
    warn "dbfile '$dbfile' does not exist" if (!-f $dbfile);

    $self->{dbh} = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "");
    #$dbh->do("PRAGMA cache_size = 8000");

    my $sql = q / 
    CREATE TABLE IF NOT EXISTS files ( 
       'id' TEXT PRIMARY KEY NOT NULL,

       'fingerprint' TEXT NOT NULL
       'fpType' TEXT NOT NULL

       'lastSeen' STRING NOT NULL
       'mtime' INTEGER NOT NULL
       'size' INTEGER NOT NULL

       'writable' INTEGER NOT NULL
       'action' INTEGER NOT NULL
    )/;

    $self->dbh->do($sql) or confess $self->dbh->errstr;
}

1;
