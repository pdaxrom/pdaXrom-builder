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
ifdef PTXCONF_STELLA
PACKAGES += stella
endif

#
# Paths and names
#
STELLA_VENDOR_VERSION	= 1
STELLA_VERSION		= 1.4.1
STELLA			= stella-$(STELLA_VERSION)-src
STELLA_SUFFIX		= tar.gz
STELLA_URL		= http://umn.dl.sourceforge.net/sourceforge/stella/$(STELLA).$(STELLA_SUFFIX)
STELLA_SOURCE		= $(SRCDIR)/$(STELLA).$(STELLA_SUFFIX)
STELLA_DIR		= $(BUILDDIR)/stella-$(STELLA_VERSION)
STELLA_IPKG_TMP		= $(STELLA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

stella_get: $(STATEDIR)/stella.get

stella_get_deps = $(STELLA_SOURCE)

$(STATEDIR)/stella.get: $(stella_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(STELLA))
	touch $@

$(STELLA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(STELLA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

stella_extract: $(STATEDIR)/stella.extract

stella_extract_deps = $(STATEDIR)/stella.get

$(STATEDIR)/stella.extract: $(stella_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(STELLA_DIR))
	@$(call extract, $(STELLA_SOURCE))
	@$(call patchin, $(STELLA), $(STELLA_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

stella_prepare: $(STATEDIR)/stella.prepare

#
# dependencies
#
stella_prepare_deps = \
	$(STATEDIR)/stella.extract \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/virtual-xchain.install

STELLA_PATH	=  PATH=$(CROSS_PATH)
STELLA_ENV 	=  $(CROSS_ENV)
#STELLA_ENV	+=
STELLA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#STELLA_OPTIONS	+= OPTLIB=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
STELLA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
STELLA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
STELLA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/stella.prepare: $(stella_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(STELLA_DIR)/config.cache)
	#cd $(STELLA_DIR) && \
	#	$(STELLA_PATH) $(STELLA_ENV) \
	#	./configure $(STELLA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

stella_compile: $(STATEDIR)/stella.compile

stella_compile_deps = $(STATEDIR)/stella.prepare

$(STATEDIR)/stella.compile: $(stella_compile_deps)
	@$(call targetinfo, $@)
	$(STELLA_PATH) $(STELLA_ENV) $(MAKE) -C $(STELLA_DIR)/src/build linux $(STELLA_OPTIONS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

stella_install: $(STATEDIR)/stella.install

$(STATEDIR)/stella.install: $(STATEDIR)/stella.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

stella_targetinstall: $(STATEDIR)/stella.targetinstall

stella_targetinstall_deps = $(STATEDIR)/stella.compile \
	$(STATEDIR)/SDL.targetinstall

$(STATEDIR)/stella.targetinstall: $(stella_targetinstall_deps)
	@$(call targetinfo, $@)
	$(INSTALL) -m 755 -D $(STELLA_DIR)/src/build/stella $(STELLA_IPKG_TMP)/usr/bin/stella
	mkdir -p $(STELLA_IPKG_TMP)/CONTROL
	echo "Package: stella" 									 >$(STELLA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(STELLA_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 								>>$(STELLA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(STELLA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(STELLA_IPKG_TMP)/CONTROL/control
	echo "Version: $(STELLA_VERSION)-$(STELLA_VENDOR_VERSION)" 				>>$(STELLA_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl" 									>>$(STELLA_IPKG_TMP)/CONTROL/control
	echo "Description: Atari 2600 emulator"							>>$(STELLA_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(STELLA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_STELLA_INSTALL
ROMPACKAGES += $(STATEDIR)/stella.imageinstall
endif

stella_imageinstall_deps = $(STATEDIR)/stella.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/stella.imageinstall: $(stella_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install stella
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

stella_clean:
	rm -rf $(STATEDIR)/stella.*
	rm -rf $(STELLA_DIR)

# vim: syntax=make
