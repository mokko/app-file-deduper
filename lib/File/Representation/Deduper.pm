#ABSTRACT: File::Representation specific for App::Dedupe
package File::Representation::Dedupe;
use strict;
use warnings;
use Digest::file qw(digest_file_hex);
use Cwd 'abs_path';
use Moose;
with 'File::Dedupe::Role::Types';




has 'id' => (
    is       => 'ro',
    isa      => 'FileExists',
    required => 1,

    #trigger runs only during object construction
    trigger => sub { $_[0]->{id} = abs_path($_[1]) },
);

has 'fingerprint' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_fingerprint'
);

sub _build_fingerprint {
    my $self      = shift;
    my $algorithm = 'SHA-512';
    $self->{fpType} = 'SHA-512';
    return digest_file_hex($self->id, $algorithm);
}

has 'fpType' => (is => 'ro', isa => 'Str');
has 'mtime' => (is => 'ro', isa => 'Int', builder => '_build_mtime');

sub _build_mtime {
    my $self = shift;
    return (stat($self->id))[9];
}

has 'lastSeen' =>
  (is => 'rw', isa => 'Int', required => 1, default => '_build_lastSeen');

sub _build_lastSeen {
    return time();
}

has 'size' => (is => 'ro', isa => 'Int', required => 1);
has 'writable' => (is => 'rw', isa => 'Int');

has 'action' => (is => 'rw', isa => 'Str');    #not sure about it
1;
