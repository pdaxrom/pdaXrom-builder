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
ifdef PTXCONF_MOZILLA
PACKAGES += mozilla
endif

#
# Paths and names
#
MOZILLA_VERSION		= 1.7.5
MOZILLA			= mozilla-source-$(MOZILLA_VERSION)
MOZILLA_SUFFIX		= tar.bz2
MOZILLA_URL		= ftp://ftp.mozilla.org/pub/mozilla.org/mozilla/releases/mozilla$(MOZILLA_VERSION)/src/$(MOZILLA).$(MOZILLA_SUFFIX)
MOZILLA_SOURCE		= $(SRCDIR)/$(MOZILLA).$(MOZILLA_SUFFIX)
MOZILLA_DIR		= $(BUILDDIR)/mozilla
MOZILLA_IPKG_TMP	= $(MOZILLA_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mozilla_get: $(STATEDIR)/mozilla.get

mozilla_get_deps = $(MOZILLA_SOURCE)

$(STATEDIR)/mozilla.get: $(mozilla_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MOZILLA))
	touch $@

$(MOZILLA_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MOZILLA_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mozilla_extract: $(STATEDIR)/mozilla.extract

mozilla_extract_deps = $(STATEDIR)/mozilla.get

$(STATEDIR)/mozilla.extract: $(mozilla_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MOZILLA_DIR))
	@$(call extract, $(MOZILLA_SOURCE))
	@$(call patchin, $(MOZILLA), $(MOZILLA_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mozilla_prepare: $(STATEDIR)/mozilla.prepare

#
# dependencies
#
mozilla_prepare_deps = \
	$(STATEDIR)/mozilla.extract \
	$(STATEDIR)/gtk22.install     \
	$(STATEDIR)/libIDL082.install \
	$(STATEDIR)/virtual-xchain.install

MOZILLA_PATH	=  PATH=$(CROSS_PATH)
MOZILLA_ENV 	=  $(CROSS_ENV)
#MOZILLA_ENV	+=
MOZILLA_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MOZILLA_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MOZILLA_AUTOCONF = \
	--build=$(GNU_HOST) \
	--target=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MOZILLA_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MOZILLA_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mozilla.prepare: $(mozilla_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MOZILLA_DIR)/config.cache)
ifdef PTXCONF_ARCH_X86
	cp $(TOPDIR)/config/pdaXrom-x86/mozilla/.mozconfig $(MOZILLA_DIR)/.mozconfig
	# configure unlike another linux target
	perl -i -p -e "s,\_cross\=no,_cross\=yes,g"	   $(MOZILLA_DIR)/configure
	perl -i -p -e "s,\_cross\=no,_cross\=yes,g"	   $(MOZILLA_DIR)/nsprpub/configure
	perl -i -p -e "s,\_cross\=no,_cross\=yes,g"	   $(MOZILLA_DIR)/directory/c-sdk/configure
endif
ifdef PTXCONF_ARCH_ARM
	cp $(TOPDIR)/config/pdaXrom/mozilla/.mozconfig $(MOZILLA_DIR)/.mozconfig
endif
	cd $(MOZILLA_DIR) && \
		$(MOZILLA_PATH) $(MOZILLA_ENV) \
		./configure $(MOZILLA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mozilla_compile: $(STATEDIR)/mozilla.compile

mozilla_compile_deps = $(STATEDIR)/mozilla.prepare

XHOST_LIBIDL_CFLAGS=HOST_LIBIDL_CFLAGS="`$(PTXCONF_PREFIX)/bin/libIDL-config-host --cflags`"
XHOST_LIBIDL_LIBS=HOST_LIBIDL_LIBS="`$(PTXCONF_PREFIX)/bin/libIDL-config-host --libs`"

XHOST_LIBIDL2_CFLAGS=HOST_LIBIDL_CFLAGS="`$(PTXCONF_PREFIX)/bin/libIDL-config-2-host --cflags`"
XHOST_LIBIDL2_LIBS=HOST_LIBIDL_LIBS="`$(PTXCONF_PREFIX)/bin/libIDL-config-2-host --libs`"

$(STATEDIR)/mozilla.compile: $(mozilla_compile_deps)
	@$(call targetinfo, $@)
	$(MOZILLA_PATH) CROSS_COMPILE=1 \
	    $(MAKE) -C $(MOZILLA_DIR) $(XHOST_LIBIDL2_CFLAGS) $(XHOST_LIBIDL2_LIBS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mozilla_install: $(STATEDIR)/mozilla.install

$(STATEDIR)/mozilla.install: $(STATEDIR)/mozilla.compile
	@$(call targetinfo, $@)
	##$(MOZILLA_PATH) $(MAKE) -C $(MOZILLA_DIR) install
	aasda
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mozilla_targetinstall: $(STATEDIR)/mozilla.targetinstall

mozilla_targetinstall_deps = \
	$(STATEDIR)/mozilla.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libIDL082.targetinstall

$(STATEDIR)/mozilla.targetinstall: $(mozilla_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MOZILLA_PATH) $(MAKE) -C $(MOZILLA_DIR) DESTDIR=$(MOZILLA_IPKG_TMP) install
	rm  -f $(MOZILLA_IPKG_TMP)/usr/bin/mozilla-config
	rm -rf $(MOZILLA_IPKG_TMP)/usr/include
	rm -rf $(MOZILLA_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(MOZILLA_IPKG_TMP)/usr/man
	rm -rf $(MOZILLA_IPKG_TMP)/usr/share/*
	mkdir -p $(MOZILLA_IPKG_TMP)/usr/share/applications
	mkdir -p $(MOZILLA_IPKG_TMP)/usr/share/pixmaps
	rm  -f $(MOZILLA_IPKG_TMP)/usr/lib/mozilla-$(MOZILLA_VERSION)/TestGtkEmbed
###ifdef PTXCONF_ARCH_ARM
	cp -a $(TOPDIR)/config/pdaXrom/mozilla/mozilla.desktop	$(MOZILLA_IPKG_TMP)/usr/share/applications
	cp -a $(MOZILLA_DIR)/widget/src/gtk2/default.xpm     	$(MOZILLA_IPKG_TMP)/usr/share/pixmaps/mozilla.xpm
###endif
	for FILE in `find $(MOZILLA_IPKG_TMP)/usr/lib -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(MOZILLA_IPKG_TMP)/CONTROL
	echo "Package: mozilla" 						 >$(MOZILLA_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(MOZILLA_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 						>>$(MOZILLA_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(MOZILLA_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(MOZILLA_IPKG_TMP)/CONTROL/control
	echo "Version: $(MOZILLA_VERSION)" 					>>$(MOZILLA_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2"	 						>>$(MOZILLA_IPKG_TMP)/CONTROL/control
	echo "Description: Web-browser built for 2004, advanced e-mail and newsgroup client, IRC chat client, and HTML editing made simple -- all your Internet needs in one application.">>$(MOZILLA_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MOZILLA_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MOZILLA_INSTALL
ROMPACKAGES += $(STATEDIR)/mozilla.imageinstall
endif

mozilla_imageinstall_deps = $(STATEDIR)/mozilla.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mozilla.imageinstall: $(mozilla_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mozilla
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mozilla_clean:
	rm -rf $(STATEDIR)/mozilla.*
	rm -rf $(MOZILLA_DIR)

# vim: syntax=make
