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
ifdef PTXCONF_RDESKTOP
PACKAGES += rdesktop
endif

#
# Paths and names
#
RDESKTOP_VERSION	= 1.3.1
RDESKTOP		= rdesktop-$(RDESKTOP_VERSION)
RDESKTOP_SUFFIX		= tar.gz
RDESKTOP_URL		= http://optusnet.dl.sourceforge.net/sourceforge/rdesktop/$(RDESKTOP).$(RDESKTOP_SUFFIX)
RDESKTOP_SOURCE		= $(SRCDIR)/$(RDESKTOP).$(RDESKTOP_SUFFIX)
RDESKTOP_DIR		= $(BUILDDIR)/$(RDESKTOP)
RDESKTOP_IPKG_TMP	= $(RDESKTOP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rdesktop_get: $(STATEDIR)/rdesktop.get

rdesktop_get_deps = $(RDESKTOP_SOURCE)

$(STATEDIR)/rdesktop.get: $(rdesktop_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(RDESKTOP))
	touch $@

$(RDESKTOP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(RDESKTOP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rdesktop_extract: $(STATEDIR)/rdesktop.extract

rdesktop_extract_deps = $(STATEDIR)/rdesktop.get

$(STATEDIR)/rdesktop.extract: $(rdesktop_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RDESKTOP_DIR))
	@$(call extract, $(RDESKTOP_SOURCE))
	@$(call patchin, $(RDESKTOP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rdesktop_prepare: $(STATEDIR)/rdesktop.prepare

#
# dependencies
#
rdesktop_prepare_deps = \
	$(STATEDIR)/rdesktop.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

RDESKTOP_PATH	=  PATH=$(CROSS_PATH)
RDESKTOP_ENV 	=  $(CROSS_ENV)
#RDESKTOP_ENV	+=
RDESKTOP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#RDESKTOP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
RDESKTOP_AUTOCONF = \
	--prefix=/usr \
	--with-x=$(CROSS_LIB_DIR) \
	--with-openssl=$(CROSS_LIB_DIR) \
	--with-incdir=$(CROSS_LIB_DIR)/include

#ifdef PTXCONF_XFREE430
#RDESKTOP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
#RDESKTOP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
#endif

$(STATEDIR)/rdesktop.prepare: $(rdesktop_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RDESKTOP_DIR)/config.cache)
	cd $(RDESKTOP_DIR) && \
		$(RDESKTOP_PATH) $(RDESKTOP_ENV) \
		./configure $(RDESKTOP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rdesktop_compile: $(STATEDIR)/rdesktop.compile

rdesktop_compile_deps = $(STATEDIR)/rdesktop.prepare

$(STATEDIR)/rdesktop.compile: $(rdesktop_compile_deps)
	@$(call targetinfo, $@)
	$(RDESKTOP_PATH) $(RDESKTOP_ENV) $(MAKE) -C $(RDESKTOP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rdesktop_install: $(STATEDIR)/rdesktop.install

$(STATEDIR)/rdesktop.install: $(STATEDIR)/rdesktop.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rdesktop_targetinstall: $(STATEDIR)/rdesktop.targetinstall

rdesktop_targetinstall_deps = $(STATEDIR)/rdesktop.compile \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/rdesktop.targetinstall: $(rdesktop_targetinstall_deps)
	@$(call targetinfo, $@)
	$(RDESKTOP_PATH) $(RDESKTOP_ENV) $(MAKE) -C $(RDESKTOP_DIR) DESTDIR=$(RDESKTOP_IPKG_TMP) install
	rm -rf $(RDESKTOP_IPKG_TMP)/usr/man
	mkdir -p $(RDESKTOP_IPKG_TMP)/CONTROL
	echo "Package: rdesktop" 						>$(RDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(RDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Section: X11" 							>>$(RDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(RDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(RDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Version: $(RDESKTOP_VERSION)" 					>>$(RDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 						>>$(RDESKTOP_IPKG_TMP)/CONTROL/control
	echo "Description: Remote Desktop Client for MS Windows"		>>$(RDESKTOP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(RDESKTOP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_RDESKTOP_INSTALL
ROMPACKAGES += $(STATEDIR)/rdesktop.imageinstall
endif

rdesktop_imageinstall_deps = $(STATEDIR)/rdesktop.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/rdesktop.imageinstall: $(rdesktop_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install rdesktop
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rdesktop_clean:
	rm -rf $(STATEDIR)/rdesktop.*
	rm -rf $(RDESKTOP_DIR)

# vim: syntax=make
