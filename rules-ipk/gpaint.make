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
ifdef PTXCONF_GPAINT
PACKAGES += gpaint
endif

#
# Paths and names
#
GPAINT_VERSION		= 0.2
GPAINT			= gpaint-$(GPAINT_VERSION)
GPAINT_SUFFIX		= tar.gz
GPAINT_URL		= http://heanet.dl.sourceforge.net/sourceforge/gpaint/$(GPAINT).$(GPAINT_SUFFIX)
GPAINT_SOURCE		= $(SRCDIR)/$(GPAINT).$(GPAINT_SUFFIX)
GPAINT_DIR		= $(BUILDDIR)/$(GPAINT)
GPAINT_IPKG_TMP		= $(GPAINT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gpaint_get: $(STATEDIR)/gpaint.get

gpaint_get_deps = $(GPAINT_SOURCE)

$(STATEDIR)/gpaint.get: $(gpaint_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GPAINT))
	touch $@

$(GPAINT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GPAINT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gpaint_extract: $(STATEDIR)/gpaint.extract

gpaint_extract_deps = $(STATEDIR)/gpaint.get

$(STATEDIR)/gpaint.extract: $(gpaint_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GPAINT_DIR))
	@$(call extract, $(GPAINT_SOURCE))
	@$(call patchin, $(GPAINT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gpaint_prepare: $(STATEDIR)/gpaint.prepare

#
# dependencies
#
gpaint_prepare_deps = \
	$(STATEDIR)/gpaint.extract \
	$(STATEDIR)/virtual-xchain.install

GPAINT_PATH	=  PATH=$(CROSS_PATH)
GPAINT_ENV 	=  $(CROSS_ENV)
GPAINT_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
GPAINT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GPAINT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GPAINT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--without-gnome

ifdef PTXCONF_XFREE430
GPAINT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GPAINT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gpaint.prepare: $(gpaint_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GPAINT_DIR)/config.cache)
	cd $(GPAINT_DIR) && aclocal
	cd $(GPAINT_DIR) && automake --add-missing
	cd $(GPAINT_DIR) && autoconf
	cd $(GPAINT_DIR) && \
		$(GPAINT_PATH) $(GPAINT_ENV) \
		./configure $(GPAINT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gpaint_compile: $(STATEDIR)/gpaint.compile

gpaint_compile_deps = $(STATEDIR)/gpaint.prepare

$(STATEDIR)/gpaint.compile: $(gpaint_compile_deps)
	@$(call targetinfo, $@)
	$(GPAINT_PATH) $(MAKE) -C $(GPAINT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gpaint_install: $(STATEDIR)/gpaint.install

$(STATEDIR)/gpaint.install: $(STATEDIR)/gpaint.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gpaint_targetinstall: $(STATEDIR)/gpaint.targetinstall

gpaint_targetinstall_deps = $(STATEDIR)/gpaint.compile

$(STATEDIR)/gpaint.targetinstall: $(gpaint_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GPAINT_PATH) $(MAKE) -C $(GPAINT_DIR) DESTDIR=$(GPAINT_IPKG_TMP) install
	mkdir -p $(GPAINT_IPKG_TMP)/CONTROL
	echo "Package: gpaint" 							>$(GPAINT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(GPAINT_IPKG_TMP)/CONTROL/control
	echo "Section: X11"				 			>>$(GPAINT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(GPAINT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(GPAINT_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPAINT_VERSION)" 					>>$(GPAINT_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(GPAINT_IPKG_TMP)/CONTROL/control
	echo "Description: This is gpaint (GNU Paint), a small-scale painting program for GNOME, the GNU Desktop.">>$(GPAINT_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(GPAINT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GPAINT_INSTALL
ROMPACKAGES += $(STATEDIR)/gpaint.imageinstall
endif

gpaint_imageinstall_deps = $(STATEDIR)/gpaint.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gpaint.imageinstall: $(gpaint_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gpaint
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gpaint_clean:
	rm -rf $(STATEDIR)/gpaint.*
	rm -rf $(GPAINT_DIR)

# vim: syntax=make
