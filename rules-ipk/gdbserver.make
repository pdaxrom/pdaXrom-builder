# -*-makefile-*-
# $Id: gdbserver.make,v 1.4 2003/11/17 03:25:08 mkl Exp $
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
ifdef PTXCONF_GDBSERVER
PACKAGES += gdbserver
endif

GDBSERVER_BUILDDIR	= $(BUILDDIR)/$(GDB)-server-build
GDBSERVER_IPKG_TMP	= $(GDBSERVER_BUILDDIR)/ipkg_tmp_server
# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gdbserver_get: $(STATEDIR)/gdbserver.get

$(STATEDIR)/gdbserver.get: $(gdb_get_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gdbserver_extract: $(STATEDIR)/gdbserver.extract

$(STATEDIR)/gdbserver.extract: $(STATEDIR)/gdb.extract
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gdbserver_prepare: $(STATEDIR)/gdbserver.prepare

gdbserver_prepare_deps = \
	$(STATEDIR)/virtual-xchain.install \
	$(STATEDIR)/gdbserver.extract

GDBSERVER_PATH		= $(GDB_PATH)
GDBSERVER_ENV		= $(GDB_ENV)

ifndef PTXCONF_GDBSERVER_SHARED
GDBSERVER_ENV		+=  LDFLAGS=-static
endif

#
# autoconf
#
GDBSERVER_AUTOCONF	= $(GDB_AUTOCONF)

$(STATEDIR)/gdbserver.prepare: $(gdbserver_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GDBSERVER_BUILDDIR))
	mkdir -p $(GDBSERVER_BUILDDIR)
#
# we call sh, cause configure is not executable
#
	cd $(GDBSERVER_BUILDDIR) && $(GDBSERVER_PATH) $(GDBSERVER_ENV) \
		sh $(GDB_DIR)/gdb/gdbserver/configure $(GDBSERVER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gdbserver_compile: $(STATEDIR)/gdbserver.compile

$(STATEDIR)/gdbserver.compile: $(STATEDIR)/gdbserver.prepare 
	@$(call targetinfo, $@)
	$(GDBSERVER_PATH) $(MAKE) -C $(GDBSERVER_BUILDDIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gdbserver_install: $(STATEDIR)/gdbserver.install

$(STATEDIR)/gdbserver.install:
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gdbserver_targetinstall: $(STATEDIR)/gdbserver.targetinstall

$(STATEDIR)/gdbserver.targetinstall: $(STATEDIR)/gdbserver.compile
	@$(call targetinfo, $@)
	mkdir -p 				$(GDBSERVER_IPKG_TMP)/usr/bin
	install $(GDBSERVER_BUILDDIR)/gdbserver $(GDBSERVER_IPKG_TMP)/usr/bin
	$(CROSS_STRIP) -R .note -R .comment	$(GDBSERVER_IPKG_TMP)/usr/bin/gdbserver
	mkdir -p 				$(GDBSERVER_IPKG_TMP)/CONTROL
	echo "Package: gdb-server"	 			 >$(GDBSERVER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(GDBSERVER_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 				>>$(GDBSERVER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"	>>$(GDBSERVER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(GDBSERVER_IPKG_TMP)/CONTROL/control
	echo "Version: $(GDB_VERSION)"	 			>>$(GDBSERVER_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(GDBSERVER_IPKG_TMP)/CONTROL/control
	echo "Description: GNU debugger server"			>>$(GDBSERVER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GDBSERVER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GDBSERVER_INSTALL
ROMPACKAGES += $(STATEDIR)/gdbserver.imageinstall
endif

gdbserver_imageinstall_deps = $(STATEDIR)/gdbserver.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gdbserver.imageinstall: $(gdbserver_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gdb-server
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gdbserver_clean: 
	rm -rf $(STATEDIR)/gdbserver.* $(GDBSERVER_BUILDDIR)

# vim: syntax=make
