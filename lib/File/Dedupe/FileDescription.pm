#ABSTRACT: Describe a file for App::Dedupe
package File::Dedupe::FileDescription;
use strict;
use warnings;
use Digest::file 'digest_file_hex';
use Cwd 'realpath';
use Moose;
use namespace::autoclean;

#with 'File::Dedupe::Role::Types';    #not necessary due to Moose's global types

=head1 SYNOPSIS

  use File::Dedupe::FileDescription;

  #describe a file on disk...  
  my $file=File::Dedupe::FileDescription->describe(path=>$0); 

  #restore fileDescription with info saved saved in db etc.
  $file=File::Dedupe::FileDescription->new(
    path=>'path/to/file',
    checksum_type=>'MD5',
    created=>123456789,
    writable=>1,
    size=>4512,
    mtime=>12345678,
    action=>'delete', #not required
  ); 

  #only getters; no setters
  my $path=$file->path; #same for other attributes
  
  #other
  my $href=$file->hashref; #return content as hashref 

=head1 DESCRIPTION 

=head2 No Updates

The only way to update a FileDescription is to make a new description. There 
are no setters. Either the file is still in the same state or we make a new
description (thru C<describe>). 

=attr path

accepts only valid paths, both absolute and relative ones. Internally paths are
always transformed to absolute ones and only absolute paths are returned. 
FileDescription resolves symbolic links and relative path components 
(like '..'). C<path> functions here the id for the file. Paths are unique.

=cut

#realpath only works for existing files, so I don't have to check
#existence separately. And cwd's error message is decent!
has 'path' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    trigger  => sub { $_[0]->{path} = realpath($_[1]) },
);

=attr checksum_type

Choose a hash logarithm. See L<Digest::file>. Default is 'MD-5'. 

=cut

has 'checksum_type' => (is => 'ro', isa => 'Str', required => 1);

=attr created

time when the description was first made in seconds since epoch.

=cut

has 'created' => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
);

=attr action
=cut 

has 'action' => (is => 'rw', isa => 'Maybe[Str]');    #allow undef

# lazy ones
has 'fingerprint' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

=attr mtime

=cut

has 'mtime' => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
);

=attr size

=cut

has 'size' => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
);

=attr writable

=cut

has 'writable' => (
    is       => 'rw',
    isa      => 'Int',
    required => 1,
);

#
# methods
#

=method my $file=File::Dedupe::FileDescription->describe(path=>$path);

Alternative constructor. Needs a path and optionally accepts a checksum_type, 
other values are filled-in automatically from the file that needs to be 
described.

  path=>$path
  checksum_type=>'MD5'; #see above

=cut

sub describe {
    my $class = shift;
    my %args  = @_;      #unvalidated hash is handed over to new...
    $args{action} = undef;    #a description made from describe never has action

    #path is required
    if (!$args{path}) {
        confess "Need path!";
    }

    #checksum_type is optional
    if (!$args{checksum_type}) {
        $args{checksum_type} = 'MD5';    #default value
    }

    $args{created}     = time();
    $args{fingerprint} = digest_file_hex($args{path}, $args{checksum_type});
    $args{writable}    = -w $args{path} || 0;
    $args{size}        = (stat($args{path}))[7];
    $args{mtime}       = (stat(_))[9];
    return __PACKAGE__->new(%args);
}

=method my $href=$file->hashref;

returns a copy(?) of the object's content as hashref.

It might actually be a reference...
TODO: Check!

=cut

sub hashref {
    my $href = {};
    for my $attr (__PACKAGE__->meta->get_all_attributes) {
        my $aname = $attr->name;
        $href->{$aname} = $_[0]->$aname if $_[0]->$aname;
    }

    return $href;
}

__PACKAGE__->meta->make_immutable;
1;
