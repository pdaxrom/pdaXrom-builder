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
ifdef PTXCONF_XMMS
PACKAGES += xmms
endif

#
# Paths and names
#
XMMS_VERSION_VENDOR	= -1
XMMS_VERSION		= 1.2.10
XMMS			= xmms-$(XMMS_VERSION)
XMMS_SUFFIX		= tar.bz2
XMMS_URL		= http://www.xmms.org/files/1.2.x/$(XMMS).$(XMMS_SUFFIX)
XMMS_SOURCE		= $(SRCDIR)/$(XMMS).$(XMMS_SUFFIX)
XMMS_DIR		= $(BUILDDIR)/$(XMMS)
XMMS_IPKG_TMP		= $(XMMS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xmms_get: $(STATEDIR)/xmms.get

xmms_get_deps = $(XMMS_SOURCE)

$(STATEDIR)/xmms.get: $(xmms_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XMMS))
	touch $@

$(XMMS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XMMS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xmms_extract: $(STATEDIR)/xmms.extract

xmms_extract_deps = $(STATEDIR)/xmms.get

$(STATEDIR)/xmms.extract: $(xmms_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XMMS_DIR))
	@$(call extract, $(XMMS_SOURCE))
	@$(call patchin, $(XMMS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xmms_prepare: $(STATEDIR)/xmms.prepare

#
# dependencies
#
xmms_prepare_deps = \
	$(STATEDIR)/xmms.extract \
	$(STATEDIR)/gtk1210.install \
	$(STATEDIR)/esound.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_ALSA-UTILS
xmms_prepare_deps += $(STATEDIR)/alsa-lib.install
endif

###	$(STATEDIR)/libmikmod.install

XMMS_PATH	=  PATH=$(CROSS_PATH)
XMMS_ENV 	=  $(CROSS_ENV)
XMMS_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
XMMS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XMMS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XMMS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-opengl \
	--disable-vorbis \
	--disable-mikmod \
	--disable-static \
	--enable-shared

ifndef PTXCONF_ALSA-UTILS
XMMS_AUTOCONF += --disable-alsa
endif

ifdef PTXCONF_XFREE430
XMMS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XMMS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/xmms.prepare: $(xmms_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XMMS_DIR)/config.cache)
	cd $(XMMS_DIR) && \
		$(XMMS_PATH) $(XMMS_ENV) \
		./configure $(XMMS_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(XMMS_DIR)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(XMMS_DIR)/libxmms
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xmms_compile: $(STATEDIR)/xmms.compile

xmms_compile_deps = $(STATEDIR)/xmms.prepare

$(STATEDIR)/xmms.compile: $(xmms_compile_deps)
	@$(call targetinfo, $@)
	$(XMMS_PATH) $(MAKE) -C $(XMMS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xmms_install: $(STATEDIR)/xmms.install

$(STATEDIR)/xmms.install: $(STATEDIR)/xmms.compile
	@$(call targetinfo, $@)
	$(XMMS_PATH) $(MAKE) -C $(XMMS_DIR) DESTDIR=$(XMMS_IPKG_TMP) install
	cp -a  $(XMMS_IPKG_TMP)/usr/bin/xmms-config     $(PTXCONF_PREFIX)/bin
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/xmms-config
	cp -a  $(XMMS_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(XMMS_IPKG_TMP)/usr/lib/libxmms.* $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libxmms.la
	cp -a  $(XMMS_IPKG_TMP)/usr/share/aclocal/*   $(CROSS_LIB_DIR)/share/aclocal
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xmms_targetinstall: $(STATEDIR)/xmms.targetinstall

xmms_targetinstall_deps = \
	$(STATEDIR)/xmms.compile \
	$(STATEDIR)/esound.targetinstall \
	$(STATEDIR)/gtk1210.targetinstall

###	$(STATEDIR)/libmikmod.targetinstall

$(STATEDIR)/xmms.targetinstall: $(xmms_targetinstall_deps)
	@$(call targetinfo, $@)
	$(XMMS_PATH) $(MAKE) -C $(XMMS_DIR) DESTDIR=$(XMMS_IPKG_TMP) install
	rm  -f $(XMMS_IPKG_TMP)/usr/bin/xmms-config
	$(CROSSSTRIP) $(XMMS_IPKG_TMP)/usr/bin/*
	rm -rf $(XMMS_IPKG_TMP)/usr/include
	rm -rf $(XMMS_IPKG_TMP)/usr/man
	rm -rf $(XMMS_IPKG_TMP)/usr/share/aclocal
	rm -rf $(XMMS_IPKG_TMP)/usr/share/locale
	rm -rf $(XMMS_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(XMMS_IPKG_TMP)/usr/lib/*.so
	rm -rf $(XMMS_IPKG_TMP)/usr/lib/xmms/Effect/*.*a
	$(CROSSSTRIP) $(XMMS_IPKG_TMP)/usr/lib/xmms/Effect/*.so
	rm -rf $(XMMS_IPKG_TMP)/usr/lib/xmms/General/*.*a
	$(CROSSSTRIP) $(XMMS_IPKG_TMP)/usr/lib/xmms/General/*.so
	rm -rf $(XMMS_IPKG_TMP)/usr/lib/xmms/Input/*.*a
ifdef PTXCONF_ARCH_ARM
	rm  -f $(XMMS_IPKG_TMP)/usr/lib/xmms/Input/libmpg123.*
endif
	$(CROSSSTRIP) $(XMMS_IPKG_TMP)/usr/lib/xmms/Input/*.so
	rm -rf $(XMMS_IPKG_TMP)/usr/lib/xmms/Output/*.*a
	$(CROSSSTRIP) $(XMMS_IPKG_TMP)/usr/lib/xmms/Output/*.so
	rm -rf $(XMMS_IPKG_TMP)/usr/lib/xmms/Visualization/*.*a
	$(CROSSSTRIP) $(XMMS_IPKG_TMP)/usr/lib/xmms/Visualization/*.so
	mkdir -p $(XMMS_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(XMMS_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/xmms.desktop $(XMMS_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/xmms.png     $(XMMS_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(XMMS_IPKG_TMP)/CONTROL
	echo "Package: xmms" 						>$(XMMS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(XMMS_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 					>>$(XMMS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"		>>$(XMMS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(XMMS_IPKG_TMP)/CONTROL/control
	echo "Version: $(XMMS_VERSION)$(XMMS_VERSION_VENDOR)" 		>>$(XMMS_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk"	 					>>$(XMMS_IPKG_TMP)/CONTROL/control
	echo "Description: X Multimedia System"				>>$(XMMS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XMMS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XMMS_INSTALL
ROMPACKAGES += $(STATEDIR)/xmms.imageinstall
endif

xmms_imageinstall_deps = $(STATEDIR)/xmms.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xmms.imageinstall: $(xmms_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xmms
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xmms_clean:
	rm -rf $(STATEDIR)/xmms.*
	rm -rf $(XMMS_DIR)

# vim: syntax=make
