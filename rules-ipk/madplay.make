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
ifdef PTXCONF_MADPLAY
PACKAGES += madplay
endif

#
# Paths and names
#
MADPLAY_VERSION		= 0.15.2b
MADPLAY			= madplay-$(MADPLAY_VERSION)
MADPLAY_SUFFIX		= tar.gz
MADPLAY_URL		= ftp://ftp.mars.org/mpeg/$(MADPLAY).$(MADPLAY_SUFFIX)
MADPLAY_SOURCE		= $(SRCDIR)/$(MADPLAY).$(MADPLAY_SUFFIX)
MADPLAY_DIR		= $(BUILDDIR)/$(MADPLAY)
MADPLAY_IPKG_TMP	= $(MADPLAY_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

madplay_get: $(STATEDIR)/madplay.get

madplay_get_deps = $(MADPLAY_SOURCE)

$(STATEDIR)/madplay.get: $(madplay_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MADPLAY))
	touch $@

$(MADPLAY_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MADPLAY_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

madplay_extract: $(STATEDIR)/madplay.extract

madplay_extract_deps = $(STATEDIR)/madplay.get

$(STATEDIR)/madplay.extract: $(madplay_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MADPLAY_DIR))
	@$(call extract, $(MADPLAY_SOURCE))
	@$(call patchin, $(MADPLAY))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

madplay_prepare: $(STATEDIR)/madplay.prepare

#
# dependencies
#
madplay_prepare_deps = \
	$(STATEDIR)/madplay.extract \
	$(STATEDIR)/libmad.install \
	$(STATEDIR)/libid3tag.install \
	$(STATEDIR)/virtual-xchain.install

MADPLAY_PATH	=  PATH=$(CROSS_PATH)
MADPLAY_ENV 	=  $(CROSS_ENV)
#MADPLAY_ENV	+=
MADPLAY_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MADPLAY_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MADPLAY_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr


ifdef PTXCONF_XFREE430
MADPLAY_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MADPLAY_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/madplay.prepare: $(madplay_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MADPLAY_DIR)/config.cache)
	cd $(MADPLAY_DIR) && \
		$(MADPLAY_PATH) $(MADPLAY_ENV) \
		./configure $(MADPLAY_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

madplay_compile: $(STATEDIR)/madplay.compile

madplay_compile_deps = $(STATEDIR)/madplay.prepare

$(STATEDIR)/madplay.compile: $(madplay_compile_deps)
	@$(call targetinfo, $@)
	$(MADPLAY_PATH) $(MAKE) -C $(MADPLAY_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

madplay_install: $(STATEDIR)/madplay.install

$(STATEDIR)/madplay.install: $(STATEDIR)/madplay.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

madplay_targetinstall: $(STATEDIR)/madplay.targetinstall

madplay_targetinstall_deps = \
	    $(STATEDIR)/madplay.compile \
	    $(STATEDIR)/libmad.targetinstall \
	    $(STATEDIR)/libid3tag.targetinstall


$(STATEDIR)/madplay.targetinstall: $(madplay_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MADPLAY_PATH) $(MAKE) -C $(MADPLAY_DIR) DESTDIR=$(MADPLAY_IPKG_TMP) install
	rm -rf $(MADPLAY_IPKG_TMP)/usr/man
	rm -rf $(MADPLAY_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(MADPLAY_IPKG_TMP)/usr/bin/madplay
	mkdir -p $(MADPLAY_IPKG_TMP)/CONTROL
	echo "Package: madplay" 			>$(MADPLAY_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(MADPLAY_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 			>>$(MADPLAY_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(MADPLAY_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(MADPLAY_IPKG_TMP)/CONTROL/control
	echo "Version: $(MADPLAY_VERSION)" 		>>$(MADPLAY_IPKG_TMP)/CONTROL/control
	echo "Depends: libmad, libid3tag" 		>>$(MADPLAY_IPKG_TMP)/CONTROL/control
	echo "Description: command-line MPEG audio decoder and player based on the MAD library (libmad).">>$(MADPLAY_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MADPLAY_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MADPLAY_INSTALL
ROMPACKAGES += $(STATEDIR)/madplay.imageinstall
endif

madplay_imageinstall_deps = $(STATEDIR)/madplay.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/madplay.imageinstall: $(madplay_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install madplay
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

madplay_clean:
	rm -rf $(STATEDIR)/madplay.*
	rm -rf $(MADPLAY_DIR)

# vim: syntax=make
