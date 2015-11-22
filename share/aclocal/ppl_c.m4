dnl A function to test for the existence and usability of particular
dnl versions of the C interface of the PPL, defining macros containing
dnl the required paths.
dnl Copyright (C) 2001-2009 Roberto Bagnara <bagnara@cs.unipr.it>
dnl Copyright (C) 1997 Owen Taylor
dnl
dnl This file is part of the Parma Polyhedra Library (PPL).
dnl
dnl The PPL is free software; you can redistribute it and/or modify it
dnl under the terms of the GNU General Public License as published by the
dnl Free Software Foundation; either version 3 of the License, or (at your
dnl option) any later version.
dnl
dnl The PPL is distributed in the hope that it will be useful, but WITHOUT
dnl ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
dnl FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
dnl for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with this program; if not, write to the Free Software Foundation,
dnl Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111-1307, USA.
dnl
dnl For the most up-to-date information see the Parma Polyhedra Library
dnl site: http://www.cs.unipr.it/ppl/ .

dnl AM_PATH_PPL_C([MINIMUM-VERSION, [ACTION-IF-FOUND [, ACTION-IF-NOT-FOUND]]])
dnl Test for the C interface of the PPL, and define PPL_CPPFLAGS,
dnl PPL_LDFLAGS, ... what else?

