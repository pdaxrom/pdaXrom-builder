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
ifdef PTXCONF_GALCULATOR
PACKAGES += galculator
endif

#
# Paths and names
#
GALCULATOR_VERSION	= 1.2.3
GALCULATOR		= galculator-$(GALCULATOR_VERSION)
GALCULATOR_SUFFIX	= tar.bz2
GALCULATOR_URL		= http://heanet.dl.sourceforge.net/sourceforge/galculator/$(GALCULATOR).$(GALCULATOR_SUFFIX)
GALCULATOR_SOURCE	= $(SRCDIR)/$(GALCULATOR).$(GALCULATOR_SUFFIX)
GALCULATOR_DIR		= $(BUILDDIR)/$(GALCULATOR)
GALCULATOR_IPKG_TMP	= $(GALCULATOR_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

galculator_get: $(STATEDIR)/galculator.get

galculator_get_deps = $(GALCULATOR_SOURCE)

$(STATEDIR)/galculator.get: $(galculator_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GALCULATOR))
	touch $@

$(GALCULATOR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GALCULATOR_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

galculator_extract: $(STATEDIR)/galculator.extract

galculator_extract_deps = $(STATEDIR)/galculator.get

$(STATEDIR)/galculator.extract: $(galculator_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GALCULATOR_DIR))
	@$(call extract, $(GALCULATOR_SOURCE))
	@$(call patchin, $(GALCULATOR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

galculator_prepare: $(STATEDIR)/galculator.prepare

#
# dependencies
#
galculator_prepare_deps = \
	$(STATEDIR)/galculator.extract \
	$(STATEDIR)/libglade.install \
	$(STATEDIR)/virtual-xchain.install

GALCULATOR_PATH	=  PATH=$(CROSS_PATH)
GALCULATOR_ENV 	=  $(CROSS_ENV)
#GALCULATOR_ENV	+=
GALCULATOR_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GALCULATOR_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GALCULATOR_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GALCULATOR_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GALCULATOR_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/galculator.prepare: $(galculator_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GALCULATOR_DIR)/config.cache)
	cd $(GALCULATOR_DIR) && \
		$(GALCULATOR_PATH) $(GALCULATOR_ENV) \
		./configure $(GALCULATOR_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

galculator_compile: $(STATEDIR)/galculator.compile

galculator_compile_deps = $(STATEDIR)/galculator.prepare

$(STATEDIR)/galculator.compile: $(galculator_compile_deps)
	@$(call targetinfo, $@)
	$(GALCULATOR_PATH) $(MAKE) -C $(GALCULATOR_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

galculator_install: $(STATEDIR)/galculator.install

$(STATEDIR)/galculator.install: $(STATEDIR)/galculator.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

galculator_targetinstall: $(STATEDIR)/galculator.targetinstall

galculator_targetinstall_deps = $(STATEDIR)/galculator.compile \
	$(STATEDIR)/libglade.targetinstall

$(STATEDIR)/galculator.targetinstall: $(galculator_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GALCULATOR_PATH) $(MAKE) -C $(GALCULATOR_DIR) DESTDIR=$(GALCULATOR_IPKG_TMP) install
	rm -rf $(GALCULATOR_IPKG_TMP)/usr/man
	rm -rf $(GALCULATOR_IPKG_TMP)/usr/share/locale
	$(CROSSSTRIP) $(GALCULATOR_IPKG_TMP)/usr/bin/*
	perl -p -i -e "s/gnome\-calc2\.png/kcalc\.png/g" $(GALCULATOR_IPKG_TMP)/usr/share/applications/galculator.desktop
	mkdir -p $(GALCULATOR_IPKG_TMP)/CONTROL
	echo "Package: galculator" 			>$(GALCULATOR_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(GALCULATOR_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 			>>$(GALCULATOR_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(GALCULATOR_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(GALCULATOR_IPKG_TMP)/CONTROL/control
	echo "Version: $(GALCULATOR_VERSION)" 		>>$(GALCULATOR_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, libglade" 			>>$(GALCULATOR_IPKG_TMP)/CONTROL/control
	echo "Description: galculator is a GTK 2 based calculator with ordinary notation/reverse polish notation, a formula entry mode, different number bases (DEC, HEX, OCT, BIN) and different units of angular measure (DEG, RAD, GRAD).">>$(GALCULATOR_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GALCULATOR_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GALCULATOR_INSTALL
ROMPACKAGES += $(STATEDIR)/galculator.imageinstall
endif

galculator_imageinstall_deps = $(STATEDIR)/galculator.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/galculator.imageinstall: $(galculator_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install galculator
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

galculator_clean:
	rm -rf $(STATEDIR)/galculator.*
	rm -rf $(GALCULATOR_DIR)

# vim: syntax=make
