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
ifdef PTXCONF_NXCOMPSH
PACKAGES += nxcompsh
endif

#
# Paths and names
#
NXCOMPSH_VERSION	= 1.3.2-1
NXCOMPSH		= nxcompsh-$(NXCOMPSH_VERSION)
NXCOMPSH_SUFFIX		= tar.gz
NXCOMPSH_URL		= http://www.nomachine.com/source/$(NXCOMPSH).$(NXCOMPSH_SUFFIX)
NXCOMPSH_SOURCE		= $(SRCDIR)/$(NXCOMPSH).$(NXCOMPSH_SUFFIX)
NXCOMPSH_DIR		= $(BUILDDIR)/nxcompsh
NXCOMPSH_IPKG_TMP	= $(NXCOMPSH_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

nxcompsh_get: $(STATEDIR)/nxcompsh.get

nxcompsh_get_deps = $(NXCOMPSH_SOURCE)

$(STATEDIR)/nxcompsh.get: $(nxcompsh_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NXCOMPSH))
	touch $@

$(NXCOMPSH_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NXCOMPSH_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

nxcompsh_extract: $(STATEDIR)/nxcompsh.extract

nxcompsh_extract_deps = $(STATEDIR)/nxcompsh.get

$(STATEDIR)/nxcompsh.extract: $(nxcompsh_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXCOMPSH_DIR))
	@$(call extract, $(NXCOMPSH_SOURCE))
	@$(call patchin, $(NXCOMPSH), $(NXCOMPSH_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

nxcompsh_prepare: $(STATEDIR)/nxcompsh.prepare

#
# dependencies
#
nxcompsh_prepare_deps = \
	$(STATEDIR)/nxcompsh.extract \
	$(STATEDIR)/nx-X11.compile \
	$(STATEDIR)/virtual-xchain.install

NXCOMPSH_PATH	=  PATH=$(CROSS_PATH)
NXCOMPSH_ENV 	=  $(CROSS_ENV)
NXCOMPSH_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
NXCOMPSH_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NXCOMPSH_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NXCOMPSH_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr/NX

ifdef PTXCONF_XFREE430
NXCOMPSH_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NXCOMPSH_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/nxcompsh.prepare: $(nxcompsh_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXCOMPSH_DIR)/config.cache)
	cd $(NXCOMPSH_DIR) && \
		$(NXCOMPSH_PATH) $(NXCOMPSH_ENV) \
		./configure $(NXCOMPSH_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

nxcompsh_compile: $(STATEDIR)/nxcompsh.compile

nxcompsh_compile_deps = $(STATEDIR)/nxcompsh.prepare

$(STATEDIR)/nxcompsh.compile: $(nxcompsh_compile_deps)
	@$(call targetinfo, $@)
	$(NXCOMPSH_PATH) $(MAKE) -C $(NXCOMPSH_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

nxcompsh_install: $(STATEDIR)/nxcompsh.install

$(STATEDIR)/nxcompsh.install: $(STATEDIR)/nxcompsh.compile
	@$(call targetinfo, $@)
	asdads
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

nxcompsh_targetinstall: $(STATEDIR)/nxcompsh.targetinstall

nxcompsh_targetinstall_deps = $(STATEDIR)/nxcompsh.compile

$(STATEDIR)/nxcompsh.targetinstall: $(nxcompsh_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NXCOMPSH_PATH) $(MAKE) -C $(NXCOMPSH_DIR) DESTDIR=$(NXCOMPSH_IPKG_TMP) install
	mkdir -p $(NXCOMPSH_IPKG_TMP)/CONTROL
	echo "Package: nxcompsh" 			>$(NXCOMPSH_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(NXCOMPSH_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(NXCOMPSH_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(NXCOMPSH_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(NXCOMPSH_IPKG_TMP)/CONTROL/control
	echo "Version: $(NXCOMPSH_VERSION)" 		>>$(NXCOMPSH_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(NXCOMPSH_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(NXCOMPSH_IPKG_TMP)/CONTROL/control
	asasd
	cd $(FEEDDIR) && $(XMKIPKG) $(NXCOMPSH_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NXCOMPSH_INSTALL
ROMPACKAGES += $(STATEDIR)/nxcompsh.imageinstall
endif

nxcompsh_imageinstall_deps = $(STATEDIR)/nxcompsh.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/nxcompsh.imageinstall: $(nxcompsh_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install nxcompsh
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

nxcompsh_clean:
	rm -rf $(STATEDIR)/nxcompsh.*
	rm -rf $(NXCOMPSH_DIR)

# vim: syntax=make
