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
ifdef PTXCONF_DILLO2
PACKAGES += dillo2
endif

#
# Paths and names
#
DILLO2_VENDOR_VERSION	= 1
DILLO2_VERSION		= 20050131
DILLO2			= dillo2-$(DILLO2_VERSION)
DILLO2_SUFFIX		= tar.bz2
DILLO2_URL		= http://www.pdaxrom.org/src/$(DILLO2).$(DILLO2_SUFFIX)
DILLO2_SOURCE		= $(SRCDIR)/$(DILLO2).$(DILLO2_SUFFIX)
DILLO2_DIR		= $(BUILDDIR)/dillo2
DILLO2_IPKG_TMP		= $(DILLO2_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dillo2_get: $(STATEDIR)/dillo2.get

dillo2_get_deps = $(DILLO2_SOURCE)

$(STATEDIR)/dillo2.get: $(dillo2_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DILLO2))
	touch $@

$(DILLO2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DILLO2_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dillo2_extract: $(STATEDIR)/dillo2.extract

dillo2_extract_deps = $(STATEDIR)/dillo2.get

$(STATEDIR)/dillo2.extract: $(dillo2_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(DILLO2_DIR))
	@$(call extract, $(DILLO2_SOURCE))
	@$(call patchin, $(DILLO2), $(DILLO2_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dillo2_prepare: $(STATEDIR)/dillo2.prepare

#
# dependencies
#
dillo2_prepare_deps = \
	$(STATEDIR)/dillo2.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/virtual-xchain.install

DILLO2_PATH	=  PATH=$(CROSS_PATH)
DILLO2_ENV 	=  $(CROSS_ENV)
DILLO2_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
DILLO2_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DILLO2_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
DILLO2_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-cookies \
	--with-jpeg-inc=$(CROSS_LIB_DIR)/include \
	--with-jpeg-lib=$(CROSS_LIB_DIR)/lib \
	--disable-debug \
	--enable-meta-refresh \
	--enable-user-agent \
	--without-libiconv-prefix \
	--sysconfdir=/usr/lib/dillo2

#ifdef PTXCONF_LIBICONV
#endif

ifdef PTXCONF_XFREE430
DILLO2_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DILLO2_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dillo2.prepare: $(dillo2_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DILLO2_DIR)/config.cache)
	cd $(DILLO2_DIR) && $(DILLO2_PATH) aclocal
	cd $(DILLO2_DIR) && $(DILLO2_PATH) automake --add-missing
	cd $(DILLO2_DIR) && $(DILLO2_PATH) autoconf
	cd $(DILLO2_DIR) && \
		$(DILLO2_PATH) $(DILLO2_ENV) \
		./configure $(DILLO2_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dillo2_compile: $(STATEDIR)/dillo2.compile

dillo2_compile_deps = $(STATEDIR)/dillo2.prepare

$(STATEDIR)/dillo2.compile: $(dillo2_compile_deps)
	@$(call targetinfo, $@)
	$(DILLO2_PATH) $(MAKE) -C $(DILLO2_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dillo2_install: $(STATEDIR)/dillo2.install

$(STATEDIR)/dillo2.install: $(STATEDIR)/dillo2.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dillo2_targetinstall: $(STATEDIR)/dillo2.targetinstall

dillo2_targetinstall_deps = $(STATEDIR)/dillo2.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/openssl.targetinstall

$(STATEDIR)/dillo2.targetinstall: $(dillo2_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DILLO2_PATH) $(MAKE) -C $(DILLO2_DIR) DESTDIR=$(DILLO2_IPKG_TMP) install
	mv $(DILLO2_IPKG_TMP)/usr/bin/dillo $(DILLO2_IPKG_TMP)/usr/bin/dillo2
	$(CROSSSTRIP) $(DILLO2_IPKG_TMP)/usr/bin/dillo2
	mkdir -p $(DILLO2_IPKG_TMP)/usr/lib/dillo2
	cp -a $(DILLO2_DIR)/dillorc 		$(DILLO2_IPKG_TMP)/usr/lib/dillo2/
	perl -p -i -e "s/640x550/620x440/g" 	$(DILLO2_IPKG_TMP)/usr/lib/dillo2/dillorc
	mkdir -p $(DILLO2_IPKG_TMP)/usr/share/applications
	mkdir -p $(DILLO2_IPKG_TMP)/usr/share/pixmaps
	cp -f $(TOPDIR)/config/pics/dillo2.desktop 	$(DILLO2_IPKG_TMP)/usr/share/applications
	cp -f $(TOPDIR)/config/pics/dillo.png           $(DILLO2_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(DILLO2_IPKG_TMP)/CONTROL
	echo "Package: dillo2" 								 >$(DILLO2_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(DILLO2_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 							>>$(DILLO2_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(DILLO2_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(DILLO2_IPKG_TMP)/CONTROL/control
	echo "Version: $(DILLO2_VERSION)-$(DILLO2_VENDOR_VERSION)" 			>>$(DILLO2_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, openssl" 							>>$(DILLO2_IPKG_TMP)/CONTROL/control
	echo "Description: Lightweight GTK2 web browser"				>>$(DILLO2_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DILLO2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DILLO2_INSTALL
ROMPACKAGES += $(STATEDIR)/dillo2.imageinstall
endif

dillo2_imageinstall_deps = $(STATEDIR)/dillo2.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dillo2.imageinstall: $(dillo2_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dillo2
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dillo2_clean:
	rm -rf $(STATEDIR)/dillo2.*
	rm -rf $(DILLO2_DIR)

# vim: syntax=make
