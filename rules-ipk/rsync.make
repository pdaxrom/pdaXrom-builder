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
ifdef PTXCONF_RSYNC
PACKAGES += rsync
endif

#
# Paths and names
#
RSYNC_VENDOR_VERSION	= 1
RSYNC_VERSION		= 2.6.3
RSYNC			= rsync-$(RSYNC_VERSION)
RSYNC_SUFFIX		= tar.gz
RSYNC_URL		= http://samba.anu.edu.au/ftp/rsync/$(RSYNC).$(RSYNC_SUFFIX)
RSYNC_SOURCE		= $(SRCDIR)/$(RSYNC).$(RSYNC_SUFFIX)
RSYNC_DIR		= $(BUILDDIR)/$(RSYNC)
RSYNC_IPKG_TMP		= $(RSYNC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rsync_get: $(STATEDIR)/rsync.get

rsync_get_deps = $(RSYNC_SOURCE)

$(STATEDIR)/rsync.get: $(rsync_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(RSYNC))
	touch $@

$(RSYNC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(RSYNC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rsync_extract: $(STATEDIR)/rsync.extract

rsync_extract_deps = $(STATEDIR)/rsync.get

$(STATEDIR)/rsync.extract: $(rsync_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RSYNC_DIR))
	@$(call extract, $(RSYNC_SOURCE))
	@$(call patchin, $(RSYNC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rsync_prepare: $(STATEDIR)/rsync.prepare

#
# dependencies
#
rsync_prepare_deps = \
	$(STATEDIR)/rsync.extract \
	$(STATEDIR)/virtual-xchain.install

RSYNC_PATH	=  PATH=$(CROSS_PATH)
RSYNC_ENV 	=  $(CROSS_ENV)
#RSYNC_ENV	+=
RSYNC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#RSYNC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
RSYNC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
RSYNC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
RSYNC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/rsync.prepare: $(rsync_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(RSYNC_DIR)/config.cache)
	cd $(RSYNC_DIR) && $(RSYNC_PATH) aclocal
	cd $(RSYNC_DIR) && $(RSYNC_PATH) automake --add-missing
	cd $(RSYNC_DIR) && $(RSYNC_PATH) autoconf
	cd $(RSYNC_DIR) && \
		$(RSYNC_PATH) $(RSYNC_ENV) \
		./configure $(RSYNC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rsync_compile: $(STATEDIR)/rsync.compile

rsync_compile_deps = $(STATEDIR)/rsync.prepare

$(STATEDIR)/rsync.compile: $(rsync_compile_deps)
	@$(call targetinfo, $@)
	$(RSYNC_PATH) $(MAKE) -C $(RSYNC_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rsync_install: $(STATEDIR)/rsync.install

$(STATEDIR)/rsync.install: $(STATEDIR)/rsync.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rsync_targetinstall: $(STATEDIR)/rsync.targetinstall

rsync_targetinstall_deps = $(STATEDIR)/rsync.compile

$(STATEDIR)/rsync.targetinstall: $(rsync_targetinstall_deps)
	@$(call targetinfo, $@)
	$(RSYNC_PATH) $(MAKE) -C $(RSYNC_DIR) DESTDIR=$(RSYNC_IPKG_TMP) install
	mkdir -p $(RSYNC_IPKG_TMP)/CONTROL
	echo "Package: rsync" 											 >$(RSYNC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(RSYNC_IPKG_TMP)/CONTROL/control
	echo "Section: Utilities" 										>>$(RSYNC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(RSYNC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(RSYNC_IPKG_TMP)/CONTROL/control
	echo "Version: $(RSYNC_VERSION)-$(RSYNC_VENDOR_VERSION)" 						>>$(RSYNC_IPKG_TMP)/CONTROL/control
	echo "Depends: " 											>>$(RSYNC_IPKG_TMP)/CONTROL/control
	echo "Description: rsync is an open source utility that provides fast incremental file transfer."	>>$(RSYNC_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(RSYNC_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_RSYNC_INSTALL
ROMPACKAGES += $(STATEDIR)/rsync.imageinstall
endif

rsync_imageinstall_deps = $(STATEDIR)/rsync.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/rsync.imageinstall: $(rsync_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install rsync
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rsync_clean:
	rm -rf $(STATEDIR)/rsync.*
	rm -rf $(RSYNC_DIR)

# vim: syntax=make
