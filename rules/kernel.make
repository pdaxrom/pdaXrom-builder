# -*-makefile-*-
# $Id: kernel.make,v 1.15 2003/11/02 23:56:52 mkl Exp $
#
# Copyright (C) 2002, 2003 by Pengutronix e.K., Hildesheim, Germany
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_OS_LINUX
ifndef PTXCONF_DONT_COMPILE_KERNEL
PACKAGES += kernel
endif
endif
#
# version stuff in now in rules/Version.make
# NB: make s*cks
#
ifndef PTXCONF_KERNEL_RMK_PXA_EMBEDIX_SLC
 ifdef PTXCONF_KERNEL_RMK6_RS1
  KERNEL		= linux-2.4.19-rmk6-rs1
  KERNEL_SUFFIX		= tar.bz2
  KERNEL_URL		= http://www.cacko.biz/src/$(KERNEL).$(KERNEL_SUFFIX)
  KERNEL_SOURCE		= $(SRCDIR)/$(KERNEL).$(KERNEL_SUFFIX)
  KERNEL_DIR		= $(BUILDDIR)/linux-2.4.19-rmk6-rs1
 else
  ifdef PTXCONF_KERNEL_RMK2_LINEO5
   KERNEL		= linux-2.4.17-rmk2-lineo5
   KERNEL_SUFFIX	= tar.bz2
   KERNEL_URL		= http://www.cacko.biz/src/$(KERNEL).$(KERNEL_SUFFIX)
   KERNEL_SOURCE	= $(SRCDIR)/$(KERNEL).$(KERNEL_SUFFIX)
   KERNEL_DIR		= $(BUILDDIR)/linux
  else
   ifdef PTXCONF_KERNEL_RMK6_PXA1_HH36
    KERNEL		= linux-2.4.19-rmk6-pxa1-hh36
    KERNEL_SUFFIX	= tar.bz2
    KERNEL_URL		= http://www.cacko.biz/src/$(KERNEL).$(KERNEL_SUFFIX)
    KERNEL_SOURCE	= $(SRCDIR)/$(KERNEL).$(KERNEL_SUFFIX)
    KERNEL_DIR		= $(BUILDDIR)/linux
   else
    ifdef PTXCONF_KERNEL_SH_DC
     KERNEL		= linux-$(KERNEL_VERSION)-sh-dc
     KERNEL_SUFFIX	= tar.bz2
     KERNEL_URL		= http://www.cacko.biz/src/$(KERNEL).$(KERNEL_SUFFIX)
     KERNEL_SOURCE	= $(SRCDIR)/$(KERNEL).$(KERNEL_SUFFIX)
     KERNEL_DIR		= $(BUILDDIR)/linux
    else
     ifdef PTXCONF_KERNEL_RMK_PXA_EMBEDIX_SL5500
       KERNEL			= linux-sl5500-20030509-rom3_10
       KERNEL_SUFFIX		= tar.bz2
       KERNEL_URL		= http://developer.ezaurus.com/sl_j/source/c860/20031107/$(KERNEL).$(KERNEL_SUFFIX)
       KERNEL_SOURCE		= $(SRCDIR)/$(KERNEL).$(KERNEL_SUFFIX)
       KERNEL_DIR		= $(BUILDDIR)/linux
     else
      KERNEL		= linux-$(KERNEL_VERSION)
      KERNEL_SUFFIX	= tar.bz2
      KERNEL_URL	= ftp://ftp.kernel.org/pub/linux/kernel/v$(KERNEL_VERSION_MAJOR).$(KERNEL_VERSION_MINOR)/$(KERNEL).$(KERNEL_SUFFIX)
      KERNEL_SOURCE	= $(SRCDIR)/$(KERNEL).$(KERNEL_SUFFIX)
      KERNEL_DIR	= $(BUILDDIR)/$(KERNEL)
     endif
    endif
   endif
  endif
 endif
else
 KERNEL			= linux-c860-20031107-rom1_10
 KERNEL_SUFFIX		= tar.bz2
 KERNEL_URL		= http://developer.ezaurus.com/sl_j/source/c860/20031107/$(KERNEL).$(KERNEL_SUFFIX)
 KERNEL_SOURCE		= $(SRCDIR)/$(KERNEL).$(KERNEL_SUFFIX)
 KERNEL_DIR		= $(BUILDDIR)/linux
