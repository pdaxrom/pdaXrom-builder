# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_NATIVE_GCC
PACKAGES += native_gcc
endif

#
# Paths and names
#
NATIVE_GCC		= $(GCC)
NATIVE_GCC_DIR		= $(BUILDDIR)/$(NATIVE_GCC)
NATIVE_GCC_BUILD_DIR	= $(NATIVE_GCC_DIR)-build
NATIVE_GCC_IPKG_TMP	= $(NATIVE_GCC_BUILD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

native_gcc_get: $(STATEDIR)/native_gcc.get

native_gcc_get_deps = $(NATIVE_GCC_SOURCE)

$(STATEDIR)/native_gcc.get: $(native_gcc_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GCC))
	touch $@

$(NATIVE_GCC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GCC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

native_gcc_extract: $(STATEDIR)/native_gcc.extract

native_gcc_extract_deps = $(STATEDIR)/native_gcc.get

$(STATEDIR)/native_gcc.extract: $(native_gcc_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NATIVE_GCC_DIR))
	@$(call extract, $(GCC_SOURCE))
	@$(call patchin, $(GCC), $(NATIVE_GCC_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

native_gcc_prepare: $(STATEDIR)/native_gcc.prepare

#
# dependencies
#
native_gcc_prepare_deps = \
	$(STATEDIR)/native_gcc.extract \
	$(STATEDIR)/virtual-xchain.install

NATIVE_GCC_PATH	=  PATH=$(CROSS_PATH)
NATIVE_GCC_ENV 	=  $(CROSS_ENV)

#
# autoconf
#
NATIVE_GCC_AUTOCONF = \
	--host=$(PTXCONF_GNU_TARGET) \
	--build=$(GNU_HOST) \
	--target=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX) \
	$(GCC_EXTRA_CONFIG) \
	$(GCC_STAGE2_AUTOCONF_THREADS) \
	--with-local-prefix=$(NATIVE_LIB_DIR) \
	--disable-nls \
	--enable-symvers=gnu \
	--enable-target-optspace \
	--enable-c99 \
	--enable-long-long \
	--enable-multilib

#	--with-headers=$(CROSS_LIB_DIR)/include

ifdef PTXCONF_GCC_SHARED
NATIVE_GCC_AUTOCONF	+= --enable-shared
else
NATIVE_GCC_AUTOCONF	+= --disable-shared
endif

#
# build C++ by default
#
# ifdef PTXCONF_CXX
NATIVE_GCC_AUTOCONF	+= --enable-languages="c,c++"
# else
# NATIVE_GCC_AUTOCONF	+= --enable-languages="c"
# endif

ifdef PTXCONF_GLIBC
NATIVE_GCC_AUTOCONF	+= --enable-__cxa_atexit
endif
ifdef PTXCONF_UCLIBC
NATIVE_GCC_AUTOCONF	+= --disable-__cxa_atexit
endif

ifndef PTXCONF_ARCH_X86
ifndef PTXCONF_ARCH_SH
ifdef PTXCONF_GCC_SOFTFLOAT
 ifndef PTXCONF_GCC_3_3_2
 NATIVE_GCC_AUTOCONF	+= --with-float=soft
 endif
else
NATIVE_GCC_AUTOCONF	+= --with-float=hard
endif
endif
endif

$(STATEDIR)/native_gcc.prepare: $(native_gcc_prepare_deps)
	@$(call targetinfo, $@)
	#@$(call clean, $(NATIVE_GCC_DIR)/config.cache)
	rm -rf $(NATIVE_GCC_BUILD_DIR)
	mkdir $(NATIVE_GCC_BUILD_DIR)
	cd $(NATIVE_GCC_BUILD_DIR) && \
		$(NATIVE_GCC_PATH) $(NATIVE_GCC_ENV) \
		$(NATIVE_GCC_DIR)/configure  $(NATIVE_GCC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

native_gcc_compile: $(STATEDIR)/native_gcc.compile

native_gcc_compile_deps = $(STATEDIR)/native_gcc.prepare

$(STATEDIR)/native_gcc.compile: $(native_gcc_compile_deps)
	@$(call targetinfo, $@)
	$(NATIVE_GCC_PATH) $(MAKE) -C $(NATIVE_GCC_BUILD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

native_gcc_install: $(STATEDIR)/native_gcc.install

$(STATEDIR)/native_gcc.install: $(STATEDIR)/native_gcc.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

native_gcc_targetinstall: $(STATEDIR)/native_gcc.targetinstall

native_gcc_targetinstall_deps = $(STATEDIR)/native_gcc.compile

$(STATEDIR)/native_gcc.targetinstall: $(native_gcc_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NATIVE_GCC_PATH) $(MAKE) -C $(NATIVE_GCC_BUILD_DIR) DESTDIR=$(NATIVE_GCC_IPKG_TMP) install
	rm -f $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/$(PTXCONF_ARCH)-*
	rm -f $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/c++
	ln -sf gcc $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/cc
	ln -sf g++ $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/c++
	$(CROSSSTRIP) $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/cpp
	$(CROSSSTRIP) $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/g++
	$(CROSSSTRIP) $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/gcc
	$(CROSSSTRIP) $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/gcov
	rm -rf $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/info
	rm -rf $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/man
	rm -f  $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/lib/*.so*

	$(CROSSSTRIP) $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/lib/gcc-lib/$(PTXCONF_GNU_TARGET)/$(GCC_VERSION)/cc1
	$(CROSSSTRIP) $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/lib/gcc-lib/$(PTXCONF_GNU_TARGET)/$(GCC_VERSION)/cc1plus
	$(CROSSSTRIP) $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/lib/gcc-lib/$(PTXCONF_GNU_TARGET)/$(GCC_VERSION)/collect2

	$(CROSSSTRIP) $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/libexec/gcc/$(PTXCONF_GNU_TARGET)/$(GCC_VERSION)/cc1
	$(CROSSSTRIP) $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/libexec/gcc/$(PTXCONF_GNU_TARGET)/$(GCC_VERSION)/cc1plus
	$(CROSSSTRIP) $(NATIVE_GCC_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/libexec/gcc/$(PTXCONF_GNU_TARGET)/$(GCC_VERSION)/collect2

	mkdir -p $(NATIVE_GCC_IPKG_TMP)/CONTROL
	echo "Package: gcc" 				>$(NATIVE_GCC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(NATIVE_GCC_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 			>>$(NATIVE_GCC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(NATIVE_GCC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(NATIVE_GCC_IPKG_TMP)/CONTROL/control
	echo "Version: $(GCC_VERSION)"	 		>>$(NATIVE_GCC_IPKG_TMP)/CONTROL/control
	echo "Depends: binutils" 			>>$(NATIVE_GCC_IPKG_TMP)/CONTROL/control
	echo "Description: GNU C/C++ Compilers"		>>$(NATIVE_GCC_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NATIVE_GCC_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NATIVE_GCC_INSTALL
ROMPACKAGES += $(STATEDIR)/native_gcc.imageinstall
endif

native_gcc_imageinstall_deps = $(STATEDIR)/native_gcc.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/native_gcc.imageinstall: $(native_gcc_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gcc
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

native_gcc_clean:
	rm -rf $(STATEDIR)/native_gcc.*
	rm -rf $(NATIVE_GCC_DIR)

# vim: syntax=make
