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
ifdef PTXCONF_FIREFOX
PACKAGES += firefox
endif

#
# Paths and names
#
FIREFOX_VERSION		= 1.0
###FIREFOX		= firefox-source-$(FIREFOX_VERSION)
FIREFOX			= firefox-$(FIREFOX_VERSION)-source
FIREFOX_SUFFIX		= tar.bz2
FIREFOX_URL		= http://ftp28f.newaol.com/pub/mozilla.org/firefox/releases/$(FIREFOX_VERSION)/$(FIREFOX).$(FIREFOX_SUFFIX)
FIREFOX_SOURCE		= $(SRCDIR)/$(FIREFOX).$(FIREFOX_SUFFIX)
FIREFOX_DIR		= $(BUILDDIR)/mozilla
FIREFOX_IPKG_TMP	= $(FIREFOX_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

firefox_get: $(STATEDIR)/firefox.get

firefox_get_deps = $(FIREFOX_SOURCE)

$(STATEDIR)/firefox.get: $(firefox_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FIREFOX))
	touch $@

$(FIREFOX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FIREFOX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

firefox_extract: $(STATEDIR)/firefox.extract

firefox_extract_deps = $(STATEDIR)/firefox.get

$(STATEDIR)/firefox.extract: $(firefox_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FIREFOX_DIR))
	@$(call extract, $(FIREFOX_SOURCE))
	@$(call patchin, $(FIREFOX), $(FIREFOX_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

firefox_prepare: $(STATEDIR)/firefox.prepare

#
# dependencies
#
firefox_prepare_deps = \
	$(STATEDIR)/firefox.extract \
	$(STATEDIR)/gtk22.install     \
	$(STATEDIR)/libIDL082.install \
	$(STATEDIR)/virtual-xchain.install

FIREFOX_PATH	=  PATH=$(CROSS_PATH)
FIREFOX_ENV 	=  $(CROSS_ENV)
#FIREFOX_ENV	+=
FIREFOX_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FIREFOX_ENV	+= LDFLAGS="-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib"
#endif

#
# autoconf
#
FIREFOX_AUTOCONF = \
	--build=$(GNU_HOST) \
	--target=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr/lib/firefox

ifdef PTXCONF_XFREE430
FIREFOX_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FIREFOX_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/firefox.prepare: $(firefox_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FIREFOX_DIR)/config.cache)
ifdef PTXCONF_ARCH_X86
	cp $(TOPDIR)/config/pdaXrom-x86/mozconfig $(FIREFOX_DIR)/.mozconfig
else
 ifdef PTXCONF_ARCH_ARM
	cp $(TOPDIR)/config/pdaXrom/firefox/.mozconfig $(FIREFOX_DIR)/.mozconfig
 endif
endif
	cd $(FIREFOX_DIR) && \
		$(FIREFOX_PATH) $(FIREFOX_ENV) \
		./configure $(FIREFOX_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

firefox_compile: $(STATEDIR)/firefox.compile

firefox_compile_deps = $(STATEDIR)/firefox.prepare

$(STATEDIR)/firefox.compile: $(firefox_compile_deps)
	@$(call targetinfo, $@)
	$(FIREFOX_PATH) CROSS_COMPILE=1 \
	    $(MAKE) -C $(FIREFOX_DIR) $(XHOST_LIBIDL2_CFLAGS) $(XHOST_LIBIDL2_LIBS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

firefox_install: $(STATEDIR)/firefox.install

$(STATEDIR)/firefox.install: $(STATEDIR)/firefox.compile
	@$(call targetinfo, $@)
	##$(FIREFOX_PATH) $(MAKE) -C $(FIREFOX_DIR) install
	aasda
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

firefox_targetinstall: $(STATEDIR)/firefox.targetinstall

firefox_targetinstall_deps = \
	$(STATEDIR)/firefox.compile \
	$(STATEDIR)/libIDL082.targetinstall \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/firefox.targetinstall: $(firefox_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FIREFOX_PATH) $(MAKE) -C $(FIREFOX_DIR) DESTDIR=$(FIREFOX_IPKG_TMP) install
	rm  -f $(FIREFOX_IPKG_TMP)/usr/lib/firefox/bin/mozilla-config
	rm -rf $(FIREFOX_IPKG_TMP)/usr/lib/firefox/include
	rm -rf $(FIREFOX_IPKG_TMP)/usr/lib/firefox/lib/pkgconfig
	rm -rf $(FIREFOX_IPKG_TMP)/usr/lib/firefox/share/*
	mkdir -p $(FIREFOX_IPKG_TMP)/usr/share/applications
	mkdir -p $(FIREFOX_IPKG_TMP)/usr/share/pixmaps
	rm  -f $(FIREFOX_IPKG_TMP)/usr/lib/firefox/lib/mozilla-1.6/TestGtkEmbed
###ifdef PTXCONF_ARCH_ARM
	cp -a $(TOPDIR)/config/pdaXrom/firefox/firefox.desktop $(FIREFOX_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pdaXrom/firefox/firefox.png     $(FIREFOX_IPKG_TMP)/usr/share/pixmaps
###endif
	mkdir -p $(FIREFOX_IPKG_TMP)/usr/bin
	ln -sf /usr/lib/firefox/bin/firefox $(FIREFOX_IPKG_TMP)/usr/bin/firefox
	for FILE in `find $(FIREFOX_IPKG_TMP)/usr/lib -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(FIREFOX_IPKG_TMP)/CONTROL
	echo "Package: firefox" 							>$(FIREFOX_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(FIREFOX_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 							>>$(FIREFOX_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"				>>$(FIREFOX_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(FIREFOX_IPKG_TMP)/CONTROL/control
	echo "Version: $(FIREFOX_VERSION)" 						>>$(FIREFOX_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2"		 						>>$(FIREFOX_IPKG_TMP)/CONTROL/control
	echo "Description: Firefox is an award winning preview of next generation browsing technology from mozilla.org.">>$(FIREFOX_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FIREFOX_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FIREFOX_INSTALL
ROMPACKAGES += $(STATEDIR)/firefox.imageinstall
endif

firefox_imageinstall_deps = $(STATEDIR)/firefox.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/firefox.imageinstall: $(firefox_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install firefox
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

firefox_clean:
	rm -rf $(STATEDIR)/firefox.*
	rm -rf $(FIREFOX_DIR)

# vim: syntax=make
