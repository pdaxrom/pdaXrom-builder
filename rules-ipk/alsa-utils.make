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
ifdef PTXCONF_ALSA-UTILS
PACKAGES += alsa-utils
endif

#
# Paths and names
#
ALSA-UTILS_VENDOR_VERSION	= 1
ALSA-UTILS_VERSION		= 1.0.8
ALSA-UTILS			= alsa-utils-$(ALSA-UTILS_VERSION)
ALSA-UTILS_SUFFIX		= tar.bz2
ALSA-UTILS_URL			= ftp://ftp.alsa-project.org/pub/utils/$(ALSA-UTILS).$(ALSA-UTILS_SUFFIX)
ALSA-UTILS_SOURCE		= $(SRCDIR)/$(ALSA-UTILS).$(ALSA-UTILS_SUFFIX)
ALSA-UTILS_DIR			= $(BUILDDIR)/$(ALSA-UTILS)
ALSA-UTILS_IPKG_TMP		= $(ALSA-UTILS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

alsa-utils_get: $(STATEDIR)/alsa-utils.get

alsa-utils_get_deps = $(ALSA-UTILS_SOURCE)

$(STATEDIR)/alsa-utils.get: $(alsa-utils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ALSA-UTILS))
	touch $@

$(ALSA-UTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ALSA-UTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

alsa-utils_extract: $(STATEDIR)/alsa-utils.extract

alsa-utils_extract_deps = $(STATEDIR)/alsa-utils.get

$(STATEDIR)/alsa-utils.extract: $(alsa-utils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ALSA-UTILS_DIR))
	@$(call extract, $(ALSA-UTILS_SOURCE))
	@$(call patchin, $(ALSA-UTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

alsa-utils_prepare: $(STATEDIR)/alsa-utils.prepare

#
# dependencies
#
alsa-utils_prepare_deps = \
	$(STATEDIR)/alsa-utils.extract \
	$(STATEDIR)/alsa-lib.install \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/virtual-xchain.install

ALSA-UTILS_PATH	=  PATH=$(CROSS_PATH)
ALSA-UTILS_ENV 	=  $(CROSS_ENV)
#ALSA-UTILS_ENV	+=
ALSA-UTILS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ALSA-UTILS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ALSA-UTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
ALSA-UTILS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ALSA-UTILS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/alsa-utils.prepare: $(alsa-utils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ALSA-UTILS_DIR)/config.cache)
	cd $(ALSA-UTILS_DIR) && \
		$(ALSA-UTILS_PATH) $(ALSA-UTILS_ENV) \
		./configure $(ALSA-UTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

alsa-utils_compile: $(STATEDIR)/alsa-utils.compile

alsa-utils_compile_deps = $(STATEDIR)/alsa-utils.prepare

$(STATEDIR)/alsa-utils.compile: $(alsa-utils_compile_deps)
	@$(call targetinfo, $@)
	$(ALSA-UTILS_PATH) $(MAKE) -C $(ALSA-UTILS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

alsa-utils_install: $(STATEDIR)/alsa-utils.install

$(STATEDIR)/alsa-utils.install: $(STATEDIR)/alsa-utils.compile
	@$(call targetinfo, $@)
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

alsa-utils_targetinstall: $(STATEDIR)/alsa-utils.targetinstall

alsa-utils_targetinstall_deps = $(STATEDIR)/alsa-utils.compile \
	$(STATEDIR)/ncurses.targetinstall \
	$(STATEDIR)/alsa-lib.targetinstall

$(STATEDIR)/alsa-utils.targetinstall: $(alsa-utils_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ALSA-UTILS_PATH) $(MAKE) -C $(ALSA-UTILS_DIR) DESTDIR=$(ALSA-UTILS_IPKG_TMP) install
	rm -rf $(ALSA-UTILS_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(ALSA-UTILS_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(ALSA-UTILS_IPKG_TMP)/usr/sbin/alsactl
	mkdir -p $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/init.d
	mkdir -p $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/rc0.d
	mkdir -p $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/rc1.d
	mkdir -p $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/rc2.d
	mkdir -p $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/rc3.d
	mkdir -p $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/rc4.d
	mkdir -p $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/rc5.d
	mkdir -p $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/rc6.d
	$(INSTALL) -m 755 $(TOPDIR)/config/pics/alsa $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/init.d/
	ln -sf ../init.d/alsa $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/rc0.d/K40alsa
	ln -sf ../init.d/alsa $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/rc1.d/K40alsa
	ln -sf ../init.d/alsa $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/rc3.d/S90alsa
	ln -sf ../init.d/alsa $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/rc4.d/S90alsa
	ln -sf ../init.d/alsa $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/rc5.d/S90alsa
	ln -sf ../init.d/alsa $(ALSA-UTILS_IPKG_TMP)/etc/rc.d/rc6.d/K40alsa
	mkdir -p $(ALSA-UTILS_IPKG_TMP)/CONTROL
	echo "Package: alsa-utils" 							 >$(ALSA-UTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ALSA-UTILS_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 							>>$(ALSA-UTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(ALSA-UTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ALSA-UTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(ALSA-UTILS_VERSION)-$(ALSA-UTILS_VENDOR_VERSION)" 		>>$(ALSA-UTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: alsa-lib" 							>>$(ALSA-UTILS_IPKG_TMP)/CONTROL/control
	echo "Description: ALSA utilities"						>>$(ALSA-UTILS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ALSA-UTILS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ALSA-UTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/alsa-utils.imageinstall
endif

alsa-utils_imageinstall_deps = $(STATEDIR)/alsa-utils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/alsa-utils.imageinstall: $(alsa-utils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install alsa-utils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

alsa-utils_clean:
	rm -rf $(STATEDIR)/alsa-utils.*
	rm -rf $(ALSA-UTILS_DIR)

# vim: syntax=make
