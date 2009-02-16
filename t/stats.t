# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}
use Math::FFT;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):
use strict;
my $num = 2;
my $set = [1, 2, 3, 4, 250];
my $d = Math::FFT->new($set);
my $mean = $d->mean;
check_value($num, 52, $mean);
$num++;
my $std = $d->stdev;
check_value($num, 13*sqrt(290)/2, $std);
$num++;
my $rms = $d->rms;
check_value($num, sqrt(12506), $rms);
$num++;
my ($min, $max) = $d->range;
check_value($num, 1, $min);
$num++;
check_value($num, 250, $max);
$num++;
my $med = $d->median;
check_value($num, 3, $med);
$num++;
$set = [1, 2, 3, 4];
$d = new Math::FFT($set);
$med = $d->median;
check_value($num, 2.5, $med);
$num++;

sub check_value {
  my ($num, $true, $calc) = @_;
  my $error = abs($true - $calc);
  print($error < 1e-10 ? "ok $num\n" : "not ok $num (error of $error)\n");
}
