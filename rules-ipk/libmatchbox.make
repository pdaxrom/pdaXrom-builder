# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_LIBMATCHBOX
PACKAGES += libmatchbox
endif

#
# Paths and names
#
LIBMATCHBOX_VERSION	= 1.6
LIBMATCHBOX		= libmatchbox-$(LIBMATCHBOX_VERSION)
LIBMATCHBOX_SUFFIX	= tar.bz2
###LIBMATCHBOX_URL		= http://matchbox.handhelds.org/sources/libmatchbox/$(LIBMATCHBOX_VERSION)/$(LIBMATCHBOX).$(LIBMATCHBOX_SUFFIX)
LIBMATCHBOX_URL		= http://projects.o-hand.com/matchbox/sources/libmatchbox/$(LIBMATCHBOX_VERSION)/$(LIBMATCHBOX).$(LIBMATCHBOX_SUFFIX)
LIBMATCHBOX_SOURCE	= $(SRCDIR)/$(LIBMATCHBOX).$(LIBMATCHBOX_SUFFIX)
LIBMATCHBOX_DIR		= $(BUILDDIR)/$(LIBMATCHBOX)
LIBMATCHBOX_ROOTDIR	= $(LIBMATCHBOX_DIR)/ipkg_tmp
# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libmatchbox_get: $(STATEDIR)/libmatchbox.get

libmatchbox_get_deps = $(LIBMATCHBOX_SOURCE)

$(STATEDIR)/libmatchbox.get: $(libmatchbox_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBMATCHBOX))
	touch $@

$(LIBMATCHBOX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBMATCHBOX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libmatchbox_extract: $(STATEDIR)/libmatchbox.extract

libmatchbox_extract_deps = $(STATEDIR)/libmatchbox.get

$(STATEDIR)/libmatchbox.extract: $(libmatchbox_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBMATCHBOX_DIR))
	@$(call extract, $(LIBMATCHBOX_SOURCE))
	@$(call patchin, $(LIBMATCHBOX))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libmatchbox_prepare: $(STATEDIR)/libmatchbox.prepare

#
# dependencies
#
libmatchbox_prepare_deps = \
	$(STATEDIR)/libmatchbox.extract \
	$(STATEDIR)/libpng125.install \
	$(STATEDIR)/jpeg.install \
	$(STATEDIR)/Xsettings-client.install \
	$(STATEDIR)/startup-notification.install \
	$(STATEDIR)/virtual-xchain.install

LIBMATCHBOX_PATH	=  PATH=$(CROSS_PATH)
LIBMATCHBOX_ENV 	=  $(CROSS_ENV)
#LIBMATCHBOX_ENV	+=
LIBMATCHBOX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#LIBMATCHBOX_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib

#
# autoconf
#
LIBMATCHBOX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--sysconfdir=/etc \
	--enable-jpeg \
	--enable-xsettings \
	--x-includes=$(CROSS_LIB_DIR)/include \
	--x-libraries=$(CROSS_LIB_DIR)/lib \
	--with-xsettings-includes=$(CROSS_LIB_DIR)/include \
	--with-xsettings-lib=$(CROSS_LIB_DIR)/lib \
	--enable-xft \
	--enable-shared \
	--disable-static

$(STATEDIR)/libmatchbox.prepare: $(libmatchbox_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBMATCHBOX_DIR)/config.cache)
	cd $(LIBMATCHBOX_DIR) && \
		$(LIBMATCHBOX_PATH) $(LIBMATCHBOX_ENV) \
		./configure $(LIBMATCHBOX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libmatchbox_compile: $(STATEDIR)/libmatchbox.compile

libmatchbox_compile_deps = $(STATEDIR)/libmatchbox.prepare

$(STATEDIR)/libmatchbox.compile: $(libmatchbox_compile_deps)
	@$(call targetinfo, $@)
	$(LIBMATCHBOX_PATH) $(MAKE) -C $(LIBMATCHBOX_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libmatchbox_install: $(STATEDIR)/libmatchbox.install

$(STATEDIR)/libmatchbox.install: $(STATEDIR)/libmatchbox.compile
	@$(call targetinfo, $@)
	$(LIBMATCHBOX_PATH) $(MAKE) -C $(LIBMATCHBOX_DIR) prefix=$(CROSS_LIB_DIR) install
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libmb.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libmb.pc
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libmatchbox_targetinstall: $(STATEDIR)/libmatchbox.targetinstall

libmatchbox_targetinstall_deps = $(STATEDIR)/libmatchbox.install \
	$(STATEDIR)/libpng125.targetinstall \
	$(STATEDIR)/jpeg.targetinstall \
	$(STATEDIR)/Xsettings-client.targetinstall \
	$(STATEDIR)/startup-notification.targetinstall

$(STATEDIR)/libmatchbox.targetinstall: $(libmatchbox_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBMATCHBOX_PATH) $(MAKE) -C $(LIBMATCHBOX_DIR) DESTDIR=$(LIBMATCHBOX_ROOTDIR) install
	rm -rf $(LIBMATCHBOX_ROOTDIR)/usr/include
	rm -rf $(LIBMATCHBOX_ROOTDIR)/usr/lib/pkgconfig
	rm -rf $(LIBMATCHBOX_ROOTDIR)/usr/lib/*.*a
	$(CROSSSTRIP) $(LIBMATCHBOX_ROOTDIR)/usr/lib/*.so*
	##mkdir -p $(LIBMATCHBOX_ROOTDIR)/usr/lib
	##$(INSTALL) $(LIBMATCHBOX_DIR)/libmb/.libs/libmb.so.1.0.5 $(LIBMATCHBOX_ROOTDIR)/usr/lib
	##ln -sf libmb.so.1.0.5 $(LIBMATCHBOX_ROOTDIR)/usr/lib/libmb.so.1
	##ln -sf libmb.so.1.0.5 $(LIBMATCHBOX_ROOTDIR)/usr/lib/libmb.so
	##$(CROSSSTRIP) $(LIBMATCHBOX_ROOTDIR)/usr/lib/libmb.so.1.0.5
	mkdir -p $(LIBMATCHBOX_ROOTDIR)/CONTROL
	echo "Package: libmatchbox"	 		 >$(LIBMATCHBOX_ROOTDIR)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBMATCHBOX_ROOTDIR)/CONTROL/control
	echo "Section: Matchbox" 			>>$(LIBMATCHBOX_ROOTDIR)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(LIBMATCHBOX_ROOTDIR)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBMATCHBOX_ROOTDIR)/CONTROL/control
	echo "Version: $(LIBMATCHBOX_VERSION)"	 	>>$(LIBMATCHBOX_ROOTDIR)/CONTROL/control
	echo "Depends: matchbox-common, x11settings-client">>$(LIBMATCHBOX_ROOTDIR)/CONTROL/control
	echo "Description: Matchbox library"		>>$(LIBMATCHBOX_ROOTDIR)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBMATCHBOX_ROOTDIR)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

libmatchbox_imageinstall_deps = $(STATEDIR)/libmatchbox.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libmatchbox.imageinstall: $(libmatchbox_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libmatchbox
	touch $@


# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libmatchbox_clean:
	rm -rf $(STATEDIR)/libmatchbox.*
	rm -rf $(LIBMATCHBOX_DIR)

# vim: syntax=make
