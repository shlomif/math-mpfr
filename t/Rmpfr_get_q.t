use warnings;
use strict;
use Config;
use Math::MPFR qw(:mpfr);
use Math::GMPq qw(:mpq);

print "1..8\n";

my $nan   = Math::MPFR->new();
my $ninf  = Math::MPFR->new(-1) / Math::MPFR->new(0);
my $pinf  = Math::MPFR->new(1) / Math::MPFR->new(0);
my $pzero = Math::MPFR->new(0);
my $nzero = Math::MPFR->new(0) * Math::MPFR->new(-1);
my $ok;

my $q = Math::GMPq->new();

$ok .= 'a' unless Rmpfr_erangeflag_p();

Rmpfr_get_q($q, $nan);

if($q == 0) {print "ok 1\n"}
else {
  warn "\nExpected 0, got $q\n";
  print "not ok 1\n";
}

$ok .= 'b' if Rmpfr_erangeflag_p();
Rmpfr_clear_erangeflag();
$ok .= 'c' unless Rmpfr_erangeflag_p();

Rmpfr_get_q($q, $ninf);

if($q == 0) {print "ok 2\n"}
else {
  warn "\nExpected 0, got $q\n";
  print "not ok 2\n";
}

$ok .= 'd' if Rmpfr_erangeflag_p();
Rmpfr_clear_erangeflag();
$ok .= 'e' unless Rmpfr_erangeflag_p();

Rmpfr_get_q($q, $pinf);

if($q == 0) {print "ok 3\n"}
else {
  warn "\nExpected 0, got $q\n";
  print "not ok 3\n";
}

$ok .= 'f' if Rmpfr_erangeflag_p();
Rmpfr_clear_erangeflag();
$ok .= 'g' unless Rmpfr_erangeflag_p();

Rmpfr_get_q($q, $pzero);

if($q == 0) {print "ok 4\n"}
else {
  warn "\nExpected 0, got $q\n";
  print "not ok 4\n";
}

Rmpfr_get_q($q, $nzero);

if($q == 0) {print "ok 5\n"}
else {
  warn "\nExpected 0, got $q\n";
  print "not ok 5\n";
}

my $val = Rmpfr_init2(121);
Rmpfr_set_d($val, 2.0, MPFR_RNDN);
$val **= 0.5;

#print "$val\n";

Rmpfr_get_q($q, $val);

if(Rmpfr_cmp_q($val, $q) == 0) {print "ok 6\n"}
else {
  warn "\n\$val ($val) != \$q ($q)\n";
  print "not ok 6\n";
}

$ok .= 'h' unless Rmpfr_erangeflag_p();

if($ok eq 'abcdefgh') {print "ok 7\n"}
else {
  warn "\nExpected 'abcdefgh', got '$ok'\n";
  print "not ok 7\n";
}

my $check = Rmpfr_init2(Rmpfr_get_prec($val) * 2);

Rmpfr_set($check, $val, MPFR_RNDN);
$check **= 2.0;

if(Rmpfr_cmp_q($check, $q * $q) == 0) {print "ok 8\n"}
else {
  warn "\n$check != ", $q * $q, "\n";
  print "not ok 8\n";
}


