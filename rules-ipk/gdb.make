# -*-makefile-*-
# $Id: gdb.make,v 1.5 2003/12/18 17:01:57 bsp Exp $
#
# Copyright (C) 2002 by Pengutronix e.K., Hildesheim, Germany
# Copyright (C) 2003 by Auerswald GmbH & Co. KG, Schandelah, Germany
#
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_GDB
PACKAGES += gdb
endif

#
# We depend on this package
#
ifdef PTXCONF_GDB_TERMCAP
PACKAGES += termcap
endif

ifdef PTXCONF_GDB_NCURSES
PACKAGES += ncurses
endif

#
# Paths and names 
#
GDB_VERSION	= 6.3
###GDB_VERSION	= 6.2.1
GDB		= gdb-$(GDB_VERSION)
GDB_SUFFIX	= tar.bz2
GDB_URL		= ftp://ftp.gnu.org/pub/gnu/gdb/$(GDB).$(GDB_SUFFIX)
GDB_SOURCE	= $(SRCDIR)/$(GDB).tar.bz2
GDB_DIR		= $(BUILDDIR)/$(GDB)
GDB_BUILDDIR	= $(BUILDDIR)/$(GDB)-build
GDB_IPKG_TMP	= $(GDB_BUILDDIR)/ipkg_tmp
# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gdb_get: $(STATEDIR)/gdb.get

gdb_get_deps = $(GDB_SOURCE)

$(STATEDIR)/gdb.get: $(gdb_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GDB))
	touch $@

$(GDB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GDB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gdb_extract: $(STATEDIR)/gdb.extract

$(STATEDIR)/gdb.extract: $(STATEDIR)/gdb.get
	@$(call targetinfo, $@)
	@$(call clean, $(GDB_DIR))
	@$(call extract, $(GDB_SOURCE))
	@$(call patchin, $(GDB))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gdb_prepare: $(STATEDIR)/gdb.prepare

#
# dependencies
#
gdb_prepare_deps = \
	$(STATEDIR)/virtual-xchain.install \
	$(STATEDIR)/gdb.extract

ifdef PTXCONF_GDB_TERMCAP
gdb_prepare_deps += $(STATEDIR)/termcap.install
endif
ifdef PTXCONF_GDB_NCURSES
gdb_prepare_deps += $(STATEDIR)/ncurses.install
endif

GDB_PATH	=  PATH=$(CROSS_PATH)
GDB_ENV		=  $(CROSS_ENV)

ifndef PTXCONF_GDB_SHARED
GDB_MAKEVARS	=  LDFLAGS=-static
endif

#
# autoconf
#
GDB_AUTOCONF	=  --prefix=/usr
GDB_AUTOCONF	+= --build=$(GNU_HOST)
GDB_AUTOCONF	+= --host=$(PTXCONF_GNU_TARGET)
GDB_AUTOCONF	+= --target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/gdb.prepare: $(gdb_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GDB_BUILDDIR))
	mkdir -p $(GDB_BUILDDIR)
	cd $(GDB_BUILDDIR) && \
		$(GDB_PATH) $(GDB_ENV) \
		$(GDB_DIR)/configure $(GDB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gdb_compile: $(STATEDIR)/gdb.compile

$(STATEDIR)/gdb.compile: $(STATEDIR)/gdb.prepare 
	@$(call targetinfo, $@)
#
# the libiberty part is compiled for the host system
#
# don't pass target CFLAGS to it, so override them and call the configure script
#
	$(GDB_PATH) bash_cv_have_mbstate_t=yes $(MAKE) -C $(GDB_BUILDDIR) $(GDB_MAKEVARS) CFLAGS='' CXXFLAGS='' configure-build-libiberty
	$(GDB_PATH) bash_cv_have_mbstate_t=yes $(MAKE) -C $(GDB_BUILDDIR) $(GDB_MAKEVARS) 
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gdb_install: $(STATEDIR)/gdb.install

$(STATEDIR)/gdb.install:
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gdb_targetinstall: $(STATEDIR)/gdb.targetinstall

gdb_targetinstall_deps = \
	$(STATEDIR)/gdb.compile

ifdef PTXCONF_GDB_SHARED
ifdef PTXCONF_NCURSES
gdb_targetinstall_deps += $(STATEDIR)/ncurses.targetinstall
endif
endif

$(STATEDIR)/gdb.targetinstall: $(gdb_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p 				$(GDB_IPKG_TMP)/usr/bin
	install $(GDB_BUILDDIR)/gdb/gdb 	$(GDB_IPKG_TMP)/usr/bin
	$(CROSSSTRIP)  -R .note -R .comment	$(GDB_IPKG_TMP)/usr/bin/gdb
	mkdir -p 				$(GDB_IPKG_TMP)/CONTROL
	echo "Package: gdb"	 				 >$(GDB_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(GDB_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 				>>$(GDB_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"	>>$(GDB_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(GDB_IPKG_TMP)/CONTROL/control
	echo "Version: $(GDB_VERSION)"	 			>>$(GDB_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(GDB_IPKG_TMP)/CONTROL/control
	echo "Description: GNU debugger"			>>$(GDB_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GDB_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GDB_INSTALL
ROMPACKAGES += $(STATEDIR)/gdb.imageinstall
endif

gdb_imageinstall_deps = $(STATEDIR)/gdb.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gdb.imageinstall: $(gdb_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gdb
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gdb_clean: 
	rm -rf $(STATEDIR)/gdb.* $(GDB_DIR)

# vim: syntax=make
