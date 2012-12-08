#ABSTRACT: programmatic low-lewel interface for File::Dedupe
package File::Deduper;
use strict;
use warnings;

use Cwd qw(realpath);
use File::Spec;
use Carp qw (croak);
use Try::Tiny;
#use App::File::Deduper::ORLite;
#use App::File::Deduper::ORLite::File;
#use Data::Dumper qw(Dumper);    #only for debug
#use Log::Log4perl qw(get_logger);

#use App::File::Deduper::List;
#use parent 'App::File::Deduper::Urclass';

use Moose;
with 'File::Dedupe::Role::Config';



has 'action'    => ( is => 'ro', isa => 'Str',  default => 'delete' );
has 'algorithm' => ( is => 'ro', isa => 'Str',  default => 'MD5' );
has 'debug'     => ( is => 'rw', isa => 'Bool', default => 0 );
has 'error' =>
  ( is => 'ro', isa => 'Str', writer => '_setError', default => '' );
has 'recursive' => ( is => 'rw', isa => 'Str', default => 1 );

our %list;    #this list only takes abs/path/to/file

=head1 SYNOPSIS

	use File::Dedupe;

    #receives all the config that's necessary
	my $deduper=File::Dedupe->new (%args); 

	#assemble items (dir/file) to work on
	$deduper->input('path/to/dir') or die "Warning"; 

    #update description in db for given input
	$deduper->scan() or die "Warning"; 

    #forgot what wipe does
	$deduper->wipe()

    #make and show a plan
	my $tdl=$deduper->plan ();  #make a plan

    #carry out the plan
	my $deduper->do();


=method die $deduper->error;
	
The method 'error' contains a message. Don't use it to test for error:

	$deduper->$method () or die $deduper->error; #good
	if ($deduper->error) #bad bad

Error should contain the last error message. But Messages are not deleted. So 
it might be an old error. By looking at error message alone you can't usually 
know when error occured.

=cut

sub input {
	my $self = shift or croak "Need myself";
	my $item = shift;

	if ( !$item ) {
		$self->_setError('input: no input value specified');
		return;
	}

	#expect -d -f or -l. What to do with links?
	if ( !-e $item ) {
		$self->_setError('input: $item not found');
		return;
	}

	my $log = Log::Log4perl::get_logger('all');
	$log->info("$item");

	if ( -f $item ) {
		$self->_addFile($item);
	}

	if ( -d $item ) {
		$self->_addDir($item);
	}

	if ( -l $item ) {
		$log->warn( "item is a link. Links are not really supported yet, "
			  . "they are merely ignored which is generally a good thing!" );
	}
	return 1;
}

=method $deduper->scan();

Walk through all the monitored items (stored in %list), determine descriptions 
as necessary. Works directly on the database.

Algorithm:
1) for each item in %list
2) get description from db
3) if no fprint, 
	create fprint, 
    new basic description
	save new description to db (with new basics)
	
4) if fprint exists, check if it requires update
   it requires an update if mtime has changed
   i.e. we're comparing current basics with stored basics
   new basic description
   if fprint is updated, 
     save to db (with new basics)
     proceed with next item
   else: just proceed with next item

TODO: missing - remove files from db which do no longer exist

=cut

sub scan {
	my $self = shift;
	my $log  = get_logger('all');
	$log->info(" Enter scan ");
	foreach my $path ( keys %list ) {
		$log->info("scanning $path");
		my $dbFile = try {
			return App::File::Deduper::ORLite::File->load($path);
		} || $self->_upsertFileDesc( 'insert', $path );

		#in current configuration this case is unlikely or even impossible
		if ( $dbFile && !$dbFile->{fingerprint} ) {
			print " no fprint in db \n ";
			$self->_upsertFileDesc( 'update', $path );
		}

		#only update if size or mtime have changed
		if ( $dbFile->{fingerprint} ) {
			my $curMtime = ( stat($path) )[9];
			my $curSize = -s $path || 0;
			if ( $curMtime != $dbFile->mtime or $curSize != $dbFile->size ) {

				#$log->info(" curMtime $curMtime");
				#$log->info( " dbMtime " . $dbFile->mtime );
				#$log->info(" curSize $curSize");
				#$log->info(" dbSize ". $dbFile->size);

				$log->info(" hash update necessary since file has changed ");
				$self->_upsertFileDesc( 'update', $path );
			}
		}
	}

	return 1;    #success
}

