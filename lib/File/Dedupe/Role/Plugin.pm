package File::Dedupe::Role::Plugin;
use strict;
use warnings;
use Moose::Role;
use Data::Dumper;

#use Scalar::Util qw(blessed);

=attr core

all plugins with the core attribute are 'recursive'; they have access to the 
core which includes access to the plugin system and that means they can 
register and call new plugins. Plugins calling plugins. Yay!

=cut

has 'core' => (is => 'ro', isa => 'File::Dedupe2', required => 1,);

before 'BUILD' => sub {

#works only for those plugs which use this role
my $self = shift;
$self->core->log('Enter BUILD'); 
#if you want log message for all plugs use Plugin::Tiny->new (debug=>1)
};

1;
