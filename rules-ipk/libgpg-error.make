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
ifdef PTXCONF_LIBGPG-ERROR
PACKAGES += libgpg-error
endif

#
# Paths and names
#
LIBGPG-ERROR_VERSION	= 0.7
LIBGPG-ERROR		= libgpg-error-$(LIBGPG-ERROR_VERSION)
LIBGPG-ERROR_SUFFIX	= tar.gz
LIBGPG-ERROR_URL	= ftp://ftp.gnupg.org/gcrypt/alpha/libgpg-error/$(LIBGPG-ERROR).$(LIBGPG-ERROR_SUFFIX)
LIBGPG-ERROR_SOURCE	= $(SRCDIR)/$(LIBGPG-ERROR).$(LIBGPG-ERROR_SUFFIX)
LIBGPG-ERROR_DIR	= $(BUILDDIR)/$(LIBGPG-ERROR)
LIBGPG-ERROR_IPKG_TMP	= $(LIBGPG-ERROR_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libgpg-error_get: $(STATEDIR)/libgpg-error.get

libgpg-error_get_deps = $(LIBGPG-ERROR_SOURCE)

$(STATEDIR)/libgpg-error.get: $(libgpg-error_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBGPG-ERROR))
	touch $@

$(LIBGPG-ERROR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBGPG-ERROR_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libgpg-error_extract: $(STATEDIR)/libgpg-error.extract

libgpg-error_extract_deps = $(STATEDIR)/libgpg-error.get

$(STATEDIR)/libgpg-error.extract: $(libgpg-error_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGPG-ERROR_DIR))
	@$(call extract, $(LIBGPG-ERROR_SOURCE))
	@$(call patchin, $(LIBGPG-ERROR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libgpg-error_prepare: $(STATEDIR)/libgpg-error.prepare

#
# dependencies
#
libgpg-error_prepare_deps = \
	$(STATEDIR)/libgpg-error.extract \
	$(STATEDIR)/virtual-xchain.install

LIBGPG-ERROR_PATH	=  PATH=$(CROSS_PATH)
LIBGPG-ERROR_ENV 	=  $(CROSS_ENV)
#LIBGPG-ERROR_ENV	+=
LIBGPG-ERROR_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBGPG-ERROR_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBGPG-ERROR_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
LIBGPG-ERROR_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBGPG-ERROR_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libgpg-error.prepare: $(libgpg-error_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBGPG-ERROR_DIR)/config.cache)
	cd $(LIBGPG-ERROR_DIR) && \
		$(LIBGPG-ERROR_PATH) $(LIBGPG-ERROR_ENV) \
		./configure $(LIBGPG-ERROR_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libgpg-error_compile: $(STATEDIR)/libgpg-error.compile

libgpg-error_compile_deps = $(STATEDIR)/libgpg-error.prepare

$(STATEDIR)/libgpg-error.compile: $(libgpg-error_compile_deps)
	@$(call targetinfo, $@)
	$(LIBGPG-ERROR_PATH) $(MAKE) -C $(LIBGPG-ERROR_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libgpg-error_install: $(STATEDIR)/libgpg-error.install

$(STATEDIR)/libgpg-error.install: $(STATEDIR)/libgpg-error.compile
	@$(call targetinfo, $@)
	$(LIBGPG-ERROR_PATH) $(MAKE) -C $(LIBGPG-ERROR_DIR) DESTDIR=$(LIBGPG-ERROR_IPKG_TMP) install
	cp -a  $(LIBGPG-ERROR_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(LIBGPG-ERROR_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	cp -a  $(LIBGPG-ERROR_IPKG_TMP)/usr/share/aclocal/*      $(CROSS_LIB_DIR)/share/aclocal
	cp -a  $(LIBGPG-ERROR_IPKG_TMP)/usr/bin/gpg-error-config $(PTXCONF_PREFIX)/bin
	rm -rf $(LIBGPG-ERROR_IPKG_TMP)
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/gpg-error-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgpg-error.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libgpg-error_targetinstall: $(STATEDIR)/libgpg-error.targetinstall

libgpg-error_targetinstall_deps = $(STATEDIR)/libgpg-error.compile

$(STATEDIR)/libgpg-error.targetinstall: $(libgpg-error_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBGPG-ERROR_PATH) $(MAKE) -C $(LIBGPG-ERROR_DIR) DESTDIR=$(LIBGPG-ERROR_IPKG_TMP) install
	rm  -f $(LIBGPG-ERROR_IPKG_TMP)/usr/bin/gpg-error-config
	rm -rf $(LIBGPG-ERROR_IPKG_TMP)/usr/include
	rm  -f $(LIBGPG-ERROR_IPKG_TMP)/usr/lib/*.la
	rm -rf $(LIBGPG-ERROR_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(LIBGPG-ERROR_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(LIBGPG-ERROR_IPKG_TMP)/usr/lib/*
	mkdir -p $(LIBGPG-ERROR_IPKG_TMP)/CONTROL
	echo "Package: libgpg-error" 			>$(LIBGPG-ERROR_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBGPG-ERROR_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(LIBGPG-ERROR_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(LIBGPG-ERROR_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBGPG-ERROR_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBGPG-ERROR_VERSION)" 	>>$(LIBGPG-ERROR_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(LIBGPG-ERROR_IPKG_TMP)/CONTROL/control
	echo "Description: This is a library that defines common error values for all GnuPG components.">>$(LIBGPG-ERROR_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBGPG-ERROR_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libgpg-error_clean:
	rm -rf $(STATEDIR)/libgpg-error.*
	rm -rf $(LIBGPG-ERROR_DIR)

# vim: syntax=make
