# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_TTF-BITSTREAM-VERA
PACKAGES += ttf-bitstream-vera
endif

#
# Paths and names
#
TTF-BITSTREAM-VERA_VERSION	= 1.10
TTF-BITSTREAM-VERA		= ttf-bitstream-vera-$(TTF-BITSTREAM-VERA_VERSION)
TTF-BITSTREAM-VERA_SUFFIX	= tar.bz2
TTF-BITSTREAM-VERA_URL		= http://ftp.gnome.org/pub/GNOME/sources/ttf-bitstream-vera/1.10/$(TTF-BITSTREAM-VERA).$(TTF-BITSTREAM-VERA_SUFFIX)
TTF-BITSTREAM-VERA_SOURCE	= $(SRCDIR)/$(TTF-BITSTREAM-VERA).$(TTF-BITSTREAM-VERA_SUFFIX)
TTF-BITSTREAM-VERA_DIR		= $(BUILDDIR)/$(TTF-BITSTREAM-VERA)
TTF-BITSTREAM-VERA_IPKG_TMP	= $(TTF-BITSTREAM-VERA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ttf-bitstream-vera_get: $(STATEDIR)/ttf-bitstream-vera.get

ttf-bitstream-vera_get_deps = $(TTF-BITSTREAM-VERA_SOURCE)

$(STATEDIR)/ttf-bitstream-vera.get: $(ttf-bitstream-vera_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TTF-BITSTREAM-VERA))
	touch $@

$(TTF-BITSTREAM-VERA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TTF-BITSTREAM-VERA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ttf-bitstream-vera_extract: $(STATEDIR)/ttf-bitstream-vera.extract

ttf-bitstream-vera_extract_deps = $(STATEDIR)/ttf-bitstream-vera.get

$(STATEDIR)/ttf-bitstream-vera.extract: $(ttf-bitstream-vera_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TTF-BITSTREAM-VERA_DIR))
	@$(call extract, $(TTF-BITSTREAM-VERA_SOURCE))
	@$(call patchin, $(TTF-BITSTREAM-VERA))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ttf-bitstream-vera_prepare: $(STATEDIR)/ttf-bitstream-vera.prepare

#
# dependencies
#
ttf-bitstream-vera_prepare_deps = \
	$(STATEDIR)/ttf-bitstream-vera.extract \
	$(STATEDIR)/virtual-xchain.install

TTF-BITSTREAM-VERA_PATH	=  PATH=$(CROSS_PATH)
TTF-BITSTREAM-VERA_ENV 	=  $(CROSS_ENV)
#TTF-BITSTREAM-VERA_ENV	+=

#
# autoconf
#
TTF-BITSTREAM-VERA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/ttf-bitstream-vera.prepare: $(ttf-bitstream-vera_prepare_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ttf-bitstream-vera_compile: $(STATEDIR)/ttf-bitstream-vera.compile

ttf-bitstream-vera_compile_deps = $(STATEDIR)/ttf-bitstream-vera.prepare

$(STATEDIR)/ttf-bitstream-vera.compile: $(ttf-bitstream-vera_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ttf-bitstream-vera_install: $(STATEDIR)/ttf-bitstream-vera.install

$(STATEDIR)/ttf-bitstream-vera.install: $(STATEDIR)/ttf-bitstream-vera.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ttf-bitstream-vera_targetinstall: $(STATEDIR)/ttf-bitstream-vera.targetinstall

ttf-bitstream-vera_targetinstall_deps = $(STATEDIR)/ttf-bitstream-vera.compile

$(STATEDIR)/ttf-bitstream-vera.targetinstall: $(ttf-bitstream-vera_targetinstall_deps)
	@$(call targetinfo, $@)
	
	$(INSTALL) -d $(TTF-BITSTREAM-VERA_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	$(INSTALL) -m 644 $(TTF-BITSTREAM-VERA_DIR)/*.ttf      $(TTF-BITSTREAM-VERA_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	$(INSTALL) -d $(TTF-BITSTREAM-VERA_IPKG_TMP)/etc/fonts
	$(INSTALL) -m 644 $(TTF-BITSTREAM-VERA_DIR)/local.conf $(TTF-BITSTREAM-VERA_IPKG_TMP)/etc/fonts

	mkdir -p $(TTF-BITSTREAM-VERA_IPKG_TMP)/CONTROL
	echo "Package: ttf-bitstream-vera" 		 >$(TTF-BITSTREAM-VERA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(TTF-BITSTREAM-VERA_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 		>>$(TTF-BITSTREAM-VERA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(TTF-BITSTREAM-VERA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(TTF-BITSTREAM-VERA_IPKG_TMP)/CONTROL/control
	echo "Version: $(TTF-BITSTREAM-VERA_VERSION)" 	>>$(TTF-BITSTREAM-VERA_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(TTF-BITSTREAM-VERA_IPKG_TMP)/CONTROL/control
	echo "Description:  ttf fonts"			>>$(TTF-BITSTREAM-VERA_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TTF-BITSTREAM-VERA_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TTF-BITSTREAM-VERA_INSTALL
ROMPACKAGES += $(STATEDIR)/ttf-bitstream-vera.imageinstall
endif

ttf-bitstream-vera_imageinstall_deps = $(STATEDIR)/ttf-bitstream-vera.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ttf-bitstream-vera.imageinstall: $(ttf-bitstream-vera_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ttf-bitstream-vera
	touch $@


# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ttf-bitstream-vera_clean:
	rm -rf $(STATEDIR)/ttf-bitstream-vera.*
	rm -rf $(TTF-BITSTREAM-VERA_DIR)

# vim: syntax=make
