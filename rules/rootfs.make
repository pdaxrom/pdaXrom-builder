# -*-makefile-*-
# $Id: rootfs.make,v 1.7 2003/10/26 13:32:10 mkl Exp $
#
# Copyright (C) 2002, 2003 by Pengutronix e.K., Hildesheim, Germany
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES += rootfs

#
# Paths and names 
#
ROOTFS			= root-0.1.1
ROOTFS_URL		= http://www.pengutronix.de/software/ptxdist/temporary-src/$(ROOTFS).tgz
ROOTFS_SOURCE		= $(SRCDIR)/$(ROOTFS).tgz
ROOTFS_DIR		= $(BUILDDIR)/$(ROOTFS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rootfs_get: $(STATEDIR)/rootfs.get

$(STATEDIR)/rootfs.get: $(ROOTFS_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(ROOTFS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ROOTFS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rootfs_extract: $(STATEDIR)/rootfs.extract

$(STATEDIR)/rootfs.extract: $(STATEDIR)/rootfs.get
	@$(call targetinfo, $@)
	@$(call extract, $(ROOTFS_SOURCE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rootfs_prepare: $(STATEDIR)/rootfs.prepare

$(STATEDIR)/rootfs.prepare: $(STATEDIR)/rootfs.extract
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rootfs_compile: $(STATEDIR)/rootfs.compile

$(STATEDIR)/rootfs.compile: $(STATEDIR)/rootfs.prepare 
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rootfs_install: $(STATEDIR)/rootfs.install

$(STATEDIR)/rootfs.install: $(STATEDIR)/rootfs.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rootfs_targetinstall: $(STATEDIR)/rootfs.targetinstall

$(STATEDIR)/rootfs.targetinstall: $(STATEDIR)/rootfs.install
	@$(call targetinfo, $@)

ifdef PTXCONF_ROOTFS_PROC
	mkdir -p $(ROOTFS_DIR)/ipkg/proc
endif

ifdef PTXCONF_ROOTFS_DEV
	mkdir -p $(ROOTFS_DIR)/ipkg/dev
endif

ifdef PTXCONF_ROOTFS_MNT
	mkdir -p $(ROOTFS_DIR)/ipkg/mnt
endif

ifdef PTXCONF_ROOTFS_FLOPPY
	mkdir -p $(ROOTFS_DIR)/ipkg/floppy
endif

ifdef PTXCONF_ROOTFS_ETC
	@$(call clean, $(ROOTFS_DIR)/ipkg/etc)
	mkdir -p $(ROOTFS_DIR)/ipkg/etc
	cp -a $(TOPDIR)/config/etc/$(PTXCONF_ETC_NAME)/* $(ROOTFS_DIR)/ipkg/etc/

#  ifdef PTXCONF_OPENSSH
#	cd $(OPENSSH_DIR) && install -m 644 sshd_config.out $(ROOTFS_DIR)/ipkg/etc/ssh/sshd_config
#  endif
endif

ifdef PTXCONF_ROOTFS_TMP
	@$(call clean, $(ROOTFS_DIR)/ipkg/tmp)
  ifdef PTXCONF_ROOTFS_TMP_DATALINK
	ln -s /data/tmp $(ROOTFS_DIR)/ipkg/tmp
  else
	mkdir -p $(ROOTFS_DIR)/ipkg/tmp
  endif
endif

ifdef PTXCONF_ROOTFS_VAR
	#mkdir -p $(ROOTFS_DIR)/ipkg/var
	#mkdir -p $(ROOTFS_DIR)/ipkg/var/log
	install -m 775 -d $(ROOTFS_DIR)/var
	install -m 755 -d $(ROOTFS_DIR)/var/empty
	install -m 775 -d $(ROOTFS_DIR)/var/home
	install -m 775 -d $(ROOTFS_DIR)/var/lib/pcmcia
	install -m 777 -d $(ROOTFS_DIR)/var/lock
	install -m 755 -d $(ROOTFS_DIR)/var/lock/subsys
	install -m 755 -d $(ROOTFS_DIR)/var/log
	install -m 775 -d $(ROOTFS_DIR)/var/spool
	install -m 775 -d $(ROOTFS_DIR)/var/tmp
	install -m 777 -d $(ROOTFS_DIR)/var/run
endif

ifdef PTXCONF_ROOTFS_VAR_LOG_DATALINK
	mkdir -p $(ROOTFS_DIR)/ipkg/var
	@$(call clean, $(ROOTFS_DIR)/ipkg/var/log)
	ln -s /data/log $(ROOTFS_DIR)/ipkg/var/log
endif	

ifdef PTXCONF_ROOTFS_DATA
	mkdir -p $(ROOTFS_DIR)/ipkg/data
endif

ifdef PTXCONF_ROOTFS_HOME
	mkdir -p $(ROOTFS_DIR)/ipkg/home
endif
	install -m 755 -d $(ROOTFS_DIR)/root
	mkdir -p $(ROOTFS_DIR)/ipkg/bin
	mkdir -p $(ROOTFS_DIR)/ipkg/lib
	mkdir -p $(ROOTFS_DIR)/ipkg/sbin
	mkdir -p $(ROOTFS_DIR)/ipkg/usr/bin
	mkdir -p $(ROOTFS_DIR)/ipkg/usr/lib
	mkdir -p $(ROOTFS_DIR)/ipkg/usr/sbin
	mkdir -p $(ROOTFS_DIR)/ipkg/usr/share

	mkdir -p $(ROOTFS_DIR)/ipkg/CONTROL
	echo "Package: rootfs" 							 >$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Priority: optional" 						>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Section: Console" 						>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Version: 1.0.0"	 						>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Depends: " 							>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	echo "Description: root file system structure"				>>$(ROOTFS_DIR)/ipkg/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ROOTFS_DIR)/ipkg

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ROOTFS_INSTALL
ROMPACKAGES += $(STATEDIR)/rootfs.imageinstall
endif

rootfs_imageinstall_deps = $(STATEDIR)/rootfs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/rootfs.imageinstall: $(rootfs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install rootfs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rootfs_clean: 
	rm -rf $(STATEDIR)/rootfs.* $(ROOTFS_DIR)

# vim: syntax=make
