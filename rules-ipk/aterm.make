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
ifdef PTXCONF_ATERM
PACKAGES += aterm
endif

#
# Paths and names
#
ATERM_VERSION		= 0.4.2
ATERM			= aterm-$(ATERM_VERSION)
ATERM_SUFFIX		= tar.bz2
ATERM_URL		= http://heanet.dl.sourceforge.net/sourceforge/aterm/$(ATERM).$(ATERM_SUFFIX)
ATERM_SOURCE		= $(SRCDIR)/$(ATERM).$(ATERM_SUFFIX)
ATERM_DIR		= $(BUILDDIR)/$(ATERM)
ATERM_IPKG_TMP		= $(ATERM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

aterm_get: $(STATEDIR)/aterm.get

aterm_get_deps = $(ATERM_SOURCE)

$(STATEDIR)/aterm.get: $(aterm_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ATERM))
	touch $@

$(ATERM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ATERM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

aterm_extract: $(STATEDIR)/aterm.extract

aterm_extract_deps = $(STATEDIR)/aterm.get

$(STATEDIR)/aterm.extract: $(aterm_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ATERM_DIR))
	@$(call extract, $(ATERM_SOURCE))
	@$(call patchin, $(ATERM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

aterm_prepare: $(STATEDIR)/aterm.prepare

#
# dependencies
#
aterm_prepare_deps = \
	$(STATEDIR)/aterm.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

ATERM_PATH	=  PATH=$(CROSS_PATH)
ATERM_ENV 	=  $(CROSS_ENV)
ATERM_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
ATERM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ATERM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ATERM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--with-jpeg \
	--with-png \
	--enable-fading \
	--with-term=xterm

ifdef PTXCONF_XFREE430
ATERM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ATERM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/aterm.prepare: $(aterm_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ATERM_DIR)/config.cache)
	cd $(ATERM_DIR) && \
		$(ATERM_PATH) $(ATERM_ENV) \
		./configure $(ATERM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

aterm_compile: $(STATEDIR)/aterm.compile

aterm_compile_deps = $(STATEDIR)/aterm.prepare

$(STATEDIR)/aterm.compile: $(aterm_compile_deps)
	@$(call targetinfo, $@)
	$(ATERM_PATH) $(MAKE) -C $(ATERM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

aterm_install: $(STATEDIR)/aterm.install

$(STATEDIR)/aterm.install: $(STATEDIR)/aterm.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

aterm_targetinstall: $(STATEDIR)/aterm.targetinstall

aterm_targetinstall_deps = $(STATEDIR)/aterm.compile

$(STATEDIR)/aterm.targetinstall: $(aterm_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(ATERM_IPKG_TMP)/usr/bin
	cp -a $(ATERM_DIR)/src/aterm $(ATERM_IPKG_TMP)/usr/bin
	$(CROSSSTRIP) $(ATERM_IPKG_TMP)/usr/bin/aterm
	mkdir -p $(ATERM_IPKG_TMP)/usr/share/applications
	mkdir -p $(ATERM_IPKG_TMP)/usr/share/pixmaps
	cp -a $(TOPDIR)/config/pics/aterm.desktop $(ATERM_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/konsole.png   $(ATERM_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(ATERM_IPKG_TMP)/CONTROL
	echo "Package: aterm" 				>$(ATERM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(ATERM_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 			>>$(ATERM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(ATERM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(ATERM_IPKG_TMP)/CONTROL/control
	echo "Version: $(ATERM_VERSION)" 		>>$(ATERM_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430, libjpeg, libpng" 	>>$(ATERM_IPKG_TMP)/CONTROL/control
	echo "Description: aterm is based upon rxvt v.2.4.8 with add ons of Alfredo Kojima's NeXT-ish scrollbars.">>$(ATERM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ATERM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ATERM_INSTALL
ROMPACKAGES += $(STATEDIR)/aterm.imageinstall
endif

aterm_imageinstall_deps = $(STATEDIR)/aterm.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/aterm.imageinstall: $(aterm_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install aterm
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

aterm_clean:
	rm -rf $(STATEDIR)/aterm.*
	rm -rf $(ATERM_DIR)

# vim: syntax=make
