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
ifdef PTXCONF_PCRE
PACKAGES += pcre
endif

#
# Paths and names
#
PCRE_VERSION		= 5.0
PCRE			= pcre-$(PCRE_VERSION)
PCRE_SUFFIX		= tar.bz2
PCRE_URL		= ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/$(PCRE).$(PCRE_SUFFIX)
PCRE_SOURCE		= $(SRCDIR)/$(PCRE).$(PCRE_SUFFIX)
PCRE_DIR		= $(BUILDDIR)/$(PCRE)
PCRE_IPKG_TMP		= $(PCRE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pcre_get: $(STATEDIR)/pcre.get

pcre_get_deps = $(PCRE_SOURCE)

$(STATEDIR)/pcre.get: $(pcre_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PCRE))
	touch $@

$(PCRE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PCRE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pcre_extract: $(STATEDIR)/pcre.extract

pcre_extract_deps = $(STATEDIR)/pcre.get

$(STATEDIR)/pcre.extract: $(pcre_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PCRE_DIR))
	@$(call extract, $(PCRE_SOURCE))
	@$(call patchin, $(PCRE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pcre_prepare: $(STATEDIR)/pcre.prepare

#
# dependencies
#
pcre_prepare_deps = \
	$(STATEDIR)/pcre.extract \
	$(STATEDIR)/virtual-xchain.install

PCRE_PATH	=  PATH=$(CROSS_PATH)
PCRE_ENV 	=  $(CROSS_ENV)
PCRE_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
PCRE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PCRE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
PCRE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
PCRE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PCRE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pcre.prepare: $(pcre_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PCRE_DIR)/config.cache)
	cd $(PCRE_DIR) && \
		$(PCRE_PATH) $(PCRE_ENV) \
		./configure $(PCRE_AUTOCONF)
	#cp -f $(PTXCONF_PREFIX)/bin/libtool $(PCRE_DIR)/
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pcre_compile: $(STATEDIR)/pcre.compile

pcre_compile_deps = $(STATEDIR)/pcre.prepare

$(STATEDIR)/pcre.compile: $(pcre_compile_deps)
	@$(call targetinfo, $@)
	$(PCRE_PATH) $(MAKE) -C $(PCRE_DIR) CC_FOR_BUILD=gcc LINK_FOR_BUILD=gcc CFLAGS_FOR_BUILD=-O2
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pcre_install: $(STATEDIR)/pcre.install

$(STATEDIR)/pcre.install: $(STATEDIR)/pcre.compile
	@$(call targetinfo, $@)
	rm -rf $(PCRE_IPKG_TMP)
	$(PCRE_PATH) $(MAKE) -C $(PCRE_DIR) DESTDIR=$(PCRE_IPKG_TMP) install
	cp -a $(PCRE_IPKG_TMP)/usr/include/*		$(CROSS_LIB_DIR)/include/
	cp -a $(PCRE_IPKG_TMP)/usr/lib/*		$(CROSS_LIB_DIR)/lib/
	cp -a $(PCRE_IPKG_TMP)/usr/bin/pcre-config	$(PTXCONF_PREFIX)/bin/
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g"	$(CROSS_LIB_DIR)/lib/libpcre.la
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g"	$(CROSS_LIB_DIR)/lib/libpcreposix.la
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g"	$(CROSS_LIB_DIR)/lib/pkgconfig/libpcre.pc
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g"	$(PTXCONF_PREFIX)/bin/pcre-config
	rm -rf $(PCRE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pcre_targetinstall: $(STATEDIR)/pcre.targetinstall

pcre_targetinstall_deps = $(STATEDIR)/pcre.compile

$(STATEDIR)/pcre.targetinstall: $(pcre_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PCRE_PATH) $(MAKE) -C $(PCRE_DIR) DESTDIR=$(PCRE_IPKG_TMP) install
	rm -rf $(PCRE_IPKG_TMP)/usr/bin
	rm -rf $(PCRE_IPKG_TMP)/usr/include
	rm -rf $(PCRE_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(PCRE_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(PCRE_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(PCRE_IPKG_TMP)/usr/lib/*
	mkdir -p $(PCRE_IPKG_TMP)/CONTROL
	echo "Package: pcre" 							>$(PCRE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(PCRE_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 						>>$(PCRE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <Sash@pdaXrom.org>" 			>>$(PCRE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(PCRE_IPKG_TMP)/CONTROL/control
	echo "Version: $(PCRE_VERSION)" 					>>$(PCRE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(PCRE_IPKG_TMP)/CONTROL/control
	echo "Description: Perl-compatible regular expression library."		>>$(PCRE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PCRE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PCRE_INSTALL
ROMPACKAGES += $(STATEDIR)/pcre.imageinstall
endif

pcre_imageinstall_deps = $(STATEDIR)/pcre.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pcre.imageinstall: $(pcre_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pcre
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pcre_clean:
	rm -rf $(STATEDIR)/pcre.*
	rm -rf $(PCRE_DIR)

# vim: syntax=make