endif

ifdef PTXCONF_KERNEL_IMAGE_Z
KERNEL_TARGET		= zImage
ifdef PTXCONF_ARM_ARCH_PXA
KERNEL_TARGET_PATH	= $(KERNEL_DIR)/arch/arm/boot/zImage
else
KERNEL_TARGET_PATH	= $(KERNEL_DIR)/arch/$(PTXCONF_ARCH)/boot/zImage
endif
endif
ifdef PTXCONF_KERNEL_IMAGE_BZ
KERNEL_TARGET		= bzImage
KERNEL_TARGET_PATH	= $(KERNEL_DIR)/arch/$(PTXCONF_ARCH)/boot/bzImage
endif
ifdef PTXCONF_KERNEL_IMAGE_U
KERNEL_TARGET		= uImage
KERNEL_TARGET_PATH	= $(KERNEL_DIR)/uImage
endif
ifdef PTXCONF_KERNEL_IMAGE_VMLINUX
KERNEL_TARGET		= vmlinux
KERNEL_TARGET_PATH	= $(KERNEL_DIR)/vmlinux
endif

# ----------------------------------------------------------------------------
# Patches
# ----------------------------------------------------------------------------

KERNEL_PATCHES	=  $(addprefix kernel-, \
	$(call get_option_ext, s/^PTXCONF_KERNEL_[0-9]_[0-9]_[0-9]*_\(.*\)=y/\1/, sed -e 's/_/ /g' -e 's/[0-9]//g' ))

# ----------------------------------------------------------------------------
# Menuconfig
# ----------------------------------------------------------------------------

kernel_menuconfig: $(STATEDIR)/kernel.extract
	@if [ -f $(TOPDIR)/config/kernel/$(PTXCONF_KERNEL_CONFIG) ]; then \
		install -m 644 $(TOPDIR)/config/kernel/$(PTXCONF_KERNEL_CONFIG) \
			$(KERNEL_DIR)/.config; \
	fi

	$(KERNEL_PATH) make -C $(KERNEL_DIR) $(KERNEL_MAKEVARS) \
		menuconfig

	@if [ -f $(KERNEL_DIR)/.config ]; then \
		install -m 644 $(KERNEL_DIR)/.config \
			$(TOPDIR)/config/kernel/$(PTXCONF_KERNEL_CONFIG); \
	fi

	@if [ -f $(STATEDIR)/kernel.compile ]; then \
		rm $(STATEDIR)/kernel.compile; \
	fi

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

kernel_get: $(STATEDIR)/kernel.get

kernel_get_deps = \
	$(KERNEL_SOURCE)

$(STATEDIR)/kernel.get: $(kernel_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(KERNEL))
	touch $@

