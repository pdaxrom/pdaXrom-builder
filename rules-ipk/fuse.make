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
ifdef PTXCONF_FUSE
PACKAGES += fuse
endif

#
# Paths and names
#
FUSE_VENDOR_VERSION	= 1
#FUSE_VERSION		= 2.1
FUSE_VERSION		= 1.4
FUSE			= fuse-$(FUSE_VERSION)
FUSE_SUFFIX		= tar.bz2
FUSE_URL		= http://distro.ibiblio.org/pub/linux/distributions/sorcerer/sources/fuse/$(FUSE_VERSION)/$(FUSE).$(FUSE_SUFFIX)
FUSE_SOURCE		= $(SRCDIR)/$(FUSE).$(FUSE_SUFFIX)
FUSE_DIR		= $(BUILDDIR)/$(FUSE)
FUSE_IPKG_TMP		= $(FUSE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fuse_get: $(STATEDIR)/fuse.get

fuse_get_deps = $(FUSE_SOURCE)

$(STATEDIR)/fuse.get: $(fuse_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FUSE))
	touch $@

$(FUSE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FUSE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fuse_extract: $(STATEDIR)/fuse.extract

fuse_extract_deps = $(STATEDIR)/fuse.get

$(STATEDIR)/fuse.extract: $(fuse_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FUSE_DIR))
	@$(call extract, $(FUSE_SOURCE))
	@$(call patchin, $(FUSE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fuse_prepare: $(STATEDIR)/fuse.prepare

#
# dependencies
#
fuse_prepare_deps = \
	$(STATEDIR)/fuse.extract \
	$(STATEDIR)/virtual-xchain.install

FUSE_PATH	=  PATH=$(CROSS_PATH)
FUSE_ENV 	=  $(CROSS_ENV)
#FUSE_ENV	+=
FUSE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FUSE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
FUSE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--with-kernel=$(KERNEL_DIR) \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
FUSE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FUSE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/fuse.prepare: $(fuse_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FUSE_DIR)/config.cache)
	cd $(FUSE_DIR) && \
		$(FUSE_PATH) $(FUSE_ENV) \
		./configure $(FUSE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fuse_compile: $(STATEDIR)/fuse.compile

fuse_compile_deps = $(STATEDIR)/fuse.prepare

$(STATEDIR)/fuse.compile: $(fuse_compile_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_KERNEL_EXTERNAL_GCC
	$(FUSE_PATH) $(MAKE) -C $(FUSE_DIR) \
	    KERNEL_CC=$(PTXCONF_KERNEL_EXTERNAL_GCC_PATH)/arm-linux-gcc \
	    KERNEL_LD=$(PTXCONF_KERNEL_EXTERNAL_GCC_PATH)/arm-linux-ld \
	    KERNEL_CFLAGS="-Os -Wall -Wstrict-prototypes -fno-strict-aliasing -pipe -march=armv4 -mtune=strongarm1100"
else
	$(FUSE_PATH) $(MAKE) -C $(FUSE_DIR)
endif
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fuse_install: $(STATEDIR)/fuse.install

$(STATEDIR)/fuse.install: $(STATEDIR)/fuse.compile
	@$(call targetinfo, $@)
	rm -rf $(FUSE_IPKG_TMP)
	$(FUSE_PATH) $(MAKE) -C $(FUSE_DIR) DESTDIR=$(FUSE_IPKG_TMP) install
	cp -a $(FUSE_IPKG_TMP)/usr/include/*	$(CROSS_LIB_DIR)/include/
	cp -a $(FUSE_IPKG_TMP)/usr/lib/*	$(CROSS_LIB_DIR)/lib/
ifeq	(2.1, $(FUSE_VERSION))
	perl -i -p -e "s,\/usr/lib,$(CROSS_LIB_DIR)/lib,g"	$(CROSS_LIB_DIR)/lib/libfuse.la
	perl -i -p -e "s,\/usr,$(CROSS_LIB_DIR),g" 		$(CROSS_LIB_DIR)/lib/pkgconfig/fuse.pc
endif
	rm -rf $(FUSE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fuse_targetinstall: $(STATEDIR)/fuse.targetinstall

fuse_targetinstall_deps = $(STATEDIR)/fuse.compile

$(STATEDIR)/fuse.targetinstall: $(fuse_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FUSE_PATH) $(MAKE) -C $(FUSE_DIR) DESTDIR=$(FUSE_IPKG_TMP) install
	rm -rf $(FUSE_IPKG_TMP)/usr/include
	rm  -f $(FUSE_IPKG_TMP)/usr/lib/*.*a
	$(CROSSSTRIP) $(FUSE_IPKG_TMP)/usr/bin/*
ifeq	(2.1, $(FUSE_VERSION))
	rm -rf $(FUSE_IPKG_TMP)/usr/lib/pkgconfig
	$(CROSSSTRIP) $(FUSE_IPKG_TMP)/usr/lib/*.so*
endif
	mkdir -p $(FUSE_IPKG_TMP)/CONTROL
	echo "Package: fuse" 											 >$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Section: Kernel"	 										>>$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Version: $(FUSE_VERSION)-$(FUSE_VENDOR_VERSION)" 							>>$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 											>>$(FUSE_IPKG_TMP)/CONTROL/control
	echo "Description: FUSE (Filesystem in USErspace) is a simple interface for userspace programs to export a virtual filesystem to the linux kernel." >>$(FUSE_IPKG_TMP)/CONTROL/control

	echo "#!/bin/sh"											 >$(FUSE_IPKG_TMP)/CONTROL/postinst
	echo "/sbin/depmod -a"											>>$(FUSE_IPKG_TMP)/CONTROL/postinst
	echo "#!/bin/sh"											 >$(FUSE_IPKG_TMP)/CONTROL/postrm
	echo "/sbin/depmod -a"											>>$(FUSE_IPKG_TMP)/CONTROL/postrm
	chmod 755 $(FUSE_IPKG_TMP)/CONTROL/postinst $(FUSE_IPKG_TMP)/CONTROL/postrm

	cd $(FEEDDIR) && $(XMKIPKG) $(FUSE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FUSE_INSTALL
ROMPACKAGES += $(STATEDIR)/fuse.imageinstall
endif

fuse_imageinstall_deps = $(STATEDIR)/fuse.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/fuse.imageinstall: $(fuse_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install fuse
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fuse_clean:
	rm -rf $(STATEDIR)/fuse.*
	rm -rf $(FUSE_DIR)

# vim: syntax=make
