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
ifdef PTXCONF_NATIVE_AUTOMAKE
PACKAGES += native_automake
endif

#
# Paths and names
#
NATIVE_AUTOMAKE_VENDOR_VERSION	= 1
NATIVE_AUTOMAKE_VERSION		= $(AUTOMAKE176_VERSION)
NATIVE_AUTOMAKE			= automake-$(AUTOMAKE176_VERSION)
NATIVE_AUTOMAKE_DIR		= $(BUILDDIR)/$(NATIVE_AUTOMAKE)
NATIVE_AUTOMAKE_IPKG_TMP	= $(NATIVE_AUTOMAKE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

native_automake_get: $(STATEDIR)/native_automake.get

native_automake_get_deps = $(NATIVE_AUTOMAKE_SOURCE)

$(STATEDIR)/native_automake.get: $(native_automake_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(AUTOMAKE176))
	touch $@

$(NATIVE_AUTOMAKE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(AUTOMAKE176_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

native_automake_extract: $(STATEDIR)/native_automake.extract

native_automake_extract_deps = $(STATEDIR)/native_automake.get

$(STATEDIR)/native_automake.extract: $(native_automake_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(NATIVE_AUTOMAKE_DIR))
	@$(call extract, $(AUTOMAKE176_SOURCE))
	@$(call patchin, $(AUTOMAKE176))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

native_automake_prepare: $(STATEDIR)/native_automake.prepare

#
# dependencies
#
native_automake_prepare_deps = \
	$(STATEDIR)/native_automake.extract \
	$(STATEDIR)/autoconf257.install \
	$(STATEDIR)/virtual-xchain.install

NATIVE_AUTOMAKE_PATH	=  PATH=$(CROSS_PATH)
NATIVE_AUTOMAKE_ENV 	=  $(CROSS_ENV)
#NATIVE_AUTOMAKE_ENV	+=
NATIVE_AUTOMAKE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NATIVE_AUTOMAKE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NATIVE_AUTOMAKE_AUTOCONF = \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_XFREE430
NATIVE_AUTOMAKE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NATIVE_AUTOMAKE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/native_automake.prepare: $(native_automake_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NATIVE_AUTOMAKE_DIR)/config.cache)
	cd $(NATIVE_AUTOMAKE_DIR) && \
		$(NATIVE_AUTOMAKE_PATH) $(NATIVE_AUTOMAKE_ENV) \
		./configure $(NATIVE_AUTOMAKE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

native_automake_compile: $(STATEDIR)/native_automake.compile

native_automake_compile_deps = $(STATEDIR)/native_automake.prepare

$(STATEDIR)/native_automake.compile: $(native_automake_compile_deps)
	@$(call targetinfo, $@)
	$(NATIVE_AUTOMAKE_PATH) $(MAKE) -C $(NATIVE_AUTOMAKE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

native_automake_install: $(STATEDIR)/native_automake.install

$(STATEDIR)/native_automake.install: $(STATEDIR)/native_automake.compile
	@$(call targetinfo, $@)
	$(NATIVE_AUTOMAKE_PATH) $(MAKE) -C $(NATIVE_AUTOMAKE_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

native_automake_targetinstall: $(STATEDIR)/native_automake.targetinstall

native_automake_targetinstall_deps = $(STATEDIR)/native_automake.compile

$(STATEDIR)/native_automake.targetinstall: $(native_automake_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(NATIVE_AUTOMAKE_IPKG_TMP)
	$(NATIVE_AUTOMAKE_PATH) $(MAKE) -C $(NATIVE_AUTOMAKE_DIR) DESTDIR=$(NATIVE_AUTOMAKE_IPKG_TMP) install
	rm -rf $(NATIVE_AUTOMAKE_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/info
	rm -f  $(NATIVE_AUTOMAKE_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/{aclocal,automake}
	ln -sf aclocal-1.9  $(NATIVE_AUTOMAKE_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/aclocal
	ln -sf automake-1.9 $(NATIVE_AUTOMAKE_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/bin/automake
	mv $(NATIVE_AUTOMAKE_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/share/aclocal-1.9 \
	   $(NATIVE_AUTOMAKE_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/share/aclocal
	ln -sf aclocal $(NATIVE_AUTOMAKE_IPKG_TMP)/$(PTXCONF_NATIVE_PREFIX)/share/aclocal-1.9
	mkdir -p $(NATIVE_AUTOMAKE_IPKG_TMP)/CONTROL
	echo "Package: automake" 									 >$(NATIVE_AUTOMAKE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 									>>$(NATIVE_AUTOMAKE_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 									>>$(NATIVE_AUTOMAKE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 						>>$(NATIVE_AUTOMAKE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 								>>$(NATIVE_AUTOMAKE_IPKG_TMP)/CONTROL/control
	echo "Version: $(NATIVE_AUTOMAKE_VERSION)-$(NATIVE_AUTOMAKE_VENDOR_VERSION)" 			>>$(NATIVE_AUTOMAKE_IPKG_TMP)/CONTROL/control
	echo "Depends: autoconf" 									>>$(NATIVE_AUTOMAKE_IPKG_TMP)/CONTROL/control
	echo "Description: This is Automake, a Makefile generator."					>>$(NATIVE_AUTOMAKE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NATIVE_AUTOMAKE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NATIVE_AUTOMAKE_INSTALL
ROMPACKAGES += $(STATEDIR)/native_automake.imageinstall
endif

native_automake_imageinstall_deps = $(STATEDIR)/native_automake.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/native_automake.imageinstall: $(native_automake_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install automake
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

native_automake_clean:
	rm -rf $(STATEDIR)/native_automake.*
	rm -rf $(NATIVE_AUTOMAKE_DIR)

# vim: syntax=make
