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

has 'core' => (is => 'ro', isa => 'File::Dedupe2', required => 1, );

#after 'BUILD' => sub {
#    my $self = shift;
#    my $ps=$self->core->plugin_system;
#    my $class=$ps->class($self) or warn "No plugin class!";
#    my $phase=$ps->phase($self) or warn "No phase!";
#    print Dumper keys %{$ps->_registry};
#    $self->core->log_debug("after BUILDing plugin '$class' for phase '$phase'");
#};

1;
