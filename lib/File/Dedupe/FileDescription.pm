#ABSTRACT: Describe a file for App::Dedupe
package File::Dedupe::FileDescription;
use strict;
use warnings;
use Digest::file qw(digest_file_hex);
use Cwd 'abs_path';
use Moose;
with 'File::Dedupe::Role::Types';    #not necessary due to Moose's global types

=head1 SYNOPSIS

  use File::Dedupe::FileDescription;
  my $file=File::Dedupe::FileDescription->new(path=>$0); 

  #getters
  $file->path; #returns absolute 'real' path
  $file->checksum_type; #string
  $file->fingerprint; #hash
  $file->lastSeen; #seconds since epoch    
  $file->writable; #book
  $file->size; #bytes
  $file->mtime; #seconds since epoch

  $file->action; #not sure about that yet; not really a file description

  #setters. Do we provide any setters? Files could change. Does it mean we
  #have to make a new file description?

=attr path

accepts only valid paths, both absolute and relative ones, but stores absolute 
paths (realpath) internally. Also, resolves symbolic links and relative path
components (like ..). Path functions here as an id for the file.

=cut

#abs_path only works for existing files, so I don't have to check 
#existence before
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

has 'checksum_type' =>(is=>'ro', isa=>'Str', default=>sub {'SHA-512'});

=method $self->lastSeen

=cut

has 'lastSeen' => (
    is      => 'rw',
    isa     => 'Int',
    default => sub { time() },
    init_arg => undef,
);

=method action
=cut 
has 'action' => (is => 'rw', isa => 'Str');    #not sure about it

# lazy ones
has 'fingerprint' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_fingerprint',
    init_arg => undef,
);

sub _build_fingerprint {
    my $self      = shift;
    return digest_file_hex($self->path, $self->checksum_type);
}

has 'mtime' => (
    is      => 'ro',
    isa     => 'Int',
    lazy    => 1,
    default => sub { (stat($_[0]->path))[9] },
    init_arg => undef,
);

has 'size' => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
    lazy     => 1,
    default  => sub { (stat($_[0]->path))[7] },
    init_arg => undef,
);

has 'writable' => (
    is      => 'rw',
    isa     => 'Int',
    lazy    => 1,
    default => sub { -w $_[0]->path },
    init_arg => undef,
);



1;
