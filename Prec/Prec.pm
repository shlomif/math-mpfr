## This file generated by InlineX::C2XS (version 0.24) using Inline::C (version 0.73)

# For an explanation of the existence of this module and the one (prec_cast) function
# that it provides, see the FORMATTED OUTPUT section of MPFR.pm's pod.

package Math::MPFR::Prec;
use strict;
use warnings;

require Exporter;
*import = \&Exporter::import;
require DynaLoader;

our $VERSION = '3.36';
#$VERSION = eval $VERSION;
DynaLoader::bootstrap Math::MPFR::Prec $VERSION;

@Math::MPFR::Prec::EXPORT = ();
@Math::MPFR::Prec::EXPORT_OK = ();

sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

1;
