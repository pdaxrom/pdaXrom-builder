# -*-makefile-*-
PASSIVEFTP	= --passive-ftp
SUDO		= sudo
PTXUSER		= $(shell echo $$USER)
GNU_BUILD	= $(shell $(TOPDIR)/scripts/config.guess)
GNU_HOST	= $(shell echo $(GNU_BUILD) | sed s/-[a-zA-Z0-9_]*-/-host-/)
HOSTCC		= gcc
HOSTCC_ENV	= CC=$(HOSTCC)
CROSSSTRIP	= PATH=$(CROSS_PATH) $(PTXCONF_GNU_TARGET)-strip
CROSS_STRIP	= $(CROSSSTRIP)
DOT		= dot
DEP_OUTPUT	= depend.out
DEP_TREE_PS	= deptree.ps

XIPKG		= IPKG_CONF_DIR=$(TOPDIR)/scripts/bin $(TOPDIR)/scripts/bin/ipkg -ignore-scripts
XMKIPKG		= rm -f $(STATEDIR)/virtual-image.install ; D2ROX=$(TOPDIR)/scripts/bin/desktop2rox $(TOPDIR)/scripts/bin/mkipkg
DESK2ROX	= $(TOPDIR)/scripts/bin/desktop2rox
XMKPACKAGES	= $(TOPDIR)/scripts/bin/mkPackages
#
# some convenience functions
#

#
# print out header information
#
targetinfo = echo;					\
	TG=`echo $(1) | sed -e "s,/.*/,,g"`; 		\
	LINE=`echo target: $$TG |sed -e "s/./-/g"`;	\
	echo $$LINE;					\
	echo target: $$TG;				\
	echo $$LINE;					\
	echo;						\
	echo $@ : $^ | sed -e "s@$(TOPDIR)@@g" -e "s@/src/@@g" -e "s@/state/@@g" >> $(DEP_OUTPUT)


#
# extract the given source to builddir
#
# $1 = filename to extract
# $2 = dir into extract
#
# if $2 is not given, it is extracted to the BUILDDIR
#
extract =							\
	PACKET="$(strip $(1))";					\
	if [ "$$PACKET" = "" ]; then				\
		echo;						\
		echo Error: empty parameter to \"extract\(\)\";	\
		echo;						\
		exit -1;					\
	fi;							\
	DEST="$(strip $(2))";					\
	DEST=$${DEST:-$(BUILDDIR)};				\
	case "$$PACKET" in					\
	*gz)							\
		EXTRACT=$(GZIP)					\
		;;						\
	*bz2)							\
		EXTRACT=$(BZIP2)				\
		;;						\
	*)							\
		echo;						\
		echo Unknown format, cannot extract!;		\
		echo;						\
		exit -1;					\
		;;						\
	esac;							\
	[ -d $$DEST ] || mkdir -p $$DEST;			\
	$$EXTRACT -dc $$PACKET | $(TAR) -C $$DEST -xf -

#
# download the given URL
#
# $1 = URL of the packet
# $2 = source dir
# 
get =								\
	URL="$(strip $(1))";					\
	if [ "$$URL" = "" ]; then				\
		echo;						\
		echo Error: empty parameter to \"get\(\)\";	\
		echo;						\
		exit -1;					\
	fi;							\
	SRC="$(strip $(2))";					\
	SRC=$${SRC:-$(SRCDIR)};					\
	[ -d $$SRC ] || mkdir -p $$SRC;				\
	$(WGET) -P $$SRC $(PASSIVEFTP) $$URL

