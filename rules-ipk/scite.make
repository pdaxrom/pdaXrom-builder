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
ifdef PTXCONF_SCITE
PACKAGES += scite
endif

#
# Paths and names
#
SCITE_VERSION_MAJOR	= 1
SCITE_VERSION_MINOR	= 61
SCITE_VERSION		= $(SCITE_VERSION_MAJOR)$(SCITE_VERSION_MINOR)
SCITE			= scite$(SCITE_VERSION)
SCITE_SUFFIX		= tgz
SCITE_URL		= http://heanet.dl.sourceforge.net/sourceforge/scintilla/$(SCITE).$(SCITE_SUFFIX)
SCITE_SOURCE		= $(SRCDIR)/$(SCITE).$(SCITE_SUFFIX)
SCINTILLA		= scintilla$(SCITE_VERSION)
SCINTILLA_DIR		= $(BUILDDIR)/scintilla
SCITE_DIR		= $(BUILDDIR)/scite
SCITE_IPKG_TMP		= $(SCITE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

scite_get: $(STATEDIR)/scite.get

scite_get_deps = $(SCITE_SOURCE)

$(STATEDIR)/scite.get: $(scite_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SCINTILLA))
	@$(call get_patches, $(SCITE))
	touch $@

$(SCITE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SCITE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

scite_extract: $(STATEDIR)/scite.extract

scite_extract_deps = $(STATEDIR)/scite.get

$(STATEDIR)/scite.extract: $(scite_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCITE_DIR))
	@$(call clean, $(SCINTILLA_DIR))
	@$(call extract, $(SCITE_SOURCE))
	@$(call patchin, $(SCINTILLA), $(SCINTILLA_DIR))
	@$(call patchin, $(SCITE),     $(SCITE_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

scite_prepare: $(STATEDIR)/scite.prepare

#
# dependencies
#
scite_prepare_deps = \
	$(STATEDIR)/scite.extract \
	$(STATEDIR)/virtual-xchain.install

SCITE_PATH	=  PATH=$(CROSS_LIB_DIR)/bin:$(CROSS_PATH)
SCITE_ENV 	=  $(CROSS_ENV)
SCITE_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
SCITE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SCITE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SCITE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
SCITE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SCITE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/scite.prepare: $(scite_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SCITE_DIR)/config.cache)
	#cd $(SCITE_DIR) && \
	#	$(SCITE_PATH) $(SCITE_ENV) \
	#	./configure $(SCITE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

scite_compile: $(STATEDIR)/scite.compile

scite_compile_deps = $(STATEDIR)/scite.prepare

$(STATEDIR)/scite.compile: $(scite_compile_deps)
	@$(call targetinfo, $@)
	$(SCITE_PATH) $(SCITE_ENV) $(MAKE) -C $(SCINTILLA_DIR)/gtk GTK2=yes
	$(SCITE_PATH) $(SCITE_ENV) $(MAKE) -C $(SCITE_DIR)/gtk LDFLAGS="" prefix=/usr GTK2=yes
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

scite_install: $(STATEDIR)/scite.install

$(STATEDIR)/scite.install: $(STATEDIR)/scite.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

scite_targetinstall: $(STATEDIR)/scite.targetinstall

scite_targetinstall_deps = $(STATEDIR)/scite.compile

$(STATEDIR)/scite.targetinstall: $(scite_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(SCITE_IPKG_TMP)/usr
	$(SCITE_PATH) $(SCITE_ENV) $(MAKE) -C $(SCITE_DIR)/gtk LDFLAGS="" prefix=$(SCITE_IPKG_TMP)/usr install GTK2=yes
	$(CROSSSTRIP) $(SCITE_IPKG_TMP)/usr/bin/*
	mkdir -p $(SCITE_IPKG_TMP)/CONTROL
	echo "Package: scite" 					>$(SCITE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(SCITE_IPKG_TMP)/CONTROL/control
	echo "Section: Applications"	 			>>$(SCITE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"	>>$(SCITE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(SCITE_IPKG_TMP)/CONTROL/control
	echo "Version: $(SCITE_VERSION_MAJOR).$(SCITE_VERSION_MINOR)">>$(SCITE_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 					>>$(SCITE_IPKG_TMP)/CONTROL/control
	echo "Description: SciTE is a SCIntilla based Text Editor.">>$(SCITE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SCITE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SCITE_INSTALL
ROMPACKAGES += $(STATEDIR)/scite.imageinstall
endif

scite_imageinstall_deps = $(STATEDIR)/scite.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/scite.imageinstall: $(scite_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install scite
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

scite_clean:
	rm -rf $(STATEDIR)/scite.*
	rm -rf $(SCITE_DIR)

# vim: syntax=make
