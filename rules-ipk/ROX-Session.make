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
ifdef PTXCONF_ROX-SESSION
PACKAGES += ROX-Session
endif

#
# Paths and names
#
ROX-SESSION_VERSION	= 0.1.24
ROX-SESSION		= ROX-Session-$(ROX-SESSION_VERSION)
ROX-SESSION_SUFFIX	= tgz
ROX-SESSION_URL		= http://heanet.dl.sourceforge.net/sourceforge/rox/$(ROX-SESSION).$(ROX-SESSION_SUFFIX)
ROX-SESSION_SOURCE	= $(SRCDIR)/$(ROX-SESSION).$(ROX-SESSION_SUFFIX)
ROX-SESSION_DIR		= $(BUILDDIR)/$(ROX-SESSION)
ROX-SESSION_IPKG_TMP	= $(ROX-SESSION_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ROX-Session_get: $(STATEDIR)/ROX-Session.get

ROX-Session_get_deps = $(ROX-SESSION_SOURCE)

$(STATEDIR)/ROX-Session.get: $(ROX-Session_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ROX-SESSION))
	touch $@

$(ROX-SESSION_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ROX-SESSION_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ROX-Session_extract: $(STATEDIR)/ROX-Session.extract

ROX-Session_extract_deps = $(STATEDIR)/ROX-Session.get

$(STATEDIR)/ROX-Session.extract: $(ROX-Session_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-SESSION_DIR))
	@$(call extract, $(ROX-SESSION_SOURCE))
	@$(call patchin, $(ROX-SESSION))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ROX-Session_prepare: $(STATEDIR)/ROX-Session.prepare

#
# dependencies
#
ROX-Session_prepare_deps = \
	$(STATEDIR)/ROX-Session.extract \
	$(STATEDIR)/dbus.install \
	$(STATEDIR)/rox-lib.install \
	$(STATEDIR)/pygtk.install \
	$(STATEDIR)/virtual-xchain.install

ROX-SESSION_PATH	=  PATH=$(CROSS_PATH)
ROX-SESSION_ENV 	=  $(CROSS_ENV)
ROX-SESSION_ENV		+= CFLAGS="-O2 -fomit-frame-pointer"
ROX-SESSION_ENV		+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ROX-SESSION_ENV		+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ROX-SESSION_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--disable-debug \
	--with-platform=Linux-$(PTXCONF_ARCH)

ifdef PTXCONF_XFREE430
ROX-SESSION_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ROX-SESSION_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ROX-Session.prepare: $(ROX-Session_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ROX-SESSION_DIR)/config.cache)
	cd $(ROX-SESSION_DIR)/ROX-Session/src && \
		$(ROX-SESSION_PATH) $(ROX-SESSION_ENV) \
		./configure $(ROX-SESSION_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ROX-Session_compile: $(STATEDIR)/ROX-Session.compile

ROX-Session_compile_deps = $(STATEDIR)/ROX-Session.prepare

$(STATEDIR)/ROX-Session.compile: $(ROX-Session_compile_deps)
	@$(call targetinfo, $@)
	$(ROX-SESSION_ENV) $(ROX-SESSION_PATH) $(MAKE) -C $(ROX-SESSION_DIR)/ROX-Session/src
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ROX-Session_install: $(STATEDIR)/ROX-Session.install

$(STATEDIR)/ROX-Session.install: $(STATEDIR)/ROX-Session.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ROX-Session_targetinstall: $(STATEDIR)/ROX-Session.targetinstall

ROX-Session_targetinstall_deps = $(STATEDIR)/ROX-Session.compile \
	$(STATEDIR)/rox-lib.targetinstall \
	$(STATEDIR)/pygtk.targetinstall \
	$(STATEDIR)/dbus.targetinstall

$(STATEDIR)/ROX-Session.targetinstall: $(ROX-Session_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(ROX-SESSION_IPKG_TMP)/usr/apps
	cp -a $(ROX-SESSION_DIR)/ROX-Session $(ROX-SESSION_IPKG_TMP)/usr/apps
	$(CROSSSTRIP) $(ROX-SESSION_IPKG_TMP)/usr/apps/ROX-Session/Linux-armv5tel/ROX-Session
	rm -rf $(ROX-SESSION_IPKG_TMP)/usr/apps/ROX-Session/Help/Guide/de
	rm -rf $(ROX-SESSION_IPKG_TMP)/usr/apps/ROX-Session/Help/Guide/it
	rm -rf $(ROX-SESSION_IPKG_TMP)/usr/apps/ROX-Session/Messages/*
	rm -rf $(ROX-SESSION_IPKG_TMP)/usr/apps/ROX-Session/src
	mkdir -p $(ROX-SESSION_IPKG_TMP)/CONTROL
	echo "Package: rox-session" 			>$(ROX-SESSION_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(ROX-SESSION_IPKG_TMP)/CONTROL/control
	echo "Section: ROX"	 			>>$(ROX-SESSION_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(ROX-SESSION_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(ROX-SESSION_IPKG_TMP)/CONTROL/control
	echo "Version: $(ROX-SESSION_VERSION)" 		>>$(ROX-SESSION_IPKG_TMP)/CONTROL/control
	echo "Depends: rox, rox-lib, dbus, pygtk, python-re, python-math" >>$(ROX-SESSION_IPKG_TMP)/CONTROL/control
	echo "Description: ROX Session Manager"		>>$(ROX-SESSION_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ROX-SESSION_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ROX-SESSION_INSTALL
ROMPACKAGES += $(STATEDIR)/ROX-Session.imageinstall
endif

ROX-Session_imageinstall_deps = $(STATEDIR)/ROX-Session.targetinstall \
	$(STATEDIR)/rox.imageinstall \
	$(STATEDIR)/dbus.imageinstall \
	$(STATEDIR)/rox-lib.imageinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ROX-Session.imageinstall: $(ROX-Session_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install rox-session
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ROX-Session_clean:
	rm -rf $(STATEDIR)/ROX-Session.*
	rm -rf $(ROX-SESSION_DIR)

# vim: syntax=make
