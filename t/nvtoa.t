use strict;
use warnings;
use Math::MPFR qw(:mpfr);

if(4 > MPFR_VERSION_MAJOR) {
  print "1..1\n";
  eval{ nvtoa(0.5) };

  if($@ =~ /^nvtoa\(\) requires version 4\.0/) {
    warn "nvtoa() not supported because the mpfr library is too old\n";
    print "ok 1\n";
  }
  else {
    warn "\$\@: $@\n";
    print "not ok 1\n";
  }
}

#elsif(Math::MPFR::_required_ldbl_mant_dig() == 2098) {
#  print "1..1\n";
#
#  eval{ nvtoa(0.5) };
#
#  if($@ =~ /^double\-double type,/) {
#    warn "nvtoa() does not support the double-double type\n";
#    print "ok 1\n";
#  }
#  else {
#    warn "\$\@: $@\n";
#    print "not ok 1\n";
#  }
#}

else {

  my $ok = 1;
  my $p = $Math::MPFR::NV_properties{max_dig} - 1;
  my $min_pow = $Math::MPFR::NV_properties{min_pow};

  my $zero = 0.0;
  my $nzero = Rmpfr_get_NV(Math::MPFR->new('-0'), MPFR_RNDN);
  my $inf = 1e4950;
  my $ninf = $inf * -1;
  my $nan = Rmpfr_get_NV(Math::MPFR->new(), MPFR_RNDN);

  my $ws = Rmpfr_init2($Math::MPFR::BITS);

  my @in = (atonv($ws, '6284685476686e5'), atonv($ws, '4501259036604e6'), atonv($ws, '1411252895572e-5'),
            atonv($ws, '9.047014579199e-57'), atonv($ws, '91630634264070293e0'),
            atonv($ws, '25922126328248069e0'), 2 ** $min_pow, 2 ** 0.5, (2 ** $min_pow) + (2 ** ($min_pow + 1)), sqrt 3.0,
            atonv($ws, '2385059e-341'), atonv($ws, '-2385059e-341'), atonv($ws, '1e-9'),
            atonv($ws, '-7373243991138e5'));

  # @py3 is 'doubles' - can't be used to check 'long double' and '__float128' builds of perl.
  my @py3 = ('6.284685476686e+17', '4.501259036604e+18', '14112528.95572', '9.047014579199e-57',
             '9.163063426407029e+16', '2.5922126328248068e+16', '5e-324', '1.4142135623730951',
             '1.5e-323', '1.7320508075688772', '0.0', '-0.0', '1e-09', '-7.373243991138e+17');

  if($Math::MPFR::NV_properties{bits} == 53) {
    print "1..8\n";

    if(nvtoa(sqrt(2.0)) == sqrt(2.0)) { print "ok 1\n" }
    else {
      warn nvtoa(sqrt(2.0)), " != sqrt(2.0)\n";
      print "not ok 1\n";
    }

    if(nvtoa($zero) eq '0.0') { print "ok 2\n" }
    else {
      warn nvtoa($zero), " ne '0.0'\n";
      print "not ok 2\n";
    }

    if($] < 5.010) {
      warn "This version of perl ($]) is old - skipping test 3\n";
    }
    else {
    if(nvtoa($nzero) eq '-0.0') { print "ok 3\n" }
      else {
        warn nvtoa($nzero), " ne '-0.0'\n";
        print "not ok 3\n";
      }
    }

    if(nvtoa($inf) eq 'Inf') { print "ok 4\n" }
    else {
      warn nvtoa($inf), " ne 'Inf'\n";
     print "not ok 4\n";
    }

    if(nvtoa($ninf) eq '-Inf') { print "ok 5\n" }
    else {
      warn nvtoa($ninf), " ne '-Inf'\n";
      print "not ok 5\n";
    }

    if(nvtoa($nan) eq 'NaN') { print "ok 6\n" }
    else {
      warn nvtoa($nan), " ne 'NaN'\n";
      print "not ok 6\n";
    }

    my $t1 = Rmpfr_init2($Math::MPFR::NV_properties{bits});
    my $t2 = Rmpfr_init2($Math::MPFR::NV_properties{bits});
    my $orig_emin = Rmpfr_get_emin();
    my $orig_emax = Rmpfr_get_emax();

    for(@in) {
      if($_ >= $Math::MPFR::NV_properties{normal_min}) {
        Rmpfr_strtofr($t1, nvtoa($_), 10, MPFR_RNDN);
        Rmpfr_set_NV($t2, $_, MPFR_RNDN);
        if($t1 != $t2) {
          $ok = 0;
          warn "$t1 != $t2\n";
        }
      }
      else {
        # We need to subnormalize the mpfr objects.
        my $s = nvtoa($_);
        Rmpfr_set_emin($Math::MPFR::NV_properties{emin}); #(-1073);
        Rmpfr_set_emax($Math::MPFR::NV_properties{emin}); #(1024);
        my $inex = Rmpfr_strtofr($t1, $s, 10, MPFR_RNDN);
        Rmpfr_subnormalize($t1, $inex, MPFR_RNDN);
        $inex = Rmpfr_set_NV($t2, $_, MPFR_RNDN);
        Rmpfr_subnormalize($t2, $inex, MPFR_RNDN);

        if($t1 != $t2) {
          $ok = 0;
          warn "$t1 != $t2\n";
        }

        Rmpfr_set_emin($orig_emin);
        Rmpfr_set_emax($orig_emax);
      }

    }

    if($ok) { print "ok 7\n" }
    else { print "not ok 7\n" }

    $ok = 1;

    for(my $i = 0; $i < @in; $i++) {
      my $t = nvtoa($in[$i]);
      if($t =~ /e\-0\d\d$/i) {$t =~ s/e\-0/e-/i}
      if($t ne $py3[$i]) {
        $ok = 0;
        warn "$t ne $py3[$i]\n";
      }
    }

    if($ok) { print "ok 8\n" }
    else { print "not ok 8\n" }

    $ok = 1;
  }

  elsif($Math::MPFR::NV_properties{bits} == 64) {
    print "1..7\n";

    if(nvtoa(sqrt(2.0)) == sqrt(2.0)) { print "ok 1\n" }
    else {
      warn nvtoa(sqrt(2.0)), " != sqrt(2.0)\n";
      print "not ok 1\n";
    }

    if(nvtoa($zero) eq '0.0') { print "ok 2\n" }
    else {
      warn nvtoa($zero), " ne '0.0'\n";
      print "not ok 2\n";
    }

    if($] < 5.010) {
      warn "This version of perl ($]) is old - skipping test 3\n";
    }
    else {
    if(nvtoa($nzero) eq '-0.0') { print "ok 3\n" }
      else {
        warn nvtoa($nzero), " ne '-0.0'\n";
        print "not ok 3\n";
      }
    }

    if(nvtoa($inf) eq 'Inf') { print "ok 4\n" }
    else {
      warn nvtoa($inf), " ne 'Inf'\n";
     print "not ok 4\n";
    }

    if(nvtoa($ninf) eq '-Inf') { print "ok 5\n" }
    else {
      warn nvtoa($ninf), " ne '-Inf'\n";
      print "not ok 5\n";
    }

    if(nvtoa($nan) eq 'NaN') { print "ok 6\n" }
    else {
      warn nvtoa($nan), " ne 'NaN'\n";
      print "not ok 6\n";
    }

    my $t1 = Rmpfr_init2($Math::MPFR::NV_properties{bits});
    my $t2 = Rmpfr_init2($Math::MPFR::NV_properties{bits});
    my $orig_emin = Rmpfr_get_emin();
    my $orig_emax = Rmpfr_get_emax();

    for(@in) {
      if($_ >= $Math::MPFR::NV_properties{normal_min}) {
        Rmpfr_strtofr($t1, nvtoa($_), 10, MPFR_RNDN);
        Rmpfr_set_NV($t2, $_, MPFR_RNDN);
        if($t1 != $t2) {
          $ok = 0;
          warn "$t1 != $t2\n";
        }
      }
      else {
        # We need to subnormalize the mpfr objects.
        my $s = nvtoa($_);
        Rmpfr_set_emin($Math::MPFR::NV_properties{emin}); #(-16444);
        Rmpfr_set_emax($Math::MPFR::NV_properties{emin}); #(16384);
        my $inex = Rmpfr_strtofr($t1, $s, 10, MPFR_RNDN);
        Rmpfr_subnormalize($t1, $inex, MPFR_RNDN);
        $inex = Rmpfr_set_NV($t2, $_, MPFR_RNDN);
        Rmpfr_subnormalize($t2, $inex, MPFR_RNDN);

        if($t1 != $t2) {
          $ok = 0;
          warn "$t1 != $t2\n";
        }

        Rmpfr_set_emin($orig_emin);
        Rmpfr_set_emax($orig_emax);
      }

    }

    if($ok) { print "ok 7\n" }
    else { print "not ok 7\n" }

    $ok = 1;
  }

  elsif($Math::MPFR::NV_properties{bits} == 113) {
    print "1..7\n";

    if(nvtoa(sqrt(2.0)) == sqrt(2.0)) { print "ok 1\n" }
    else {
      warn nvtoa(sqrt(2.0)), " != sqrt(2.0)\n";
      print "not ok 1\n";
    }

    if(nvtoa($zero) eq '0.0') { print "ok 2\n" }
    else {
      warn nvtoa($zero), " ne '0.0'\n";
      print "not ok 2\n";
    }

    if($] < 5.010) {
      warn "This version of perl ($]) is old - skipping test 3\n";
    }
    else {
    if(nvtoa($nzero) eq '-0.0') { print "ok 3\n" }
      else {
        warn nvtoa($nzero), " ne '-0.0'\n";
        print "not ok 3\n";
      }
    }

    if(nvtoa($inf) eq 'Inf') { print "ok 4\n" }
    else {
      warn nvtoa($inf), " ne 'Inf'\n";
     print "not ok 4\n";
    }

    if(nvtoa($ninf) eq '-Inf') { print "ok 5\n" }
    else {
      warn nvtoa($ninf), " ne '-Inf'\n";
      print "not ok 5\n";
    }

    if(nvtoa($nan) eq 'NaN') { print "ok 6\n" }
    else {
      warn nvtoa($nan), " ne 'NaN'\n";
      print "not ok 6\n";
    }

    my $t1 = Rmpfr_init2($Math::MPFR::NV_properties{bits});
    my $t2 = Rmpfr_init2($Math::MPFR::NV_properties{bits});
    my $orig_emin = Rmpfr_get_emin();
    my $orig_emax = Rmpfr_get_emax();

    for(@in) {
      if($_ >= $Math::MPFR::NV_properties{normal_min}) {
        Rmpfr_strtofr($t1, nvtoa($_), 10, MPFR_RNDN);
        Rmpfr_set_NV($t2, $_, MPFR_RNDN);
        if($t1 != $t2) {
          $ok = 0;
          warn "$t1 != $t2\n";
        }
      }
      else {
        # We need to subnormalize the mpfr objects.
        my $s = nvtoa($_);
        Rmpfr_set_emin($Math::MPFR::NV_properties{emin}); #(-16493);
        Rmpfr_set_emax($Math::MPFR::NV_properties{emin}); #(16384);
        my $inex = Rmpfr_strtofr($t1, $s, 10, MPFR_RNDN);
        Rmpfr_subnormalize($t1, $inex, MPFR_RNDN);
        $inex = Rmpfr_set_NV($t2, $_, MPFR_RNDN);
        Rmpfr_subnormalize($t2, $inex, MPFR_RNDN);

        if($t1 != $t2) {
          $ok = 0;
          warn "$t1 != $t2\n";
        }

        Rmpfr_set_emin($orig_emin);
        Rmpfr_set_emax($orig_emax);
      }

    }

    if($ok) { print "ok 7\n" }
    else { print "not ok 7\n" }

    $ok = 1;
  }

  elsif($Math::MPFR::NV_properties{bits} == 2098) {
    print "1..8\n";

    if(nvtoa(sqrt(2.0)) == sqrt(2.0)) { print "ok 1\n" }
    else {
      warn nvtoa(sqrt(2.0)), " != sqrt(2.0)\n";
      print "not ok 1\n";
    }

    if(nvtoa($zero) eq '0.0') { print "ok 2\n" }
    else {
      warn nvtoa($zero), " ne '0.0'\n";
      print "not ok 2\n";
    }

    if($] < 5.010) {
      warn "This version of perl ($]) is old - skipping test 3\n";
    }
    else {
    if(nvtoa($nzero) eq '-0.0') { print "ok 3\n" }
      else {
        warn nvtoa($nzero), " ne '-0.0'\n";
        print "not ok 3\n";
      }
    }

    if(nvtoa($inf) eq 'Inf') { print "ok 4\n" }
    else {
      warn nvtoa($inf), " ne 'Inf'\n";
      print "not ok 4\n";
    }

    if(nvtoa($ninf) eq '-Inf') { print "ok 5\n" }
    else {
      warn nvtoa($ninf), " ne '-Inf'\n";
      print "not ok 5\n";
    }

    if(nvtoa($nan) eq 'NaN') { print "ok 6\n" }
    else {
      warn nvtoa($nan), " ne 'NaN'\n";
      print "not ok 6\n";
    }

    if(nvtoa(-7373243991138e5) == -7373243991138e5) { print "ok 7\n" }
    else {
      warn nvtoa(-7373243991138e5), " != -7373243991138e5\n";
      print "not ok 7\n";
    }

    for(@in) {
      if(nvtoa($_) != $_) {
        $ok = 0;
        warn nvtoa($_), " != ", sprintf("%.${p}e", $_), "\n";
      }
    }

    if($ok) { print "ok 8\n" }
    else { print "not ok 8\n" }

    $ok = 1;
  }

  else {
    print "1..1\n";
    warn "Error: Unrecognized nvtype\n";
    print "not ok 1\n";
  }
}

__END__
# 1e-09
# Populate @py3

for(@in) {
   my $for_python = sprintf("%.${p}e", $_);
   my $py = `python3 -c \"print($for_python)\"`;
   chomp $py;
   push @py3, $py;
}

print join "', ", @py3;