#
# download patches from Pengutronix' patch repository
# 
# $1 = packet name = identifier for patch subdir
# 
# the wget options:
# ----------------
# -r -l1		recursive 1 level
# -nH --cutdirs=3	remove hostname and next 3 dirs from URL, when saving
#			so "http://www.pengutronix.de/software/ptxdist-cvs/patches/glibc-2.2.5/*"
#			becomes "glibc-2.2.5/*"
#
get_patches =											\
	PACKET_NAME="$(strip $(1))";								\
	if [ "$$PACKET_NAME" = "" ]; then							\
		echo;										\
		echo Error: empty parameter to \"get_pachtes\(\)\";				\
		echo;										\
		exit -1;									\
	fi;											\
	if [ "$(EXTRAVERSION)" = "-cvs" ]; then							\
		PATCH_TREE=cvs;									\
	else											\
		PATCH_TREE=$(FULLVERSION);							\
	fi;											\
	if [ ! -d $(PATCHDIR) ]; then								\
		mkdir -p $(PATCHDIR);								\
	fi;											\
	if [ -d $(PATCHDIR)/$$PACKET_NAME ]; then						\
		rm -fr $(PATCHDIR)/$$PACKET_NAME;						\
	fi;											\
	if [ ! -f $(PATCHDIR)-local/$$PACKET_NAME/.localonly ]; then				\
	    $(WGET) -r -l 1 -nH --cut-dirs=3 -A.diff -A.patch -A.gz -A.bz2 -q -P $(PATCHDIR)	\
		$(PASSIVEFTP) $(PTXPATCH_URL)-$$PATCH_TREE/$$PACKET_NAME/generic/;		\
	    $(WGET) -r -l 1 -nH --cut-dirs=3 -A.diff -A.patch -A.gz -A.bz2 -q -P $(PATCHDIR)	\
		$(PASSIVEFTP) $(PTXPATCH_URL)-$$PATCH_TREE/$$PACKET_NAME/$(PTXCONF_ARCH)/;	\
	fi;											\
	if [ -d $(PATCHDIR)-local/$$PACKET_NAME ]; then						\
		echo "Copying Local patches from patches-local/"$$PACKET_NAME;			\
		cp -R $(PATCHDIR)-local/$$PACKET_NAME $(PATCHDIR);				\
	fi;											\
	true

#
# returns an options from the .config file
#
# $1 = regex, that's applied to the .config file
#      format: 's/foo/bar/'
#
# $2 = default option, this value is returned if the regex outputs nothing
#
get_option =										\
	$(shell										\
		REGEX="$(strip $(1))";							\
		DEFAULT="$(strip $(2))";						\
		if [ -f $(TOPDIR)/.config ]; then					\
			VALUE=`cat $(TOPDIR)/.config | sed -n -e "$${REGEX}p"`;		\
		fi;									\
		echo $${VALUE:-$$DEFAULT}						\
	)

#
# returns an options from the .config file
#
# $1 = regex, that's applied to the .config file
#      format: 's/foo/bar/'
# $2 = command that get in STDIN the output from the regex magic
#      should return something in STDOUT
#
get_option_ext =									\
	$(shell										\
		REGEX="$(strip $(1))";							\
		if [ -f $(TOPDIR)/.config ]; then					\
			cat $(TOPDIR)/.config | sed -n -e "$${REGEX}p" | $(2);		\
		fi;									\
	)


#
# cleanup the given directory or file
#
clean =								\
	DIR="$(strip $(1))";					\
	if [ -e $$DIR ]; then					\
		rm -rf $$DIR;					\
	fi

# 	if [ "$$DIR" = "" ]; then				\
# 		echo;						\
# 		echo Error: empty parameter to \"clean\(\)\";	\
# 		echo;						\
# 		exit -1;					\
# 	fi;							\


#
# find latest config
#
latestconfig = `find $(TOPDIR)/config -name $(1)* -print | sort | tail -1`


#
# enables a define, removes /* */
#
# (often found in .c or .h files)
#
# $1 = file
# $2 = parameter
#
enable_c =											\
	FILENAME="$(strip $(1))";								\
	PARAMETER="$(strip $(2))";								\
	perl -p -i -e										\
		"s,^\s*(\/\*)?\s*(\#\s*define\s+$$PARAMETER)\s*(\*\/)?$$,\$$2\n,"		\
		$$FILENAME

#
# disables a define with, adds /* */
#
# (often found in .c or .h files)
#
# $1 = file
# $2 = parameter
#
disable_c =											\
	FILENAME="$(strip $(1))";								\
	PARAMETER="$(strip $(2))";								\
	perl -p -i -e										\
		"s,^\s*(\/\*)?\s*(\#\s*define\s+$$PARAMETER)\s*(\*\/)?$$,\/\*\$$2\*\/\n,"	\
		$$FILENAME

#
# enabled something, removes #
#
# often found in shell scripts, Makefiles
#
# $1 = file
# $2 = parameter
#
enable_sh =						\
	FILENAME="$(strip $(1))";			\
	PARAMETER="$(strip $(2))";			\
	perl -p -i -e					\
		"s,^\s*(\#)?\s*($$PARAMETER),\$$2,"	\
		$$FILENAME

#
# disables a comment, adds #
#
# often found in shell scripts, Makefiles
#
# $1 = file
# $2 = parameter
#
disable_sh =						\
	FILENAME="$(strip $(1))";			\
	PARAMETER="$(strip $(2))";			\
	perl -p -i -e					\
		"s,^\s*(\#)?\s*($$PARAMETER),\#\$$2,"	\
		$$FILENAME

