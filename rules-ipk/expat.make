# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <Sash@pdaXrom.org>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_EXPAT
PACKAGES += expat
endif

#
# Paths and names
#
EXPAT_VERSION		= 1.95.8
EXPAT			= expat-$(EXPAT_VERSION)
EXPAT_SUFFIX		= tar.gz
EXPAT_URL		= http://heanet.dl.sourceforge.net/sourceforge/expat/$(EXPAT).$(EXPAT_SUFFIX)
EXPAT_SOURCE		= $(SRCDIR)/$(EXPAT).$(EXPAT_SUFFIX)
EXPAT_DIR		= $(BUILDDIR)/$(EXPAT)
EXPAT_IPKG_TMP		= $(EXPAT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

expat_get: $(STATEDIR)/expat.get

expat_get_deps = $(EXPAT_SOURCE)

$(STATEDIR)/expat.get: $(expat_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(EXPAT))
	touch $@

$(EXPAT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(EXPAT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

expat_extract: $(STATEDIR)/expat.extract

expat_extract_deps = $(STATEDIR)/expat.get

$(STATEDIR)/expat.extract: $(expat_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EXPAT_DIR))
	@$(call extract, $(EXPAT_SOURCE))
	@$(call patchin, $(EXPAT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

expat_prepare: $(STATEDIR)/expat.prepare

#
# dependencies
#
expat_prepare_deps = \
	$(STATEDIR)/expat.extract \
	$(STATEDIR)/virtual-xchain.install

EXPAT_PATH	=  PATH=$(CROSS_PATH)
EXPAT_ENV 	=  $(CROSS_ENV)
EXPAT_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
EXPAT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
##ifdef PTXCONF_XFREE430
##EXPAT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
##endif

#
# autoconf
#
EXPAT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

#ifdef PTXCONF_XFREE430
#EXPAT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
#EXPAT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
#endif

$(STATEDIR)/expat.prepare: $(expat_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EXPAT_DIR)/config.cache)
	cd $(EXPAT_DIR) && \
		$(EXPAT_PATH) $(EXPAT_ENV) \
		./configure $(EXPAT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

expat_compile: $(STATEDIR)/expat.compile

expat_compile_deps = $(STATEDIR)/expat.prepare

$(STATEDIR)/expat.compile: $(expat_compile_deps)
	@$(call targetinfo, $@)
	$(EXPAT_PATH) $(MAKE) -C $(EXPAT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

expat_install: $(STATEDIR)/expat.install

$(STATEDIR)/expat.install: $(STATEDIR)/expat.compile
	@$(call targetinfo, $@)
	rm -f $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libexpat.so*
	install $(EXPAT_DIR)/.libs/libexpat.so.0.5.0 $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/
	ln -sf libexpat.so.0.5.0 $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libexpat.so.0
	ln -sf libexpat.so.0.5.0 $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libexpat.so
	rm -f $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/include/expat.h
	install $(EXPAT_DIR)/lib/expat.h $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/include
	install $(EXPAT_DIR)/lib/expat_external.h $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/include
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

expat_targetinstall: $(STATEDIR)/expat.targetinstall

expat_targetinstall_deps = $(STATEDIR)/expat.compile

$(STATEDIR)/expat.targetinstall: $(expat_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(EXPAT_IPKG_TMP)/usr/lib
	install $(EXPAT_DIR)/.libs/libexpat.so.0.5.0 $(EXPAT_IPKG_TMP)/usr/lib/
	ln -s libexpat.so.0.5.0 $(EXPAT_IPKG_TMP)/usr/lib/libexpat.so.0
	ln -s libexpat.so.0.5.0 $(EXPAT_IPKG_TMP)/usr/lib/libexpat.so
	$(CROSSSTRIP) $(EXPAT_IPKG_TMP)/usr/lib/libexpat.so.0.5.0
	mkdir -p $(EXPAT_IPKG_TMP)/CONTROL
	echo "Package: expat" 						>$(EXPAT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(EXPAT_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 					>>$(EXPAT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <Sash@pdaXrom.org>" 		>>$(EXPAT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(EXPAT_IPKG_TMP)/CONTROL/control
	echo "Version: $(EXPAT_VERSION)" 				>>$(EXPAT_IPKG_TMP)/CONTROL/control
	echo "Depends: " 						>>$(EXPAT_IPKG_TMP)/CONTROL/control
	echo "Description: C library for parsing XML, written by James Clark.">>$(EXPAT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(EXPAT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_EXPAT_INSTALL
ROMPACKAGES += $(STATEDIR)/expat.imageinstall
endif

expat_imageinstall_deps = $(STATEDIR)/expat.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/expat.imageinstall: $(expat_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install expat
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

expat_clean:
	rm -rf $(STATEDIR)/expat.*
	rm -rf $(EXPAT_DIR)

# vim: syntax=make
