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
ifdef PTXCONF_KONQUEROR-EMBEDDED
PACKAGES += konqueror-embedded
endif

#
# Paths and names
#
KONQUEROR-EMBEDDED_VERSION		= 20030705
KONQUEROR-EMBEDDED			= konqueror-embedded-snapshot-$(KONQUEROR-EMBEDDED_VERSION)
KONQUEROR-EMBEDDED_SUFFIX		= tar.gz
KONQUEROR-EMBEDDED_URL			= http://devel-home.kde.org/~hausmann/snapshots/$(KONQUEROR-EMBEDDED).$(KONQUEROR-EMBEDDED_SUFFIX)
KONQUEROR-EMBEDDED_SOURCE		= $(SRCDIR)/$(KONQUEROR-EMBEDDED).$(KONQUEROR-EMBEDDED_SUFFIX)
KONQUEROR-EMBEDDED_DIR			= $(BUILDDIR)/$(KONQUEROR-EMBEDDED)
KONQUEROR-EMBEDDED_IPKG_TMP		= $(KONQUEROR-EMBEDDED_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

konqueror-embedded_get: $(STATEDIR)/konqueror-embedded.get

konqueror-embedded_get_deps = $(KONQUEROR-EMBEDDED_SOURCE)

$(STATEDIR)/konqueror-embedded.get: $(konqueror-embedded_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(KONQUEROR-EMBEDDED))
	touch $@

$(KONQUEROR-EMBEDDED_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(KONQUEROR-EMBEDDED_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

konqueror-embedded_extract: $(STATEDIR)/konqueror-embedded.extract

konqueror-embedded_extract_deps = $(STATEDIR)/konqueror-embedded.get

$(STATEDIR)/konqueror-embedded.extract: $(konqueror-embedded_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KONQUEROR-EMBEDDED_DIR))
	@$(call extract, $(KONQUEROR-EMBEDDED_SOURCE))
	@$(call patchin, $(KONQUEROR-EMBEDDED))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

konqueror-embedded_prepare: $(STATEDIR)/konqueror-embedded.prepare

#
# dependencies
#
konqueror-embedded_prepare_deps = \
	$(STATEDIR)/konqueror-embedded.extract \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/pcre.install \
	$(STATEDIR)/qt-x11-free.install \
	$(STATEDIR)/virtual-xchain.install

KONQUEROR-EMBEDDED_PATH	=  PATH=$(CROSS_PATH)
KONQUEROR-EMBEDDED_ENV 	=  $(CROSS_ENV)
KONQUEROR-EMBEDDED_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
KONQUEROR-EMBEDDED_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS) -fno-rtti -fno-exceptions"
KONQUEROR-EMBEDDED_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#KONQUEROR-EMBEDDED_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif
KONQUEROR-EMBEDDED_ENV	+= QTDIR=$(QT-X11-FREE_DIR)

#
# autoconf
#
KONQUEROR-EMBEDDED_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-mt \
	--with-konq-tmp-prefix=/tmp \
	--enable-static \
	--disable-shared \
	--disable-debug \
	--with-javascript=static \
	--with-ssl-dir=$(CROSS_LIB_DIR) \
	--with-ssl-version=$(OPENSSL_VERSION)
#	--enable-final

ifdef PTXCONF_XFREE430
KONQUEROR-EMBEDDED_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
KONQUEROR-EMBEDDED_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/konqueror-embedded.prepare: $(konqueror-embedded_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(KONQUEROR-EMBEDDED_DIR)/config.cache)
	cd $(KONQUEROR-EMBEDDED_DIR) && \
		$(KONQUEROR-EMBEDDED_PATH) $(KONQUEROR-EMBEDDED_ENV) \
		./configure $(KONQUEROR-EMBEDDED_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

konqueror-embedded_compile: $(STATEDIR)/konqueror-embedded.compile

konqueror-embedded_compile_deps = $(STATEDIR)/konqueror-embedded.prepare

$(STATEDIR)/konqueror-embedded.compile: $(konqueror-embedded_compile_deps)
	@$(call targetinfo, $@)
	$(KONQUEROR-EMBEDDED_PATH) $(KONQUEROR-EMBEDDED_ENV) $(MAKE) -C $(KONQUEROR-EMBEDDED_DIR) UIC=uic
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

konqueror-embedded_install: $(STATEDIR)/konqueror-embedded.install

$(STATEDIR)/konqueror-embedded.install: $(STATEDIR)/konqueror-embedded.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

konqueror-embedded_targetinstall: $(STATEDIR)/konqueror-embedded.targetinstall

konqueror-embedded_targetinstall_deps = $(STATEDIR)/konqueror-embedded.compile \
	$(STATEDIR)/openssl.targetinstall \
	$(STATEDIR)/pcre.targetinstall \
	$(STATEDIR)/qt-x11-free.targetinstall

$(STATEDIR)/konqueror-embedded.targetinstall: $(konqueror-embedded_targetinstall_deps)
	@$(call targetinfo, $@)
	$(KONQUEROR-EMBEDDED_PATH) $(MAKE) -C $(KONQUEROR-EMBEDDED_DIR) DESTDIR=$(KONQUEROR-EMBEDDED_IPKG_TMP) install
	mkdir -p $(KONQUEROR-EMBEDDED_IPKG_TMP)/CONTROL
	echo "Package: konqueror-embedded" 					>$(KONQUEROR-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(KONQUEROR-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 						>>$(KONQUEROR-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(KONQUEROR-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(KONQUEROR-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Version: $(KONQUEROR-EMBEDDED_VERSION)" 				>>$(KONQUEROR-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Depends: openssl, pcre, qt-mt" 					>>$(KONQUEROR-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Description: KDE Web Browser Konqueror, embedded version"		>>$(KONQUEROR-EMBEDDED_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(KONQUEROR-EMBEDDED_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_KONQUEROR-EMBEDDED_INSTALL
ROMPACKAGES += $(STATEDIR)/konqueror-embedded.imageinstall
endif

konqueror-embedded_imageinstall_deps = $(STATEDIR)/konqueror-embedded.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/konqueror-embedded.imageinstall: $(konqueror-embedded_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install konqueror-embedded
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

konqueror-embedded_clean:
	rm -rf $(STATEDIR)/konqueror-embedded.*
	rm -rf $(KONQUEROR-EMBEDDED_DIR)

# vim: syntax=make
