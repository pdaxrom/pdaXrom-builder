# -*-makefile-*-
# $Id: coreutils.make,v 1.3 2003/10/23 20:40:00 mkl Exp $
#
# Copyright (C) 2003 by Pengutronix e.K., Hildesheim, Germany
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_COREUTILS
PACKAGES += coreutils
endif

#
# Paths and names 
#
COREUTILS_VERSION	= 5.0
COREUTILS		= coreutils-$(COREUTILS_VERSION)
COREUTILS_URL		= http://ftp.gnu.org/pub/gnu/coreutils/$(COREUTILS).tar.bz2 
COREUTILS_SOURCE	= $(SRCDIR)/$(COREUTILS).tar.bz2
COREUTILS_DIR		= $(BUILDDIR)/$(COREUTILS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

coreutils_get: $(STATEDIR)/coreutils.get

$(STATEDIR)/coreutils.get: $(COREUTILS_SOURCE)
	@$(call targetinfo, $@)
	@$(call get_patches, $(COREUTILS))
	touch $@

$(COREUTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(COREUTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

coreutils_extract: $(STATEDIR)/coreutils.extract

$(STATEDIR)/coreutils.extract: $(STATEDIR)/coreutils.get
	@$(call targetinfo, $@)
	@$(call clean, $(COREUTILS_DIR))
	@$(call extract, $(COREUTILS_SOURCE))
	@$(call patchin, $(COREUTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

coreutils_prepare: $(STATEDIR)/coreutils.prepare

COREUTILS_AUTOCONF	=  --build=$(GNU_HOST)
COREUTILS_AUTOCONF	+= --host=$(PTXCONF_GNU_TARGET)
COREUTILS_AUTOCONF	+= --target=$(PTXCONF_GNU_TARGET)

COREUTILS_PATH		=  PATH=$(CROSS_PATH)
COREUTILS_ENV		=  $(CROSS_ENV)

#ifdef PTXCONF_COREUTILS_SHLIKE
#COREUTILS_AUTOCONF	+= --enable-shell=sh
#else
#COREUTILS_AUTOCONF	+= --enable-shell=ksh
#endif

#
# dependencies
#
coreutils_prepare_deps = \
	$(STATEDIR)/virtual-xchain.install \
	$(STATEDIR)/coreutils.extract \

$(STATEDIR)/coreutils.prepare: $(coreutils_prepare_deps)
	@$(call targetinfo, $@)
	cd $(COREUTILS_DIR) && \
		$(COREUTILS_PATH) $(COREUTILS_ENV) \
		./configure $(COREUTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

coreutils_compile_deps = $(STATEDIR)/coreutils.prepare

coreutils_compile: $(STATEDIR)/coreutils.compile

$(STATEDIR)/coreutils.compile: $(STATEDIR)/coreutils.prepare 
	@$(call targetinfo, $@)
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/lib libfetish.a
ifdef PTXCONF_COREUTILS_SEQ
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src seq
endif
ifdef PTXCONF_COREUTILS_NICE
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src nice
endif
ifdef PTXCONF_COREUTILS_DATE
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src date
endif
ifdef PTXCONF_COREUTILS_SPLIT
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src split
endif
ifdef PTXCONF_COREUTILS_WC
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src wc
endif
ifdef PTXCONF_COREUTILS_COMM
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src comm
endif
ifdef PTXCONF_COREUTILS_FOLD
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src fold
endif
ifdef PTXCONF_COREUTILS_SORT
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src sort
endif
ifdef PTXCONF_COREUTILS_UNIQ
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src uniq
endif
ifdef PTXCONF_COREUTILS_GINSTALL
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src ginstall
endif
ifdef PTXCONF_COREUTILS_CAT
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src cat
endif
ifdef PTXCONF_COREUTILS_CP
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src cp
endif
ifdef PTXCONF_COREUTILS_LS
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src ls
endif
ifdef PTXCONF_COREUTILS_JOIN
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src join
endif
ifdef PTXCONF_COREUTILS_PASTE
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src paste
endif
ifdef PTXCONF_COREUTILS_FMT
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src fmt
endif
ifdef PTXCONF_COREUTILS_TEE
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src tee
endif
ifdef PTXCONF_COREUTILS_TR
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src tr
endif
ifdef PTXCONF_COREUTILS_RM
	$(COREUTILS_PATH) $(MAKE) -C $(COREUTILS_DIR)/src rm
endif
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

coreutils_install: $(STATEDIR)/coreutils.install

$(STATEDIR)/coreutils.install:
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

coreutils_targetinstall: $(STATEDIR)/coreutils.targetinstall

$(STATEDIR)/coreutils.targetinstall: $(STATEDIR)/coreutils.compile
	@$(call targetinfo, $@)
	install -d $(COREUTILS_DIR)/ipk/bin
	install -d $(COREUTILS_DIR)/ipk/usr/bin
ifdef PTXCONF_COREUTILS_SEQ
	install $(COREUTILS_DIR)/src/seq $(COREUTILS_DIR)/ipk/usr/bin
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/seq
endif
ifdef PTXCONF_COREUTILS_NICE
	install $(COREUTILS_DIR)/src/nice $(COREUTILS_DIR)/ipk/usr/bin
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/nice
endif
ifdef PTXCONF_COREUTILS_DATE
	install $(COREUTILS_DIR)/src/date $(COREUTILS_DIR)/ipk/bin/date
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/bin/date
endif
ifdef PTXCONF_COREUTILS_SPLIT
	install $(COREUTILS_DIR)/src/split $(COREUTILS_DIR)/ipk/usr/bin/split
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/split
endif
ifdef PTXCONF_COREUTILS_WC
	install $(COREUTILS_DIR)/src/wc $(COREUTILS_DIR)/ipk/usr/bin/wc
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/wc
endif
ifdef PTXCONF_COREUTILS_COMM
	install $(COREUTILS_DIR)/src/comm $(COREUTILS_DIR)/ipk/usr/bin/comm
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/comm
endif
ifdef PTXCONF_COREUTILS_FOLD
	install $(COREUTILS_DIR)/src/fold $(COREUTILS_DIR)/ipk/usr/bin/fold
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/fold
endif
ifdef PTXCONF_COREUTILS_SORT
	install $(COREUTILS_DIR)/src/sort $(COREUTILS_DIR)/ipk/usr/bin/sort
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/sort
endif
ifdef PTXCONF_COREUTILS_UNIQ
	install $(COREUTILS_DIR)/src/uniq $(COREUTILS_DIR)/ipk/usr/bin/uniq
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/uniq
endif
ifdef PTXCONF_COREUTILS_GINSTALL
	install $(COREUTILS_DIR)/src/ginstall $(COREUTILS_DIR)/ipk/usr/bin/ginstall
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/ginstall
	ln -sf ginstall $(COREUTILS_DIR)/ipk/usr/bin/install
endif
ifdef PTXCONF_COREUTILS_CP
	install $(COREUTILS_DIR)/src/cp $(COREUTILS_DIR)/ipk/bin/cp
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/bin/cp
endif
ifdef PTXCONF_COREUTILS_CAT
	install $(COREUTILS_DIR)/src/cat $(COREUTILS_DIR)/ipk/bin/cat
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/bin/cat
endif
ifdef PTXCONF_COREUTILS_LS
	install $(COREUTILS_DIR)/src/ls $(COREUTILS_DIR)/ipk/bin/ls
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/bin/ls
endif
ifdef PTXCONF_COREUTILS_JOIN
	install $(COREUTILS_DIR)/src/join $(COREUTILS_DIR)/ipk/usr/bin/join
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/join
endif
ifdef PTXCONF_COREUTILS_PASTE
	install $(COREUTILS_DIR)/src/paste $(COREUTILS_DIR)/ipk/usr/bin/paste
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/paste
endif
ifdef PTXCONF_COREUTILS_FMT
	install $(COREUTILS_DIR)/src/fmt $(COREUTILS_DIR)/ipk/usr/bin/fmt
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/fmt
endif
ifdef PTXCONF_COREUTILS_TEE
	install $(COREUTILS_DIR)/src/tee $(COREUTILS_DIR)/ipk/usr/bin/tee
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/tee
endif
ifdef PTXCONF_COREUTILS_TR
	install $(COREUTILS_DIR)/src/tr $(COREUTILS_DIR)/ipk/usr/bin/tr
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/usr/bin/tr
endif
ifdef PTXCONF_COREUTILS_RM
	install $(COREUTILS_DIR)/src/rm $(COREUTILS_DIR)/ipk/bin/rm
	$(CROSSSTRIP) -R .note -R .comment $(COREUTILS_DIR)/ipk/bin/rm
endif
	mkdir -p $(COREUTILS_DIR)/ipk/CONTROL
	echo "Package: coreutils" 						 >$(COREUTILS_DIR)/ipk/CONTROL/control
	echo "Priority: optional" 						>>$(COREUTILS_DIR)/ipk/CONTROL/control
	echo "Section: Console" 						>>$(COREUTILS_DIR)/ipk/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(COREUTILS_DIR)/ipk/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(COREUTILS_DIR)/ipk/CONTROL/control
	echo "Version: $(COREUTILS_VERSION)" 					>>$(COREUTILS_DIR)/ipk/CONTROL/control
	echo "Depends: " 							>>$(COREUTILS_DIR)/ipk/CONTROL/control
	echo "Description: A collection of core GNU utilities."			>>$(COREUTILS_DIR)/ipk/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(COREUTILS_DIR)/ipk
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_COREUTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/coreutils.imageinstall
endif

coreutils_imageinstall_deps = $(STATEDIR)/coreutils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/coreutils.imageinstall: $(coreutils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install coreutils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

coreutils_clean: 
	rm -rf $(STATEDIR)/coreutils.* $(COREUTILS_DIR)

# vim: syntax=make
