#ABSTRACT: Describe a file for App::Dedupe
package File::Dedupe::FileDescription;
use strict;
use warnings;
use Digest::file qw(digest_file_hex);
use Cwd 'abs_path';
use Moose;
use namespace::autoclean;
#with 'File::Dedupe::Role::Types';    #not necessary due to Moose's global types

=head1 SYNOPSIS

  use File::Dedupe::FileDescription;

  #describe a file on disk...  
  my $file=File::Dedupe::FileDescription->describe(path=>$0); 

  #restore fileDescription with info saved saved in db etc.
  $file=File::Dedupe::FileDescription->new(
    path=>$abs_path,
    checksum_type=>'MD5',
    lastSeen=>$lastSeen,
    writable=>1,
    size=>'4512',
    mtime=>$mtime,
    action=>$action', #not required
  ); 

  #getters
  $file->path; #returns absolute 'real' path
  $file->checksum_type; #string
  $file->fingerprint; #hash
  $file->lastSeen; #seconds since epoch    
  $file->writable; #boolean
  $file->size; #bytes
  $file->mtime; #seconds since epoch
  
  #
  $file->action; #not sure about that yet; not really a file description

  #setters
  $file->action ('bla');  
  
  my $href=$file->hashref; #return content as hashref 

=head1 DESCRIPTION / QUESTIONS

The only way to update a FileDescription is to make a new one. We don't want 
setters for most of the attributes. Either the file is the same or we need a 
new  description (thru ->describe). 

Perhaps I will make an exception for lastSeen in the future. Probably not.
  
=attr path

accepts only valid paths, both absolute and relative ones, but stores absolute 
paths (realpath) internally. It resolves symbolic links and relative path
components (like '..'). Path functions here the id for the file. Paths are 
unique.

=cut

#abs_path only works for existing files, so I don't have to check
#existence before. And cwd's error message is decent!
has 'path' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    trigger  => sub { $_[0]->{path} = abs_path($_[1]) },
);

=attr checksum_type

Choose one of the types available for Digest::file, e.g. 'MD5'. Default is
'SHA-512'.

=cut

has 'checksum_type' => (is => 'ro', isa => 'Str', required => 1);

=method $self->lastSeen

default gets called when a new object is made. 

Is it read only? Or should we be able to update the file?

=cut

has 'lastSeen' => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
);

=method action
=cut 

has 'action' => (is => 'rw', isa => 'Maybe[Str]');    #allow undef

# lazy ones
has 'fingerprint' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);


has 'mtime' => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
);

has 'size' => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
);

has 'writable' => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

#
# methods
#

=method my $file=File::Dedupe::FileDescription->describe(path=>$path);

Alternative constructor. You need path and you may specify checksum_type, all
other values are filled-in automatically from the file that needs to be 
described.

=cut

sub describe {
    my $class = shift;
    my %args  = @_;      #unvalidated hash is handed over to new...
    $args{action}=undef;    #a description made from describe never has action
    #path is required
    if (!$args{path}) {
        confess "Need path!";
    }

    #checksum_type is optional
    if (!$args{checksum_type}) {
        $args{checksum_type} = 'MD5';    #default value
    }

    $args{lastSeen}    = time();
    $args{fingerprint} = digest_file_hex($args{path}, $args{checksum_type});
    $args{writable}    = -w $args{path};
    $args{size}        = (stat($args{path}))[7];
    $args{mtime}       = (stat(_))[9];
    return __PACKAGE__->new(%args);
}

=method my $href=$file->hashref;

returns a copy of the objects content as hashref.

=cut

sub hashref {
    my $self=shift;
    my $href={};    
    for my $attr ( __PACKAGE__->meta->get_all_attributes ) {
      my $aname=$attr->name;
      #don't put action in href if it doesn't exist
      $href->{$aname}=$self->$aname if $self->$aname; 
  }

  return $href;
}

__PACKAGE__->meta->make_immutable;
1;
