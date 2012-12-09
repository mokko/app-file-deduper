package File::Dedupe::Plugin::ScanDefault;
use strict;
use warnings;
use Data::Dumper;    #debugging
use Carp 'confess';
use Cwd qw(realpath);

#use Scalar::Util qw(blessed);
use Moose;
with 'File::Dedupe::Role::Plugin';

sub BUILD {
    my $self = shift;

    my $ps = $self->core->plugin_system;

    $ps->add_phase(
        qw(
          ScanMonitored
          ScanCompare
          ScanStore
          ScanWipe)
    );

    $ps->register('File::Dedupe::Plugin::ScanMonitored');
    $ps->register('File::Dedupe::Plugin::ScanCompare');
    $ps->register('File::Dedupe::Plugin::ScanStore');
    $ps->register('File::Dedupe::Plugin::ScanWipe');

    $self->core->plugin_system->execute(
        phase   => 'ScanMonitored',
        core => $self->core,
    );

}

#it is possible to overwrite a role model? appearantly
sub phase {'Scan'};

1;