$(KERNEL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(KERNEL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

kernel_extract: $(STATEDIR)/kernel.extract

kernel_extract_deps = \
	$(STATEDIR)/kernel-base.extract	\
	$(addprefix $(STATEDIR)/, $(addsuffix .install, $(KERNEL_PATCHES)))

$(STATEDIR)/kernel.extract: $(kernel_extract_deps)
	@$(call targetinfo, $@)
	touch $@

$(STATEDIR)/kernel-base.extract: $(STATEDIR)/kernel.get
	@$(call targetinfo, $@)
	@$(call clean, $(KERNEL_DIR))
	@$(call extract, $(KERNEL_SOURCE), $(BUILDDIR))
	@$(call patchin, $(KERNEL), $(KERNEL_DIR))
#
#	kernels before 2.4.19 extract to "linux" instead of "linux-<version>"
#
#ifeq (2.4.18,$(KERNEL_VERSION))
#ifndef PTXCONF_KERNEL_RMK_PXA_EMBEDIX_SLC
#	mv $(BUILDDIR)/linux $(KERNEL_DIR)
#endif
#endif
ifdef PTXCONF_KERNEL_RMK6_PXA1_HH36
#	mv $(BUILDDIR)/$(KERNEL) $(KERNEL_DIR)
	cp -a $(TOPDIR)/config/pdaXrom-ipaq/wireless-firmware/*.BIN $(KERNEL_DIR)/drivers/net/wireless
endif
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

kernel_prepare: $(STATEDIR)/kernel.prepare

kernel_prepare_deps = \
	$(STATEDIR)/virtual-xchain.install \
	$(STATEDIR)/xchain-modutils.install \
	$(STATEDIR)/kernel.extract

ifdef PTXCONF_KERNEL_EXTERNAL_GCC
KERNEL_PATH	= PATH=$(PTXCONF_KERNEL_EXTERNAL_GCC_PATH):$$PATH
KERNEL_MAKEVARS	=
else
KERNEL_PATH	= PATH=$(CROSS_PATH)
KERNEL_MAKEVARS	= \
	ARCH=$(PTXCONF_ARCH) \
	CROSS_COMPILE=$(PTXCONF_GNU_TARGET)- \
	HOSTCC=$(HOSTCC) \
	GENKSYMS=$(PTXCONF_GNU_TARGET)-genksyms \
	DEPMOD=true
###	DEPMOD=$(PTXCONF_GNU_TARGET)-depmod
endif

$(STATEDIR)/kernel.prepare: $(kernel_prepare_deps)
	@$(call targetinfo, $@)

	$(KERNEL_PATH) make -C $(KERNEL_DIR) $(KERNEL_MAKEVARS) \
		mrproper

	if [ -f $(TOPDIR)/config/kernel/$(PTXCONF_KERNEL_CONFIG) ]; then	\
		install -m 644 $(TOPDIR)/config/kernel/$(PTXCONF_KERNEL_CONFIG) \
		$(KERNEL_DIR)/.config;						\
	fi

	#yes no | 
	$(KERNEL_PATH) make -C $(KERNEL_DIR) $(KERNEL_MAKEVARS) \
		oldconfig
	$(KERNEL_PATH) make -C $(KERNEL_DIR) $(KERNEL_MAKEVARS) \
		dep

	touch $@

# ----------------------------------------------------------------------------
# Modversions-Prepare
# ----------------------------------------------------------------------------

#
# Some packages (like rtnet.) need modversions.h
#
# we build it only when needed cause it can be build only if kernel modules
# are selected
#
$(STATEDIR)/kernel-modversions.prepare: $(STATEDIR)/kernel.prepare
	@$(call targetinfo, $@)

	$(KERNEL_PATH) make -C $(KERNEL_DIR) $(KERNEL_MAKEVARS) \
		$(KERNEL_DIR)/include/linux/modversions.h
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

kernel_compile: $(STATEDIR)/kernel.compile

kernel_compile_deps =  $(STATEDIR)/kernel.prepare
ifdef PTXCONF_KERNEL_IMAGE_U
kernel_compile_deps += $(STATEDIR)/xchain-umkimage.install
endif

$(STATEDIR)/kernel.compile: $(kernel_compile_deps)
	@$(call targetinfo, $@)
	$(KERNEL_PATH) make -C $(KERNEL_DIR) $(KERNEL_MAKEVARS) \
		$(KERNEL_TARGET) modules
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

kernel_install: $(STATEDIR)/kernel.install

$(STATEDIR)/kernel.install:
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

kernel_targetinstall: $(STATEDIR)/kernel.targetinstall

$(STATEDIR)/kernel.targetinstall: $(STATEDIR)/kernel.compile
	@$(call targetinfo, $@)
ifdef PTXCONF_KERNEL_INSTALL
	mkdir -p $(KERNEL_DIR)/ipkg_tmp/boot
	install $(KERNEL_TARGET_PATH) $(KERNEL_DIR)/ipkg_tmp/boot
else
ifdef PTXCONF_KERNEL_RMK_PXA_EMBEDIX_SLC
	install $(KERNEL_TARGET_PATH) $(TOPDIR)/bootdisk/zImage.bin
else
 ifdef PTXCONF_KERNEL_RMK_PXA_EMBEDIX_SL5500
	install $(KERNEL_TARGET_PATH) $(TOPDIR)/bootdisk/zImage
 else
	install $(KERNEL_TARGET_PATH) $(TOPDIR)/bootdisk
 endif
endif
endif
ifdef PTXCONF_KERNEL_MODULES_INSTALL
	$(KERNEL_PATH) make -C $(KERNEL_DIR) $(KERNEL_MAKEVARS) \
		modules_install INSTALL_MOD_PATH=$(KERNEL_DIR)/ipkg_tmp DEPMOD=$(XCHAIN_MODUTILS_DIR)/depmod/depmod
endif
ifdef PTXCONF_KERNEL_RMK_PXA_EMBEDIX_SLC
	for MNAME in isofs ntfs reiserfs ; do													\
	    mkdir -p $(KERNEL_DIR)/ipkg_tmp_$$MNAME/CONTROL ;											\
	    mkdir -p $(KERNEL_DIR)/ipkg_tmp_$$MNAME/lib/modules/`cd $(KERNEL_DIR)/ipkg_tmp/lib/modules && ls | grep '$(KERNEL_VERSION)'`/kernel/fs/ ;	\
	    mv -f $(KERNEL_DIR)/ipkg_tmp/lib/modules/`cd $(KERNEL_DIR)/ipkg_tmp/lib/modules && ls | grep '$(KERNEL_VERSION)'`/kernel/fs/$$MNAME 	\
		  $(KERNEL_DIR)/ipkg_tmp_$$MNAME/lib/modules/`cd $(KERNEL_DIR)/ipkg_tmp/lib/modules && ls | grep '$(KERNEL_VERSION)'`/kernel/fs/ ;	\
	    mkdir -p $(KERNEL_DIR)/ipkg_tmp_$$MNAME/CONTROL ;											\
	    echo "Package: kernel-modules-$$MNAME" 					 >$(KERNEL_DIR)/ipkg_tmp_$$MNAME/CONTROL/control ;	\
	    echo "Priority: optional" 							>>$(KERNEL_DIR)/ipkg_tmp_$$MNAME/CONTROL/control ;	\
	    echo "Section: System"	 						>>$(KERNEL_DIR)/ipkg_tmp_$$MNAME/CONTROL/control ;	\
	    echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(KERNEL_DIR)/ipkg_tmp_$$MNAME/CONTROL/control ;	\
	    echo "Architecture: $(SHORT_TARGET)" 					>>$(KERNEL_DIR)/ipkg_tmp_$$MNAME/CONTROL/control ;	\
	    echo "Version: $(KERNEL_VERSION)" 						>>$(KERNEL_DIR)/ipkg_tmp_$$MNAME/CONTROL/control ;	\
	    echo "Depends: " 								>>$(KERNEL_DIR)/ipkg_tmp_$$MNAME/CONTROL/control ;	\
	    echo "Description: $$MNAME kernel modules"					>>$(KERNEL_DIR)/ipkg_tmp_$$MNAME/CONTROL/control ;	\
	    echo "#!/bin/sh"								 >$(KERNEL_DIR)/ipkg_tmp_$$MNAME/CONTROL/postinst ;	\
	    echo "/sbin/depmod -a"							>>$(KERNEL_DIR)/ipkg_tmp_$$MNAME/CONTROL/postinst ;	\
	    chmod 755 $(KERNEL_DIR)/ipkg_tmp_$$MNAME/CONTROL/postinst ;										\
	    cd $(FEEDDIR) && $(XMKIPKG) $(KERNEL_DIR)/ipkg_tmp_$$MNAME ;									\
	done
endif
	mkdir -p $(KERNEL_DIR)/ipkg_tmp/CONTROL
	echo "Package: kernel-modules" 						 >$(KERNEL_DIR)/ipkg_tmp/CONTROL/control
	echo "Priority: optional" 						>>$(KERNEL_DIR)/ipkg_tmp/CONTROL/control
	echo "Section: System"	 						>>$(KERNEL_DIR)/ipkg_tmp/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(KERNEL_DIR)/ipkg_tmp/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(KERNEL_DIR)/ipkg_tmp/CONTROL/control
	echo "Version: $(KERNEL_VERSION)" 					>>$(KERNEL_DIR)/ipkg_tmp/CONTROL/control
	echo "Depends: " 							>>$(KERNEL_DIR)/ipkg_tmp/CONTROL/control
	echo "Description: kernel modules"					>>$(KERNEL_DIR)/ipkg_tmp/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(KERNEL_DIR)/ipkg_tmp
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_KERNEL_IPKG_INSTALL
ROMPACKAGES += $(STATEDIR)/kernel.imageinstall
endif

kernel_imageinstall_deps = $(STATEDIR)/kernel.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/kernel.imageinstall: $(kernel_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install kernel-modules
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

kernel_clean:
	rm -rf $(STATEDIR)/kernel.* $(KERNEL_DIR)

# vim: syntax=make
