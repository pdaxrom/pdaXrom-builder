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
ifdef PTXCONF_THUNDERBIRD
PACKAGES += thunderbird
endif

#
# Paths and names
#
THUNDERBIRD_VERSION		= 1.0
THUNDERBIRD			= thunderbird-$(THUNDERBIRD_VERSION)-source
THUNDERBIRD_SUFFIX		= tar.bz2
THUNDERBIRD_URL			= ftp://ftp.mozilla.org/pub/mozilla.org/thunderbird/releases/$(THUNDERBIRD_VERSION)/$(THUNDERBIRD).$(THUNDERBIRD_SUFFIX)
THUNDERBIRD_SOURCE		= $(SRCDIR)/$(THUNDERBIRD).$(THUNDERBIRD_SUFFIX)
THUNDERBIRD_DIR			= $(BUILDDIR)/mozilla
THUNDERBIRD_IPKG_TMP		= $(THUNDERBIRD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

thunderbird_get: $(STATEDIR)/thunderbird.get

thunderbird_get_deps = $(THUNDERBIRD_SOURCE)

$(STATEDIR)/thunderbird.get: $(thunderbird_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(THUNDERBIRD))
	touch $@

$(THUNDERBIRD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(THUNDERBIRD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

thunderbird_extract: $(STATEDIR)/thunderbird.extract

thunderbird_extract_deps = $(STATEDIR)/thunderbird.get

$(STATEDIR)/thunderbird.extract: $(thunderbird_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(THUNDERBIRD_DIR))
	@$(call extract, $(THUNDERBIRD_SOURCE))
	@$(call patchin, $(THUNDERBIRD), $(THUNDERBIRD_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

thunderbird_prepare: $(STATEDIR)/thunderbird.prepare

#
# dependencies
#
thunderbird_prepare_deps = \
	$(STATEDIR)/thunderbird.extract \
	$(STATEDIR)/gtk22.install     \
	$(STATEDIR)/libIDL082.install \
	$(STATEDIR)/virtual-xchain.install

THUNDERBIRD_PATH	=  PATH=$(CROSS_PATH)
THUNDERBIRD_ENV 	=  $(CROSS_ENV)
#THUNDERBIRD_ENV	+=
THUNDERBIRD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#THUNDERBIRD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

THUNDERBIRD_ENV	+= HOST_CC=gcc

#
# autoconf
#
THUNDERBIRD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--target=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
THUNDERBIRD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
THUNDERBIRD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/thunderbird.prepare: $(thunderbird_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(THUNDERBIRD_DIR)/config.cache)
ifdef PTXCONF_ARCH_X86
	cp $(TOPDIR)/config/pdaXrom-x86/mozconfig $(THUNDERBIRD_DIR)/.mozconfig
else
 ifdef PTXCONF_ARCH_ARM
	cp $(TOPDIR)/config/pdaXrom/thunderbird/.mozconfig $(THUNDERBIRD_DIR)/.mozconfig
 endif
endif
	cd $(THUNDERBIRD_DIR) && \
		$(THUNDERBIRD_PATH) $(THUNDERBIRD_ENV) \
		./configure $(THUNDERBIRD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

thunderbird_compile: $(STATEDIR)/thunderbird.compile

thunderbird_compile_deps = $(STATEDIR)/thunderbird.prepare

$(STATEDIR)/thunderbird.compile: $(thunderbird_compile_deps)
	@$(call targetinfo, $@)
	$(THUNDERBIRD_PATH) CROSS_COMPILE=1 \
	    $(MAKE) -C $(THUNDERBIRD_DIR) $(XHOST_LIBIDL2_CFLAGS) $(XHOST_LIBIDL2_LIBS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

thunderbird_install: $(STATEDIR)/thunderbird.install

$(STATEDIR)/thunderbird.install: $(STATEDIR)/thunderbird.compile
	@$(call targetinfo, $@)
	##$(THUNDERBIRD_PATH) $(MAKE) -C $(THUNDERBIRD_DIR) install
	aasda
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

thunderbird_targetinstall: $(STATEDIR)/thunderbird.targetinstall

thunderbird_targetinstall_deps = \
	$(STATEDIR)/thunderbird.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libIDL082.targetinstall

$(STATEDIR)/thunderbird.targetinstall: $(thunderbird_targetinstall_deps)
	@$(call targetinfo, $@)
	$(THUNDERBIRD_PATH) $(MAKE) -C $(THUNDERBIRD_DIR) DESTDIR=$(THUNDERBIRD_IPKG_TMP) install
	rm  -f $(THUNDERBIRD_IPKG_TMP)/usr/bin/thunderbird-config
	rm -rf $(THUNDERBIRD_IPKG_TMP)/usr/include
	rm -rf $(THUNDERBIRD_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(THUNDERBIRD_IPKG_TMP)/usr/share/*
	mkdir -p $(THUNDERBIRD_IPKG_TMP)/usr/share/applications
	mkdir -p $(THUNDERBIRD_IPKG_TMP)/usr/share/pixmaps
	rm  -f $(THUNDERBIRD_IPKG_TMP)/usr/lib/thunderbird-$(THUNDERBIRD_VERSION)/TestGtkEmbed
###ifdef PTXCONF_ARCH_ARM
	cp -a $(TOPDIR)/config/pdaXrom/thunderbird/thunderbird.desktop $(THUNDERBIRD_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pdaXrom/thunderbird/thunderbird.xpm     $(THUNDERBIRD_IPKG_TMP)/usr/share/pixmaps
###endif
	for FILE in `find $(THUNDERBIRD_IPKG_TMP)/usr/lib -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(THUNDERBIRD_IPKG_TMP)/CONTROL
	echo "Package: thunderbird" 							>$(THUNDERBIRD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(THUNDERBIRD_IPKG_TMP)/CONTROL/control
	echo "Section: Internet" 							>>$(THUNDERBIRD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(THUNDERBIRD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(THUNDERBIRD_IPKG_TMP)/CONTROL/control
	echo "Version: $(THUNDERBIRD_VERSION)" 						>>$(THUNDERBIRD_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2"	 							>>$(THUNDERBIRD_IPKG_TMP)/CONTROL/control
	echo "Description: Thunderbird is a full-featured e-mail and newsgroup client that makes emailing safer, faster and easier than ever before more.">>$(THUNDERBIRD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(THUNDERBIRD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_THUNDERBIRD_INSTALL
ROMPACKAGES += $(STATEDIR)/thunderbird.imageinstall
endif

thunderbird_imageinstall_deps = $(STATEDIR)/thunderbird.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/thunderbird.imageinstall: $(thunderbird_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install thunderbird
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

thunderbird_clean:
	rm -rf $(STATEDIR)/thunderbird.*
	rm -rf $(THUNDERBIRD_DIR)

# vim: syntax=make