AC_DEFUN([AM_PATH_PPL_C],
[
dnl Get the required information from the ppl-config program.
AC_ARG_WITH(ppl-prefix,
  AS_HELP_STRING([--with-ppl-prefix=PREFIX],
    [prefix used to configure the PPL]),
  ppl_prefix="$withval",
  ppl_prefix="")
AC_ARG_WITH(ppl-exec-prefix,
  AS_HELP_STRING([--with-ppl-exec-prefix=PREFIX],
    [exec-prefix used to configure the PPL]),
  ppl_exec_prefix="$withval",
  ppl_exec_prefix="")
AC_ARG_ENABLE(ppl-test,
  AS_HELP_STRING([--disable-ppltest],
    [do not try to compile and run a test PPL program]),
  ,
  enable_ppltest=yes)

if test "x$ppl_exec_prefix" != x
then
  ppl_config_args="$ppl_config_args --exec-prefix=$ppl_exec_prefix"
  if test "x${PPL_CONFIG+set}" != xset
  then
    PPL_CONFIG="$ppl_exec_prefix/bin/ppl-config"
  fi
fi
if test "x$ppl_prefix" != x
then
  ppl_config_args="$ppl_config_args --prefix=$ppl_prefix"
  if test "x${PPL_CONFIG+set}" != xset
  then
    PPL_CONFIG="$ppl_prefix/bin/ppl-config"
  fi
fi

AC_PATH_PROG(PPL_CONFIG, ppl-config, no)
min_ppl_version=ifelse([$1], ,0.0,$1)
if test \( "x$min_ppl_version" = "x0.0" \) -o \( "x$min_ppl_version" = "x0.0.0" \)
then
  AC_MSG_CHECKING([for the Parma Polyhedra Library])
else
  AC_MSG_CHECKING([for the Parma Polyhedra Library, version >= $min_ppl_version])
fi
no_ppl=""
if test $PPL_CONFIG = no
then
  no_ppl=yes
else
  PPL_CPPFLAGS=`$PPL_CONFIG $ppl_config_args --cppflags`
  PPL_LDFLAGS=`$PPL_CONFIG $ppl_config_args --interface=C --ldflags`
  ppl_config_version="`$PPL_CONFIG $ppl_config_args --version`"

  if test "x$enable_ppltest" = xyes
  then
    ac_save_CPPFLAGS="$CPPFLAGS"
    ac_save_LDFLAGS="$LDFLAGS"
    CPPFLAGS="$CPPFLAGS $PPL_CPPFLAGS"
    LDFLAGS="$PPL_LDFLAGS $LDFLAGS"

dnl Now check if the installed (C interface of the) PPL is sufficiently new.
dnl (Also sanity checks the results of ppl-config to some extent.)

    AC_LANG_PUSH(C)

    rm -f conf.ppltest
    AC_TRY_RUN([
#include <ppl_c.h>
#include <stdio.h>
#include <stdlib.h>

#define BOOL int
#define TRUE 1
#define FALSE 0

int
main() {
  const char* version_string = 0;

  system("touch conf.ppltest");

  unsigned min_ppl_major, min_ppl_minor, min_ppl_revision, min_ppl_beta;
  int n = sscanf("$min_ppl_version",
                 "%u.%u.%upre%u%*c",
                 &min_ppl_major, &min_ppl_minor,
                 &min_ppl_revision, &min_ppl_beta);
  BOOL min_ppl_version_ok = TRUE;
  if (n == 4) {
    if (min_ppl_beta == 0)
      min_ppl_version_ok = FALSE;
  }
  else if (n == 3) {
    n = sscanf("$min_ppl_version",
               "%u.%u.%u%*c",
               &min_ppl_major, &min_ppl_minor, &min_ppl_revision);
    if (n != 3)
      min_ppl_version_ok = FALSE;
    else
      min_ppl_beta = 0;
  }
  else if (n == 2) {
    n = sscanf("$min_ppl_version",
               "%u.%upre%u%*c",
               &min_ppl_major, &min_ppl_minor, &min_ppl_beta);
    if (n == 3) {
      if (min_ppl_beta == 0)
        min_ppl_version_ok = FALSE;
      else
        min_ppl_revision = 0;
    }
    else if (n == 2) {
      n = sscanf("$min_ppl_version",
                 "%u.%u%*c",
                 &min_ppl_major, &min_ppl_minor);
      if (n != 2)
        min_ppl_version_ok = FALSE;
      else {
        min_ppl_revision = 0;
        min_ppl_beta = 0;
      }
    }
    else
      min_ppl_version_ok = FALSE;
  }
  else
    min_ppl_version_ok = FALSE;

  if (!min_ppl_version_ok) {
    printf("illegal version string '$min_ppl_version'\n");
    return 1;
  }

  ppl_version(&version_string);

  if (strcmp("$ppl_config_version", version_string) != 0) {
    printf("\n*** 'ppl-config --version' returned $ppl_config_version, "
           "but PPL version %s", version_string);
    printf("\n*** was found!  If ppl-config was correct, then it is best"
           "\n*** to remove the old version of PPL."
           "  You may also be able to fix the error"
           "\n*** by modifying your LD_LIBRARY_PATH enviroment variable,"
           " or by editing"
           "\n*** /etc/ld.so.conf."
           "  Make sure you have run ldconfig if that is"
           "\n*** required on your system."
           "\n*** If ppl-config was wrong, set the environment variable"
           " PPL_CONFIG"
           "\n*** to point to the correct copy of ppl-config,"
           " and remove the file config.cache"
           "\n*** before re-running configure.\n");
    return 1;
  }
  else if (strcmp(PPL_VERSION, version_string) != 0) {
    printf("\n*** PPL header file (version " PPL_VERSION ") does not match"
           "\n*** library (version %s)\n", version_string);
    return 1;
  }
  else if (PPL_VERSION_MAJOR < min_ppl_major
           || (PPL_VERSION_MAJOR == min_ppl_major
              && PPL_VERSION_MINOR < min_ppl_minor)
           || (PPL_VERSION_MAJOR == min_ppl_major
              && PPL_VERSION_MINOR == min_ppl_minor
              && PPL_VERSION_REVISION < min_ppl_revision)
           || (PPL_VERSION_MAJOR == min_ppl_major
              && PPL_VERSION_MINOR == min_ppl_minor
              && PPL_VERSION_REVISION == min_ppl_revision
              && PPL_VERSION_BETA < min_ppl_beta)) {
      printf("\n*** An old version of PPL (" PPL_VERSION ") was found."
             "\n*** You need at least PPL version $min_ppl_version."
             "  The latest version of"
             "\n*** PPL is always available from ftp://ftp.cs.unipr.it/ppl/ ."
             "\n***"
             "\n*** If you have already installed a sufficiently new version,"
             " this error"
             "\n*** probably means that the wrong copy of the ppl-config"
             " program is"
             "\n*** being found.  The easiest way to fix this is to remove"
             " the old version"
             "\n*** of PPL, but you can also set the PPL_CONFIG environment"
             " variable to point"
             "\n*** to the correct copy of ppl-config.  (In this case,"
             " you will have to"
             "\n*** modify your LD_LIBRARY_PATH enviroment"
             " variable or edit /etc/ld.so.conf"
             "\n*** so that the correct libraries are found at run-time.)\n");
      return 1;
  }
  return 0;
}
],, no_ppl=yes,[echo $ac_n "cross compiling; assumed OK... $ac_c"])

    AC_LANG_POP

    CPPFLAGS="$ac_save_CPPFLAGS"
    LDFLAGS="$ac_save_LDFLAGS"
  fi
fi

if test "x$no_ppl" = x
then
  AC_MSG_RESULT(yes)
  ifelse([$2], , :, [$2])
else
  AC_MSG_RESULT(no)
  if test x"$PPL_CONFIG" = xno
  then
    echo "*** The ppl-config script installed by PPL could not be found."
    echo "*** If the PPL was installed in PREFIX, make sure PREFIX/bin is in"
    echo "*** your path, or set the PPL_CONFIG environment variable to the"
    echo "*** full path to ppl-config."
  else
    if test -f conf.ppltest
    then
      :
    else
      echo "*** Could not run PPL test program, checking why..."
      CPPFLAGS="$CPPFLAGS $PPL_CPPFLAGS"
      LDFLAGS="$LDFLAGS $PPL_LDFLAGS"
      AC_TRY_LINK([
#include <ppl_c.h>
],
[
  return ppl_version_major() || ppl_version_minor()
  || ppl_version_revision() || ppl_version_beta();
],
[
  echo "*** The test program compiled, but did not run.  This usually means"
  echo "*** that the run-time linker is not finding the PPL or finding the"
  echo "*** wrong version of the PPL.  If it is not finding the PPL, you will"
  echo "*** need to set your LD_LIBRARY_PATH environment variable, or edit"
  echo "*** /etc/ld.so.conf to point to the installed location.  Also, make"
  echo "*** sure you have run ldconfig if that is required on your system."
  echo "***"
  echo "*** If you have an old version installed, it is best to remove it,"
  echo "*** although you may also be able to get things to work by modifying"
  echo "*** LD_LIBRARY_PATH."
],
[
  echo "*** The test program failed to compile or link. See the file"
  echo "*** config.log for the exact error that occured.  This usually means"
  echo "*** the PPL was incorrectly installed or that someone moved the PPL"
  echo "*** since it was installed.  In both cases you should reinstall"
  echo "*** the library."
])
      CPPFLAGS="$ac_save_CPPFLAGS"
      LDFLAGS="$ac_save_LDFLAGS"
    fi
  fi
  PPL_CPPFLAGS=""
  PPL_LDFLAGS=""
  ifelse([$3], , :, [$3])
fi
AC_SUBST(PPL_CPPFLAGS)
AC_SUBST(PPL_LDFLAGS)
rm -f conf.ppltest
])
