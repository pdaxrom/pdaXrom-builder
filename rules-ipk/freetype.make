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
ifdef PTXCONF_FREETYPE
PACKAGES += freetype
endif

#
# Paths and names
#
FREETYPE_VERSION	= 2.1.9
FREETYPE		= freetype-$(FREETYPE_VERSION)
FREETYPE_SUFFIX		= tar.bz2
FREETYPE_URL		= http://heanet.dl.sourceforge.net/sourceforge/freetype/$(FREETYPE).$(FREETYPE_SUFFIX)
FREETYPE_SOURCE		= $(SRCDIR)/$(FREETYPE).$(FREETYPE_SUFFIX)
FREETYPE_DIR		= $(BUILDDIR)/$(FREETYPE)
FREETYPE_IPKG_TMP	= $(FREETYPE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

freetype_get: $(STATEDIR)/freetype.get

freetype_get_deps = $(FREETYPE_SOURCE)

$(STATEDIR)/freetype.get: $(freetype_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FREETYPE))
	touch $@

$(FREETYPE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FREETYPE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

freetype_extract: $(STATEDIR)/freetype.extract

freetype_extract_deps = $(STATEDIR)/freetype.get

$(STATEDIR)/freetype.extract: $(freetype_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FREETYPE_DIR))
	@$(call extract, $(FREETYPE_SOURCE))
	@$(call patchin, $(FREETYPE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

freetype_prepare: $(STATEDIR)/freetype.prepare

#
# dependencies
#
freetype_prepare_deps = \
	$(STATEDIR)/freetype.extract \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/expat.install \
	$(STATEDIR)/virtual-xchain.install

FREETYPE_PATH	=  PATH=$(CROSS_PATH)
FREETYPE_ENV 	=  $(CROSS_ENV)
FREETYPE_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
FREETYPE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
##ifdef PTXCONF_XFREE430
##FREETYPE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
##endif

#
# autoconf
#
FREETYPE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

#ifdef PTXCONF_XFREE430
#FREETYPE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
#FREETYPE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
#endif

$(STATEDIR)/freetype.prepare: $(freetype_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FREETYPE_DIR)/config.cache)
	cd $(FREETYPE_DIR) && \
		$(FREETYPE_PATH) $(FREETYPE_ENV) \
		./configure $(FREETYPE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

freetype_compile: $(STATEDIR)/freetype.compile

freetype_compile_deps = $(STATEDIR)/freetype.prepare

$(STATEDIR)/freetype.compile: $(freetype_compile_deps)
	@$(call targetinfo, $@)
	$(FREETYPE_PATH) $(MAKE) -C $(FREETYPE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

freetype_install: $(STATEDIR)/freetype.install

$(STATEDIR)/freetype.install: $(STATEDIR)/freetype.compile
	@$(call targetinfo, $@)
	$(FREETYPE_PATH) $(MAKE) -C $(FREETYPE_DIR) DESTDIR=$(FREETYPE_IPKG_TMP) install
	cp -a  $(FREETYPE_IPKG_TMP)/usr/include/*           $(CROSS_LIB_DIR)/include
	cp -a  $(FREETYPE_IPKG_TMP)/usr/lib/*               $(CROSS_LIB_DIR)/lib
	cp -a  $(FREETYPE_IPKG_TMP)/usr/bin/freetype-config $(PTXCONF_PREFIX)/bin
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g"          $(PTXCONF_PREFIX)/bin/freetype-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libfreetype.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g"          $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/freetype2.pc
	rm -rf $(FREETYPE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

freetype_targetinstall: $(STATEDIR)/freetype.targetinstall

freetype_targetinstall_deps = $(STATEDIR)/freetype.compile

$(STATEDIR)/freetype.targetinstall: $(freetype_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FREETYPE_PATH) $(MAKE) -C $(FREETYPE_DIR) DESTDIR=$(FREETYPE_IPKG_TMP) install
	rm -rf $(FREETYPE_IPKG_TMP)/usr/bin
	rm -rf $(FREETYPE_IPKG_TMP)/usr/include
	rm -rf $(FREETYPE_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(FREETYPE_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(FREETYPE_IPKG_TMP)/usr/share
	$(CROSSSTRIP) $(FREETYPE_IPKG_TMP)/usr/lib/*
	mkdir -p $(FREETYPE_IPKG_TMP)/CONTROL
	echo "Package: freetype" 					>$(FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 					>>$(FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Section: X11"			 			>>$(FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 		>>$(FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 				>>$(FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Version: $(FREETYPE_VERSION)" 				>>$(FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 						>>$(FREETYPE_IPKG_TMP)/CONTROL/control
	echo "Description: Free and portable TrueType font rendering engine.">>$(FREETYPE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FREETYPE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FREETYPE_INSTALL
ROMPACKAGES += $(STATEDIR)/freetype.imageinstall
endif

freetype_imageinstall_deps = $(STATEDIR)/freetype.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/freetype.imageinstall: $(freetype_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install freetype
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

freetype_clean:
	rm -rf $(STATEDIR)/freetype.*
	rm -rf $(FREETYPE_DIR)

# vim: syntax=make
