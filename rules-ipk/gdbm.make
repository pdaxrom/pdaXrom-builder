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
ifdef PTXCONF_GDBM
PACKAGES += gdbm
endif

#
# Paths and names
#
GDBM_VERSION	= 1.8.3
GDBM		= gdbm-$(GDBM_VERSION)
GDBM_SUFFIX	= tar.gz
GDBM_URL	= ftp://ftp.gnu.org/gnu/gdbm/$(GDBM).$(GDBM_SUFFIX)
GDBM_SOURCE	= $(SRCDIR)/$(GDBM).$(GDBM_SUFFIX)
GDBM_DIR	= $(BUILDDIR)/$(GDBM)
GDBM_IPKG_TMP	= $(GDBM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gdbm_get: $(STATEDIR)/gdbm.get

gdbm_get_deps = $(GDBM_SOURCE)

$(STATEDIR)/gdbm.get: $(gdbm_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GDBM))
	touch $@

$(GDBM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GDBM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gdbm_extract: $(STATEDIR)/gdbm.extract

gdbm_extract_deps = $(STATEDIR)/gdbm.get

$(STATEDIR)/gdbm.extract: $(gdbm_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GDBM_DIR))
	@$(call extract, $(GDBM_SOURCE))
	@$(call patchin, $(GDBM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gdbm_prepare: $(STATEDIR)/gdbm.prepare

#
# dependencies
#
gdbm_prepare_deps = \
	$(STATEDIR)/gdbm.extract \
	$(STATEDIR)/virtual-xchain.install

GDBM_PATH	=  PATH=$(CROSS_PATH)
GDBM_ENV 	=  $(CROSS_ENV)
#GDBM_ENV	+=
GDBM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GDBM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GDBM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
GDBM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GDBM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gdbm.prepare: $(gdbm_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GDBM_DIR)/config.cache)
	cd $(GDBM_DIR) && \
		$(GDBM_PATH) $(GDBM_ENV) \
		./configure $(GDBM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gdbm_compile: $(STATEDIR)/gdbm.compile

gdbm_compile_deps = $(STATEDIR)/gdbm.prepare

$(STATEDIR)/gdbm.compile: $(gdbm_compile_deps)
	@$(call targetinfo, $@)
	$(GDBM_PATH) $(MAKE) -C $(GDBM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gdbm_install: $(STATEDIR)/gdbm.install

$(STATEDIR)/gdbm.install: $(STATEDIR)/gdbm.compile
	@$(call targetinfo, $@)
	$(GDBM_PATH) $(MAKE) -C $(GDBM_DIR) prefix=$(GDBM_IPKG_TMP)/usr install
	cp -a  $(GDBM_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(GDBM_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(GDBM_IPKG_TMP)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgdbm.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gdbm_targetinstall: $(STATEDIR)/gdbm.targetinstall

gdbm_targetinstall_deps = $(STATEDIR)/gdbm.compile

$(STATEDIR)/gdbm.targetinstall: $(gdbm_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GDBM_PATH) $(MAKE) -C $(GDBM_DIR) prefix=$(GDBM_IPKG_TMP)/usr install
	rm -rf $(GDBM_IPKG_TMP)/usr/include
	rm -rf $(GDBM_IPKG_TMP)/usr/info
	rm -rf $(GDBM_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(GDBM_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(GDBM_IPKG_TMP)/usr/lib/*
	mkdir -p $(GDBM_IPKG_TMP)/CONTROL
	echo "Package: gdbm" 				>$(GDBM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(GDBM_IPKG_TMP)/CONTROL/control
	echo "Section: Database" 			>>$(GDBM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(GDBM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(GDBM_IPKG_TMP)/CONTROL/control
	echo "Version: $(GDBM_VERSION)" 		>>$(GDBM_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(GDBM_IPKG_TMP)/CONTROL/control
	echo "Description: GNU dbm is a set of database routines that use extendible hashing and works similar to the standard UNIX dbm routines.">>$(GDBM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GDBM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GDBM_INSTALL
ROMPACKAGES += $(STATEDIR)/gdbm.imageinstall
endif

gdbm_imageinstall_deps = $(STATEDIR)/gdbm.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gdbm.imageinstall: $(gdbm_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gdbm
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gdbm_clean:
	rm -rf $(STATEDIR)/gdbm.*
	rm -rf $(GDBM_DIR)

# vim: syntax=make
