/*************************************************
Documentation of symbols defined by Math::MPFR

NV_IS_LONG_DOUBLE        : Automatically defined by Makefile.PL iff
                           $Config{nvtype} is 'long double'.

NV_IS_FLOAT128           : Automatically defined by Makefile.PL iff
                           $Config{nvtype} is __float128
                           If NV_IS_FLOAT128 is defined we include the
                           quadmath.h header.

MPFR_WANT_FLOAT128       : Defined by Makefile.PL if $have_float128 is
                           set to a true value. $have_float128 can be set
                           to a true value by either editing the Makefile.PL
                           appropriately or by specifying F128=1 in the
                           Makefile.PL's @ARGV.
                           The quadmath.h header is included if this symbol
                           is defined.
                           NOTE: If MPFR_WANT_FLOAT128 is defined, it is
                           assumed that the mpfr library was built with
                           __float128 support - ie was configured with the
                           '--enable-float128' option.
                           MPFR_WANT_FLOAT128 must NOT be defined if the
                           mpfr library has NOT been built with __float128
                           support.
                           MPFR_WANT_FLOAT128 does not imply that NV_IS_FLOAT128
                           has been defined - perhaps we have defined
                           MPFR_WANT_FLOAT128 solely because we wish to make
                           use of the Math::Float128-Math::MPFR interface.

CAN_PASS_FLOAT128        : Defined only when both MPFR_WANT_FLOAT128 and
                           NV_IS_FLOAT128 is defined, and then only if the mpfr
                           library is at version 4.0.0 or later. (There was no
                           __float128 support in the mpfr library prior to
                           4.0.0.)
                           DANGER: The assumption is that if MPFR_WANT_FLOAT128
                           is defined then the mpfr library has been built
                           with __float128 support, which won't be the case if
                           the mpfr library wasn't configured with
                           '--enable-float128'.
                           I haven't yet found a way of managing this - it's
                           instead left up to the person building Math::MPFR to
                           NOT define MATH_MPFR_WANT_FLOAT128 unless mpfr WAS
                           configured with --enable-float128.

MPFR_WANT_DECIMAL_FLOATS : The symbol needs to be defined (before mpfr.h is
                           included) in order to enable _Decimal64 support.
                           Hence we define it in the Makefile.PL by setting
                           $have_decimal64 to a true value. $have_decimal64
                           can also be set to a true value by specifying
                           D64=1 in the Makefile.PL's @ARGV.
                           $have_decimal64 must not be set to a true value
                           if the mpfr library has not been built with
                           _Decimal64 support.
                           We define the symbol solely to make use of the
                           Math::Decimal64-Math::MPFR interface. Otherwise
                           there's no point (apparent to me) in defining it.

HAVE_IEEE_754_LONG_DOUBLE :Used only by the test suite.
                           Defined by Makefile.PL iff
                           ($Config{longdblkind} == 1 ||
                            $Config{longdblkind} == 2)
                           This implies that long double is the quad (128-bit)
                           long double.

HAVE_EXTENDED_PRECISION_LONG_DOUBLE :
                           Used only by the test suite.
                           Defined by Makefile.PL iff
                           ($Config{longdblkind} == 3 ||
                            $Config{longdblkind} == 4)
                           This implies that nvtype is the extended
                           precision (80-bit) long double.

REQUIRED_LDBL_MANT_DIG   : Defined to float.h's LDBL_MANT_DIG unless
                           LDBL_MANT_DIG is 106 (ie long double is
                           double-double) - in which case it is defined to
                           be 2098.
                           This is needed to ensure that the mpfr value is
                           an accurate rendition of the double-double value.

MAXIMUM_ALLOWABLE_BASE   : Defined to 62 iff mpfr version >= 3.0.0.
                           Else defined to 32.

CHECK_ROUNDING_VALUE     : Macro that checks (on mpfr-versions 2.x.x only)
                           that the rounding value provided is in the
                           allowable range of 0-3 inclusive.
                           (The range has been extended for versions 3.0.0
                           and later.)

DEAL_WITH_NANFLAG_BUG    : Macro that corrects certain failures (in mpfr
                           versions prior to 3.1.4) to set the NaN flag.

DEAL_WITH_NANFLAG_BUG_OVERLOADED
                         : Another macro that corrects the same bug as
                           DEAL_WITH_NANFLAG_BUG - but recoded for the
                           overloaded operations affected by the bug.

MATH_MPFR_NEED_LONG_LONG_INT
                         : Defined by Makefile.PL if
                           $Config{ivsize} >= 8 && $Config{ivtype} is not
                           'long' && $use_64_bit_int (in the Makefile.PL)
                           has not been set to -1. This symbol will also be
                           defined if $use_64_bit_int is set to 1.
                           The setting of this symbol is taken to imply that
                           the mpfr _uj/_sj functions are needed for
                           converting mpfr integer values to perl integers.
                           Conversely, if the symbol is not defined, then
                           the implication is that the _uj/sj functions are
                           not needed (because the _ui/_si functions, which
                           are alway available) provide the same
                           functionality) - and therefore those _uj/_sj
                           functions are then not made available.

IVSIZE_BITS              : Defined only if MATH_MPFR_NEED_LONG_LONG_INT is
                           defined - whereupon it will be set to the bitsize
                           of the IV (perl's integer type).
                           Currently, I think this symbol will only ever be
                           either undefined or set to 64 - and I suspect
                           that it could (currently) be replaced with a hard
                           code 64 wherever it occurs in the code.

*************************************************/

