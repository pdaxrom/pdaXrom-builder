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
ifdef PTXCONF_NXKBD
PACKAGES += nxkbd
endif

#
# Paths and names
#
NXKBD_VERSION		= 1.3.2-1
NXKBD			= nxkbd-$(NXKBD_VERSION)
NXKBD_SUFFIX		= tar.gz
NXKBD_URL		= http://www.nomachine.com/source/$(NXKBD).$(NXKBD_SUFFIX)
NXKBD_SOURCE		= $(SRCDIR)/$(NXKBD).$(NXKBD_SUFFIX)
NXKBD_DIR		= $(BUILDDIR)/nxkbd
NXKBD_IPKG_TMP		= $(NXKBD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

nxkbd_get: $(STATEDIR)/nxkbd.get

nxkbd_get_deps = $(NXKBD_SOURCE)

$(STATEDIR)/nxkbd.get: $(nxkbd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NXKBD))
	touch $@

$(NXKBD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NXKBD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

nxkbd_extract: $(STATEDIR)/nxkbd.extract

nxkbd_extract_deps = $(STATEDIR)/nxkbd.get

$(STATEDIR)/nxkbd.extract: $(nxkbd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXKBD_DIR))
	@$(call extract, $(NXKBD_SOURCE))
	@$(call patchin, $(NXKBD), $(NXKBD_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

nxkbd_prepare: $(STATEDIR)/nxkbd.prepare

#
# dependencies
#
nxkbd_prepare_deps = \
	$(STATEDIR)/nxkbd.extract \
	$(STATEDIR)/virtual-xchain.install

NXKBD_PATH	=  PATH=$(CROSS_PATH)
NXKBD_ENV 	=  $(CROSS_ENV)
NXKBD_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
NXKBD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NXKBD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NXKBD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr/NX \
	--enable-xft \
	--enable-xpm

ifdef PTXCONF_XFREE430
NXKBD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NXKBD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/nxkbd.prepare: $(nxkbd_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NXKBD_DIR)/config.cache)
	cd $(NXKBD_DIR) && aclocal
	#cd $(NXKBD_DIR) && automake --add-missing
	cd $(NXKBD_DIR) && autoconf
	cd $(NXKBD_DIR) && \
		$(NXKBD_PATH) $(NXKBD_ENV) \
		./configure $(NXKBD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

nxkbd_compile: $(STATEDIR)/nxkbd.compile

nxkbd_compile_deps = $(STATEDIR)/nxkbd.prepare

$(STATEDIR)/nxkbd.compile: $(nxkbd_compile_deps)
	@$(call targetinfo, $@)
	$(NXKBD_PATH) $(MAKE) -C $(NXKBD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

nxkbd_install: $(STATEDIR)/nxkbd.install

$(STATEDIR)/nxkbd.install: $(STATEDIR)/nxkbd.compile
	@$(call targetinfo, $@)
	asasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

nxkbd_targetinstall: $(STATEDIR)/nxkbd.targetinstall

nxkbd_targetinstall_deps = $(STATEDIR)/nxkbd.compile

$(STATEDIR)/nxkbd.targetinstall: $(nxkbd_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NXKBD_PATH) $(MAKE) -C $(NXKBD_DIR) DESTDIR=$(NXKBD_IPKG_TMP) install
	mkdir -p $(NXKBD_IPKG_TMP)/CONTROL
	echo "Package: nxkbd" 			>$(NXKBD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(NXKBD_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(NXKBD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(NXKBD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(NXKBD_IPKG_TMP)/CONTROL/control
	echo "Version: $(NXKBD_VERSION)" 		>>$(NXKBD_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(NXKBD_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(NXKBD_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(NXKBD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NXKBD_INSTALL
ROMPACKAGES += $(STATEDIR)/nxkbd.imageinstall
endif

nxkbd_imageinstall_deps = $(STATEDIR)/nxkbd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/nxkbd.imageinstall: $(nxkbd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install nxkbd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

nxkbd_clean:
	rm -rf $(STATEDIR)/nxkbd.*
	rm -rf $(NXKBD_DIR)

# vim: syntax=make
