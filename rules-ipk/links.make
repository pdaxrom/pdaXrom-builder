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
ifdef PTXCONF_LINKS
PACKAGES += links
endif

#
# Paths and names
#
LINKS_VERSION		= 2.1pre14
LINKS			= links-$(LINKS_VERSION)
LINKS_SUFFIX		= tar.bz2
LINKS_URL		= http://atrey.karlin.mff.cuni.cz/~clock/twibright/links/download/$(LINKS).$(LINKS_SUFFIX)
LINKS_SOURCE		= $(SRCDIR)/$(LINKS).$(LINKS_SUFFIX)
LINKS_DIR		= $(BUILDDIR)/$(LINKS)
LINKS_IPKG_TMP	= $(LINKS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

links_get: $(STATEDIR)/links.get

links_get_deps = $(LINKS_SOURCE)

$(STATEDIR)/links.get: $(links_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LINKS))
	touch $@

$(LINKS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LINKS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

links_extract: $(STATEDIR)/links.extract

links_extract_deps = $(STATEDIR)/links.get

$(STATEDIR)/links.extract: $(links_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LINKS_DIR))
	@$(call extract, $(LINKS_SOURCE))
	@$(call patchin, $(LINKS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

links_prepare: $(STATEDIR)/links.prepare

#
# dependencies
#
links_prepare_deps = \
	$(STATEDIR)/links.extract \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LINKS_GUI
links_prepare_deps += $(STATEDIR)/xfree430.install
endif

LINKS_PATH	=  PATH=$(CROSS_PATH)
LINKS_ENV 	=  $(CROSS_ENV)
#LINKS_ENV	+=
LINKS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LINKS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LINKS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-javascript

###ifdef PTXCONF_OPENSSL
LINKS_AUTOCONF += --with-ssl=$(CROSS_LIB_DIR)
###endif

ifdef PTXCONF_LINKS_GUI
LINKS_AUTOCONF += --enable-graphics
ifdef PTXCONF_XFREE430
LINKS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LINKS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
LINKS_AUTOCONF += --with-x
else
LINKS_AUTOCONF += --without-x
endif
endif

$(STATEDIR)/links.prepare: $(links_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LINKS_DIR)/config.cache)
	cd $(LINKS_DIR) && \
		$(LINKS_PATH) $(LINKS_ENV) \
		CFLAGS="-O2 -fomit-frame-pointer" \
		./configure $(LINKS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

links_compile: $(STATEDIR)/links.compile

links_compile_deps = $(STATEDIR)/links.prepare

$(STATEDIR)/links.compile: $(links_compile_deps)
	@$(call targetinfo, $@)
	$(LINKS_PATH) $(MAKE) -C $(LINKS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

links_install: $(STATEDIR)/links.install

$(STATEDIR)/links.install: $(STATEDIR)/links.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

links_targetinstall: $(STATEDIR)/links.targetinstall

links_targetinstall_deps = $(STATEDIR)/links.compile \
	$(STATEDIR)/openssl.targetinstall

ifdef PTXCONF_LINKS_GUI
links_targetinstall_deps += $(STATEDIR)/xfree430.targetinstall
endif

$(STATEDIR)/links.targetinstall: $(links_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LINKS_PATH) $(MAKE) -C $(LINKS_DIR) DESTDIR=$(LINKS_IPKG_TMP) install
	rm -rf $(LINKS_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(LINKS_IPKG_TMP)/usr/bin/links
	mkdir -p $(LINKS_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(LINKS_IPKG_TMP)/usr/share/applications
	cp $(LINKS_DIR)/links_32x32.xpm $(LINKS_IPKG_TMP)/usr/share/pixmaps
	echo "[Desktop Entry]" 		  >$(LINKS_IPKG_TMP)/usr/share/applications/links.desktop
	echo "Name=links"		 >>$(LINKS_IPKG_TMP)/usr/share/applications/links.desktop
	echo "Comment=Links web browser" >>$(LINKS_IPKG_TMP)/usr/share/applications/links.desktop
ifdef PTXCONF_LINKS_GUI
	echo "Exec=links -g"		 >>$(LINKS_IPKG_TMP)/usr/share/applications/links.desktop
else
	echo "Exec=xterm -e links"	 >>$(LINKS_IPKG_TMP)/usr/share/applications/links.desktop
endif
	echo "Icon=links_32x32.xpm"	 >>$(LINKS_IPKG_TMP)/usr/share/applications/links.desktop
	echo "Terminal=false"		 >>$(LINKS_IPKG_TMP)/usr/share/applications/links.desktop
	echo "Type=Application"		 >>$(LINKS_IPKG_TMP)/usr/share/applications/links.desktop
	echo "Categories=Application;Network;WebBrowser;" >>$(LINKS_IPKG_TMP)/usr/share/applications/links.desktop
	mkdir -p $(LINKS_IPKG_TMP)/CONTROL
	echo "Package: links" 				>$(LINKS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LINKS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(LINKS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(LINKS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LINKS_IPKG_TMP)/CONTROL/control
	echo "Version: $(LINKS_VERSION)" 		>>$(LINKS_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_LINKS_GUI
	echo "Depends: xfree430, openssl" 		>>$(LINKS_IPKG_TMP)/CONTROL/control
else
	echo "Depends: openssl" 			>>$(LINKS_IPKG_TMP)/CONTROL/control
endif
	echo "Description: generated with pdaXrom builder">>$(LINKS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LINKS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LINKS_INSTALL
ROMPACKAGES += $(STATEDIR)/links.imageinstall
endif

links_imageinstall_deps = $(STATEDIR)/links.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/links.imageinstall: $(links_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install links
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

links_clean:
	rm -rf $(STATEDIR)/links.*
	rm -rf $(LINKS_DIR)

# vim: syntax=make
