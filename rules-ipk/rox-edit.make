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
ifdef PTXCONF_ROX-EDIT
PACKAGES += rox-edit
endif

#
# Paths and names
#
ROX-EDIT_VERSION	= 1.9.6
ROX-EDIT		= edit-$(ROX-EDIT_VERSION)
ROX-EDIT_SUFFIX		= tgz
ROX-EDIT_URL		= http://heanet.dl.sourceforge.net/sourceforge/rox/$(ROX-EDIT).$(ROX-EDIT_SUFFIX)
ROX-EDIT_SOURCE		= $(SRCDIR)/$(ROX-EDIT).$(ROX-EDIT_SUFFIX)
ROX-EDIT_DIR		= $(BUILDDIR)/$(ROX-EDIT)
ROX-EDIT_IPKG_TMP	= $(ROX-EDIT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rox-edit_get: $(STATEDIR)/rox-edit.get

rox-edit_get_deps = $(ROX-EDIT_SOURCE)

$(STATEDIR)/rox-edit.get: $(rox-edit_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ROX-EDIT))
	touch $@

$(ROX-EDIT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ROX-EDIT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rox-edit_extract: $(STATEDIR)/rox-edit.extract

rox-edit_extract_deps = $(STATEDIR)/rox-edit.get

$(STATEDIR)/rox-edit.extract: $(rox-edit_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-EDIT_DIR))
	@$(call extract, $(ROX-EDIT_SOURCE))
	@$(call patchin, $(ROX-EDIT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rox-edit_prepare: $(STATEDIR)/rox-edit.prepare

#
# dependencies
#
rox-edit_prepare_deps = \
	$(STATEDIR)/rox-edit.extract \
	$(STATEDIR)/rox.install \
	$(STATEDIR)/pygtk.install \
	$(STATEDIR)/virtual-xchain.install

ROX-EDIT_PATH	=  PATH=$(CROSS_PATH)
ROX-EDIT_ENV 	=  $(CROSS_ENV)
#ROX-EDIT_ENV	+=
ROX-EDIT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ROX-EDIT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ROX-EDIT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
ROX-EDIT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ROX-EDIT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/rox-edit.prepare: $(rox-edit_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-EDIT_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rox-edit_compile: $(STATEDIR)/rox-edit.compile

rox-edit_compile_deps = $(STATEDIR)/rox-edit.prepare

$(STATEDIR)/rox-edit.compile: $(rox-edit_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rox-edit_install: $(STATEDIR)/rox-edit.install

$(STATEDIR)/rox-edit.install: $(STATEDIR)/rox-edit.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rox-edit_targetinstall: $(STATEDIR)/rox-edit.targetinstall

rox-edit_targetinstall_deps = $(STATEDIR)/rox-edit.compile \
	$(STATEDIR)/rox.targetinstall \
	$(STATEDIR)/pygtk.targetinstall

$(STATEDIR)/rox-edit.targetinstall: $(rox-edit_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(ROX-EDIT_IPKG_TMP)/usr/apps
	cp -a $(ROX-EDIT_DIR)/Edit $(ROX-EDIT_IPKG_TMP)/usr/apps
	rm -f $(ROX-EDIT_IPKG_TMP)/usr/apps/Edit/Messages/*.po
	rm -f $(ROX-EDIT_IPKG_TMP)/usr/apps/Edit/Messages/*.gmo
	mkdir -p $(ROX-EDIT_IPKG_TMP)/CONTROL
	echo "Package: edit" 				>$(ROX-EDIT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(ROX-EDIT_IPKG_TMP)/CONTROL/control
	echo "Section: ROX"	 			>>$(ROX-EDIT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(ROX-EDIT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(ROX-EDIT_IPKG_TMP)/CONTROL/control
	echo "Version: $(ROX-EDIT_VERSION)" 		>>$(ROX-EDIT_IPKG_TMP)/CONTROL/control
	echo "Depends: rox, pygtk, rox-lib" 		>>$(ROX-EDIT_IPKG_TMP)/CONTROL/control
	echo "Description: A simple text editor for ROX by Thomas Leonard">>$(ROX-EDIT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ROX-EDIT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ROX-EDIT_INSTALL
ROMPACKAGES += $(STATEDIR)/rox-edit.imageinstall
endif

rox-edit_imageinstall_deps = $(STATEDIR)/rox-edit.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/rox-edit.imageinstall: $(rox-edit_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install edit
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rox-edit_clean:
	rm -rf $(STATEDIR)/rox-edit.*
	rm -rf $(ROX-EDIT_DIR)

# vim: syntax=make