#
# go into a directory and apply all patches from there into a sourcetree
#
# $1 = $(PACKET_NAME) -> identifier
# $2 = path to source tree 
#      if this parameter is omitted, the path will be derived
#      from the packet name
#
patchin =									\
	PACKET_NAME="$(strip $(1))";						\
	if [ "$$PACKET_NAME" = "" ]; then					\
		echo;								\
		echo Error: empty parameter to \"patchin\(\)\";			\
		echo;								\
		exit -1;							\
	fi;									\
	PACKET_DIR="$(strip $(2))";						\
	PACKET_DIR=$${PACKET_DIR:-$(BUILDDIR)/$$PACKET_NAME};			\
	for PATCH_NAME in							\
	    $(TOPDIR)/patches/$$PACKET_NAME/generic/*.diff			\
	    $(TOPDIR)/patches/$$PACKET_NAME/generic/*.patch			\
	    $(TOPDIR)/patches/$$PACKET_NAME/generic/*.gz			\
	    $(TOPDIR)/patches/$$PACKET_NAME/generic/*.bz2			\
	    $(TOPDIR)/patches/$$PACKET_NAME/$(PTXCONF_ARCH)/*.diff		\
	    $(TOPDIR)/patches/$$PACKET_NAME/$(PTXCONF_ARCH)/*.patch		\
	    $(TOPDIR)/patches/$$PACKET_NAME/$(PTXCONF_ARCH)/*.gz		\
	    $(TOPDIR)/patches/$$PACKET_NAME/$(PTXCONF_ARCH)/*.bz2		\
	    $(TOPDIR)/patches/$$PACKET_NAME/$(PTXCONF_ARCH)-$(PTXCONF_FPU_TYPE)/*.diff		\
	    $(TOPDIR)/patches/$$PACKET_NAME/$(PTXCONF_ARCH)-$(PTXCONF_FPU_TYPE)/*.patch		\
	    $(TOPDIR)/patches/$$PACKET_NAME/$(PTXCONF_ARCH)-$(PTXCONF_FPU_TYPE)/*.gz		\
	    $(TOPDIR)/patches/$$PACKET_NAME/$(PTXCONF_ARCH)-$(PTXCONF_FPU_TYPE)/*.bz2;		\
	    do									\
		if [ -f $$PATCH_NAME ]; then					\
			case `basename $$PATCH_NAME` in				\
			*.gz)							\
				CAT=$(ZCAT)					\
				;;						\
			*.bz2)							\
				CAT=$(BZCAT)					\
				;;						\
			*.diff|diff*|*.patch|patch*)				\
				CAT=$(CAT)					\
				;;						\
			*)							\
				echo;						\
				echo Unknown patch format, cannot apply!;	\
				echo;						\
				exit -1;					\
				;;						\
			esac;							\
			echo "patchin' $$PATCH_NAME ...";			\
			$$CAT $$PATCH_NAME | $(PATCH) -Np1 -d $$PACKET_DIR || exit -1;	\
		fi;								\
	    done

#
# apply a patch
#
# $1 = the name of the patch to apply
# #2 = apply patch to that directory
#
patch_apply =								\
	PATCH_NAME="$(strip $(1))";					\
	if [ "$$PATCH_NAME" = "" ]; then				\
		echo;							\
		echo Error: empty parameter to \"patch_apply\(\)\";	\
		echo;							\
		exit -1;						\
	fi;								\
	PACKET_DIR="$(strip $(2))";					\
	if [ -f $$PATCH_NAME ]; then					\
		case `basename $$PATCH_NAME` in				\
		*.gz)							\
			CAT=$(ZCAT)					\
			;;						\
		*.bz2)							\
			CAT=$(BZCAT)					\
			;;						\
		*.diff|diff*|*.patch|patch*)				\
			CAT=$(CAT)					\
			;;						\
		*)							\
			echo;						\
			echo Unknown patch format, cannot apply!;	\
			echo;						\
			exit -1;					\
			;;						\
		esac;							\
		echo "patchin' $$PATCH_NAME ...";			\
		$$CAT $$PATCH_NAME | $(PATCH) -Np1 -d $$PACKET_DIR || exit -1;	\
	fi;								\
	true;


#
# CFLAGS // CXXFLAGS
#
# the TARGET_CFLAGS and TARGET_CXXFLAGS are included from the architecture
# depended config file that is specified in .config
#
# the option in the .config is called 'TARGET_CONFIG_FILE'
#
#
TARGET_CFLAGS		+= $(PTXCONF_TARGET_EXTRA_CFLAGS)
TARGET_CXXFLAGS		+= $(PTXCONF_TARGET_EXTRA_CXXFLAGS)


