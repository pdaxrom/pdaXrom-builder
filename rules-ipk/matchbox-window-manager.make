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
ifdef PTXCONF_MATCHBOX-WINDOW-MANAGER
PACKAGES += matchbox-window-manager
endif

#
# Paths and names
#
MATCHBOX-WINDOW-MANAGER_VENDOR_VERSION	= 1
MATCHBOX-WINDOW-MANAGER_VERSION		= 0.9.2
MATCHBOX-WINDOW-MANAGER			= matchbox-window-manager-$(MATCHBOX-WINDOW-MANAGER_VERSION)
MATCHBOX-WINDOW-MANAGER_SUFFIX		= tar.bz2
MATCHBOX-WINDOW-MANAGER_URL		= http://projects.o-hand.com/matchbox/sources/matchbox-window-manager/0.9/$(MATCHBOX-WINDOW-MANAGER).$(MATCHBOX-WINDOW-MANAGER_SUFFIX)
MATCHBOX-WINDOW-MANAGER_SOURCE		= $(SRCDIR)/$(MATCHBOX-WINDOW-MANAGER).$(MATCHBOX-WINDOW-MANAGER_SUFFIX)
MATCHBOX-WINDOW-MANAGER_DIR		= $(BUILDDIR)/$(MATCHBOX-WINDOW-MANAGER)
MATCHBOX-WINDOW-MANAGER_IPKG_TMP	= $(MATCHBOX-WINDOW-MANAGER_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

matchbox-window-manager_get: $(STATEDIR)/matchbox-window-manager.get

matchbox-window-manager_get_deps = $(MATCHBOX-WINDOW-MANAGER_SOURCE)

$(STATEDIR)/matchbox-window-manager.get: $(matchbox-window-manager_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MATCHBOX-WINDOW-MANAGER))
	touch $@

$(MATCHBOX-WINDOW-MANAGER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MATCHBOX-WINDOW-MANAGER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

matchbox-window-manager_extract: $(STATEDIR)/matchbox-window-manager.extract

matchbox-window-manager_extract_deps = $(STATEDIR)/matchbox-window-manager.get

$(STATEDIR)/matchbox-window-manager.extract: $(matchbox-window-manager_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX-WINDOW-MANAGER_DIR))
	@$(call extract, $(MATCHBOX-WINDOW-MANAGER_SOURCE))
	@$(call patchin, $(MATCHBOX-WINDOW-MANAGER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

matchbox-window-manager_prepare: $(STATEDIR)/matchbox-window-manager.prepare

#
# dependencies
#
matchbox-window-manager_prepare_deps = \
	$(STATEDIR)/matchbox-window-manager.extract \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/libmatchbox.install \
	$(STATEDIR)/virtual-xchain.install

MATCHBOX-WINDOW-MANAGER_PATH	=  PATH=$(CROSS_PATH)
MATCHBOX-WINDOW-MANAGER_ENV 	=  $(CROSS_ENV)
MATCHBOX-WINDOW-MANAGER_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
MATCHBOX-WINDOW-MANAGER_ENV	+= LDFLAGS="-lm"
MATCHBOX-WINDOW-MANAGER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MATCHBOX-WINDOW-MANAGER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
MATCHBOX-WINDOW-MANAGER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-gconf \
	--disable-debug \
	--enable-startup-notification \
	--enable-expat \
	--with-expat-includes=$(CROSS_LIB_DIR) \
	--with-expat-lib=$(CROSS_LIB_DIR) \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
MATCHBOX-WINDOW-MANAGER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MATCHBOX-WINDOW-MANAGER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/matchbox-window-manager.prepare: $(matchbox-window-manager_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MATCHBOX-WINDOW-MANAGER_DIR)/config.cache)
	cd $(MATCHBOX-WINDOW-MANAGER_DIR) && \
		$(MATCHBOX-WINDOW-MANAGER_PATH) $(MATCHBOX-WINDOW-MANAGER_ENV) \
		./configure $(MATCHBOX-WINDOW-MANAGER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

matchbox-window-manager_compile: $(STATEDIR)/matchbox-window-manager.compile

matchbox-window-manager_compile_deps = $(STATEDIR)/matchbox-window-manager.prepare

$(STATEDIR)/matchbox-window-manager.compile: $(matchbox-window-manager_compile_deps)
	@$(call targetinfo, $@)
	$(MATCHBOX-WINDOW-MANAGER_PATH) $(MAKE) -C $(MATCHBOX-WINDOW-MANAGER_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

matchbox-window-manager_install: $(STATEDIR)/matchbox-window-manager.install

$(STATEDIR)/matchbox-window-manager.install: $(STATEDIR)/matchbox-window-manager.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

matchbox-window-manager_targetinstall: $(STATEDIR)/matchbox-window-manager.targetinstall

matchbox-window-manager_targetinstall_deps = $(STATEDIR)/matchbox-window-manager.compile \
	$(STATEDIR)/startup-notification.targetinstall \
	$(STATEDIR)/libmatchbox.targetinstall

$(STATEDIR)/matchbox-window-manager.targetinstall: $(matchbox-window-manager_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MATCHBOX-WINDOW-MANAGER_PATH) $(MAKE) -C $(MATCHBOX-WINDOW-MANAGER_DIR) DESTDIR=$(MATCHBOX-WINDOW-MANAGER_IPKG_TMP) install
	$(CROSSSTRIP) $(MATCHBOX-WINDOW-MANAGER_IPKG_TMP)/usr/bin/*
	mkdir -p $(MATCHBOX-WINDOW-MANAGER_IPKG_TMP)/CONTROL
	echo "Package: matchbox-window-manager" 									 >$(MATCHBOX-WINDOW-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 											>>$(MATCHBOX-WINDOW-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Section: Matchbox" 											>>$(MATCHBOX-WINDOW-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 								>>$(MATCHBOX-WINDOW-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 										>>$(MATCHBOX-WINDOW-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Version: $(MATCHBOX-WINDOW-MANAGER_VERSION)-$(MATCHBOX-WINDOW-MANAGER_VENDOR_VERSION)" 			>>$(MATCHBOX-WINDOW-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Depends: libmatchbox, startup-notification" 								>>$(MATCHBOX-WINDOW-MANAGER_IPKG_TMP)/CONTROL/control
	echo "Description: Matchbox Window Manager"									>>$(MATCHBOX-WINDOW-MANAGER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MATCHBOX-WINDOW-MANAGER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MATCHBOX-WINDOW-MANAGER_INSTALL
ROMPACKAGES += $(STATEDIR)/matchbox-window-manager.imageinstall
endif

matchbox-window-manager_imageinstall_deps = $(STATEDIR)/matchbox-window-manager.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/matchbox-window-manager.imageinstall: $(matchbox-window-manager_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install matchbox-window-manager
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

matchbox-window-manager_clean:
	rm -rf $(STATEDIR)/matchbox-window-manager.*
	rm -rf $(MATCHBOX-WINDOW-MANAGER_DIR)

# vim: syntax=make
