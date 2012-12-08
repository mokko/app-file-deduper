package File::Dedupe::Plugin::Scan::Default;
use strict;
use warnings;
use Data::Dumper; #debugging
use Carp 'confess';
use Cwd qw(realpath);
#use Scalar::Util qw(blessed);
use Moose;
with 'File::Dedupe::Role::Plugin';

sub execute {
    my $self=shift;
    my $active_profile=shift or confess "Need profile";
    #print Dumper $active_profile;
    foreach my $item (@{$active_profile->{input}}) {
        my $key   = (keys %{$item})[0];
        my $value = $item->{$key};

        #print "$key->$value\n";
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
    return $self->{filelist};
}

#at this point it is already tested to be a file NOT
sub _inputFile {
    my $self = shift;
    my $file = shift or die "Need file";

    $file = realpath($file);

    #print " addFile : $file \n ";
    $self->{filelist}{$file}++;    #number is irrelevant
}

sub _inputDir {
    my $self = shift or return " Need myself ";
    my $dir  = shift or return;
    my $recursive = shift || 1;

    #my very first manual recursive directory lookup. Yay!
    #$self->log_debug ("readdir $dir");
    opendir(my $DH, $dir) or die " Cannot opendir '$dir' : $! ";

    #doesn't work with while. Don't know why.
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