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
ifdef PTXCONF_FLTDJ
PACKAGES += fltdj
endif

#
# Paths and names
#
FLTDJ_VERSION		= 0.7rc1
FLTDJ			= fltdj-$(FLTDJ_VERSION)-src
FLTDJ_SUFFIX		= tar.gz
FLTDJ_URL		= http://www.geocities.com/letapk/$(FLTDJ).$(FLTDJ_SUFFIX)
FLTDJ_SOURCE		= $(SRCDIR)/$(FLTDJ).$(FLTDJ_SUFFIX)
FLTDJ_DIR		= $(BUILDDIR)/$(FLTDJ)
FLTDJ_IPKG_TMP		= $(FLTDJ_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fltdj_get: $(STATEDIR)/fltdj.get

fltdj_get_deps = $(FLTDJ_SOURCE)

$(STATEDIR)/fltdj.get: $(fltdj_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FLTDJ))
	touch $@

$(FLTDJ_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FLTDJ_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fltdj_extract: $(STATEDIR)/fltdj.extract

fltdj_extract_deps = $(STATEDIR)/fltdj.get

$(STATEDIR)/fltdj.extract: $(fltdj_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FLTDJ_DIR))
	@$(call extract, $(FLTDJ_SOURCE))
	@$(call patchin, $(FLTDJ))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fltdj_prepare: $(STATEDIR)/fltdj.prepare

#
# dependencies
#
fltdj_prepare_deps = \
	$(STATEDIR)/fltdj.extract \
	$(STATEDIR)/fltk-utf8.install \
	$(STATEDIR)/virtual-xchain.install

FLTDJ_PATH	=  PATH=$(CROSS_PATH)
FLTDJ_ENV 	=  $(CROSS_ENV)
#FLTDJ_ENV	+=
FLTDJ_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FLTDJ_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
FLTDJ_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
FLTDJ_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FLTDJ_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/fltdj.prepare: $(fltdj_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FLTDJ_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fltdj_compile: $(STATEDIR)/fltdj.compile

fltdj_compile_deps = $(STATEDIR)/fltdj.prepare

$(STATEDIR)/fltdj.compile: $(fltdj_compile_deps)
	@$(call targetinfo, $@)
	$(FLTDJ_PATH) $(MAKE) -C $(FLTDJ_DIR) CC=$(PTXCONF_GNU_TARGET)-g++ 
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fltdj_install: $(STATEDIR)/fltdj.install

$(STATEDIR)/fltdj.install: $(STATEDIR)/fltdj.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fltdj_targetinstall: $(STATEDIR)/fltdj.targetinstall

fltdj_targetinstall_deps = $(STATEDIR)/fltdj.compile \
	$(STATEDIR)/fltk-utf8.targetinstall

$(STATEDIR)/fltdj.targetinstall: $(fltdj_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FLTDJ_PATH) $(MAKE) -C $(FLTDJ_DIR) DESTDIR=$(FLTDJ_IPKG_TMP) install
	$(CROSSSTRIP) $(FLTDJ_IPKG_TMP)/usr/bin/*
	mkdir -p $(FLTDJ_IPKG_TMP)/usr/share/{applications,pixmaps}
	cp -a $(TOPDIR)/config/pics/fltdj.desktop $(FLTDJ_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/fltdj.png     $(FLTDJ_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(FLTDJ_IPKG_TMP)/CONTROL
	echo "Package: fltdj" 					 >$(FLTDJ_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(FLTDJ_IPKG_TMP)/CONTROL/control
	echo "Section: PIM"	 				>>$(FLTDJ_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"	>>$(FLTDJ_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(FLTDJ_IPKG_TMP)/CONTROL/control
	echo "Version: $(FLTDJ_VERSION)" 			>>$(FLTDJ_IPKG_TMP)/CONTROL/control
	echo "Depends: fltk-utf8" 				>>$(FLTDJ_IPKG_TMP)/CONTROL/control
	echo "Description: fltdj manages daily notes, appointments, alarms to upcoming appointments, contacts, holidays and to-do list.">>$(FLTDJ_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FLTDJ_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FLTDJ_INSTALL
ROMPACKAGES += $(STATEDIR)/fltdj.imageinstall
endif

fltdj_imageinstall_deps = $(STATEDIR)/fltdj.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fltdj.imageinstall: $(fltdj_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fltdj
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fltdj_clean:
	rm -rf $(STATEDIR)/fltdj.*
	rm -rf $(FLTDJ_DIR)

# vim: syntax=make
