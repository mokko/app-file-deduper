package File::Dedupe::Plugin::Scan::Monitor;
use strict;
use warnings;
use Data::Dumper;    #debugging
use Carp 'confess';
use Cwd qw(realpath);

#use Scalar::Util qw(blessed);
use Moose;
with 'File::Dedupe::Role::Plugin';

=head1 SYNOPSIS

    #first register plugin
    plugin_system->register(phase=>ScanMonitor, plugin=>'Scan::Monitor');    

    #start scanning
    my $monitorget_plugin('ScanMonitor') or confess 
      'Cant get plugin for ScanMonitor';
    $monitor->scan;

=head1 DESCRIPTION

The plugin Scan::Monitor is intended for the phase ScanMonitor. It is
part of the Scan::Default plugin bundle. 

It scans the monitored directories of the active profile (described by input) 
and launches the plugin with the phase 'ScanCampare' on each file it discovers.

=cut

sub BUILD {
    
}

sub scan {
    my $self = shift;

    foreach my $item (@{$self->core->active_config->{input}}) {
        my $key   = (keys %{$item})[0];
        my $value = $item->{$key};

        $self->core->log("$key:$value");

        #check if I should do -d -f etc. tests here
        if ($key eq 'dir') {
            $self->_inputDir($value, 1);
        }
        if ($key eq 'single_dir') {
            $self->_inputDir($value, 0);
        }
        if ($key eq 'file') {
            $self->_inputFile($value);
        }
    }
}

sub _inputFile {
    my $self = shift;
    my $file = shift or confess "Need file";

    #realpath works only for existing files (implicit -f test)
    $file = realpath($file);    #absolute path...
    if (-f $file) {
        #print "....................$file\n";
        #print Dumper $self->core->plugin_system;
        my $sc = $self->core->plugin_system->get_plugin('ScanCompare')
          or confess "Need plugin for phase 'ScanCompare'";
        $sc->check($file);
    }

}

sub _inputDir {
    my $self = shift or return " Need myself ";
    my $dir  = shift or return;
    my $recursive = shift || 1;

    #my very first manual recursive directory lookup. Yay!
    #$self->log_debug ("readdir $dir");
    if (!-d $dir) {
        $self->core->log_fatal("item is no directory: $dir");
    }
    opendir(my $DH, $dir) or die " Cannot opendir '$dir' : $! ";

    foreach my $entry (readdir($DH)) {
        next if ($entry =~ /^\./);    #sort out . .. and dotfiles
        $entry = File::Spec->catfile($dir, $entry);
        if (-f $entry) {
            $self->_inputFile($entry);
        }
        if (-d $entry && $recursive) {
            $self->_inputDir($entry, $recursive);
        }

        if (-l $entry) {
            warn " Links not supported yet : $entry ";
        }
    }
    closedir($DH);
}

1;
