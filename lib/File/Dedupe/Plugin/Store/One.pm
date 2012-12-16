#ABSTRACT: Straight-foward no-frills store implementation with SQLite
package File::Dedupe::Plugin::Store::One;
use strict;
use warnings;
use Cwd 'realpath';
use File::Spec;
use Carp 'confess';
use DBI ':sql_types';
use Digest::file qw(digest_file_hex);
use SQL::Abstract;    #SQL is just too cross to write it manually...
use Data::Dumper;     #only debugging
use File::Dedupe::FileDescription;
use Moose;
with 'File::Dedupe::Role::Logger';
use namespace::autoclean;

has 'dbfile' => (is => 'ro', isa => 'Str',    required => 1);
has 'dbh'    => (is => 'ro', isa => 'Object', init_arg => undef);

=head1 SYNOPSIS

  my $store=File::Dedupe::Plugin::Store::One->new(dbfile=>$dbfile);
  $store->create ($path);
  my $file=$store->read ($path); #returns undef if path doesn't exist
  $store->update ($path);
  $store->delete ($path);

=head1 DESCRIPTION

This is my first stab at a store implementation, a straight-forward no-frills
SQLite store. 

A store is an object which provides access to descriptions of files in a 
database of sorts.

TODO: Role that specifies the interface of stores 

=cut

sub BUILD {
    my $self = shift;
    $self->_initDB;

}

=method $self->create ($path);

Confesses on serious errors. Return value?

=cut

sub create {
    my $self = shift or return;
    my $path = shift or return;    #relative path is ok...

    my $file = File::Dedupe::FileDescription->describe(path => $path);
    my ($stmt, @bind) = SQL::Abstract->new->insert('files', $file->hashref);
    $self->log_debug("Store create: $path");    #doesn't return true...
    $self->dbh->selectrow_array($stmt, undef, @bind);
    return 1;
}


=method $self->read ($path);

Expects a path (absolute or relative, although you can't specify a relative path of 
file which doesn't exist anymore).

Returns a File::Dedupe::FileDescription object with data from the store.

=cut

sub read {
    my $self = shift;
    my $path = _realpath(shift) or return;

    if (!File::Spec->file_name_is_absolute($path)) {
        $path = realpath($path);
    }

    #I could get this list of fields from FileDescription
    my @fields = qw(path fingerprint checksum_type created mtime
      size writable action
    );
    my ($stmt, @bind) =
      SQL::Abstract->new->select('files', \@fields, {path => $path});

    $self->log_debug("Store read: $path");
    my $result = $self->dbh->selectrow_hashref($stmt, undef, @bind) or return;
    return File::Dedupe::FileDescription->new(%{$result});
}


=method $self->update ($path);

Expects an existing relative or absolute path.

=cut

sub update {
    my $self = shift;
    my $path = _realpath(shift) or return;
    my $file = File::Dedupe::FileDescription->describe(path => $path);
    my ($stmt, @bind) =
      SQL::Abstract->new->update('files', $file->hashref, {path => $path});
    $self->log_debug("Store update: $path");
    $self->dbh->selectrow_array($stmt, undef, @bind);
    return 1;
}


=method delete

=cut

sub delete {
    my $self = shift;
    my $path = shift or return;
    my ($stmt, @bind) = SQL::Abstract->new->delete('files', {path => $path});
    $self->log_debug("Store: deleted $path");
    $self->dbh->selectrow_array($stmt, undef, @bind);
    return 1;
}


=method $self->iterate(sub{#do_something});


=cut

sub iterate {
    my $self = shift;
    my $sub  = shift or return;
    my $stmt = 'SELECT * FROM files';
    my $sth  = $self->_execute_sql($stmt);
    $sth->fetchrow_array($sth);

    return $sth;
}


#
# PRIVATE
#

sub _initDB {
    my $self = shift;
    my $dbfile = $self->dbfile or confess 'Need dbfile!';
    $self->log_debug("Store: using $dbfile");

    #it's perfectly ok if $dbfile doesn't exist. In that case sqlite will
    #create it. We are in trouble only if that file can't be created.
    if (!-f $dbfile) {
        $self->log_debug("dbfile '$dbfile' does not exist");
    }
    $self->{dbh} = DBI->connect("dbi:SQLite:dbname=$dbfile", "", "");

    #$dbh->do("PRAGMA cache_size = 8000");

    my $sql = q / 
    CREATE TABLE IF NOT EXISTS files ( 
       'path' TEXT PRIMARY KEY NOT NULL,

       'fingerprint' TEXT NOT NULL,
       'checksum_type' TEXT NOT NULL,

       'created' INTEGER NOT NULL,
       'mtime' INTEGER NOT NULL,
       'size' INTEGER NOT NULL,

       'writable' INTEGER, 
       'action' INTEGER
    )/;

    #currently lastSeen is not really lastSeen. It gets updated only when the
    #description gets updated and not every time.

    $self->dbh->do($sql) or confess $self->dbh->errstr;
}


#function...
#might be better placed in File::Dedupe::FileDescription
sub _realpath {
    my $path = shift or confess("Need path!");

    #I wonder what's more expensive: a call to file_name_is_absolute or
    #a call to realpath ...
    #if (!File::Spec->file_name_is_absolute($path)) {
    return realpath($path);

    #}
    return $path;
}


__PACKAGE__->meta->make_immutable;
1;
