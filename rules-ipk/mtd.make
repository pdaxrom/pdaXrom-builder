# -*-makefile-*-
# $Id: mtd.make,v 1.9 2003/10/24 01:27:16 mkl Exp $
#
# Copyright (C) 2003 by Pengutronix e.K., Hildesheim, Germany
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_MTD_UTILS
PACKAGES += mtd
endif

#
# Paths and names
#
MTD_VERSION	= 20030301-1
MTD		= mtd-$(MTD_VERSION)
MTD_SUFFIX	= tar.gz
MTD_URL		= http://www.pengutronix.de/software/ptxdist/temporary-src/$(MTD).$(MTD_SUFFIX)
MTD_SOURCE	= $(SRCDIR)/$(MTD).$(MTD_SUFFIX)
MTD_DIR		= $(BUILDDIR)/$(MTD)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mtd_get: $(STATEDIR)/mtd.get

mtd_get_deps = $(MTD_SOURCE)

$(STATEDIR)/mtd.get: $(mtd_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MTD))
	touch $@

$(MTD_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MTD_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mtd_extract: $(STATEDIR)/mtd.extract

mtd_extract_deps = $(STATEDIR)/mtd.get

$(STATEDIR)/mtd.extract: $(mtd_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MTD_DIR))
	@$(call extract, $(MTD_SOURCE))
	@$(call patchin, $(MTD))
#
# Makefile is currently fucked up... @#*$
# FIXME: patch sent to maintainer, remove this for fixed version
#
	perl -i -p -e 's/\(CFLAGS\) -o/\(LDFLAGS\) -o/g' $(MTD_DIR)/util/Makefile
	perl -i -p -e 's/^CFLAGS \+\=/override CFLAGS +=/g' $(MTD_DIR)/util/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mtd_prepare: $(STATEDIR)/mtd.prepare

#
# dependencies
#
mtd_prepare_deps = \
	$(STATEDIR)/virtual-xchain.install \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/mtd.extract

MTD_PATH	= PATH=$(CROSS_PATH)
MTD_MAKEVARS	= CROSS=$(PTXCONF_GNU_TARGET)-

$(STATEDIR)/mtd.prepare: $(mtd_prepare_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mtd_compile: $(STATEDIR)/mtd.compile

mtd_compile_deps = $(STATEDIR)/mtd.prepare

$(STATEDIR)/mtd.compile: $(mtd_compile_deps)
	@$(call targetinfo, $@)
	$(MTD_PATH) $(MAKE) -C $(MTD_DIR)/util $(MTD_MAKEVARS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mtd_install: $(STATEDIR)/mtd.install

$(STATEDIR)/mtd.install: $(STATEDIR)/mtd.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mtd_targetinstall: $(STATEDIR)/mtd.targetinstall

mtd_targetinstall_deps	=  $(STATEDIR)/mtd.compile
ifdef PTXCONF_MTD_MKJFFS
mtd_targetinstall_deps	+= $(STATEDIR)/zlib.targetinstall
endif
ifdef PTXCONF_MTD_MKJFFS2
mtd_targetinstall_deps	+= $(STATEDIR)/zlib.targetinstall
endif

$(STATEDIR)/mtd.targetinstall: $(mtd_targetinstall_deps)
	@$(call targetinfo, $@)
	install -d $(MTD_DIR)/ipk/sbin

ifdef PTXCONF_MTD_EINFO
	install $(MTD_DIR)/util/einfo $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/einfo
endif
ifdef PTXCONF_MTD_ERASE
	install $(MTD_DIR)/util/erase $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/erase
endif
ifdef PTXCONF_MTD_ERASEALL
	install $(MTD_DIR)/util/eraseall $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/eraseall
endif
ifdef PTXCONF_MTD_FCP
	install $(MTD_DIR)/util/fcp $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/fcp
endif
ifdef PTXCONF_MTD_FTL_CHECK
	install $(MTD_DIR)/util/ftl_check $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/check
endif
ifdef PTXCONF_MTD_FTL_FORMAT
	install $(MTD_DIR)/util/ftl_format $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/ftl_format
endif
ifdef PTXCONF_MTD_JFFS2READER
	install $(MTD_DIR)/util/jffs2reader $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/jffs2reader
endif
ifdef PTXCONF_MTD_LOCK
	install $(MTD_DIR)/util/lock $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/lock
endif
ifdef PTXCONF_MTD_MTDDEBUG
	install $(MTD_DIR)/util/mtd_debug $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/mtd_debug
endif
ifdef PTXCONF_MTD_NANDDUMP
	install $(MTD_DIR)/util/nanddump $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/nanddump
endif
ifdef PTXCONF_MTD_NANDTEST
	install $(MTD_DIR)/util/nandtest $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/nandtest
endif
ifdef PTXCONF_MTD_NANDWRITE
	install $(MTD_DIR)/util/nandwrite $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/nandwrite
endif
ifdef PTXCONF_MTD_NFTL_FORMAT
	install $(MTD_DIR)/util/nftl_format $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/nftl_format
endif
ifdef PTXCONF_MTD_NFTLDUMP
	install $(MTD_DIR)/util/nftldump $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/nftldump
endif
ifdef PTXCONF_MTD_UNLOCK
	install $(MTD_DIR)/util/unlock $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/unlock
endif
ifdef PTXCONF_MTD_MKJFFS
	install $(MTD_DIR)/util/mkfs.jffs $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/mkfs.jffs
endif
ifdef PTXCONF_MTD_MKJFFS2
	install $(MTD_DIR)/util/mkfs.jffs2 $(MTD_DIR)/ipk/sbin
	$(CROSSSTRIP) -R .note -R .comment $(MTD_DIR)/ipk/sbin/mkfs.jffs2
endif
	mkdir -p $(MTD_DIR)/ipk/CONTROL
	echo "Package: mtd"			 				  >$(MTD_DIR)/ipk/CONTROL/control
	echo "Priority: optional"	 					>>$(MTD_DIR)/ipk/CONTROL/control
	echo "Section: Utils"	 						>>$(MTD_DIR)/ipk/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"		 	>>$(MTD_DIR)/ipk/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(MTD_DIR)/ipk/CONTROL/control
	echo "Version: $(MTD_VERSION)"	 					>>$(MTD_DIR)/ipk/CONTROL/control
	echo "Depends: libz" 							>>$(MTD_DIR)/ipk/CONTROL/control
	echo "Description: Tools for managing memory technology devices."	>>$(MTD_DIR)/ipk/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MTD_DIR)/ipk
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MTD_UTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/mtd.imageinstall
endif

mtd_imageinstall_deps = $(STATEDIR)/mtd.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mtd.imageinstall: $(mtd_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mtd
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mtd_clean:
	rm -rf $(STATEDIR)/mtd.*
	rm -rf $(MTD_DIR)

# vim: syntax=make
