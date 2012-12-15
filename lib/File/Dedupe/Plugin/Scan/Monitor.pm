package File::Dedupe::Plugin::Scan::Monitor;
use strict;
use warnings;
use Carp 'confess';
use Cwd qw(realpath);
use File::Find;
use Moose;
with 'File::Dedupe::Role::Plugin';
use Data::Dumper;    #debugging

#use Scalar::Util qw(blessed);

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
and updates or creates new descriptions in store if necessary (see check).

=head1 STATUS

I will need a mechanism to exclude files and directories, i.e. config value
in config file...

=cut

has 'store' => (
    is       => 'ro',
    isa      => 'Object',
    default  => sub { $_[0]->core->plugin_system->get_plugin('Store') },
    init_arg => undef,
);


#
# Methods
#

sub BUILD {    #method modifer needs BUILD even if empty
}

=method scan

starts the scanning. Requires the store.

=cut

sub scan {
    my $self = shift;

    my @dirs;
    foreach my $pair (@{$self->core->active_config->{input}}) {
        my $type = (keys %{$pair})[0];
        my $item = $pair->{$type};

        #$self->core->log("$type:$value");

        if ($type eq 'dir') {
            confess "Input item described as dir is not a directory "
              if (!-d $item);
            if (grep ($_ eq $item,@dirs) ==0) {    #only if new 
                push @dirs, $item;
            }
        }
        if ($type eq 'single_dir') {
            confess "Input item described as single_dir is not a directory "
              if (!-d $item);
            $self->_inputDir($item);
        }

        if ($type eq 'file') {
            confess "Input item described as file is not a file" if (!-f $item);
            $self->_inputFile($item);
        }
    }
    find(
        {   no_chdir => 1,
            wanted   => sub {
                $self->_inputFile($File::Find::name);
            },
        },
        @dirs
    ) if (@dirs);
}


=method check ($path)

saves a new description of the file referenced in path if necessary. Gets
called on every file the Scan::Monitor encounters. If description is updated, 
it returns the new description; otherwise undef.

New file description is necessary if 
-store has no description for this file
-we're using a different checksum type than before
-existing mtime or size are outdated 

=cut

sub check {
    my $self = shift;
    my $path = shift or return;    #absolute or relative is both fine
    print "discovered $path\n";
    my $desc = $self->store->read($path);
    if ($desc) {
        my $size          = (stat($path))[7];
        my $mtime         = (stat(_))[9];
        my $checksum_type = $self->core->config->{main}{checksum_type};
        $self->store->update($path)
          if ( $size != $desc->size
            or $mtime != $desc->mtime
            or $checksum_type ne $desc->checksum_type);
    }
    else { $self->store->create($path) }
}

#
# PRIVATE
#

sub _inputFile {

    #only if file i.e leaves out links and dirs...
    $_[0]->check($_[1]) if (-f $_[1]);
}

sub _inputDir {
    my $self = shift or return "Need myself";
    my $dir  = shift or return;

    opendir(my $DH, $dir) or die " Cannot opendir '$dir' : $! ";

    foreach my $entry (readdir($DH)) {
        next if ($entry eq '.' or $entry eq '..');
        $entry = File::Spec->catfile($dir, $entry);
        $self->_inputFile($entry);

        if (-l $entry) {
            warn " Links not supported yet : $entry ";
        }
    }
    closedir($DH);
}

1;
