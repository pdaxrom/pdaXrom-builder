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
ifdef PTXCONF_BLUEZ-LIBS
PACKAGES += bluez-libs
endif

#
# Paths and names
#
BLUEZ-LIBS_VERSION	= 2.5
BLUEZ-LIBS		= bluez-libs-$(BLUEZ-LIBS_VERSION)
BLUEZ-LIBS_SUFFIX	= tar.gz
BLUEZ-LIBS_URL		= http://bluez.sourceforge.net/download/$(BLUEZ-LIBS).$(BLUEZ-LIBS_SUFFIX)
BLUEZ-LIBS_SOURCE	= $(SRCDIR)/$(BLUEZ-LIBS).$(BLUEZ-LIBS_SUFFIX)
BLUEZ-LIBS_DIR		= $(BUILDDIR)/$(BLUEZ-LIBS)
BLUEZ-LIBS_IPKG_TMP	= $(BLUEZ-LIBS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

bluez-libs_get: $(STATEDIR)/bluez-libs.get

bluez-libs_get_deps = $(BLUEZ-LIBS_SOURCE)

$(STATEDIR)/bluez-libs.get: $(bluez-libs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(BLUEZ-LIBS))
	touch $@

$(BLUEZ-LIBS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(BLUEZ-LIBS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

bluez-libs_extract: $(STATEDIR)/bluez-libs.extract

bluez-libs_extract_deps = $(STATEDIR)/bluez-libs.get

$(STATEDIR)/bluez-libs.extract: $(bluez-libs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BLUEZ-LIBS_DIR))
	@$(call extract, $(BLUEZ-LIBS_SOURCE))
	@$(call patchin, $(BLUEZ-LIBS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

bluez-libs_prepare: $(STATEDIR)/bluez-libs.prepare

#
# dependencies
#
bluez-libs_prepare_deps = \
	$(STATEDIR)/bluez-libs.extract \
	$(STATEDIR)/virtual-xchain.install

BLUEZ-LIBS_PATH	=  PATH=$(CROSS_PATH)
BLUEZ-LIBS_ENV 	=  $(CROSS_ENV)
#BLUEZ-LIBS_ENV	+=
BLUEZ-LIBS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#BLUEZ-LIBS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
BLUEZ-LIBS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
BLUEZ-LIBS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
BLUEZ-LIBS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/bluez-libs.prepare: $(bluez-libs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(BLUEZ-LIBS_DIR)/config.cache)
	cd $(BLUEZ-LIBS_DIR) && \
		$(BLUEZ-LIBS_PATH) $(BLUEZ-LIBS_ENV) \
		./configure $(BLUEZ-LIBS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

bluez-libs_compile: $(STATEDIR)/bluez-libs.compile

bluez-libs_compile_deps = $(STATEDIR)/bluez-libs.prepare

$(STATEDIR)/bluez-libs.compile: $(bluez-libs_compile_deps)
	@$(call targetinfo, $@)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(BLUEZ-LIBS_DIR)
	$(BLUEZ-LIBS_PATH) $(MAKE) -C $(BLUEZ-LIBS_DIR) CC=$(PTXCONF_GNU_TARGET)-gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

bluez-libs_install: $(STATEDIR)/bluez-libs.install

$(STATEDIR)/bluez-libs.install: $(STATEDIR)/bluez-libs.compile
	@$(call targetinfo, $@)
	$(BLUEZ-LIBS_PATH) $(MAKE) -C $(BLUEZ-LIBS_DIR) DESTDIR=$(BLUEZ-LIBS_IPKG_TMP) CC=$(PTXCONF_GNU_TARGET)-gcc install
	cp -a  $(BLUEZ-LIBS_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(BLUEZ-LIBS_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(BLUEZ-LIBS_IPKG_TMP)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libbluetooth.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

bluez-libs_targetinstall: $(STATEDIR)/bluez-libs.targetinstall

bluez-libs_targetinstall_deps = $(STATEDIR)/bluez-libs.compile

$(STATEDIR)/bluez-libs.targetinstall: $(bluez-libs_targetinstall_deps)
	@$(call targetinfo, $@)
	$(BLUEZ-LIBS_PATH) $(MAKE) -C $(BLUEZ-LIBS_DIR) DESTDIR=$(BLUEZ-LIBS_IPKG_TMP) CC=$(PTXCONF_GNU_TARGET)-gcc install
	mkdir -p $(BLUEZ-LIBS_IPKG_TMP)/CONTROL
	echo "Package: bluez-libs" 			>$(BLUEZ-LIBS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(BLUEZ-LIBS_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(BLUEZ-LIBS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(BLUEZ-LIBS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(BLUEZ-LIBS_IPKG_TMP)/CONTROL/control
	echo "Version: $(BLUEZ-LIBS_VERSION)" 		>>$(BLUEZ-LIBS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(BLUEZ-LIBS_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(BLUEZ-LIBS_IPKG_TMP)/CONTROL/control
	rm -rf $(BLUEZ-LIBS_IPKG_TMP)/usr/include
	rm -rf $(BLUEZ-LIBS_IPKG_TMP)/usr/lib/*.la
	rm -rf $(BLUEZ-LIBS_IPKG_TMP)/usr/lib/*.a
	$(CROSSSTRIP) $(BLUEZ-LIBS_IPKG_TMP)/usr/lib/libbluetooth.so.1.0.3
	cd $(FEEDDIR) && $(XMKIPKG) $(BLUEZ-LIBS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

bluez-libs_clean:
	rm -rf $(STATEDIR)/bluez-libs.*
	rm -rf $(BLUEZ-LIBS_DIR)

# vim: syntax=make
