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
ifdef PTXCONF_XINE-UI
PACKAGES += xine-ui
endif

#
# Paths and names
#
XINE-UI_VENDOR_VERSION	= 1
XINE-UI_VERSION	= 0.99.3
XINE-UI		= xine-ui-$(XINE-UI_VERSION)
XINE-UI_SUFFIX		= tar.gz
XINE-UI_URL		= http://heanet.dl.sourceforge.net/sourceforge/xine/$(XINE-UI).$(XINE-UI_SUFFIX)
XINE-UI_SOURCE		= $(SRCDIR)/$(XINE-UI).$(XINE-UI_SUFFIX)
XINE-UI_DIR		= $(BUILDDIR)/$(XINE-UI)
XINE-UI_IPKG_TMP	= $(XINE-UI_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xine-ui_get: $(STATEDIR)/xine-ui.get

xine-ui_get_deps = $(XINE-UI_SOURCE)

$(STATEDIR)/xine-ui.get: $(xine-ui_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XINE-UI))
	touch $@

$(XINE-UI_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XINE-UI_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xine-ui_extract: $(STATEDIR)/xine-ui.extract

xine-ui_extract_deps = $(STATEDIR)/xine-ui.get

$(STATEDIR)/xine-ui.extract: $(xine-ui_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XINE-UI_DIR))
	@$(call extract, $(XINE-UI_SOURCE))
	@$(call patchin, $(XINE-UI))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xine-ui_prepare: $(STATEDIR)/xine-ui.prepare

#
# dependencies
#
xine-ui_prepare_deps = \
	$(STATEDIR)/xine-ui.extract \
	$(STATEDIR)/virtual-xchain.install

XINE-UI_PATH	=  PATH=$(CROSS_PATH)
XINE-UI_ENV 	=  $(CROSS_ENV)
#XINE-UI_ENV	+=
XINE-UI_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XINE-UI_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
XINE-UI_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XINE-UI_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XINE-UI_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xine-ui.prepare: $(xine-ui_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XINE-UI_DIR)/config.cache)
	cd $(XINE-UI_DIR) && \
		$(XINE-UI_PATH) $(XINE-UI_ENV) \
		./configure $(XINE-UI_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xine-ui_compile: $(STATEDIR)/xine-ui.compile

xine-ui_compile_deps = $(STATEDIR)/xine-ui.prepare

$(STATEDIR)/xine-ui.compile: $(xine-ui_compile_deps)
	@$(call targetinfo, $@)
	$(XINE-UI_PATH) $(MAKE) -C $(XINE-UI_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xine-ui_install: $(STATEDIR)/xine-ui.install

$(STATEDIR)/xine-ui.install: $(STATEDIR)/xine-ui.compile
	@$(call targetinfo, $@)
	$(XINE-UI_PATH) $(MAKE) -C $(XINE-UI_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xine-ui_targetinstall: $(STATEDIR)/xine-ui.targetinstall

xine-ui_targetinstall_deps = $(STATEDIR)/xine-ui.compile

$(STATEDIR)/xine-ui.targetinstall: $(xine-ui_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XINE-UI_PATH) $(MAKE) -C $(XINE-UI_DIR) DESTDIR=$(XINE-UI_IPKG_TMP) install
	mkdir -p $(XINE-UI_IPKG_TMP)/CONTROL
	echo "Package: xine-ui" 							 >$(XINE-UI_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XINE-UI_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(XINE-UI_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(XINE-UI_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XINE-UI_IPKG_TMP)/CONTROL/control
	echo "Version: $(XINE-UI_VERSION)-$(XINE-UI_VENDOR_VERSION)" 			>>$(XINE-UI_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(XINE-UI_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(XINE-UI_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XINE-UI_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XINE-UI_INSTALL
ROMPACKAGES += $(STATEDIR)/xine-ui.imageinstall
endif

xine-ui_imageinstall_deps = $(STATEDIR)/xine-ui.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xine-ui.imageinstall: $(xine-ui_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xine-ui
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xine-ui_clean:
	rm -rf $(STATEDIR)/xine-ui.*
	rm -rf $(XINE-UI_DIR)

# vim: syntax=make
