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
ifdef PTXCONF_NXRUN
PACKAGES += nxrun
endif

#
# Paths and names
#
NXRUN_VERSION		= 1.3.2-1
NXRUN			= nxrun-$(NXRUN_VERSION)
NXRUN_SUFFIX		= tar.gz
NXRUN_URL		= http://www.nomachine.com/source/$(NXRUN).$(NXRUN_SUFFIX)
NXRUN_SOURCE		= $(SRCDIR)/$(NXRUN).$(NXRUN_SUFFIX)
NXRUN_DIR		= $(BUILDDIR)/nxrun
NXRUN_IPKG_TMP		= $(NXRUN_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

nxrun_get: $(STATEDIR)/nxrun.get

nxrun_get_deps = $(NXRUN_SOURCE)

$(STATEDIR)/nxrun.get: $(nxrun_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NXRUN))
	touch $@

$(NXRUN_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NXRUN_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

nxrun_extract: $(STATEDIR)/nxrun.extract

nxrun_extract_deps = $(STATEDIR)/nxrun.get

$(STATEDIR)/nxrun.extract: $(nxrun_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXRUN_DIR))
	@$(call extract, $(NXRUN_SOURCE))
	@$(call patchin, $(NXRUN), $(NXRUN_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

nxrun_prepare: $(STATEDIR)/nxrun.prepare

#
# dependencies
#
nxrun_prepare_deps = \
	$(STATEDIR)/nxrun.extract \
	$(STATEDIR)/nxcompsh.compile \
	$(STATEDIR)/virtual-xchain.install

NXRUN_PATH	=  PATH=$(CROSS_PATH)
NXRUN_ENV 	=  $(CROSS_ENV)
NXRUN_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
NXRUN_ENV	+= CXXFLAGS="-O2 -fomit-frame-pointer"
NXRUN_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NXRUN_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NXRUN_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr/NX

ifdef PTXCONF_XFREE430
NXRUN_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NXRUN_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/nxrun.prepare: $(nxrun_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXRUN_DIR)/config.cache)
	touch $(NXRUN_DIR)/ChangeLog
	#cd $(NXRUN_DIR) && aclocal
	#cd $(NXRUN_DIR) && automake --add-missing
	#cd $(NXRUN_DIR) && autoconf
	cd $(NXRUN_DIR) && ./autogen.sh
	cd $(NXRUN_DIR) && \
		$(NXRUN_PATH) $(NXRUN_ENV) \
		./configure $(NXRUN_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(NXRUN_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

nxrun_compile: $(STATEDIR)/nxrun.compile

nxrun_compile_deps = $(STATEDIR)/nxrun.prepare

$(STATEDIR)/nxrun.compile: $(nxrun_compile_deps)
	@$(call targetinfo, $@)
	$(NXRUN_PATH) $(MAKE) -C $(NXRUN_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

nxrun_install: $(STATEDIR)/nxrun.install

$(STATEDIR)/nxrun.install: $(STATEDIR)/nxrun.compile
	@$(call targetinfo, $@)
	asads
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

nxrun_targetinstall: $(STATEDIR)/nxrun.targetinstall

nxrun_targetinstall_deps = $(STATEDIR)/nxrun.compile

$(STATEDIR)/nxrun.targetinstall: $(nxrun_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NXRUN_PATH) $(MAKE) -C $(NXRUN_DIR) DESTDIR=$(NXRUN_IPKG_TMP) install
	mkdir -p $(NXRUN_IPKG_TMP)/CONTROL
	echo "Package: nxrun" 			>$(NXRUN_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(NXRUN_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(NXRUN_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(NXRUN_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(NXRUN_IPKG_TMP)/CONTROL/control
	echo "Version: $(NXRUN_VERSION)" 		>>$(NXRUN_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(NXRUN_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(NXRUN_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(NXRUN_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NXRUN_INSTALL
ROMPACKAGES += $(STATEDIR)/nxrun.imageinstall
endif

nxrun_imageinstall_deps = $(STATEDIR)/nxrun.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/nxrun.imageinstall: $(nxrun_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install nxrun
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

nxrun_clean:
	rm -rf $(STATEDIR)/nxrun.*
	rm -rf $(NXRUN_DIR)

# vim: syntax=make
