package File::Dedupe::Role::Plugin;
use strict;
use warnings;
use Moose::Role;
use Scalar::Util qw(blessed); 
with 'Plugin::Simple::Role::Plugin';

=attr core

all plugins with the core attribute are 'recursive'; they have access to the 
core which includes access to the plugin system and that means they can 
register and call new plugins. Plugins calling plugins. Yay!

=cut

has 'core' => (is => 'ro', isa => 'File::Dedupe2', required=>1,  );

before 'BUILD' => sub{
    $_[0]->core->log_debug ('before BUILDing plugin '.ref $_[0]);
};

#__PACKAGE__ always returns Plugin::Dedupe::Role::Plugin
sub phase {
    my $self=shift;
    my @a=split ('::',$self); 
    my $phase=$a[-1]; #lcfist?
    #print "phase:$phase\n";
    return $phase; 
}

1;
