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
ifdef PTXCONF_XCDROAST
PACKAGES += xcdroast
endif

#
# Paths and names
#
XCDROAST_VENDOR_VERSION	= 1
XCDROAST_VERSION	= 0.98alpha15
XCDROAST		= xcdroast-$(XCDROAST_VERSION)
XCDROAST_SUFFIX		= tar.gz
XCDROAST_URL		= http://mesh.dl.sourceforge.net/sourceforge/xcdroast/$(XCDROAST).$(XCDROAST_SUFFIX)
XCDROAST_SOURCE		= $(SRCDIR)/$(XCDROAST).$(XCDROAST_SUFFIX)
XCDROAST_DIR		= $(BUILDDIR)/$(XCDROAST)
XCDROAST_IPKG_TMP	= $(XCDROAST_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xcdroast_get: $(STATEDIR)/xcdroast.get

xcdroast_get_deps = $(XCDROAST_SOURCE)

$(STATEDIR)/xcdroast.get: $(xcdroast_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XCDROAST))
	touch $@

$(XCDROAST_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XCDROAST_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xcdroast_extract: $(STATEDIR)/xcdroast.extract

xcdroast_extract_deps = $(STATEDIR)/xcdroast.get

$(STATEDIR)/xcdroast.extract: $(xcdroast_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCDROAST_DIR))
	@$(call extract, $(XCDROAST_SOURCE))
	@$(call patchin, $(XCDROAST))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xcdroast_prepare: $(STATEDIR)/xcdroast.prepare

#
# dependencies
#
xcdroast_prepare_deps = \
	$(STATEDIR)/xcdroast.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

XCDROAST_PATH	=  PATH=$(CROSS_PATH)
XCDROAST_ENV 	=  $(CROSS_ENV)
#XCDROAST_ENV	+=
XCDROAST_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XCDROAST_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XCDROAST_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-gtk2 \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
XCDROAST_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XCDROAST_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xcdroast.prepare: $(xcdroast_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCDROAST_DIR)/config.cache)
	cd $(XCDROAST_DIR) && \
		$(XCDROAST_PATH) $(XCDROAST_ENV) \
		./configure $(XCDROAST_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xcdroast_compile: $(STATEDIR)/xcdroast.compile

xcdroast_compile_deps = $(STATEDIR)/xcdroast.prepare

$(STATEDIR)/xcdroast.compile: $(xcdroast_compile_deps)
	@$(call targetinfo, $@)
	$(XCDROAST_PATH) $(MAKE) -C $(XCDROAST_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xcdroast_install: $(STATEDIR)/xcdroast.install

$(STATEDIR)/xcdroast.install: $(STATEDIR)/xcdroast.compile
	@$(call targetinfo, $@)
	$(XCDROAST_PATH) $(MAKE) -C $(XCDROAST_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xcdroast_targetinstall: $(STATEDIR)/xcdroast.targetinstall

xcdroast_targetinstall_deps = $(STATEDIR)/xcdroast.compile \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/xcdroast.targetinstall: $(xcdroast_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XCDROAST_PATH) $(MAKE) -C $(XCDROAST_DIR) DESTDIR=$(XCDROAST_IPKG_TMP) install
	rm -rf $(XCDROAST_IPKG_TMP)/usr/man
	rm -rf $(XCDROAST_IPKG_TMP)/usr/share/locale
	$(CROSSSTRIP) $(XCDROAST_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(XCDROAST_IPKG_TMP)/usr/lib/xcdroast-0.98/bin/*
	mkdir -p $(XCDROAST_IPKG_TMP)/usr/share/applications
	mkdir -p $(XCDROAST_IPKG_TMP)/usr/share/pixmaps
	cp -a $(XCDROAST_IPKG_TMP)/usr/lib/xcdroast-0.98/icons/xcdricon.png	$(XCDROAST_IPKG_TMP)/usr/share/pixmaps/
	cp -a $(TOPDIR)/config/pics/xcdroast.desktop				$(XCDROAST_IPKG_TMP)/usr/share/applications/
	mkdir -p $(XCDROAST_IPKG_TMP)/CONTROL
	echo "Package: xcdroast" 							 >$(XCDROAST_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(XCDROAST_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 							>>$(XCDROAST_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(XCDROAST_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(XCDROAST_IPKG_TMP)/CONTROL/control
	echo "Version: $(XCDROAST_VERSION)-$(XCDROAST_VENDOR_VERSION)" 			>>$(XCDROAST_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 								>>$(XCDROAST_IPKG_TMP)/CONTROL/control
	echo "Description: X-CD-Roast tries to be the most flexible CD-burning software ever. It allows even the unexperienced user to create or copy a CD with a few mouse clicks in a intuitive and nice looking graphical user interface." >>$(XCDROAST_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XCDROAST_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XCDROAST_INSTALL
ROMPACKAGES += $(STATEDIR)/xcdroast.imageinstall
endif

xcdroast_imageinstall_deps = $(STATEDIR)/xcdroast.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xcdroast.imageinstall: $(xcdroast_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xcdroast
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xcdroast_clean:
	rm -rf $(STATEDIR)/xcdroast.*
	rm -rf $(XCDROAST_DIR)

# vim: syntax=make