#
# crossenvironment
#
CROSS_ENV_AR		= AR=$(PTXCONF_GNU_TARGET)-ar
CROSS_ENV_AS		= AS=$(PTXCONF_GNU_TARGET)-as
CROSS_ENV_LD		= LD=$(PTXCONF_GNU_TARGET)-ld
CROSS_ENV_NM		= NM=$(PTXCONF_GNU_TARGET)-nm
CROSS_ENV_CC		= CC=$(PTXCONF_GNU_TARGET)-gcc
CROSS_ENV_CXX		= CXX=$(PTXCONF_GNU_TARGET)-g++
CROSS_ENV_OBJCOPY	= OBJCOPY=$(PTXCONF_GNU_TARGET)-objcopy
CROSS_ENV_OBJDUMP	= OBJDUMP=$(PTXCONF_GNU_TARGET)-objdump
CROSS_ENV_RANLIB	= RANLIB=$(PTXCONF_GNU_TARGET)-ranlib
CROSS_ENV_STRIP		= STRIP=$(PTXCONF_GNU_TARGET)-strip
ifneq ('','$(strip $(subst ",,$(TARGET_CFLAGS)))')
CROSS_ENV_CFLAGS	= CFLAGS='$(strip $(subst ",,$(TARGET_CFLAGS)))'
endif
ifneq ('','$(strip $(subst ",,$(TARGET_CXXFLAGS)))')
CROSS_ENV_CXXFLAGS	= CXXFLAGS='$(strip $(subst ",,$(TARGET_CXXFLAGS)))'
endif

CROSS_ENV := \
	$(CROSS_ENV_AR) \
	$(CROSS_ENV_AS) \
	$(CROSS_ENV_CXX) \
	$(CROSS_ENV_CC) \
	$(CROSS_ENV_LD) \
	$(CROSS_ENV_NM) \
	$(CROSS_ENV_OBJCOPY) \
	$(CROSS_ENV_OBJDUMP) \
	$(CROSS_ENV_RANLIB) \
	$(CROSS_ENV_STRIP) \
	$(CROSS_ENV_CFLAGS) \
	$(CROSS_ENV_CXXFLAGS)

###
###
###
#ifdef PTXCONF_ARCH_TARGET_EQU_HOST
#CROSS_ENV += \
#	LD_LIBRARY_PATH=$(CROSS_LIB_DIR)/lib
#endif

###
###
###
ifdef PTXCONF_ARCH_X86
TARGET_OPT_CFLAGS=-O3 -fomit-frame-pointer

# glib
CROSS_ENV += \
	glib_cv_stack_grows=no \
	ac_cv_func_vsnprintf_c99=yes \
	ac_cv_func_printf_unix98=yes \
	ac_cv_sizeof_long_long=8 \
	glib_cv_long_long_format=ll \
	ac_cv_func_posix_getpwuid_r=yes

# dbus
CROSS_ENV += \
	ac_cv_func_posix_getpwnam_r=yes

# Orbit2
CROSS_ENV += \
	ac_cv_c_bigendian=no \
	ac_cv_alignof_CORBA_boolean=1 \
	ac_cv_alignof_CORBA_char=1 \
	ac_cv_alignof_CORBA_double=4 \
	ac_cv_alignof_CORBA_float=4 \
	ac_cv_alignof_CORBA_long=4 \
	ac_cv_alignof_CORBA_long_double=4 \
	ac_cv_alignof_CORBA_long_long=4 \
	ac_cv_alignof_CORBA_octet=1 \
	ac_cv_alignof_CORBA_pointer=4 \
	ac_cv_alignof_CORBA_short=2 \
	ac_cv_alignof_CORBA_struct=1 \
	ac_cv_alignof_CORBA_wchar=2

# xkbd
CROSS_ENV += \
	ac_cv_func_malloc_0_nonnull=yes \
	ac_cv_func_realloc_0_nonnull=yes \
	ac_cv_func_strnlen_working=yes

# mysql
CROSS_ENV += \
	mysql_cv_func_atomic_sub=yes \
	mysql_cv_func_atomic_add=yes \
	ac_cv_conv_longlong_to_float=yes \
	ac_cv_sys_restartable_syscalls=yes

# ddd
CROSS_ENV += \
	ac_cv_func_getpgrp_void=yes \
	ac_cv_func_setpgrp_void=yes

endif

###
###
###
ifdef PTXCONF_ARCH_ARM
TARGET_OPT_CFLAGS=-Os -fomit-frame-pointer

