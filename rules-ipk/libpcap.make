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
ifdef PTXCONF_LIBPCAP
PACKAGES += libpcap
endif

#
# Paths and names
#
LIBPCAP_VENDOR_VERSION	= 1
LIBPCAP_VERSION		= 0.8.3
LIBPCAP			= libpcap-$(LIBPCAP_VERSION)
LIBPCAP_SUFFIX		= tar.gz
LIBPCAP_URL		= http://www.tcpdump.org/release/$(LIBPCAP).$(LIBPCAP_SUFFIX)
LIBPCAP_SOURCE		= $(SRCDIR)/$(LIBPCAP).$(LIBPCAP_SUFFIX)
LIBPCAP_DIR		= $(BUILDDIR)/$(LIBPCAP)
LIBPCAP_IPKG_TMP	= $(LIBPCAP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libpcap_get: $(STATEDIR)/libpcap.get

libpcap_get_deps = $(LIBPCAP_SOURCE)

$(STATEDIR)/libpcap.get: $(libpcap_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBPCAP))
	touch $@

$(LIBPCAP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBPCAP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libpcap_extract: $(STATEDIR)/libpcap.extract

libpcap_extract_deps = $(STATEDIR)/libpcap.get

$(STATEDIR)/libpcap.extract: $(libpcap_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBPCAP_DIR))
	@$(call extract, $(LIBPCAP_SOURCE))
	@$(call patchin, $(LIBPCAP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libpcap_prepare: $(STATEDIR)/libpcap.prepare

#
# dependencies
#
libpcap_prepare_deps = \
	$(STATEDIR)/libpcap.extract \
	$(STATEDIR)/virtual-xchain.install

LIBPCAP_PATH	=  PATH=$(CROSS_PATH)
LIBPCAP_ENV 	=  $(CROSS_ENV)
#LIBPCAP_ENV	+=
LIBPCAP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBPCAP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
LIBPCAP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-debug \
	--with-pcap=linux

ifdef PTXCONF_XFREE430
LIBPCAP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBPCAP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libpcap.prepare: $(libpcap_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBPCAP_DIR)/config.cache)
	cd $(LIBPCAP_DIR) && \
		$(LIBPCAP_PATH) $(LIBPCAP_ENV) \
		ac_cv_linux_vers=2 \
		./configure $(LIBPCAP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libpcap_compile: $(STATEDIR)/libpcap.compile

libpcap_compile_deps = $(STATEDIR)/libpcap.prepare

$(STATEDIR)/libpcap.compile: $(libpcap_compile_deps)
	@$(call targetinfo, $@)
	$(LIBPCAP_PATH) $(MAKE) -C $(LIBPCAP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libpcap_install: $(STATEDIR)/libpcap.install

$(STATEDIR)/libpcap.install: $(STATEDIR)/libpcap.compile
	@$(call targetinfo, $@)
	rm -rf $(LIBPCAP_IPKG_TMP)
	$(LIBPCAP_PATH) $(MAKE) -C $(LIBPCAP_DIR) DESTDIR=$(LIBPCAP_IPKG_TMP) install
	cp -a $(LIBPCAP_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(LIBPCAP_IPKG_TMP)/usr/lib/*	$(CROSS_LIB_DIR)/lib/
	rm -rf $(LIBPCAP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libpcap_targetinstall: $(STATEDIR)/libpcap.targetinstall

libpcap_targetinstall_deps = $(STATEDIR)/libpcap.compile

$(STATEDIR)/libpcap.targetinstall: $(libpcap_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBPCAP_PATH) $(MAKE) -C $(LIBPCAP_DIR) DESTDIR=$(LIBPCAP_IPKG_TMP) install
	mkdir -p $(LIBPCAP_IPKG_TMP)/CONTROL
	echo "Package: libpcap" 							 >$(LIBPCAP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(LIBPCAP_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 							>>$(LIBPCAP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(LIBPCAP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(LIBPCAP_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBPCAP_VERSION)-$(LIBPCAP_VENDOR_VERSION)" 			>>$(LIBPCAP_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(LIBPCAP_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"				>>$(LIBPCAP_IPKG_TMP)/CONTROL/control
	asdas
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBPCAP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBPCAP_INSTALL
ROMPACKAGES += $(STATEDIR)/libpcap.imageinstall
endif

libpcap_imageinstall_deps = $(STATEDIR)/libpcap.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libpcap.imageinstall: $(libpcap_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libpcap
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libpcap_clean:
	rm -rf $(STATEDIR)/libpcap.*
	rm -rf $(LIBPCAP_DIR)

# vim: syntax=make
