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
ifdef PTXCONF_QUAKE1
PACKAGES += quake1
endif

#
# Paths and names
#
QUAKE1_VERSION		= 1.0.0
QUAKE1			= quake1src
QUAKE1_SUFFIX		= tar.bz2
QUAKE1_URL		= http://www.pdaXrom.org/src/$(QUAKE1).$(QUAKE1_SUFFIX)
QUAKE1_DATA_URL		= http://www.pdaXrom.org/src/pak0.tar.gz
QUAKE1_SOURCE		= $(SRCDIR)/$(QUAKE1).$(QUAKE1_SUFFIX)
QUAKE1_DATA_SOURCE	= $(SRCDIR)/pak0.tar.gz
QUAKE1_DIR		= $(BUILDDIR)/$(QUAKE1)
QUAKE1_IPKG_TMP		= $(QUAKE1_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

quake1_get: $(STATEDIR)/quake1.get

quake1_get_deps = $(QUAKE1_SOURCE)

$(STATEDIR)/quake1.get: $(quake1_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QUAKE1))
	touch $@

$(QUAKE1_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QUAKE1_URL))
	@$(call get, $(QUAKE1_DATA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

quake1_extract: $(STATEDIR)/quake1.extract

quake1_extract_deps = $(STATEDIR)/quake1.get

$(STATEDIR)/quake1.extract: $(quake1_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QUAKE1_DIR))
	@$(call extract, $(QUAKE1_SOURCE))
	@$(call extract, $(QUAKE1_DATA_SOURCE), $(QUAKE1_DIR))
	@$(call patchin, $(QUAKE1))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

quake1_prepare: $(STATEDIR)/quake1.prepare

#
# dependencies
#
quake1_prepare_deps = \
	$(STATEDIR)/quake1.extract \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/virtual-xchain.install

QUAKE1_PATH	=  PATH=$(CROSS_PATH)
QUAKE1_ENV 	=  $(CROSS_ENV)
#QUAKE1_ENV	+=
QUAKE1_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#QUAKE1_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
QUAKE1_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
QUAKE1_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
QUAKE1_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/quake1.prepare: $(quake1_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QUAKE1_DIR)/config.cache)
	#cd $(QUAKE1_DIR) && \
	#	$(QUAKE1_PATH) $(QUAKE1_ENV) \
	#	./configure $(QUAKE1_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

quake1_compile: $(STATEDIR)/quake1.compile

quake1_compile_deps = $(STATEDIR)/quake1.prepare

$(STATEDIR)/quake1.compile: $(quake1_compile_deps)
	@$(call targetinfo, $@)
	$(QUAKE1_PATH) $(MAKE) -C $(QUAKE1_DIR) $(CROSS_ENV_CC) LFLAGS="-s"
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

quake1_install: $(STATEDIR)/quake1.install

$(STATEDIR)/quake1.install: $(STATEDIR)/quake1.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

quake1_targetinstall: $(STATEDIR)/quake1.targetinstall

quake1_targetinstall_deps = $(STATEDIR)/quake1.compile \
	$(STATEDIR)/SDL.targetinstall

$(STATEDIR)/quake1.targetinstall: $(quake1_targetinstall_deps)
	@$(call targetinfo, $@)
	$(QUAKE1_PATH) $(MAKE) -C $(QUAKE1_DIR) DESTDIR=$(QUAKE1_IPKG_TMP) install
	$(QUAKE1_PATH) $(MAKE) -C $(QUAKE1_DIR) DESTDIR=$(QUAKE1_IPKG_TMP) install-data
	mkdir -p $(QUAKE1_IPKG_TMP)/CONTROL
	echo "Package: quake" 						>$(QUAKE1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(QUAKE1_IPKG_TMP)/CONTROL/control
	echo "Section: Games"	 					>>$(QUAKE1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(QUAKE1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(QUAKE1_IPKG_TMP)/CONTROL/control
	echo "Version: $(QUAKE1_VERSION)" 				>>$(QUAKE1_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl" 						>>$(QUAKE1_IPKG_TMP)/CONTROL/control
	echo "Description: Popular 3D shooter."				>>$(QUAKE1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(QUAKE1_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_QUAKE1_INSTALL
ROMPACKAGES += $(STATEDIR)/quake1.imageinstall
endif

quake1_imageinstall_deps = $(STATEDIR)/quake1.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/quake1.imageinstall: $(quake1_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install quake
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

quake1_clean:
	rm -rf $(STATEDIR)/quake1.*
	rm -rf $(QUAKE1_DIR)

# vim: syntax=make