CROSS_ENV += \
	ac_cv_func_getpgrp_void=yes \
	ac_cv_func_setpgrp_void=yes \
	ac_cv_sizeof_long_long=8 \
	ac_cv_func_memcmp_clean=yes \
	ac_cv_func_setvbuf_reversed=no \
	ac_cv_func_getrlimit=yes

# xkbd
CROSS_ENV += \
	ac_cv_func_malloc_0_nonnull=yes \
	ac_cv_func_realloc_0_nonnull=yes \
	ac_cv_func_strnlen_working=yes

# dbus
CROSS_ENV += \
	ac_cv_func_posix_getpwnam_r=yes

# Orbit2
CROSS_ENV += \
	ac_cv_c_bigendian=no ac_cv_alignof_CORBA_octet=1 ac_cv_alignof_CORBA_boolean=1 \
	ac_cv_alignof_CORBA_char=1 ac_cv_alignof_CORBA_wchar=2 ac_cv_alignof_CORBA_short=2 \
	ac_cv_alignof_CORBA_long=4 ac_cv_alignof_CORBA_long_long=4 ac_cv_alignof_CORBA_float=4 \
	ac_cv_alignof_CORBA_double=4 ac_cv_alignof_CORBA_long_double=4 ac_cv_alignof_CORBA_struct=4 \
	ac_cv_alignof_CORBA_pointer=4 

# findutils
CROSS_ENV += \
	ac_cv_func_closedir_void=yes

# glib
CROSS_ENV += \
	glib_cv_stack_grows=no \
	glib_cv_use_pid_surrogate=no \
	ac_cv_func_posix_getpwuid_r=yes \
	ac_cv_sizeof_long_long=8 \
	glib_cv_long_long_format=ll \
	ac_cv_func_vsnprintf_c99=yes \
	ac_cv_func_printf_unix98=yes

# mysql
CROSS_ENV += \
	mysql_cv_func_atomic_sub=no \
	mysql_cv_func_atomic_add=no \
	ac_cv_conv_longlong_to_float=yes \
	ac_cv_sys_restartable_syscalls=yes

# apache
CROSS_ENV += \
	ac_cv_func_pthread_key_delete=yes 	\
	apr_cv_process_shared_works=no		\
	ac_cv_sizeof_size_t=4			\
	ac_cv_sizeof_ssize_t=4			\
	ac_cv_header_netinet_sctp_h=no		\
	ac_cv_header_netinet_sctp_uio_h=no	\
	ac_cv_sctp=no

# php
CROSS_ENV += \
	ac_cv_pread=no \
	ac_cv_pwrite=no \
	php_cv_lib_cookie_io_functions_use_off64_t=yes \
	ac_cv_func_fopencookie=no \
	ac_cv_func_getaddrinfo=yes

# mono
CROSS_ENV += \
	cv_mono_sizeof_sunpath=108

endif

ifdef PTXCONF_ARCH_SH
TARGET_OPT_CFLAGS=-O3 -fomit-frame-pointer

# findutils
CROSS_ENV += \
	ac_cv_func_closedir_void=yes

endif

#
# CROSS_LIB_DIR	= into this dir, the libs for the target system, are installed
#
CROSS_LIB_DIR		= $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)
NATIVE_LIB_DIR		= $(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)

#
# Use the masquerading method of invoking distcc if enabled
#
#
ifdef PTXCONF_XCHAIN-DISTCC
# FIXME: should also allow use of DISTCC for native stuff
DISTCC_PATH_COLON     = $(PTXCONF_PREFIX)/lib/distcc/bin:
endif

#
# prepare the search path
#
CROSS_PATH		= $(DISTCC_PATH_COLON)$(PTXCONF_PREFIX)/bin:$$PATH

#
# same as PTXCONF_GNU_TARGET, but w/o -linux
# e.g. i486 instead of i486-linux
#
SHORT_TARGET		:= `echo $(PTXCONF_GNU_TARGET) |  perl -i -p -e 's/(.*?)-.*/$$1/'`

#
# change this if you have some wired configuration :)
#
SH		:= /bin/sh
WGET		:= wget
MAKE		:= make
PATCH		:= patch
TAR		:= tar
GZIP		:= gzip
ZCAT		:= zcat
BZIP2		:= bzip2
BZCAT		:= bzcat
CAT		:= cat
RM		:= rm
MKDIR		:= mkdir
CD		:= cd
MV		:= mv
CP		:= cp
LN		:= ln
PERL		:= perl
GREP		:= grep
INSTALL		:= install

# vim: syntax=make
