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
ifdef PTXCONF_MPEG2DEC
PACKAGES += mpeg2dec
endif

#
# Paths and names
#
MPEG2DEC_VERSION	= 0.4.0b
MPEG2DEC		= mpeg2dec-$(MPEG2DEC_VERSION)
MPEG2DEC_SUFFIX		= tar.gz
MPEG2DEC_URL		= http://libmpeg2.sourceforge.net/files/$(MPEG2DEC).$(MPEG2DEC_SUFFIX)
MPEG2DEC_SOURCE		= $(SRCDIR)/$(MPEG2DEC).$(MPEG2DEC_SUFFIX)
MPEG2DEC_DIR		= $(BUILDDIR)/mpeg2dec-0.4.0
MPEG2DEC_IPKG_TMP	= $(MPEG2DEC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mpeg2dec_get: $(STATEDIR)/mpeg2dec.get

mpeg2dec_get_deps = $(MPEG2DEC_SOURCE)

$(STATEDIR)/mpeg2dec.get: $(mpeg2dec_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MPEG2DEC))
	touch $@

$(MPEG2DEC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MPEG2DEC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mpeg2dec_extract: $(STATEDIR)/mpeg2dec.extract

mpeg2dec_extract_deps = $(STATEDIR)/mpeg2dec.get

$(STATEDIR)/mpeg2dec.extract: $(mpeg2dec_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MPEG2DEC_DIR))
	@$(call extract, $(MPEG2DEC_SOURCE))
	@$(call patchin, $(MPEG2DEC), $(MPEG2DEC_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mpeg2dec_prepare: $(STATEDIR)/mpeg2dec.prepare

#
# dependencies
#
mpeg2dec_prepare_deps = \
	$(STATEDIR)/mpeg2dec.extract \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_ARCH_ARM
###mpeg2dec_prepare_deps += $(STATEDIR)/libipp.prepare
endif

MPEG2DEC_PATH	=  PATH=$(CROSS_PATH)
MPEG2DEC_ENV 	=  $(CROSS_ENV)
MPEG2DEC_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
MPEG2DEC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MPEG2DEC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MPEG2DEC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
MPEG2DEC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MPEG2DEC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

ifdef PTXCONF_ARCH_ARM
###MPEG2DEC_AUTOCONF += --with-ipp-dir=$(LIBIPP_DIR)
endif

$(STATEDIR)/mpeg2dec.prepare: $(mpeg2dec_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MPEG2DEC_DIR)/config.cache)
	cd $(MPEG2DEC_DIR) && \
		$(MPEG2DEC_PATH) $(MPEG2DEC_ENV) \
		./configure $(MPEG2DEC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mpeg2dec_compile: $(STATEDIR)/mpeg2dec.compile

mpeg2dec_compile_deps = $(STATEDIR)/mpeg2dec.prepare

$(STATEDIR)/mpeg2dec.compile: $(mpeg2dec_compile_deps)
	@$(call targetinfo, $@)
	$(MPEG2DEC_PATH) $(MAKE) -C $(MPEG2DEC_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mpeg2dec_install: $(STATEDIR)/mpeg2dec.install

$(STATEDIR)/mpeg2dec.install: $(STATEDIR)/mpeg2dec.compile
	@$(call targetinfo, $@)
	rm -rf $(MPEG2DEC_IPKG_TMP)
	$(MPEG2DEC_PATH) $(MAKE) -C $(MPEG2DEC_DIR) DESTDIR=$(MPEG2DEC_IPKG_TMP) install
	cp -a $(MPEG2DEC_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a $(MPEG2DEC_IPKG_TMP)/usr/lib/* $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libmpeg2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libmpeg2.pc
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libmpeg2convert.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/libmpeg2convert.pc
	rm -rf $(MPEG2DEC_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mpeg2dec_targetinstall: $(STATEDIR)/mpeg2dec.targetinstall

mpeg2dec_targetinstall_deps = $(STATEDIR)/mpeg2dec.compile

$(STATEDIR)/mpeg2dec.targetinstall: $(mpeg2dec_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MPEG2DEC_PATH) $(MAKE) -C $(MPEG2DEC_DIR) DESTDIR=$(MPEG2DEC_IPKG_TMP) install
	rm -rf $(MPEG2DEC_IPKG_TMP)/usr/bin
	rm -rf $(MPEG2DEC_IPKG_TMP)/usr/include
	rm -rf $(MPEG2DEC_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(MPEG2DEC_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(MPEG2DEC_IPKG_TMP)/usr/lib/libmpeg2convert.*
	rm -rf $(MPEG2DEC_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(MPEG2DEC_IPKG_TMP)/usr/lib/*
	mkdir -p $(MPEG2DEC_IPKG_TMP)/CONTROL
	echo "Package: libmpeg2"		 						>$(MPEG2DEC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(MPEG2DEC_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 								>>$(MPEG2DEC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(MPEG2DEC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(MPEG2DEC_IPKG_TMP)/CONTROL/control
	echo "Version: $(MPEG2DEC_VERSION)" 							>>$(MPEG2DEC_IPKG_TMP)/CONTROL/control
	echo "Depends: " 									>>$(MPEG2DEC_IPKG_TMP)/CONTROL/control
	echo "Description: mpeg2 decoder"							>>$(MPEG2DEC_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MPEG2DEC_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MPEG2DEC_INSTALL
ROMPACKAGES += $(STATEDIR)/mpeg2dec.imageinstall
endif

mpeg2dec_imageinstall_deps = $(STATEDIR)/mpeg2dec.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mpeg2dec.imageinstall: $(mpeg2dec_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mpeg2dec
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mpeg2dec_clean:
	rm -rf $(STATEDIR)/mpeg2dec.*
	rm -rf $(MPEG2DEC_DIR)

# vim: syntax=make
