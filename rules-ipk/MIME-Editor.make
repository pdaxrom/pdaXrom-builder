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
ifdef PTXCONF_MIME-EDITOR
PACKAGES += MIME-Editor
endif

#
# Paths and names
#
MIME-EDITOR_VERSION	= 0.1.3
MIME-EDITOR		= mime-editor-$(MIME-EDITOR_VERSION)
MIME-EDITOR_SUFFIX	= tgz
MIME-EDITOR_URL		= http://heanet.dl.sourceforge.net/sourceforge/rox/$(MIME-EDITOR).$(MIME-EDITOR_SUFFIX)
MIME-EDITOR_SOURCE	= $(SRCDIR)/$(MIME-EDITOR).$(MIME-EDITOR_SUFFIX)
MIME-EDITOR_DIR		= $(BUILDDIR)/$(MIME-EDITOR)
MIME-EDITOR_IPKG_TMP	= $(MIME-EDITOR_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

MIME-Editor_get: $(STATEDIR)/MIME-Editor.get

MIME-Editor_get_deps = $(MIME-EDITOR_SOURCE)

$(STATEDIR)/MIME-Editor.get: $(MIME-Editor_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MIME-EDITOR))
	touch $@

$(MIME-EDITOR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MIME-EDITOR_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

MIME-Editor_extract: $(STATEDIR)/MIME-Editor.extract

MIME-Editor_extract_deps = $(STATEDIR)/MIME-Editor.get

$(STATEDIR)/MIME-Editor.extract: $(MIME-Editor_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MIME-EDITOR_DIR))
	@$(call extract, $(MIME-EDITOR_SOURCE))
	@$(call patchin, $(MIME-EDITOR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

MIME-Editor_prepare: $(STATEDIR)/MIME-Editor.prepare

#
# dependencies
#
MIME-Editor_prepare_deps = \
	$(STATEDIR)/MIME-Editor.extract \
	$(STATEDIR)/virtual-xchain.install

MIME-EDITOR_PATH	=  PATH=$(CROSS_PATH)
MIME-EDITOR_ENV 	=  $(CROSS_ENV)
#MIME-EDITOR_ENV	+=
MIME-EDITOR_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MIME-EDITOR_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MIME-EDITOR_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MIME-EDITOR_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MIME-EDITOR_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/MIME-Editor.prepare: $(MIME-Editor_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MIME-EDITOR_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

MIME-Editor_compile: $(STATEDIR)/MIME-Editor.compile

MIME-Editor_compile_deps = $(STATEDIR)/MIME-Editor.prepare

$(STATEDIR)/MIME-Editor.compile: $(MIME-Editor_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

MIME-Editor_install: $(STATEDIR)/MIME-Editor.install

$(STATEDIR)/MIME-Editor.install: $(STATEDIR)/MIME-Editor.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

MIME-Editor_targetinstall: $(STATEDIR)/MIME-Editor.targetinstall

MIME-Editor_targetinstall_deps = $(STATEDIR)/MIME-Editor.compile

$(STATEDIR)/MIME-Editor.targetinstall: $(MIME-Editor_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(MIME-EDITOR_IPKG_TMP)/usr/apps/Settings
	cp -a $(MIME-EDITOR_DIR)/MIME-Editor $(MIME-EDITOR_IPKG_TMP)/usr/apps/Settings
	rm -f $(MIME-EDITOR_IPKG_TMP)/usr/apps/Settings/MIME-Editor/Messages/*.po
	rm -f $(MIME-EDITOR_IPKG_TMP)/usr/apps/Settings/MIME-Editor/Messages/*.gmo
	find  $(MIME-EDITOR_IPKG_TMP)/usr/apps/Settings -name "CVS" | xargs rm -fr 
	mkdir -p $(MIME-EDITOR_IPKG_TMP)/CONTROL
	echo "Package: mime-editor" 			>$(MIME-EDITOR_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(MIME-EDITOR_IPKG_TMP)/CONTROL/control
	echo "Section: ROX"	 			>>$(MIME-EDITOR_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(MIME-EDITOR_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(MIME-EDITOR_IPKG_TMP)/CONTROL/control
	echo "Version: $(MIME-EDITOR_VERSION)" 		>>$(MIME-EDITOR_IPKG_TMP)/CONTROL/control
	echo "Depends: rox, pygtk, rox-lib" 		>>$(MIME-EDITOR_IPKG_TMP)/CONTROL/control
	echo "Description: MIME database editor">>$(MIME-EDITOR_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MIME-EDITOR_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MIME-EDITOR_INSTALL
ROMPACKAGES += $(STATEDIR)/MIME-Editor.imageinstall
endif

MIME-Editor_imageinstall_deps = $(STATEDIR)/MIME-Editor.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/MIME-Editor.imageinstall: $(MIME-Editor_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mime-editor
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

MIME-Editor_clean:
	rm -rf $(STATEDIR)/MIME-Editor.*
	rm -rf $(MIME-EDITOR_DIR)

# vim: syntax=make
