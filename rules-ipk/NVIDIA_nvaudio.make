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
ifdef PTXCONF_NVIDIA_NVAUDIO
PACKAGES += NVIDIA_nvaudio
endif

#
# Paths and names
#
NVIDIA_NVAUDIO_VENDOR_VERSION	= 1
NVIDIA_NVAUDIO_VERSION		= 1.0-0274
NVIDIA_NVAUDIO			= NVIDIA_nvaudio-$(NVIDIA_NVAUDIO_VERSION)
NVIDIA_NVAUDIO_SUFFIX		= tar.gz
NVIDIA_NVAUDIO_URL		= http://www.pdaXrom.org/src/$(NVIDIA_NVAUDIO).$(NVIDIA_NVAUDIO_SUFFIX)
NVIDIA_NVAUDIO_SOURCE		= $(SRCDIR)/$(NVIDIA_NVAUDIO).$(NVIDIA_NVAUDIO_SUFFIX)
NVIDIA_NVAUDIO_DIR		= $(BUILDDIR)/nvpanel
NVIDIA_NVAUDIO_IPKG_TMP		= $(NVIDIA_NVAUDIO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

NVIDIA_nvaudio_get: $(STATEDIR)/NVIDIA_nvaudio.get

NVIDIA_nvaudio_get_deps = $(NVIDIA_NVAUDIO_SOURCE)

$(STATEDIR)/NVIDIA_nvaudio.get: $(NVIDIA_nvaudio_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NVIDIA_NVAUDIO))
	touch $@

$(NVIDIA_NVAUDIO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NVIDIA_NVAUDIO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

NVIDIA_nvaudio_extract: $(STATEDIR)/NVIDIA_nvaudio.extract

NVIDIA_nvaudio_extract_deps = $(STATEDIR)/NVIDIA_nvaudio.get

$(STATEDIR)/NVIDIA_nvaudio.extract: $(NVIDIA_nvaudio_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(NVIDIA_NVAUDIO_DIR))
	@$(call extract, $(NVIDIA_NVAUDIO_SOURCE))
	@$(call patchin, $(NVIDIA_NVAUDIO), $(NVIDIA_NVAUDIO_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

NVIDIA_nvaudio_prepare: $(STATEDIR)/NVIDIA_nvaudio.prepare

#
# dependencies
#
NVIDIA_nvaudio_prepare_deps = \
	$(STATEDIR)/NVIDIA_nvaudio.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

NVIDIA_NVAUDIO_PATH	=  PATH=$(CROSS_PATH)
NVIDIA_NVAUDIO_ENV 	=  $(CROSS_ENV)
#NVIDIA_NVAUDIO_ENV	+=
NVIDIA_NVAUDIO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NVIDIA_NVAUDIO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NVIDIA_NVAUDIO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
NVIDIA_NVAUDIO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NVIDIA_NVAUDIO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/NVIDIA_nvaudio.prepare: $(NVIDIA_nvaudio_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NVIDIA_NVAUDIO_DIR)/config.cache)
	#cd $(NVIDIA_NVAUDIO_DIR) && \
	#	$(NVIDIA_NVAUDIO_PATH) $(NVIDIA_NVAUDIO_ENV) \
	#	./configure $(NVIDIA_NVAUDIO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

NVIDIA_nvaudio_compile: $(STATEDIR)/NVIDIA_nvaudio.compile

NVIDIA_nvaudio_compile_deps = $(STATEDIR)/NVIDIA_nvaudio.prepare

$(STATEDIR)/NVIDIA_nvaudio.compile: $(NVIDIA_nvaudio_compile_deps)
	@$(call targetinfo, $@)
	$(NVIDIA_NVAUDIO_PATH) $(NVIDIA_NVAUDIO_ENV) $(MAKE) -C $(NVIDIA_NVAUDIO_DIR) X11_LIBS=""
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

NVIDIA_nvaudio_install: $(STATEDIR)/NVIDIA_nvaudio.install

$(STATEDIR)/NVIDIA_nvaudio.install: $(STATEDIR)/NVIDIA_nvaudio.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

NVIDIA_nvaudio_targetinstall: $(STATEDIR)/NVIDIA_nvaudio.targetinstall

NVIDIA_nvaudio_targetinstall_deps = $(STATEDIR)/NVIDIA_nvaudio.compile

$(STATEDIR)/NVIDIA_nvaudio.targetinstall: $(NVIDIA_nvaudio_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NVIDIA_NVAUDIO_PATH) $(MAKE) -C $(NVIDIA_NVAUDIO_DIR) INSTROOT=$(NVIDIA_NVAUDIO_IPKG_TMP) install
	mkdir -p $(NVIDIA_NVAUDIO_IPKG_TMP)/usr/share/{applications,pixmaps}
	cp -a $(NVIDIA_NVAUDIO_DIR)/Nvpanel/nvicon_xpm.h	$(NVIDIA_NVAUDIO_IPKG_TMP)/usr/share/pixmaps/nvicon.xpm
	cp -a $(TOPDIR)/config/pics/nvaudio.desktop		$(NVIDIA_NVAUDIO_IPKG_TMP)/usr/share/applications/
	$(CROSSSTRIP) $(NVIDIA_NVAUDIO_IPKG_TMP)/usr/bin/*
	mkdir -p $(NVIDIA_NVAUDIO_IPKG_TMP)/CONTROL
	echo "Package: nvidia-nvaudio" 							 >$(NVIDIA_NVAUDIO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(NVIDIA_NVAUDIO_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(NVIDIA_NVAUDIO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(NVIDIA_NVAUDIO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(NVIDIA_NVAUDIO_IPKG_TMP)/CONTROL/control
	echo "Version: $(NVIDIA_NVAUDIO_VERSION)"				 	>>$(NVIDIA_NVAUDIO_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 								>>$(NVIDIA_NVAUDIO_IPKG_TMP)/CONTROL/control
	echo "Description: NVIDIA NForce audiomixer"					>>$(NVIDIA_NVAUDIO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NVIDIA_NVAUDIO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NVIDIA_NVAUDIO_INSTALL
ROMPACKAGES += $(STATEDIR)/NVIDIA_nvaudio.imageinstall
endif

NVIDIA_nvaudio_imageinstall_deps = $(STATEDIR)/NVIDIA_nvaudio.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/NVIDIA_nvaudio.imageinstall: $(NVIDIA_nvaudio_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install nvidia-nvaudio
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

NVIDIA_nvaudio_clean:
	rm -rf $(STATEDIR)/NVIDIA_nvaudio.*
	rm -rf $(NVIDIA_NVAUDIO_DIR)

# vim: syntax=make
