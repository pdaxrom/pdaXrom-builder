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
ifdef PTXCONF_PYLDIN
PACKAGES += pyldin
endif

#
# Paths and names
#
PYLDIN_VERSION		= 3.1.2
PYLDIN			= pyldin-$(PYLDIN_VERSION)
PYLDIN_SUFFIX		= tar.bz2
PYLDIN_URL		= http://www.pdaXrom.org/src/$(PYLDIN).$(PYLDIN_SUFFIX)
PYLDIN_SOURCE		= $(SRCDIR)/$(PYLDIN).$(PYLDIN_SUFFIX)
PYLDIN_DIR		= $(BUILDDIR)/$(PYLDIN)
PYLDIN_IPKG_TMP		= $(PYLDIN_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pyldin_get: $(STATEDIR)/pyldin.get

pyldin_get_deps = $(PYLDIN_SOURCE)

$(STATEDIR)/pyldin.get: $(pyldin_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PYLDIN))
	touch $@

$(PYLDIN_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PYLDIN_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pyldin_extract: $(STATEDIR)/pyldin.extract

pyldin_extract_deps = $(STATEDIR)/pyldin.get

$(STATEDIR)/pyldin.extract: $(pyldin_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PYLDIN_DIR))
	@$(call extract, $(PYLDIN_SOURCE))
	@$(call patchin, $(PYLDIN))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pyldin_prepare: $(STATEDIR)/pyldin.prepare

#
# dependencies
#
pyldin_prepare_deps = \
	$(STATEDIR)/pyldin.extract \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/virtual-xchain.install

PYLDIN_PATH	=  PATH=$(CROSS_PATH)
#PYLDIN_ENV 	=  $(CROSS_ENV)
PYLDIN_ENV 	=  $(CROSS_ENV_CC)
PYLDIN_ENV 	+= $(CROSS_ENV_CXX)
PYLDIN_ENV	+= OPT_FLAGS="-O3 -fomit-frame-pointer -funroll-all-loops"
PYLDIN_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PYLDIN_ENV	+= OPT_LIBS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
PYLDIN_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

#ifdef PTXCONF_XFREE430
#PYLDIN_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
#PYLDIN_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
#endif

$(STATEDIR)/pyldin.prepare: $(pyldin_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PYLDIN_DIR)/config.cache)
	##cd $(PYLDIN_DIR) && \
	##	$(PYLDIN_PATH) $(PYLDIN_ENV) \
	##	./configure $(PYLDIN_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pyldin_compile: $(STATEDIR)/pyldin.compile

pyldin_compile_deps = $(STATEDIR)/pyldin.prepare

$(STATEDIR)/pyldin.compile: $(pyldin_compile_deps)
	@$(call targetinfo, $@)
	$(PYLDIN_PATH) $(MAKE) -C $(PYLDIN_DIR) $(PYLDIN_ENV)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pyldin_install: $(STATEDIR)/pyldin.install

$(STATEDIR)/pyldin.install: $(STATEDIR)/pyldin.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pyldin_targetinstall: $(STATEDIR)/pyldin.targetinstall

pyldin_targetinstall_deps = $(STATEDIR)/pyldin.compile \
	$(STATEDIR)/SDL.targetinstall

$(STATEDIR)/pyldin.targetinstall: $(pyldin_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PYLDIN_PATH) $(MAKE) -C $(PYLDIN_DIR) DESTDIR=$(PYLDIN_IPKG_TMP) install
	mkdir -p $(PYLDIN_IPKG_TMP)/CONTROL
	echo "Package: pyldin" 												>$(PYLDIN_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 											>>$(PYLDIN_IPKG_TMP)/CONTROL/control
	echo "Section: Emulators" 											>>$(PYLDIN_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 								>>$(PYLDIN_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 										>>$(PYLDIN_IPKG_TMP)/CONTROL/control
	echo "Version: $(PYLDIN_VERSION)" 										>>$(PYLDIN_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl"					 							>>$(PYLDIN_IPKG_TMP)/CONTROL/control
	echo "Description: Pyldin-601 emulator, old bulgarian computer based on MC6800 CPU and sashz floppy archive."	>>$(PYLDIN_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PYLDIN_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PYLDIN_INSTALL
ROMPACKAGES += $(STATEDIR)/pyldin.imageinstall
endif

pyldin_imageinstall_deps = $(STATEDIR)/pyldin.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pyldin.imageinstall: $(pyldin_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pyldin
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pyldin_clean:
	rm -rf $(STATEDIR)/pyldin.*
	rm -rf $(PYLDIN_DIR)

# vim: syntax=make
