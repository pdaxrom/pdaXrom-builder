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
ifdef PTXCONF_LIBMAD
PACKAGES += libmad
endif

#
# Paths and names
#
LIBMAD_VERSION	= 0.15.1b
LIBMAD		= libmad-$(LIBMAD_VERSION)
LIBMAD_SUFFIX	= tar.gz
LIBMAD_URL	= ftp://ftp.mars.org/mpeg/$(LIBMAD).$(LIBMAD_SUFFIX)
LIBMAD_SOURCE	= $(SRCDIR)/$(LIBMAD).$(LIBMAD_SUFFIX)
LIBMAD_DIR	= $(BUILDDIR)/$(LIBMAD)
LIBMAD_IPKG_TMP	= $(LIBMAD_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libmad_get: $(STATEDIR)/libmad.get

libmad_get_deps = $(LIBMAD_SOURCE)

$(STATEDIR)/libmad.get: $(libmad_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBMAD))
	touch $@

$(LIBMAD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBMAD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libmad_extract: $(STATEDIR)/libmad.extract

libmad_extract_deps = $(STATEDIR)/libmad.get

$(STATEDIR)/libmad.extract: $(libmad_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBMAD_DIR))
	@$(call extract, $(LIBMAD_SOURCE))
	@$(call patchin, $(LIBMAD))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libmad_prepare: $(STATEDIR)/libmad.prepare

#
# dependencies
#
libmad_prepare_deps = \
	$(STATEDIR)/libmad.extract \
	$(STATEDIR)/virtual-xchain.install

LIBMAD_PATH	=  PATH=$(CROSS_PATH)
LIBMAD_ENV 	=  $(CROSS_ENV)
#LIBMAD_ENV	+=
LIBMAD_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBMAD_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBMAD_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-speed \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
LIBMAD_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBMAD_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/libmad.prepare: $(libmad_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBMAD_DIR)/config.cache)
	cd $(LIBMAD_DIR) && \
		$(LIBMAD_PATH) $(LIBMAD_ENV) \
		./configure $(LIBMAD_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libmad_compile: $(STATEDIR)/libmad.compile

libmad_compile_deps = $(STATEDIR)/libmad.prepare

NEWCFLAGS=
ifdef PTXCONF_ARM_ARCH_PXA
 NEWCFLAGS=CFLAGS="-Os -fomit-frame-pointer -ffast-math -funroll-all-loops -mcpu=xscale -mtune=xscale"
else
 ifdef PTXCONF_ARM_ARCH_ARM7500FE
  NEWCFLAGS=CFLAGS="-Os -fomit-frame-pointer -ffast-math -funroll-all-loops -mcpu=arm7500fe -mtune=arm7500fe"
 else
  ifdef PTXCONF_ARM_ARCH_ARM7
    NEWCFLAGS=CFLAGS="-Os -fomit-frame-pointer -ffast-math -funroll-all-loops -mcpu=arm7 -mtune=arm7"
  else
    ifdef PTXCONF_ARM_ARCH_LE
      NEWCFLAGS=CFLAGS="-Os -fomit-frame-pointer -ffast-math -funroll-all-loops -mcpu=strongarm -mtune=strongarm"
    else
      NEWCFLAGS=CFLAGS="-Os -fomit-frame-pointer -ffast-math -funroll-all-loops"
    endif
  endif
 endif
endif


$(STATEDIR)/libmad.compile: $(libmad_compile_deps)
	@$(call targetinfo, $@)
	$(LIBMAD_PATH) $(MAKE) -C $(LIBMAD_DIR) $(NEWCFLAGS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libmad_install: $(STATEDIR)/libmad.install

$(STATEDIR)/libmad.install: $(STATEDIR)/libmad.compile
	@$(call targetinfo, $@)
	$(LIBMAD_PATH) $(MAKE) -C $(LIBMAD_DIR) install DESTDIR=$(LIBMAD_IPKG_TMP)
	cp -a  $(LIBMAD_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(LIBMAD_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(LIBMAD_IPKG_TMP)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libmad.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libmad_targetinstall: $(STATEDIR)/libmad.targetinstall

libmad_targetinstall_deps = $(STATEDIR)/libmad.compile

$(STATEDIR)/libmad.targetinstall: $(libmad_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBMAD_PATH) $(MAKE) -C $(LIBMAD_DIR) DESTDIR=$(LIBMAD_IPKG_TMP) install
	rm -rf $(LIBMAD_IPKG_TMP)/usr/include
	rm -rf $(LIBMAD_IPKG_TMP)/usr/lib/libmad.la
	$(CROSSSTRIP) $(LIBMAD_IPKG_TMP)/usr/lib/libmad.so.0.2.1
	mkdir -p $(LIBMAD_IPKG_TMP)/CONTROL
	echo "Package: libmad" 				>$(LIBMAD_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBMAD_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 			>>$(LIBMAD_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(LIBMAD_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBMAD_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBMAD_VERSION)" 		>>$(LIBMAD_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(LIBMAD_IPKG_TMP)/CONTROL/control
	echo "Description: MAD (libmad) is a high-quality MPEG audio decoder.">>$(LIBMAD_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBMAD_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_LIBMAD_INSTALL
ROMPACKAGES += $(STATEDIR)/libmad.imageinstall
endif

libmad_imageinstall_deps = $(STATEDIR)/libmad.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/libmad.imageinstall: $(libmad_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libmad
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libmad_clean:
	rm -rf $(STATEDIR)/libmad.*
	rm -rf $(LIBMAD_DIR)

# vim: syntax=make
