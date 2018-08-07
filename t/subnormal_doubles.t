# Run some checks on subnormal double-doubles and doubles.
# This script also checks some values that are Inf (or close to Inf).
# For subnormal double values we check that atodouble() and atonv() return the same value.
# We do the same for normal values - but not if the NV type is double-double.

use strict;
use warnings;
use Math::MPFR qw(:mpfr);


if($Config::Config{nvtype} eq 'double' ||
    ($Config::Config{nvtype} eq 'long double' &&
      ($Config::Config{nvsize} == 8 ||  Math::MPFR::_required_ldbl_mant_dig() == 2098)
    )
  ) {

  my $have_atodouble = MPFR_VERSION <= 196869 ? 0 : 1;

  if($have_atodouble) {

    print "1..1\n";

    my ($ok, $dmin) = (1, 2 ** - 1022);
    my($exp, $sig, $val, $d, $nv);
    my $ws = Rmpfr_init2($Math::MPFR::BITS);

    for my $it(1 .. 500) {
      $exp = 300 + int(rand(30));
      $exp *= -1 if($it % 3);
      $sig = (1 + int(rand(9))) . '.' . int(rand(10)) . int(rand(10)) . int(rand(10)) . (1 + int(rand(9)));

      $val = "${sig}e${exp}";
      $d = atodouble($val);
      $nv = atonv($ws, $val);

      if($Math::MPFR::BITS != 2098) { # Check that $d == $nv for all values
        if($d != $nv) {
          warn "\n $d != $nv\n";
          $ok = 0;
        }
      }
      elsif($d <= $dmin) {            # Check that $d == $nv for subnormal values only
        if($d != $nv) {
          warn "\n $d != $nv\n";
          $ok = 0;
        }
      }
    }

    if($ok) {print "ok 1\n"}
    else {print "not ok 1\n"}
  }
  else { # atodouble is unavailable

    print "1..1\n";
    eval{atodouble('1234.5');};

    if($@ =~ /^The atodoublefunction requires mpfr-3.1.6 or later/) {print "ok 1\n"}
    else {
      warn "\n \$\@: $@\n";
      print "not ok 1\n";
    }
  }
}
else { # Not a double or double-double build
  print "1..1\n";
  warn "\n Skipping tests: NV type ($Config::Config{nvtype} is neither\n  'double' nor double-double'\n";
  print "ok 1\n";
}


