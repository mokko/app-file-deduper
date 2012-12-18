#!perl

use strict;
use warnings;
use Test::More;
use Scalar::Util qw(blessed);
use File::Dedupe;

#use Data::Dumper;
package Try; #logger only
use Moose;
with 'File::Dedupe::Role::Logger';

sub BUILD {
    $_[0]->log(["log from Try::BUILD %s", 'bla']);
}

1;

package main;
use strict;
use warnings;
use File::Spec;
use FindBin;
my $file = File::Spec->catfile($FindBin::Bin, '..', 'profiles.yml');

my $one = Try->new(debug => 1) or die "Cant make one";
my $two = File::Dedupe->new(debug => 0, config_file => $file)
  or die "Cant make two";
ok ($one, "one exists".$one);
ok ($two, "two exists".$two);

foreach my $self ($one, $two) {
    ok($self,         $self."exists");
    ok($self->logger, "logger exists");
    is(blessed $self->{logger}, 'Log::Dispatchouli');
    $self->log(["log Mama %s", 'bla']);
    $self->log_debug('debug on');
}
done_testing;


1;

