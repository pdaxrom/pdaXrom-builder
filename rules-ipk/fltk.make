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
ifdef PTXCONF_FLTK
PACKAGES += fltk
endif

#
# Paths and names
#
FLTK_VERSION		= 2.0.x
FLTK			= fltk-$(FLTK_VERSION)
FLTK_SOURCE		= $(SRCDIR)/$(FLTK)
FLTK_DIR		= $(BUILDDIR)/$(FLTK)
FLTK_IPKG_TMP		= $(FLTK_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fltk_get: $(STATEDIR)/fltk.get

fltk_get_deps = $(FLTK_SOURCE)

$(STATEDIR)/fltk.get: $(fltk_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FLTK))
	touch $@

$(FLTK_SOURCE):
	@$(call targetinfo, $@)
	cvs -d :pserver:anonymous:@cvs.sourceforge.net:/cvsroot/fltk login
	cd $(TOPDIR)/src && cvs -z3 -d :pserver:anonymous:@cvs.sourceforge.net:/cvsroot/fltk get -d fltk-2.0.x fltk

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fltk_extract: $(STATEDIR)/fltk.extract

fltk_extract_deps = $(STATEDIR)/fltk.get

$(STATEDIR)/fltk.extract: $(fltk_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FLTK_DIR))
	cp -a  $(FLTK_SOURCE) $(BUILDDIR)
	@$(call patchin, $(FLTK))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fltk_prepare: $(STATEDIR)/fltk.prepare

#
# dependencies
#
fltk_prepare_deps = \
	$(STATEDIR)/fltk.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

FLTK_PATH	=  PATH=$(CROSS_PATH)
FLTK_ENV 	=  $(CROSS_ENV)
FLTK_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
FLTK_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
FLTK_ENV	+= CPPFLAGS=-I$(CROSS_LIB_DIR)/include/freetype2
FLTK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FLTK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
FLTK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared \
	--disable-gl \
	--enable-threads \
	--disable-cairo \
	--enable-xft \
	--disable-xdbe \
	--disable-xinerama \
	--with-optim="$(TARGET_OPT_CFLAGS) -I$(CROSS_LIB_DIR)/include/freetype2"

ifdef PTXCONF_XFREE430
FLTK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FLTK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/fltk.prepare: $(fltk_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FLTK_DIR)/config.cache)
	cd $(FLTK_DIR) && autoconf
	cd $(FLTK_DIR) && \
		$(FLTK_PATH) $(FLTK_ENV) \
		./configure $(FLTK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fltk_compile: $(STATEDIR)/fltk.compile

fltk_compile_deps = $(STATEDIR)/fltk.prepare

$(STATEDIR)/fltk.compile: $(fltk_compile_deps)
	@$(call targetinfo, $@)
	$(FLTK_PATH) $(MAKE) -C $(FLTK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fltk_install: $(STATEDIR)/fltk.install

$(STATEDIR)/fltk.install: $(STATEDIR)/fltk.compile
	@$(call targetinfo, $@)
	$(FLTK_PATH) $(MAKE) -C $(FLTK_DIR) DESTDIR=$(FLTK_IPKG_TMP) install
	asadsas
	rm -rf $(FLTK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fltk_targetinstall: $(STATEDIR)/fltk.targetinstall

fltk_targetinstall_deps = $(STATEDIR)/fltk.compile \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/fltk.targetinstall: $(fltk_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FLTK_PATH) $(MAKE) -C $(FLTK_DIR) DESTDIR=$(FLTK_IPKG_TMP) install
	mkdir -p $(FLTK_IPKG_TMP)/CONTROL
	echo "Package: fltk" 					 >$(FLTK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(FLTK_IPKG_TMP)/CONTROL/control
	echo "Section: FLTK"		 			>>$(FLTK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(FLTK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(FLTK_IPKG_TMP)/CONTROL/control
	echo "Version: $(FLTK_VERSION)" 			>>$(FLTK_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 				>>$(FLTK_IPKG_TMP)/CONTROL/control
	echo "Description: FLTK (pronounced "fulltick") is a cross-platform C++ GUI toolkit for UNIX?/Linux (X11), Microsoft? Windows, and MacOS X.">>$(FLTK_IPKG_TMP)/CONTROL/control
	asads
	cd $(FEEDDIR) && $(XMKIPKG) $(FLTK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FLTK_INSTALL
ROMPACKAGES += $(STATEDIR)/fltk.imageinstall
endif

fltk_imageinstall_deps = $(STATEDIR)/fltk.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fltk.imageinstall: $(fltk_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fltk
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fltk_clean:
	rm -rf $(STATEDIR)/fltk.*
	rm -rf $(FLTK_DIR)

# vim: syntax=make
