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
ifdef PTXCONF_NATIVE_BINUTILS
PACKAGES += native_binutils
endif

#
# Paths and names
#
NATIVE_BINUTILS			= $(BINUTILS)
NATIVE_BINUTILS_DIR		= $(BUILDDIR)/$(NATIVE_BINUTILS)
NATIVE_BINUTILS_BUILD_DIR	= $(NATIVE_BINUTILS_DIR)-build
NATIVE_BINUTILS_IPKG_TMP	= $(NATIVE_BINUTILS_BUILD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

native_binutils_get: $(STATEDIR)/native_binutils.get

native_binutils_get_deps = $(NATIVE_BINUTILS_SOURCE)

$(STATEDIR)/native_binutils.get: $(native_binutils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BINUTILS))
	touch $@

$(NATIVE_BINUTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BINUTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

native_binutils_extract: $(STATEDIR)/native_binutils.extract

native_binutils_extract_deps = $(STATEDIR)/native_binutils.get

$(STATEDIR)/native_binutils.extract: $(native_binutils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NATIVE_BINUTILS_DIR))
	@$(call extract, $(BINUTILS_SOURCE))
	@$(call patchin, $(BINUTILS), $(NATIVE_BINUTILS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

native_binutils_prepare: $(STATEDIR)/native_binutils.prepare

#
# dependencies
#
native_binutils_prepare_deps = \
	$(STATEDIR)/native_binutils.extract \
	$(STATEDIR)/virtual-xchain.install

NATIVE_BINUTILS_PATH	=  PATH=$(CROSS_PATH)
NATIVE_BINUTILS_ENV 	=  $(CROSS_ENV)

#
# autoconf
#
NATIVE_BINUTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX) \
	--enable-targets=$(PTXCONF_GNU_TARGET) \
	$(BINUTILS_EXTRA_CONFIG) \
	--disable-nls \
	--enable-shared \
	--with-lib-path="$(NATIVE_LIB_DIR)/usr/lib:$(NATIVE_LIB_DIR)/lib:$(NATIVE_LIB_DIR)/X11R6/lib:/lib:/usr/lib:/usr/local/lib:/usr/X11R6/lib" \
	--enable-commonbfdlib

#	--enable-install-libiberty
#	--with-sysroot=$(CROSS_LIB_DIR)

$(STATEDIR)/native_binutils.prepare: $(native_binutils_prepare_deps)
	@$(call targetinfo, $@)
	#@$(call clean, $(NATIVE_BINUTILS_DIR)/config.cache)
	rm -rf $(NATIVE_BINUTILS_BUILD_DIR)
	mkdir $(NATIVE_BINUTILS_BUILD_DIR)
	cd $(NATIVE_BINUTILS_BUILD_DIR) && \
		$(NATIVE_BINUTILS_PATH) $(NATIVE_BINUTILS_ENV) \
		$(NATIVE_BINUTILS_DIR)/configure $(NATIVE_BINUTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

native_binutils_compile: $(STATEDIR)/native_binutils.compile

native_binutils_compile_deps = $(STATEDIR)/native_binutils.prepare

$(STATEDIR)/native_binutils.compile: $(native_binutils_compile_deps)
	@$(call targetinfo, $@)
	$(NATIVE_BINUTILS_PATH) $(MAKE) -C $(NATIVE_BINUTILS_BUILD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

native_binutils_install: $(STATEDIR)/native_binutils.install

$(STATEDIR)/native_binutils.install: $(STATEDIR)/native_binutils.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

native_binutils_targetinstall: $(STATEDIR)/native_binutils.targetinstall

native_binutils_targetinstall_deps = $(STATEDIR)/native_binutils.compile

$(STATEDIR)/native_binutils.targetinstall: $(native_binutils_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NATIVE_BINUTILS_PATH) $(MAKE) -C $(NATIVE_BINUTILS_BUILD_DIR) DESTDIR=$(NATIVE_BINUTILS_IPKG_TMP) install MAKEINFO=true
	rm -f $(NATIVE_BINUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/*
	ln -sf ../../bin/ar $(NATIVE_BINUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/ar
	ln -sf ../../bin/as $(NATIVE_BINUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/as
	ln -sf ../../bin/ld $(NATIVE_BINUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/ld
	ln -sf ../../bin/nm $(NATIVE_BINUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/nm
	ln -sf ../../bin/ranlib $(NATIVE_BINUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/ranlib
	ln -sf ../../bin/strip  $(NATIVE_BINUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/strip
	$(CROSSSTRIP) $(NATIVE_BINUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/*
	$(CROSSSTRIP) $(NATIVE_BINUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/lib/*.so
	rm -f  $(NATIVE_BINUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/lib/*.*a
	rm -rf $(NATIVE_BINUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/info
	rm -rf $(NATIVE_BINUTILS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/man
	mkdir -p $(NATIVE_BINUTILS_IPKG_TMP)/CONTROL
	echo "Package: binutils"	 		>$(NATIVE_BINUTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(NATIVE_BINUTILS_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 			>>$(NATIVE_BINUTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(NATIVE_BINUTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(NATIVE_BINUTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(BINUTILSX_VERSION)" 		>>$(NATIVE_BINUTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(NATIVE_BINUTILS_IPKG_TMP)/CONTROL/control
	echo "Description: GNU development tools"	>>$(NATIVE_BINUTILS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NATIVE_BINUTILS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NATIVE_BINUTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/native_binutils.imageinstall
endif

native_binutils_imageinstall_deps = $(STATEDIR)/native_binutils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/native_binutils.imageinstall: $(native_binutils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install binutils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

native_binutils_clean:
	rm -rf $(STATEDIR)/native_binutils.*
	rm -rf $(NATIVE_BINUTILS_DIR)

# vim: syntax=make
