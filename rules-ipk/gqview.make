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
ifdef PTXCONF_GQVIEW
PACKAGES += gqview
endif

#
# Paths and names
#
#GQVIEW_VERSION	= 1.4.2
GQVIEW_VERSION	= 1.5.4
GQVIEW		= gqview-$(GQVIEW_VERSION)
GQVIEW_SUFFIX	= tar.gz
GQVIEW_URL	= http://heanet.dl.sourceforge.net/sourceforge/gqview/$(GQVIEW).$(GQVIEW_SUFFIX)
GQVIEW_SOURCE	= $(SRCDIR)/$(GQVIEW).$(GQVIEW_SUFFIX)
GQVIEW_DIR	= $(BUILDDIR)/$(GQVIEW)
GQVIEW_IPKG_TMP	= $(GQVIEW_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gqview_get: $(STATEDIR)/gqview.get

gqview_get_deps = $(GQVIEW_SOURCE)

$(STATEDIR)/gqview.get: $(gqview_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GQVIEW))
	touch $@

$(GQVIEW_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GQVIEW_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gqview_extract: $(STATEDIR)/gqview.extract

gqview_extract_deps = $(STATEDIR)/gqview.get

$(STATEDIR)/gqview.extract: $(gqview_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GQVIEW_DIR))
	@$(call extract, $(GQVIEW_SOURCE))
	@$(call patchin, $(GQVIEW))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gqview_prepare: $(STATEDIR)/gqview.prepare

#
# dependencies
#
gqview_prepare_deps = \
	$(STATEDIR)/gqview.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

GQVIEW_PATH	=  PATH=$(CROSS_PATH)
GQVIEW_ENV 	=  $(CROSS_ENV)
#GQVIEW_ENV	+=
GQVIEW_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GQVIEW_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GQVIEW_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GQVIEW_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GQVIEW_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gqview.prepare: $(gqview_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GQVIEW_DIR)/config.cache)
	#cd $(GQVIEW_DIR) && aclocal
	#cd $(GQVIEW_DIR) && automake --add-missing
	#cd $(GQVIEW_DIR) && autoconf
	cd $(GQVIEW_DIR) && \
		$(GQVIEW_PATH) $(GQVIEW_ENV) \
		./configure $(GQVIEW_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(GQVIEW_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gqview_compile: $(STATEDIR)/gqview.compile

gqview_compile_deps = $(STATEDIR)/gqview.prepare

$(STATEDIR)/gqview.compile: $(gqview_compile_deps)
	@$(call targetinfo, $@)
	$(GQVIEW_PATH) $(MAKE) -C $(GQVIEW_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gqview_install: $(STATEDIR)/gqview.install

$(STATEDIR)/gqview.install: $(STATEDIR)/gqview.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gqview_targetinstall: $(STATEDIR)/gqview.targetinstall

gqview_targetinstall_deps = \
	$(STATEDIR)/gqview.compile \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/gqview.targetinstall: $(gqview_targetinstall_deps)
	@$(call targetinfo, $@)

	$(GQVIEW_PATH) $(MAKE) -C $(GQVIEW_DIR) DESTDIR=$(GQVIEW_IPKG_TMP) install
	rm -rf $(GQVIEW_IPKG_TMP)/usr/man
	rm -rf $(GQVIEW_IPKG_TMP)/usr/share
	mkdir -p $(GQVIEW_IPKG_TMP)/usr/share/applications
	cp $(TOPDIR)/config/pics/gqview.desktop $(GQVIEW_IPKG_TMP)/usr/share/applications
	mkdir -p $(GQVIEW_IPKG_TMP)/usr/share/pixmaps
	cp $(GQVIEW_DIR)/gqview.png $(GQVIEW_IPKG_TMP)/usr/share/pixmaps
	$(CROSSSTRIP) $(GQVIEW_IPKG_TMP)/usr/bin/gqview
	mkdir -p $(GQVIEW_IPKG_TMP)/CONTROL
	echo "Package: gqview" 				>$(GQVIEW_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(GQVIEW_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 			>>$(GQVIEW_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(GQVIEW_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(GQVIEW_IPKG_TMP)/CONTROL/control
	echo "Version: $(GQVIEW_VERSION)" 		>>$(GQVIEW_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 				>>$(GQVIEW_IPKG_TMP)/CONTROL/control
	echo "Description: GQview is an image viewer for Unix operating systems.">>$(GQVIEW_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GQVIEW_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GQVIEW_INSTALL
ROMPACKAGES += $(STATEDIR)/gqview.imageinstall
endif

gqview_imageinstall_deps = $(STATEDIR)/gqview.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gqview.imageinstall: $(gqview_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gqview
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gqview_clean:
	rm -rf $(STATEDIR)/gqview.*
	rm -rf $(GQVIEW_DIR)

# vim: syntax=make
