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
ifdef PTXCONF_TREMOR
PACKAGES += tremor
endif

#
# Paths and names
#
TREMOR_VERSION		= cvs
TREMOR			= Tremor-$(TREMOR_VERSION)
TREMOR_SUFFIX		= tar.bz2
TREMOR_URL		= http://www.pdaxrom.org/src
###http://xiph.org/ogg/vorbis/download/tremor_cvs_snapshot.tgz
TREMOR_SOURCE		= $(SRCDIR)/$(TREMOR).$(TREMOR_SUFFIX)
TREMOR_DIR		= $(BUILDDIR)/Tremor
TREMOR_IPKG_TMP	= $(TREMOR_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tremor_get: $(STATEDIR)/tremor.get

tremor_get_deps = $(TREMOR_SOURCE)

$(STATEDIR)/tremor.get: $(tremor_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TREMOR))
	touch $@

$(TREMOR_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TREMOR_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tremor_extract: $(STATEDIR)/tremor.extract

tremor_extract_deps = $(STATEDIR)/tremor.get

$(STATEDIR)/tremor.extract: $(tremor_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TREMOR_DIR))
	@$(call extract, $(TREMOR_SOURCE))
	@$(call patchin, $(TREMOR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tremor_prepare: $(STATEDIR)/tremor.prepare

#
# dependencies
#
tremor_prepare_deps = \
	$(STATEDIR)/tremor.extract \
	$(STATEDIR)/virtual-xchain.install

TREMOR_PATH	=  PATH=$(CROSS_PATH)
TREMOR_ENV 	=  $(CROSS_ENV)
#TREMOR_ENV	+=
TREMOR_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TREMOR_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
TREMOR_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
TREMOR_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TREMOR_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

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

$(STATEDIR)/tremor.prepare: $(tremor_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TREMOR_DIR)/config.cache)
	cd $(TREMOR_DIR) && \
		$(TREMOR_PATH) ./autogen.sh
	@$(call clean, $(TREMOR_DIR)/config.cache)
	cd $(TREMOR_DIR) && \
		$(TREMOR_PATH) $(TREMOR_ENV) \
		$(NEWCFLAGS) ./configure $(TREMOR_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tremor_compile: $(STATEDIR)/tremor.compile

tremor_compile_deps = $(STATEDIR)/tremor.prepare

$(STATEDIR)/tremor.compile: $(tremor_compile_deps)
	@$(call targetinfo, $@)
	$(TREMOR_PATH) $(MAKE) -C $(TREMOR_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tremor_install: $(STATEDIR)/tremor.install

$(STATEDIR)/tremor.install: $(STATEDIR)/tremor.compile
	@$(call targetinfo, $@)
	$(TREMOR_PATH) $(MAKE) -C $(TREMOR_DIR) DESTDIR=$(TREMOR_IPKG_TMP) install
	cp -a  $(TREMOR_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(TREMOR_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(TREMOR_IPKG_TMP)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libvorbisidec.la
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tremor_targetinstall: $(STATEDIR)/tremor.targetinstall

tremor_targetinstall_deps = $(STATEDIR)/tremor.compile

$(STATEDIR)/tremor.targetinstall: $(tremor_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TREMOR_PATH) $(MAKE) -C $(TREMOR_DIR) DESTDIR=$(TREMOR_IPKG_TMP) install
	rm -rf $(TREMOR_IPKG_TMP)/usr/include
	rm  -f $(TREMOR_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(TREMOR_IPKG_TMP)/usr/lib/libvorbisidec.so.1.0.2
	mkdir -p $(TREMOR_IPKG_TMP)/CONTROL
	echo "Package: tremor" 				>$(TREMOR_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(TREMOR_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(TREMOR_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(TREMOR_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(TREMOR_IPKG_TMP)/CONTROL/control
	echo "Version: 1.0.2"		 		>>$(TREMOR_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(TREMOR_IPKG_TMP)/CONTROL/control
	echo "Description: The Tremor decoder, an integer-only, fully Ogg Vorbis compliant software decoder library.">>$(TREMOR_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TREMOR_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TREMOR_INSTALL
ROMPACKAGES += $(STATEDIR)/tremor.imageinstall
endif

tremor_imageinstall_deps = $(STATEDIR)/tremor.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/tremor.imageinstall: $(tremor_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install tremor
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tremor_clean:
	rm -rf $(STATEDIR)/tremor.*
	rm -rf $(TREMOR_DIR)

# vim: syntax=make
