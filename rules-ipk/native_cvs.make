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
ifdef PTXCONF_NATIVE_CVS
PACKAGES += native_cvs
endif

#
# Paths and names
#
NATIVE_CVS_VENDOR_VERSION	= 1
NATIVE_CVS_VERSION		= 1.11.18
NATIVE_CVS			= cvs-$(NATIVE_CVS_VERSION)
NATIVE_CVS_SUFFIX		= tar.bz2
NATIVE_CVS_URL			= http://ccvs.cvshome.org/files/documents/19/534/$(NATIVE_CVS).$(NATIVE_CVS_SUFFIX)
###NATIVE_CVS_URL			= http://musthave.sunbase.org/progs/ccvs/$(NATIVE_CVS).$(NATIVE_CVS_SUFFIX)
NATIVE_CVS_SOURCE		= $(SRCDIR)/$(NATIVE_CVS).$(NATIVE_CVS_SUFFIX)
NATIVE_CVS_DIR			= $(BUILDDIR)/$(NATIVE_CVS)
NATIVE_CVS_IPKG_TMP		= $(NATIVE_CVS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

native_cvs_get: $(STATEDIR)/native_cvs.get

native_cvs_get_deps = $(NATIVE_CVS_SOURCE)

$(STATEDIR)/native_cvs.get: $(native_cvs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NATIVE_CVS))
	touch $@

$(NATIVE_CVS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NATIVE_CVS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

native_cvs_extract: $(STATEDIR)/native_cvs.extract

native_cvs_extract_deps = $(STATEDIR)/native_cvs.get

$(STATEDIR)/native_cvs.extract: $(native_cvs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NATIVE_CVS_DIR))
	@$(call extract, $(NATIVE_CVS_SOURCE))
	@$(call patchin, $(NATIVE_CVS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

native_cvs_prepare: $(STATEDIR)/native_cvs.prepare

#
# dependencies
#
native_cvs_prepare_deps = \
	$(STATEDIR)/native_cvs.extract \
	$(STATEDIR)/virtual-xchain.install

NATIVE_CVS_PATH	=  PATH=$(CROSS_PATH)
NATIVE_CVS_ENV 	=  $(CROSS_ENV)
#NATIVE_CVS_ENV	+=
NATIVE_CVS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NATIVE_CVS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NATIVE_CVS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_XFREE430
NATIVE_CVS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NATIVE_CVS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/native_cvs.prepare: $(native_cvs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NATIVE_CVS_DIR)/config.cache)
	cd $(NATIVE_CVS_DIR) && \
		$(NATIVE_CVS_PATH) $(NATIVE_CVS_ENV) \
		./configure $(NATIVE_CVS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

native_cvs_compile: $(STATEDIR)/native_cvs.compile

native_cvs_compile_deps = $(STATEDIR)/native_cvs.prepare

$(STATEDIR)/native_cvs.compile: $(native_cvs_compile_deps)
	@$(call targetinfo, $@)
	$(NATIVE_CVS_PATH) $(MAKE) -C $(NATIVE_CVS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

native_cvs_install: $(STATEDIR)/native_cvs.install

$(STATEDIR)/native_cvs.install: $(STATEDIR)/native_cvs.compile
	@$(call targetinfo, $@)
	$(NATIVE_CVS_PATH) $(MAKE) -C $(NATIVE_CVS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

native_cvs_targetinstall: $(STATEDIR)/native_cvs.targetinstall

native_cvs_targetinstall_deps = $(STATEDIR)/native_cvs.compile

$(STATEDIR)/native_cvs.targetinstall: $(native_cvs_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NATIVE_CVS_PATH) $(MAKE) -C $(NATIVE_CVS_DIR) DESTDIR=$(NATIVE_CVS_IPKG_TMP) install
	rm -rf $(NATIVE_CVS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/{man,info}
	rm  -f $(NATIVE_CVS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/cvsbug
	$(CROSSSTRIP) $(NATIVE_CVS_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/cvs
	mkdir -p $(NATIVE_CVS_IPKG_TMP)/CONTROL
	echo "Package: cvs" 											 >$(NATIVE_CVS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(NATIVE_CVS_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 										>>$(NATIVE_CVS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(NATIVE_CVS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(NATIVE_CVS_IPKG_TMP)/CONTROL/control
	echo "Version: $(NATIVE_CVS_VERSION)-$(NATIVE_CVS_VENDOR_VERSION)" 					>>$(NATIVE_CVS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 											>>$(NATIVE_CVS_IPKG_TMP)/CONTROL/control
	echo "Description: The Concurrent Versions System"							>>$(NATIVE_CVS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NATIVE_CVS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NATIVE_CVS_INSTALL
ROMPACKAGES += $(STATEDIR)/native_cvs.imageinstall
endif

native_cvs_imageinstall_deps = $(STATEDIR)/native_cvs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/native_cvs.imageinstall: $(native_cvs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install cvs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

native_cvs_clean:
	rm -rf $(STATEDIR)/native_cvs.*
	rm -rf $(NATIVE_CVS_DIR)

# vim: syntax=make
