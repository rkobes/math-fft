# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..19\n"; }
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
my $PI = 4.0*atan2(1,1);
my $N = 16;
my $NBIG = 32768;
#my $NBIG = 16;

my ($data1, $data2);
for (my $i=0; $i<$N; $i++) {
   $data1->[$i] = cos(4*$i*$PI/$N);
   $data2->[$i] = sin(4*$i*$PI/$N);
}
my $fft = new Math::FFT($data1);
my $corr = $fft->correl($data2);
my $y = 8/sqrt(2);
my $true = [0,-$y,-8,-$y,0,$y,8,$y,0,-$y,-8,-$y,0,$y,8,$y];
check_error($num, 0, $N, $corr, $true);
$num++;
my $dum = $fft->invrdft();
$corr = $fft->correl($data2);
check_error($num, 0, $N, $corr, $true);
$num++;
my $fft5 = new Math::FFT($data2);
$corr = $fft->correl($fft5);
check_error($num, 0, $N, $corr, $true);
$num++;
my $fft6 = Math::FFT->new($data2);
my $discard = $fft6->rdft();
$corr = $fft->correl($fft6);
check_error($num, 0, $N, $corr, $true);
$num++;

my $M = 9;
my $data3;
for (my $i=0; $i<$M; $i++) {
   $data3->[$i] = sin(4*$i*$PI/$N);
}
my $convlv = $fft->convlv($data3);
my $u = sqrt(2);
my $v = 2+$u;
$true = [$u,$v,$v,$u,-$u,-$v,-$v,-$u,$u,$v,$v,$u,-$u,-$v,-$v,-$u];
check_error($num, 0, $N, $convlv, $true);
$num++;

my $data4;
for (my $i=0; $i<$M; $i++) {
   $data4->[$i] = cos(4*$i*$PI/$N);
}
$convlv = $fft->convlv($data4);
my $fft4 = new Math::FFT($convlv);
my $orig_data = $fft4->deconvlv($data4);
check_error($num, 0, $N, $orig_data, $data1);
$num++;

my $data;
# The following data file is taken from the test of the power
# spectrum routine of Numerical Recipes in C
open(SPCTRL, 't/spctrl.dat')
  or die "Cannot open spctrl.dat: $!";
while (<SPCTRL>) {
  chomp $_;
  my @a = split ' ', $_;
  push @$data, @a;
}
close (SPCTRL);
my $max = 15;
require 't/results.pl' or die "Cannot: $!";
my $results = results();
my $s = new Math::FFT($data);
my $tol = 2e-05;
my $spec = $s->spctrm(segments => 32, number=> 16, overlap => 0);
check_error($num, 0, $max, $spec, $results->{unity}->{no}, $tol);
$num++;
$spec = $s->spctrm(segments => 16, number=> 16, overlap => 1);
check_error($num, 0, $max, $spec, $results->{unity}->{ov}, $tol);
$num++;

$spec = $s->spctrm(segments => 32, number=> 16, overlap => 0, window => 'hann');
check_error($num, 0, $max, $spec, $results->{hamm}->{no}, $tol);
$num++;
$spec = $s->spctrm(segments => 16, number=> 16, overlap => 1, window => 'hann');
check_error($num, 0, $max, $spec, $results->{hamm}->{ov}, $tol);
$num++;

$spec = $s->spctrm(segments => 32, number=> 16, overlap => 0, window => 'welch');
check_error($num, 0, $max, $spec, $results->{welch}->{no}, $tol);
$num++;
$spec = $s->spctrm(segments => 16, number=> 16, overlap => 1, window => 'welch');
check_error($num, 0, $max, $spec, $results->{welch}->{ov}, $tol);
$num++;

$spec = $s->spctrm(segments => 32, number=> 16, overlap => 0, window => 'bartlett');
check_error($num, 0, $max, $spec, $results->{bartlett}->{no}, $tol);
$num++;
$spec = $s->spctrm(segments => 16, number=> 16, overlap => 1, window => 'bartlett');
check_error($num, 0, $max, $spec, $results->{bartlett}->{ov}, $tol);
$num++;

$spec = $s->spctrm(segments => 32, number=> 16, overlap => 0, window => \&my_test);
check_error($num, 0, $max, $spec, $results->{bartlett}->{no}, $tol);
$num++;
$spec = $s->spctrm(segments => 16, number=> 16, overlap => 1, window => \&my_test);
check_error($num, 0, $max, $spec, $results->{bartlett}->{ov}, $tol);
$num++;
$N = 32;
$max = 8;
$data = [];
for (my $i=0; $i<16; $i++) {
   $data->[$i] = cos(4*$i*$PI/$N);
}

my $t = Math::FFT->new($data);
$spec = $t->spctrm();
$true = [ 0.000000, 0.500000, 0.000000, 0.000000, 0.000000, 
   0.000000, 0.000000, 0.000000];
check_error($num, 0, $max, $spec, $true, $tol);
$num++;
$spec = $t->spctrm(window => 'bartlett');
$true = [ 0.125423, 0.372093, 0.079131, 0.000000, 0.001995, 
      0.000000, 0.000561, 0.000000];
check_error($num, 0, $max, $spec, $true, $tol);
$num++;


sub check_error {
  my ($num, $start, $end, $old, $new, $tol) = @_;
  $tol ||= 2e-10;
  my $error = 0;
  for (my $j=$start; $j<$end; $j++) {
    $error += abs($old->[$j] - $new->[$j]);
  }
  print($error < $tol ? "ok $num\n" : "not ok $num (error of $error)\n");
}

sub my_test {
  my ($j, $n) = @_;
  return 1 - abs(2*($j-$n/2)/$n);
}