=method $self->wipe();

Walk thru all files descriptions in db and delete the ones which no longer 
exist in filesystem or no longer within the scope of the monitored input
directories (in case those have changed). 

Not sure yet if this should be a mandatory part of the scan. Or configurable.

iterate gave me a lot of trouble. Apparently, it needs a return value and 
transactions seem to speed up the whole deal greatly.

=cut

sub wipe {
	my $self = shift;
	my $log  = get_logger('all');
	$log->info("Enter wipe ");

	App::File::Deduper::ORLite->begin();
	App::File::Deduper::ORLite::File->iterate(
		sub {
			my $log  = get_logger('all');
			my $path = $_->id();

			#$log->info(" wiper tests $path");
			if ( not( $list{$path} ) ) {
				$log->info(" want to wipe $path");
				App::File::Deduper::ORLite::File->delete( 'where id= ?',
					$path );
			}
			return 1;    # without if exits early...
		}
	);

	App::File::Deduper::ORLite->commit();
	$log->info('db wiped');

	return 1;
}

=method my $list=$deduper->plan();

expects nothing and returns todolist as hashref?

Walks through all file descriptions in the db, identifies duplicates, decides 
what to do with them and displays decision (previously I though I should record
decisions in the db).

Returns a hashref with all file (descriptions) where action is suggested.

=cut

sub plan {
	my $self = shift or die " Need myself !";

	#my $signal = shift || '';    #optional

	my $i    = 0;
	my $list = $self->listDuplicates();
	print 'mmm' . Dumper($list);
	return 1;
}

sub listDuplicates {
	my $sql = q(SELECT fingerprint, id FROM file WHERE 
	fingerprint IN (SELECT fingerprint FROM file GROUP BY fingerprint HAVING COUNT(*)>1)
	);

	#fetchall_hashref works only for unique keys

	my $aref = App::File::Deduper::ORLite->selectall_arrayref( $sql, )
	  or die "Problem!";

	my $href = {};
	foreach my $pair ( @{$aref} ) {
		my $key   = @{$pair}[0];
		my $value = @{$pair}[1];

		if ( !$href->{$key} ) {
			$href->{$key} = [$value];
		}
		else {
			push $value, @{ $href->{$key} };
		}
	}

	return $href;
}

#
##
### PRIVATE STUFF
##
#

sub _addDir {
	my $self = shift or return " Need myself ";
	my $dir  = shift or return;

	#my very first manual recursive directory lookup. Yay!
	#$self->verbose (" readdir $dir ");
	opendir( my $DH, $dir ) or die " Cannot opendir '$dir' : $! ";

	#doesn't work with while. Don't know why.
	foreach my $entry ( readdir($DH) ) {
		next if ( $entry =~ /^\./ );    #sort out . .. and dotfiles
		$entry = File::Spec->catfile( $dir, $entry );
		if ( -f $entry ) {
			$self->_addFile($entry);
		}
		if ( -d $entry && $self->recursive ) {
			$self->_addDir($entry);
		}

		#if ( -l $entry ) {
		#	warn " Links not supported yet : $entry ";
		#}
	}
	closedir($DH);
}

#at this point it is already tested to be a file
sub _addFile {
	my $self = shift or die " Need myself !";
	my $file = shift or return;

	$file = realpath($file);

	#print " addFile : $file \n ";
	$list{$file}++;
}

=method $self->_upsertFileDesc ('insert', $path);

=cut

sub _upsertFileDesc {
	my $self   = shift or return;
	my $signal = shift or return;
	my $path   = shift or return;

	if ( $signal eq 'insert' ) {
		my $file = new App::File::Deduper::ORLite::File( id => $path );
		$file->getInfo( $self->algorithm );

		#print " Duduper . pm : _upsertFileDesc::INSERT || ".Dumper $file;
		return $file->insert($file);    #not sure if this works
	}

	if ( $signal eq 'update' ) {
		my $file = App::File::Deduper::ORLite::File::load( id => $path );
		$file->getInfo( $self->algorithm );

		#print " Duduper . pm : _upsertFileDesc::UPDATE || ".Dumper $file;
		return $file->update( %{$file} );
	}

	croak " Bad signal !";

}

1;
