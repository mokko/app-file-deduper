package File::Dedupe::Role::Plugin;
use strict;
use warnings;
use Moose::Role;

#use Scalar::Util qw(blessed);

=attr core

all plugins with the core attribute are 'recursive'; they have access to the 
core which includes access to the plugin system and that means they can 
register and call new plugins. Plugins calling plugins. Yay!

=cut

has 'core' => (is => 'ro', isa => 'File::Dedupe2', required => 1, );

before 'BUILD' => sub {
    my $self = shift;
    $self->core->log_debug('before BUILDing plugin ' . ref $self);
};

1;