#include <stdio.h>

#if defined MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
#include <inttypes.h>
#endif
#endif


#include <gmp.h>
#include <mpfr.h>
#include <float.h>

#if defined(MPFR_WANT_FLOAT128) || defined(NV_IS_FLOAT128)
#include <quadmath.h>
#if defined(NV_IS_FLOAT128) && defined(MPFR_WANT_FLOAT128) && defined(MPFR_VERSION) && MPFR_VERSION >= MPFR_VERSION_NUM(4,0,0)
#define CAN_PASS_FLOAT128
#endif
#if defined(__MINGW32__) && !defined(__MINGW64__)
typedef __float128 float128 __attribute__ ((aligned(32)));
#elif defined(__MINGW64__) || (defined(DEBUGGING) && defined(NV_IS_DOUBLE))
typedef __float128 float128 __attribute__ ((aligned(8)));
#else
typedef __float128 float128;
#endif
#endif

#if LDBL_MANT_DIG == 106
#define REQUIRED_LDBL_MANT_DIG 2098
#else
#define REQUIRED_LDBL_MANT_DIG LDBL_MANT_DIG
#endif

#if defined(MPFR_VERSION_MAJOR) && MPFR_VERSION_MAJOR >= 3
#define MAXIMUM_ALLOWABLE_BASE 62
#else
#define MAXIMUM_ALLOWABLE_BASE 36
#endif

/* Don't use CHECK_ROUNDING_VALUE macro with Rmpfr_set_NV      *
 * (as this function's "round" arg is "unsigned int", not SV*) */

#if MPFR_VERSION_MAJOR < 3
#define CHECK_ROUNDING_VALUE \
 if((mp_rnd_t)SvUV(round) > 3) \
  croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#else
#define CHECK_ROUNDING_VALUE
#endif


#define NOK_POK_DUALVAR_CHECK \
        if(SvNOK(b)) { \
         nok_pok++; \
         if(SvIV(get_sv("Math::MPFR::NOK_POK", 0))) \
           warn("Scalar passed to %s is both NV and PV. Using PV (string) value"

/* Don't use NON_NUMERIC_CHAR_CHECK macro with Rmpfr_inp_str as this *
 * function requires a different condition (!ret vs ret).            */

#define NON_NUMERIC_CHAR_CHECK \
       if(ret) { \
         nnum++; \
         if(SvIV(get_sv("Math::MPFR::NNW", 0))) \
           warn("string used in %s contains non-numeric characters"



#define NEG_ZERO_BUG 196866 /* A bug affecting mpfr_fits_u*_p functions         */
                            /* Fixed in mpfr after MPFR_VERSION 196866 (3.1.2)  */
                            /* For earlier versions of mpfr, we fix this bug in */
                            /* our own code                                     */

#define LNGAMMA_BUG 196867  /* lngamma(-0) set to NaN instead of +Inf           */
                            /* Fixed in mpfr after MPFR_VERSION 196867 (3.1.3)  */
                            /* For earlier versions of mpfr, we fix this bug in */
                            /* our own code                                     */

#define NANFLAG_BUG 196868  /* A bug affecting setting of the NaN flag          */
                            /* Fixed in mpfr after MPFR_VERSION 196868 (3.1.4)  */
                            /* For earlier versions of mpfr, we fix this bug in */
                            /* our own code                                     */

#define DD_INF_BUG 196869   /* mpfr_get_ld on (double-double platforms only)    */
                            /* might return NaN when it sould return Inf.       */
                            /* Presumably, this will be                         */
                            /* fixed in mpfr after MPFR_VERSION 196869 (3.1.5)  */
                            /* For earlier versions of mpfr, we fix this bug in */
                            /* our own code                                     */

#if  !defined(MPFR_VERSION) || (defined(MPFR_VERSION) && MPFR_VERSION <= NANFLAG_BUG)
#define DEAL_WITH_NANFLAG_BUG if(mpfr_nan_p(*b))mpfr_set_nanflag();
#define DEAL_WITH_NANFLAG_BUG_OVERLOADED if(mpfr_nan_p(*(INT2PTR(mpfr_t *,SvIVX(SvRV(a))))))mpfr_set_nanflag();
#else
#define DEAL_WITH_NANFLAG_BUG
#define DEAL_WITH_NANFLAG_BUG_OVERLOADED
#endif

/* Squash some annoying compiler warnings (Microsoft compilers only). */

#ifdef _MSC_VER
#pragma warning(disable:4700 4715 4716)
#endif

#ifdef OLDPERL
#define SvUOK SvIsUV
#endif

#ifndef Newx
#  define Newx(v,n,t) New(0,v,n,t)
#endif

#ifndef Newxz
#  define Newxz(v,n,t) Newz(0,v,n,t)
#endif

/* May one day be removed from mpfr.h */
#ifndef mp_rnd_t
# define mp_rnd_t  mpfr_rnd_t
#endif
#ifndef mp_prec_t
# define mp_prec_t mpfr_prec_t
#endif

#ifndef __gmpfr_default_rounding_mode
#define __gmpfr_default_rounding_mode mpfr_get_default_rounding_mode()
#endif

#if !defined(__GNU_MP_VERSION) || __GNU_MP_VERSION < 5
#define mp_bitcnt_t unsigned long int
#endif

