# -*-makefile-*-
# $Id: e2fsprogs.make,v 1.11 2003/12/23 10:50:30 robert Exp $
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
ifdef PTXCONF_E2FSPROGS
PACKAGES += e2fsprogs
endif

#
# Paths and names 
#
E2FSPROGS_VERSION		= 1.34
E2FSPROGS			= e2fsprogs-$(E2FSPROGS_VERSION)
E2FSPROGS_SUFFIX		= tar.gz
E2FSPROGS_URL			= http://cesnet.dl.sourceforge.net/sourceforge/e2fsprogs/$(E2FSPROGS).$(E2FSPROGS_SUFFIX)
E2FSPROGS_SOURCE		= $(SRCDIR)/$(E2FSPROGS).$(E2FSPROGS_SUFFIX)
E2FSPROGS_DIR			= $(BUILDDIR)/$(E2FSPROGS)
E2FSPROGS_BUILD_DIR		= $(BUILDDIR)/$(E2FSPROGS)-build

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

e2fsprogs_get: $(STATEDIR)/e2fsprogs.get

$(STATEDIR)/e2fsprogs.get: $(E2FSPROGS_SOURCE)
	@$(call targetinfo, $@)
	@$(call get_patches, $(E2FSPROGS))
	touch $@

$(E2FSPROGS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(E2FSPROGS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

e2fsprogs_extract: $(STATEDIR)/e2fsprogs.extract

$(STATEDIR)/e2fsprogs.extract: $(STATEDIR)/e2fsprogs.get
	@$(call targetinfo, $@)
	@$(call clean, $(E2FSPROGS_DIR))
	@$(call extract, $(E2FSPROGS_SOURCE))
	@$(call patchin, $(E2FSPROGS))
	chmod +w $(E2FSPROGS_DIR)/po/*.po
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

e2fsprogs_prepare: $(STATEDIR)/e2fsprogs.prepare

E2FSPROGS_AUTOCONF	=  --prefix=/
E2FSPROGS_AUTOCONF	+= --build=$(GNU_HOST)
E2FSPROGS_AUTOCONF	+= --host=$(PTXCONF_GNU_TARGET)
E2FSPROGS_AUTOCONF	+= --with-cc=$(PTXCONF_GNU_TARGET)-gcc
E2FSPROGS_AUTOCONF	+= --with-linker=$(PTXCONF_GNU_TARGET)-ld
E2FSPROGS_AUTOCONF	+= --enable-elf-shlibs --enable-dynamic-e2fsck --disable-nls --enable-compression

E2FSPROGS_PATH		=  PATH=$(CROSS_PATH)
E2FSPROGS_ENV		=  $(CROSS_ENV) 
E2FSPROGS_ENV		+= BUILD_CC=$(HOSTCC)

e2fsprogs_prepare_deps = \
	$(STATEDIR)/virtual-xchain.install \
	$(STATEDIR)/e2fsprogs.extract

$(STATEDIR)/e2fsprogs.prepare: $(e2fsprogs_prepare_deps)
	@$(call targetinfo, $@)
	mkdir -p $(E2FSPROGS_BUILD_DIR) && \
	cd $(E2FSPROGS_BUILD_DIR) && \
		$(E2FSPROGS_PATH) $(E2FSPROGS_ENV) \
		$(E2FSPROGS_DIR)/configure $(E2FSPROGS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

e2fsprogs_compile: $(STATEDIR)/e2fsprogs.compile

e2fsprogs_compile_deps = $(STATEDIR)/e2fsprogs.prepare

$(STATEDIR)/e2fsprogs.compile: $(e2fsprogs_compile_deps) 
	@$(call targetinfo, $@)
#
# in the util dir are tools that are compiled for the host system
# these tools are needed later in the compile progress
#
# it's not good to pass target CFLAGS to the host compiler :)
# so override these
#
	$(E2FSPROGS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)/util
	$(E2FSPROGS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

e2fsprogs_install: $(STATEDIR)/e2fsprogs.install

$(STATEDIR)/e2fsprogs.install:
	@$(call targetinfo, $@)
	###$(E2FSPROGS_PATH) $(MAKE) -C $(E2FSPROGS_BUILD_DIR) DESTDIR=$(CROSS_LIB_DIR) install
	install -m 644 -D $(E2FSPROGS_DIR)/lib/uuid/uuid.h		$(CROSS_LIB_DIR)/include/uuid/uuid.h
	install -m 755    $(E2FSPROGS_BUILD_DIR)/lib/libuuid.so.1.2	$(CROSS_LIB_DIR)/lib
	ln -sf libuuid.so.1.2 $(CROSS_LIB_DIR)/lib/libuuid.so.1
	ln -sf libuuid.so.1.2 $(CROSS_LIB_DIR)/lib/libuuid.so
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

e2fsprogs_targetinstall: $(STATEDIR)/e2fsprogs.targetinstall

$(STATEDIR)/e2fsprogs.targetinstall: $(STATEDIR)/e2fsprogs.compile
	@$(call targetinfo, $@)
	install -d $(E2FSPROGS_BUILD_DIR)/ipk/bin
	install -d $(E2FSPROGS_BUILD_DIR)/ipk/lib
	install -d $(E2FSPROGS_BUILD_DIR)/ipk/sbin
	install -d $(E2FSPROGS_BUILD_DIR)/ipk/usr/bin
	install -d $(E2FSPROGS_BUILD_DIR)/ipk/usr/sbin
	install $(E2FSPROGS_BUILD_DIR)/lib/libblkid.so.1.0 $(E2FSPROGS_BUILD_DIR)/ipk/lib/libblkid.so.1.0
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/lib/libblkid.so.1.0
	cd $(E2FSPROGS_BUILD_DIR)/ipk/lib && ln -sf libblkid.so.1.0 libblkid.so.1
	install $(E2FSPROGS_BUILD_DIR)/lib/libcom_err.so.2.1 $(E2FSPROGS_BUILD_DIR)/ipk/lib/libcom_err.so.2.1
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/lib/libcom_err.so.2.1
	cd $(E2FSPROGS_BUILD_DIR)/ipk/lib && ln -sf libcom_err.so.2.1 libcom_err.so.2
	install $(E2FSPROGS_BUILD_DIR)/lib/libe2p.so.2.3 $(E2FSPROGS_BUILD_DIR)/ipk/lib/libe2p.so.2.3
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/lib/libe2p.so.2.3
	cd $(E2FSPROGS_BUILD_DIR)/ipk/lib && ln -sf libe2p.so.2.3 libe2p.so.2
	install $(E2FSPROGS_BUILD_DIR)/lib/libext2fs.so.2.4 $(E2FSPROGS_BUILD_DIR)/ipk/lib/libext2fs.so.2.4
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/lib/libext2fs.so.2.4
	cd $(E2FSPROGS_BUILD_DIR)/ipk/lib && ln -sf libext2fs.so.2.4 libext2fs.so.2
	install $(E2FSPROGS_BUILD_DIR)/lib/libss.so.2.0 $(E2FSPROGS_BUILD_DIR)/ipk/lib/libss.so.2.0
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/lib/libss.so.2.0
	cd $(E2FSPROGS_BUILD_DIR)/ipk/lib && ln -sf libss.so.2.0 libss.so.2
	install $(E2FSPROGS_BUILD_DIR)/lib/libuuid.so.1.2 $(E2FSPROGS_BUILD_DIR)/ipk/lib/libuuid.so.1.2
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/lib/libuuid.so.1.2
	cd $(E2FSPROGS_BUILD_DIR)/ipk/lib && ln -sf libuuid.so.1.2 libuuid.so.1
	install -m 755 -d $(E2FSPROGS_BUILD_DIR)/ipk/lib/evms
	install $(E2FSPROGS_BUILD_DIR)/lib/evms/libe2fsim.1.2.1.so $(E2FSPROGS_BUILD_DIR)/ipk/lib/evms/libe2fsim.1.2.1.so
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/lib/evms/libe2fsim.1.2.1.so
	install $(E2FSPROGS_BUILD_DIR)/debugfs/debugfs	$(E2FSPROGS_BUILD_DIR)/ipk/sbin/debugfs
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/sbin/debugfs
	install $(E2FSPROGS_BUILD_DIR)/e2fsck/e2fsck	$(E2FSPROGS_BUILD_DIR)/ipk/sbin/e2fsck
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/sbin/e2fsck
	cd $(E2FSPROGS_BUILD_DIR)/ipk/sbin && ln -sf e2fsck fsck.ext2
	cd $(E2FSPROGS_BUILD_DIR)/ipk/sbin && ln -sf e2fsck fsck.ext3
	install $(E2FSPROGS_BUILD_DIR)/resize/resize2fs	$(E2FSPROGS_BUILD_DIR)/ipk/sbin/resize2fs
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/sbin/resize2fs
	install $(E2FSPROGS_BUILD_DIR)/misc/mke2fs	$(E2FSPROGS_BUILD_DIR)/ipk/sbin/mke2fs
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/sbin/mke2fs
	install $(E2FSPROGS_BUILD_DIR)/misc/badblocks	$(E2FSPROGS_BUILD_DIR)/ipk/sbin/badblocks
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/sbin/badblocks
	install $(E2FSPROGS_BUILD_DIR)/misc/tune2fs	$(E2FSPROGS_BUILD_DIR)/ipk/sbin/tune2fs
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/sbin/tune2fs
	install $(E2FSPROGS_BUILD_DIR)/misc/dumpe2fs	$(E2FSPROGS_BUILD_DIR)/ipk/sbin/dumpe2fs
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/sbin/dumpe2fs
	install $(E2FSPROGS_BUILD_DIR)/misc/blkid	$(E2FSPROGS_BUILD_DIR)/ipk/sbin/blkid
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/sbin/blkid
	install $(E2FSPROGS_BUILD_DIR)/misc/logsave	$(E2FSPROGS_BUILD_DIR)/ipk/sbin/logsave
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/sbin/logsave
	install $(E2FSPROGS_BUILD_DIR)/misc/e2image	$(E2FSPROGS_BUILD_DIR)/ipk/sbin/e2image
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/sbin/e2image
	install $(E2FSPROGS_BUILD_DIR)/misc/fsck	$(E2FSPROGS_BUILD_DIR)/ipk/sbin/fsck
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/sbin/fsck
	install $(E2FSPROGS_BUILD_DIR)/misc/mklost+found $(E2FSPROGS_BUILD_DIR)/ipk/usr/sbin/mklost+found
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/usr/sbin/mklost+found
	install $(E2FSPROGS_BUILD_DIR)/misc/chattr	$(E2FSPROGS_BUILD_DIR)/ipk/bin/chattr
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/bin/chattr
	install $(E2FSPROGS_BUILD_DIR)/misc/lsattr	$(E2FSPROGS_BUILD_DIR)/ipk/bin/lsattr
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/bin/lsattr
	install $(E2FSPROGS_BUILD_DIR)/misc/uuidgen	$(E2FSPROGS_BUILD_DIR)/ipk/bin/uuidgen
	$(CROSSSTRIP) -R .note -R .comment $(E2FSPROGS_BUILD_DIR)/ipk/bin/uuidgen
	cd $(E2FSPROGS_BUILD_DIR)/ipk/sbin && ln -sf mke2fs mkfs.ext2
	cd $(E2FSPROGS_BUILD_DIR)/ipk/sbin && ln -sf mke2fs mkfs.ext3
	cd $(E2FSPROGS_BUILD_DIR)/ipk/sbin && ln -sf tune2fs e2label
	cd $(E2FSPROGS_BUILD_DIR)/ipk/sbin && ln -sf tune2fs findfs
	mkdir -p $(E2FSPROGS_BUILD_DIR)/ipk/CONTROL
	echo "Package: e2fsprogs" 						 >$(E2FSPROGS_BUILD_DIR)/ipk/CONTROL/control
	echo "Priority: optional" 						>>$(E2FSPROGS_BUILD_DIR)/ipk/CONTROL/control
	echo "Section: Utilities" 						>>$(E2FSPROGS_BUILD_DIR)/ipk/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(E2FSPROGS_BUILD_DIR)/ipk/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(E2FSPROGS_BUILD_DIR)/ipk/CONTROL/control
	echo "Version: $(E2FSPROGS_VERSION)" 					>>$(E2FSPROGS_BUILD_DIR)/ipk/CONTROL/control
	echo "Depends: " 							>>$(E2FSPROGS_BUILD_DIR)/ipk/CONTROL/control
	echo "Description: EXT2 Filesystem Utilities"				>>$(E2FSPROGS_BUILD_DIR)/ipk/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(E2FSPROGS_BUILD_DIR)/ipk
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_E2FSPROGS_INSTALL
ROMPACKAGES += $(STATEDIR)/e2fsprogs.imageinstall
endif

e2fsprogs_imageinstall_deps = $(STATEDIR)/e2fsprogs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/e2fsprogs.imageinstall: $(e2fsprogs_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install e2fsprogs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

e2fsprogs_clean: 
	rm -rf $(STATEDIR)/e2fsprogs.* $(E2FSPROGS_DIR) $(E2FSPROGS_BUILD_DIR)

# vim: syntax=make
