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
ifdef PTXCONF_ABIWORD
PACKAGES += abiword
endif

#
# Paths and names
#
#ABIWORD_VERSION		= 2.0.7
#ABIWORD_VERSION		= 2.1.96
ABIWORD_VERSION		= 2.2.3
ABIWORD			= abiword-$(ABIWORD_VERSION)
ABIWORD_SUFFIX		= tar.bz2
ABIWORD_URL		= http://mesh.dl.sourceforge.net/sourceforge/abiword/$(ABIWORD).$(ABIWORD_SUFFIX)
ABIWORD_SOURCE		= $(SRCDIR)/$(ABIWORD).$(ABIWORD_SUFFIX)
ABIWORD_DIR		= $(BUILDDIR)/$(ABIWORD)
ABIWORD_IPKG_TMP	= $(ABIWORD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

abiword_get: $(STATEDIR)/abiword.get

abiword_get_deps = $(ABIWORD_SOURCE)

$(STATEDIR)/abiword.get: $(abiword_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ABIWORD))
	touch $@

$(ABIWORD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ABIWORD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

abiword_extract: $(STATEDIR)/abiword.extract

abiword_extract_deps = $(STATEDIR)/abiword.get

$(STATEDIR)/abiword.extract: $(abiword_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ABIWORD_DIR))
	@$(call extract, $(ABIWORD_SOURCE))
	@$(call patchin, $(ABIWORD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

abiword_prepare: $(STATEDIR)/abiword.prepare

#
# dependencies
#
abiword_prepare_deps = \
	$(STATEDIR)/abiword.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/fribidi.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/popt.install \
	$(STATEDIR)/libglade.install \
	$(STATEDIR)/virtual-xchain.install

ABIWORD_PATH	=  PATH=$(CROSS_PATH)
ABIWORD_ENV 	=  $(CROSS_ENV)
ABIWORD_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
ABIWORD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ABIWORD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ABIWORD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--enable-extra-optimization \
	--with-zlib=$(CROSS_LIB_DIR) \
	--with-libpng=$(CROSS_LIB_DIR) \
	--with-popt=$(CROSS_LIB_DIR) \
	--with-libjpeg-prefix=$(CROSS_LIB_DIR)

ifdef PTXCONF_LIBICONV
ABIWORD_AUTOCONF += --with-libiconv=$(CROSS_LIB_DIR)
endif

ifdef PTXCONF_XFREE430
ABIWORD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ABIWORD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/abiword.prepare: $(abiword_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ABIWORD_DIR)/config.cache)
	cd $(ABIWORD_DIR)/abi && \
		$(ABIWORD_PATH) $(ABIWORD_ENV) \
		./configure $(ABIWORD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

abiword_compile: $(STATEDIR)/abiword.compile

abiword_compile_deps = $(STATEDIR)/abiword.prepare

$(STATEDIR)/abiword.compile: $(abiword_compile_deps)
	@$(call targetinfo, $@)
	$(ABIWORD_PATH) $(MAKE) -C $(ABIWORD_DIR)/abi/src/tools/cdump/xp CC=gcc
	$(ABIWORD_PATH) $(MAKE) -C $(ABIWORD_DIR)/abi
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

abiword_install: $(STATEDIR)/abiword.install

$(STATEDIR)/abiword.install: $(STATEDIR)/abiword.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

abiword_targetinstall: $(STATEDIR)/abiword.targetinstall

abiword_targetinstall_deps = \
	$(STATEDIR)/abiword.compile \
	$(STATEDIR)/libglade.targetinstall \
	$(STATEDIR)/popt.targetinstall \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/fribidi.targetinstall

$(STATEDIR)/abiword.targetinstall: $(abiword_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ABIWORD_PATH) $(MAKE) -C $(ABIWORD_DIR)/abi DESTDIR=$(ABIWORD_IPKG_TMP) install
	$(CROSSSTRIP) $(ABIWORD_IPKG_TMP)/usr/bin/AbiWord-2.2
	$(CROSSSTRIP) $(ABIWORD_IPKG_TMP)/usr/bin/ttftool
	cp -f $(TOPDIR)/config/pics/normal.awt $(ABIWORD_IPKG_TMP)/usr/share/AbiSuite-2.2/templates/
	mv -f $(ABIWORD_IPKG_TMP)/usr/share/icons $(ABIWORD_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(ABIWORD_IPKG_TMP)/CONTROL
	echo "Package: abiword" 			>$(ABIWORD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(ABIWORD_IPKG_TMP)/CONTROL/control
	echo "Section: Office" 				>>$(ABIWORD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(ABIWORD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(ABIWORD_IPKG_TMP)/CONTROL/control
	echo "Version: $(ABIWORD_VERSION)" 		>>$(ABIWORD_IPKG_TMP)/CONTROL/control
	echo "Depends: fribidi, libglade, gtk2, popt" 	>>$(ABIWORD_IPKG_TMP)/CONTROL/control
	echo "Description: AbiWord is a free word processing program similar to Microsoft Word. It is suitable for typing papers, letters, reports, memos, and so forth.">>$(ABIWORD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ABIWORD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ABIWORD_INSTALL
ROMPACKAGES += $(STATEDIR)/abiword.imageinstall
endif

abiword_imageinstall_deps = $(STATEDIR)/abiword.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/abiword.imageinstall: $(abiword_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install abiword
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

abiword_clean:
	rm -rf $(STATEDIR)/abiword.*
	rm -rf $(ABIWORD_DIR)

# vim: syntax=make
