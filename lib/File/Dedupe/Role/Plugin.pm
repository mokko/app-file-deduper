package File::Dedupe::Role::Plugin;
use strict;
use warnings;
use Moose::Role;
use Scalar::Util qw(blessed); 
with 'Plugin::Simple::Role::Plugin';

#__PACKAGE__ always returns Plugin::Dedupe::Role::Plugin
sub phase {
    my $self=shift;
    my @a=split ('::',$self);
    return lc($a[-2]);
}



1;
