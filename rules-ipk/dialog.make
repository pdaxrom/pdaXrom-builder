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
ifdef PTXCONF_DIALOG
PACKAGES += dialog
endif

#
# Paths and names
#
DIALOG_VENDOR_VERSION	= 1
DIALOG_VERSION		= 1.0-20041222
DIALOG			= dialog_$(DIALOG_VERSION)
DIALOG_SUFFIX		= orig.tar.gz
DIALOG_URL		= ftp://ftp.us.debian.org/debian/pool/main/d/dialog/$(DIALOG).$(DIALOG_SUFFIX)
DIALOG_SOURCE		= $(SRCDIR)/$(DIALOG).$(DIALOG_SUFFIX)
DIALOG_DIR		= $(BUILDDIR)/dialog-$(DIALOG_VERSION)
DIALOG_IPKG_TMP		= $(DIALOG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dialog_get: $(STATEDIR)/dialog.get

dialog_get_deps = $(DIALOG_SOURCE)

$(STATEDIR)/dialog.get: $(dialog_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DIALOG))
	touch $@

$(DIALOG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DIALOG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dialog_extract: $(STATEDIR)/dialog.extract

dialog_extract_deps = $(STATEDIR)/dialog.get

$(STATEDIR)/dialog.extract: $(dialog_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DIALOG_DIR))
	@$(call extract, $(DIALOG_SOURCE))
	@$(call patchin, $(DIALOG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dialog_prepare: $(STATEDIR)/dialog.prepare

#
# dependencies
#
dialog_prepare_deps = \
	$(STATEDIR)/dialog.extract \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/virtual-xchain.install

DIALOG_PATH	=  PATH=$(CROSS_PATH)
DIALOG_ENV 	=  $(CROSS_ENV)
#DIALOG_ENV	+=
DIALOG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DIALOG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
DIALOG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
DIALOG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DIALOG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dialog.prepare: $(dialog_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DIALOG_DIR)/config.cache)
	cd $(DIALOG_DIR) && \
		$(DIALOG_PATH) $(DIALOG_ENV) \
		./configure $(DIALOG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dialog_compile: $(STATEDIR)/dialog.compile

dialog_compile_deps = $(STATEDIR)/dialog.prepare

$(STATEDIR)/dialog.compile: $(dialog_compile_deps)
	@$(call targetinfo, $@)
	$(DIALOG_PATH) $(MAKE) -C $(DIALOG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dialog_install: $(STATEDIR)/dialog.install

$(STATEDIR)/dialog.install: $(STATEDIR)/dialog.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dialog_targetinstall: $(STATEDIR)/dialog.targetinstall

dialog_targetinstall_deps = $(STATEDIR)/dialog.compile \
	$(STATEDIR)/ncurses.targetinstall

$(STATEDIR)/dialog.targetinstall: $(dialog_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DIALOG_PATH) $(MAKE) -C $(DIALOG_DIR) DESTDIR=$(DIALOG_IPKG_TMP) install
	rm -rf $(DIALOG_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(DIALOG_IPKG_TMP)/usr/bin/*
	mkdir -p $(DIALOG_IPKG_TMP)/CONTROL
	echo "Package: dialog" 											 >$(DIALOG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(DIALOG_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 										>>$(DIALOG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(DIALOG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(DIALOG_IPKG_TMP)/CONTROL/control
	echo "Version: $(DIALOG_VERSION)-$(DIALOG_VENDOR_VERSION)" 						>>$(DIALOG_IPKG_TMP)/CONTROL/control
	echo "Depends: ncurses" 										>>$(DIALOG_IPKG_TMP)/CONTROL/control
	echo "Description:  Dialog is a utility to create nice user interfaces to shell scripts, or other scripting languages, such as perl. It is non-graphical (it uses curses) so it can be run in the console or an xterm." >>$(DIALOG_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DIALOG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DIALOG_INSTALL
ROMPACKAGES += $(STATEDIR)/dialog.imageinstall
endif

dialog_imageinstall_deps = $(STATEDIR)/dialog.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dialog.imageinstall: $(dialog_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dialog
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dialog_clean:
	rm -rf $(STATEDIR)/dialog.*
	rm -rf $(DIALOG_DIR)

# vim: syntax=make
