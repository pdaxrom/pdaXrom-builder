# -*-makefile-*-
# $Id: util-linux.make,v 1.7 2003/12/08 12:39:19 bsp Exp $
#
# Copyright (C) 2003 by Robert Schwebel <r.schwebel@pengutronix.de>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_UTLNX
PACKAGES += util-linux
endif

#
# Paths and names
#
UTIL-LINUX_VERSION	= 2.12
UTIL-LINUX		= util-linux-$(UTIL-LINUX_VERSION)
UTIL-LINUX_SUFFIX	= tar.gz
UTIL-LINUX_URL		= http://ftp.cwi.nl/aeb/util-linux/$(UTIL-LINUX).$(UTIL-LINUX_SUFFIX)
UTIL-LINUX_SOURCE	= $(SRCDIR)/$(UTIL-LINUX).$(UTIL-LINUX_SUFFIX)
UTIL-LINUX_DIR		= $(BUILDDIR)/$(UTIL-LINUX)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

util-linux_get: $(STATEDIR)/util-linux.get

util-linux_get_deps	=  $(UTIL-LINUX_SOURCE)

$(STATEDIR)/util-linux.get: $(util-linux_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(UTIL-LINUX))
	touch $@

$(UTIL-LINUX_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(UTIL-LINUX_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

util-linux_extract: $(STATEDIR)/util-linux.extract

util-linux_extract_deps	=  $(STATEDIR)/util-linux.get

$(STATEDIR)/util-linux.extract: $(util-linux_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UTIL-LINUX_DIR))
	@$(call extract, $(UTIL-LINUX_SOURCE))
	@$(call patchin, $(UTIL-LINUX))
	touch $@
	
# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

util-linux_prepare: $(STATEDIR)/util-linux.prepare

#
# dependencies
#
util-linux_prepare_deps =  \
	$(STATEDIR)/util-linux.extract \
	$(STATEDIR)/virtual-xchain.install

UTIL-LINUX_PATH	=  PATH=$(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin:$(CROSS_PATH)
UTIL-LINUX_ENV 	=  $(CROSS_ENV)

ifdef PTXCONF_ARCH_ARM
UTIL-LINUX_ENV 	+=  CFLAGS="-O2 -mstructure-size-boundary=8 -fomit-frame-pointer"
endif

ADDON_ENV =
ifdef PTXCONF_ARCH_ARM
 ifdef PTXCONF_ARM_ARCH_PXA
  ADDON_ENV = CPU=pxa ARCH=arm
 else
  ifdef PTXCONF_ARM_ARCH_ARM7500FE
   ADDON_ENV = CPU=arm7500fe ARCH=arm
  else
    ifdef PTXCONF_ARM_ARCH_ARM7
     ADDON_ENV = CPU=arm7 ARCH=arm
    else
     ADDON_ENV = CPU=sa1100 ARCH=arm
    endif
  endif
 endif
endif

$(STATEDIR)/util-linux.prepare: $(util-linux_prepare_deps)
	@$(call targetinfo, $@)
	cd $(UTIL-LINUX_DIR) && \
		$(UTIL-LINUX_PATH) $(UTIL-LINUX_ENV) \
		./configure $(ADDON_ENV)
ifdef PTXCONF_UTLNX_SWAPON
	echo "#define SWAPON_HAS_TWO_ARGS"  > $(UTIL-LINUX_DIR)/mount/swapargs.h
	echo "#include <asm/page.h>"       >> $(UTIL-LINUX_DIR)/mount/swapargs.h
	echo "#include <sys/swap.h>"       >> $(UTIL-LINUX_DIR)/mount/swapargs.h
endif
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

util-linux_compile: $(STATEDIR)/util-linux.compile

util-linux_compile_deps =  $(STATEDIR)/util-linux.prepare

$(STATEDIR)/util-linux.compile: $(util-linux_compile_deps)
	@$(call targetinfo, $@)
	$(UTIL-LINUX_PATH) $(MAKE) -C $(UTIL-LINUX_DIR)/lib $(ADDON_ENV)
ifdef PTXCONF_UTLNX_MKSWAP
	$(UTIL-LINUX_PATH) $(MAKE) -C $(UTIL-LINUX_DIR)/disk-utils mkswap $(ADDON_ENV)
endif
ifdef PTXCONF_UTLNX_SWAPON
	$(UTIL-LINUX_PATH) $(MAKE) -C $(UTIL-LINUX_DIR)/mount swapon $(ADDON_ENV)
endif	
ifdef PTXCONF_UTLNX_MOUNT
	$(UTIL-LINUX_PATH) $(MAKE) -C $(UTIL-LINUX_DIR)/mount mount $(ADDON_ENV)
endif	
ifdef PTXCONF_UTLNX_UMOUNT
	$(UTIL-LINUX_PATH) $(MAKE) -C $(UTIL-LINUX_DIR)/mount umount $(ADDON_ENV)
endif	
ifdef PTXCONF_UTLNX_HWCLOCK
	$(UTIL-LINUX_PATH) $(MAKE) -C $(UTIL-LINUX_DIR)/hwclock hwclock $(ADDON_ENV)
endif
ifdef PTXCONF_UTLNX_IPCS
	$(UTIL-LINUX_PATH) $(MAKE) -C $(UTIL-LINUX_DIR)/sys-utils ipcs $(ADDON_ENV)
endif
ifdef PTXCONF_UTLNX_READPROFILE
	$(UTIL-LINUX_PATH) $(MAKE) -C $(UTIL-LINUX_DIR)/sys-utils readprofile $(ADDON_ENV)
endif
ifdef PTXCONF_UTLNX_CAL
	$(UTIL-LINUX_PATH) $(MAKE) -C $(UTIL-LINUX_DIR)/misc-utils cal $(ADDON_ENV)
endif
ifdef PTXCONF_UTLNX_MCOOKIE
	$(UTIL-LINUX_PATH) $(MAKE) -C $(UTIL-LINUX_DIR)/misc-utils mcookie $(ADDON_ENV)
endif
ifdef PTXCONF_UTLNX_CFDISK
	$(UTIL-LINUX_PATH) $(MAKE) -C $(UTIL-LINUX_DIR)/fdisk cfdisk $(ADDON_ENV)
endif
ifdef PTXCONF_UTLNX_FDISK
	$(UTIL-LINUX_PATH) $(MAKE) -C $(UTIL-LINUX_DIR)/fdisk fdisk $(ADDON_ENV)
endif

#
# FIXME: implement other utilities
#
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

util-linux_install: $(STATEDIR)/util-linux.install

$(STATEDIR)/util-linux.install: $(STATEDIR)/util-linux.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

util-linux_targetinstall: $(STATEDIR)/util-linux.targetinstall

util-linux_targetinstall_deps	=  $(STATEDIR)/util-linux.compile

$(STATEDIR)/util-linux.targetinstall: $(util-linux_targetinstall_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_UTLNX_MKSWAP
	install -D $(UTIL-LINUX_DIR)/disk-utils/mkswap $(UTIL-LINUX_DIR)/ipkg_tmp/sbin/mkswap
	$(CROSSSTRIP) -R .note -R comment $(UTIL-LINUX_DIR)/ipkg_tmp/sbin/mkswap
endif
ifdef PTXCONF_UTLNX_SWAPON
	install -D $(UTIL-LINUX_DIR)/mount/swapon $(UTIL-LINUX_DIR)/ipkg_tmp/sbin/swapon
	$(CROSSSTRIP) -R .note -R comment $(UTIL-LINUX_DIR)/ipkg_tmp/sbin/swapon
	ln -sf swapon $(UTIL-LINUX_DIR)/ipkg_tmp/sbin/swapoff
endif
ifdef PTXCONF_UTLNX_MOUNT
	install -D $(UTIL-LINUX_DIR)/mount/mount $(UTIL-LINUX_DIR)/ipkg_tmp/bin/mount
	$(CROSSSTRIP) -R .note -R comment $(UTIL-LINUX_DIR)/ipkg_tmp/bin/mount
endif
ifdef PTXCONF_UTLNX_UMOUNT
	install -D $(UTIL-LINUX_DIR)/mount/umount $(UTIL-LINUX_DIR)/ipkg_tmp/bin/umount
	$(CROSSSTRIP) -R .note -R comment $(UTIL-LINUX_DIR)/ipkg_tmp/bin/umount
endif
ifdef PTXCONF_UTLNX_HWCLOCK
	install -D $(UTIL-LINUX_DIR)/hwclock/hwclock $(UTIL-LINUX_DIR)/ipkg_tmp/sbin/hwclock
	$(CROSSSTRIP) -R .note -R comment $(UTIL-LINUX_DIR)/ipkg_tmp/sbin/hwclock
endif
ifdef PTXCONF_UTLNX_IPCS
	install -D $(UTIL-LINUX_DIR)/sys-utils/ipcs $(UTIL-LINUX_DIR)/ipkg_tmp/usr/bin/ipcs
	$(CROSSSTRIP) -R .note -R comment $(UTIL-LINUX_DIR)/ipkg_tmp/usr/bin/ipcs
endif
ifdef PTXCONF_UTLNX_READPROFILE
	install -D $(UTIL-LINUX_DIR)/sys-utils/readprofile $(UTIL-LINUX_DIR)/ipkg_tmp/usr/sbin/readprofile
	$(CROSSSTRIP) -R .note -R comment $(UTIL-LINUX_DIR)/ipkg_tmp/usr/sbin/readprofile
endif
ifdef PTXCONF_UTLNX_CAL
	install -D $(UTIL-LINUX_DIR)/misc-utils/cal $(UTIL-LINUX_DIR)/ipkg_tmp/usr/bin/cal
	$(CROSSSTRIP) -R .note -R comment $(UTIL-LINUX_DIR)/ipkg_tmp/usr/bin/cal
endif
ifdef PTXCONF_UTLNX_MCOOKIE
	install -D $(UTIL-LINUX_DIR)/misc-utils/mcookie $(UTIL-LINUX_DIR)/ipkg_tmp/usr/bin/mcookie
	$(CROSSSTRIP) -R .note -R comment $(UTIL-LINUX_DIR)/ipkg_tmp/usr/bin/mcookie
endif
ifdef PTXCONF_UTLNX_CFDISK
	install -D $(UTIL-LINUX_DIR)/fdisk/cfdisk $(UTIL-LINUX_DIR)/ipkg_tmp/usr/sbin/cfdisk
	$(CROSSSTRIP) -R .note -R comment $(UTIL-LINUX_DIR)/ipkg_tmp/usr/sbin/cfdisk
endif
ifdef PTXCONF_UTLNX_FDISK
	install -D $(UTIL-LINUX_DIR)/fdisk/fdisk $(UTIL-LINUX_DIR)/ipkg_tmp/sbin/fdisk
	$(CROSSSTRIP) -R .note -R comment $(UTIL-LINUX_DIR)/ipkg_tmp/sbin/fdisk
endif
	mkdir -p $(UTIL-LINUX_DIR)/ipkg_tmp/CONTROL
	echo "Package: util-linux" 						 >$(UTIL-LINUX_DIR)/ipkg_tmp/CONTROL/control
	echo "Priority: optional" 						>>$(UTIL-LINUX_DIR)/ipkg_tmp/CONTROL/control
	echo "Section: Utilities" 						>>$(UTIL-LINUX_DIR)/ipkg_tmp/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(UTIL-LINUX_DIR)/ipkg_tmp/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(UTIL-LINUX_DIR)/ipkg_tmp/CONTROL/control
	echo "Version: $(UTIL-LINUX_VERSION)" 					>>$(UTIL-LINUX_DIR)/ipkg_tmp/CONTROL/control
	echo "Depends: " 							>>$(UTIL-LINUX_DIR)/ipkg_tmp/CONTROL/control
	echo "Description: Util-linux is a suite of essential utilities for any Linux system.">>$(UTIL-LINUX_DIR)/ipkg_tmp/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(UTIL-LINUX_DIR)/ipkg_tmp

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_UTLNX_INSTALL
ROMPACKAGES += $(STATEDIR)/util-linux.imageinstall
endif

util-linux_imageinstall_deps = $(STATEDIR)/util-linux.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/util-linux.imageinstall: $(util-linux_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install util-linux
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

util-linux_clean:
	rm -rf $(STATEDIR)/util-linux.*
	rm -rf $(UTIL-LINUX_DIR)

# vim: syntax=make
