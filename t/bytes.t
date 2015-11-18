use warnings;
use strict;
use Config;
use Math::MPFR qw(:mpfr);


print  "# Using Math::MPFR version ", $Math::MPFR::VERSION, "\n";
print  "# Using mpfr library version ", MPFR_VERSION_STRING, "\n";
print  "# Using gmp library version ", Math::MPFR::gmp_v(), "\n";

my @bytes;

eval {@bytes = Math::MPFR::_ld_bytes('2.3', 64);};

if($@) {

  my $mess = $@;

  print "1..1\n";

  my $dd = 0;
  my $nv1 = 1.0;
  my $nv2 = $nv1 + (2 ** -1000);
  $dd = 1 if $nv2 != $nv1;

  if($Config{longdblkind} == 6 || $dd == 1) {
    warn "\ndouble-double detected\n";
    if($mess =~ /^2nd arg \(/) {print "ok 1\n"}
    else {
      warn "\n\$\@: $mess\n";
      print "not ok 1\n";
    }
  }
  elsif(64 != MPFR_LDBL_DIG) {
    my $dig = MPFR_LDBL_DIG;
    warn "\n$dig != 64\n";
    if($mess =~ /^2nd arg \(/) {print "ok 1\n"}
    else {
      warn "\n\$\@: $mess\n";
      print "not ok 1\n";
    }
  }
  else {
    warn "\n\$\@: $mess\n";
    print "not ok 1\n";
  }
}
else {
  print "1..4\n";

  my $hex = join '', @bytes;

  if($hex eq '40009333333333333333') {print "ok 1\n"}
  else {
    warn "expected 40009333333333333333, got $hex";
    print "not ok 1\n";
  }

  @bytes = Math::MPFR::_ld_bytes('2.93', 64);
  $hex = join '', @bytes;

  if($hex eq '4000bb851eb851eb851f') {print "ok 2\n"}
  else {
    warn "expected 4000bb851eb851eb851f, got $hex";
    print "not ok 2\n";
  }

  eval{Math::MPFR::_ld_bytes('2.93', 63);};

  if($@ =~ /^2nd arg to Math::MPFR::_ld_bytes must be 64/) {print "ok 3\n"}
  else {
    warn "\nIn Math::MPFR::_ld_bytes: $@\n";
    print "not ok 3\n";
  }

  eval{Math::MPFR::_ld_bytes(2.93, 64);};

  if($@ =~ /^1st arg supplied to Math::MPFR::_ld_bytes is not a string/) {print "ok 4\n"}
  else {
    warn "\nIn Math::MPFR::_ld_bytes: $@\n";
    print "not ok 4\n";
  }

}



