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
ifdef PTXCONF_DOSFSTOOLS
PACKAGES += dosfstools
endif

#
# Paths and names
#
DOSFSTOOLS_VERSION	= 2.10
DOSFSTOOLS		= dosfstools-$(DOSFSTOOLS_VERSION).src
DOSFSTOOLS_SUFFIX	= tar.gz
DOSFSTOOLS_URL		= ftp://ftp.uni-erlangen.de/pub/Linux/LOCAL/dosfstools/$(DOSFSTOOLS).$(DOSFSTOOLS_SUFFIX)
DOSFSTOOLS_SOURCE	= $(SRCDIR)/$(DOSFSTOOLS).$(DOSFSTOOLS_SUFFIX)
DOSFSTOOLS_DIR		= $(BUILDDIR)/dosfstools-$(DOSFSTOOLS_VERSION)
DOSFSTOOLS_IPKG_TMP	= $(DOSFSTOOLS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dosfstools_get: $(STATEDIR)/dosfstools.get

dosfstools_get_deps = $(DOSFSTOOLS_SOURCE)

$(STATEDIR)/dosfstools.get: $(dosfstools_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DOSFSTOOLS))
	touch $@

$(DOSFSTOOLS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DOSFSTOOLS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dosfstools_extract: $(STATEDIR)/dosfstools.extract

dosfstools_extract_deps = $(STATEDIR)/dosfstools.get

$(STATEDIR)/dosfstools.extract: $(dosfstools_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DOSFSTOOLS_DIR))
	@$(call extract, $(DOSFSTOOLS_SOURCE))
	@$(call patchin, $(DOSFSTOOLS), $(DOSFSTOOLS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dosfstools_prepare: $(STATEDIR)/dosfstools.prepare

#
# dependencies
#
dosfstools_prepare_deps = \
	$(STATEDIR)/dosfstools.extract \
	$(STATEDIR)/virtual-xchain.install

DOSFSTOOLS_PATH	=  PATH=$(CROSS_PATH)
DOSFSTOOLS_ENV 	=  $(CROSS_ENV)
#DOSFSTOOLS_ENV	+=
DOSFSTOOLS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DOSFSTOOLS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

ifdef PTXCONF_ARCH_ARM
DOSFSTOOLS_ENV 	+=  CFLAGS="-O2 -mstructure-size-boundary=8 -fomit-frame-pointer"
else
DOSFSTOOLS_ENV 	+=  CFLAGS="-O2 -fomit-frame-pointer"
endif

#
# autoconf
#
DOSFSTOOLS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
DOSFSTOOLS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DOSFSTOOLS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dosfstools.prepare: $(dosfstools_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DOSFSTOOLS_DIR)/config.cache)
	#cd $(DOSFSTOOLS_DIR) && \
	#	$(DOSFSTOOLS_PATH) $(DOSFSTOOLS_ENV) \
	#	./configure $(DOSFSTOOLS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dosfstools_compile: $(STATEDIR)/dosfstools.compile

dosfstools_compile_deps = $(STATEDIR)/dosfstools.prepare

$(STATEDIR)/dosfstools.compile: $(dosfstools_compile_deps)
	@$(call targetinfo, $@)
	$(DOSFSTOOLS_PATH) $(DOSFSTOOLS_ENV) $(MAKE) -C $(DOSFSTOOLS_DIR)/mkdosfs
	$(DOSFSTOOLS_PATH) $(DOSFSTOOLS_ENV) $(MAKE) -C $(DOSFSTOOLS_DIR)/dosfsck
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dosfstools_install: $(STATEDIR)/dosfstools.install

$(STATEDIR)/dosfstools.install: $(STATEDIR)/dosfstools.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dosfstools_targetinstall: $(STATEDIR)/dosfstools.targetinstall

dosfstools_targetinstall_deps = $(STATEDIR)/dosfstools.compile

$(STATEDIR)/dosfstools.targetinstall: $(dosfstools_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(DOSFSTOOLS_IPKG_TMP)/sbin
	cp -a $(DOSFSTOOLS_DIR)/mkdosfs/mkdosfs $(DOSFSTOOLS_IPKG_TMP)/sbin
	ln -sf mkdosfs $(DOSFSTOOLS_IPKG_TMP)/sbin/mkfs.msdos
	ln -sf mkdosfs $(DOSFSTOOLS_IPKG_TMP)/sbin/mkfs.vfat
	$(CROSSSTRIP) $(DOSFSTOOLS_IPKG_TMP)/sbin/mkdosfs
	cp -a $(DOSFSTOOLS_DIR)/dosfsck/dosfsck $(DOSFSTOOLS_IPKG_TMP)/sbin
	ln -sf dosfsck $(DOSFSTOOLS_IPKG_TMP)/sbin/fsck.msdos
	ln -sf dosfsck $(DOSFSTOOLS_IPKG_TMP)/sbin/fsck.vfat
	$(CROSSSTRIP) $(DOSFSTOOLS_IPKG_TMP)/sbin/dosfsck
	mkdir -p $(DOSFSTOOLS_IPKG_TMP)/CONTROL
	echo "Package: dosfstools" 			>$(DOSFSTOOLS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(DOSFSTOOLS_IPKG_TMP)/CONTROL/control
	echo "Section: Utils"	 			>>$(DOSFSTOOLS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(DOSFSTOOLS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(DOSFSTOOLS_IPKG_TMP)/CONTROL/control
	echo "Version: $(DOSFSTOOLS_VERSION)" 		>>$(DOSFSTOOLS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(DOSFSTOOLS_IPKG_TMP)/CONTROL/control
	echo "Description: Utilities to create and check MS-DOS FAT filesystems.">>$(DOSFSTOOLS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DOSFSTOOLS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DOSFSTOOLS_INSTALL
ROMPACKAGES += $(STATEDIR)/dosfstools.imageinstall
endif

dosfstools_imageinstall_deps = $(STATEDIR)/dosfstools.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dosfstools.imageinstall: $(dosfstools_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dosfstools
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dosfstools_clean:
	rm -rf $(STATEDIR)/dosfstools.*
	rm -rf $(DOSFSTOOLS_DIR)

# vim: syntax=make
