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
ifdef PTXCONF_TCL
PACKAGES += tcl
endif

#
# Paths and names
#
TCL_VERSION	= 8.4.6
TCL		= tcl$(TCL_VERSION)
TCL_SUFFIX	= tar.gz
TCL_URL		= http://heanet.dl.sourceforge.net/sourceforge/tcl/$(TCL)-src.$(TCL_SUFFIX)
TCL_SOURCE	= $(SRCDIR)/$(TCL)-src.$(TCL_SUFFIX)
TCL_DIR		= $(BUILDDIR)/$(TCL)
TCL_IPKG_TMP	= $(TCL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tcl_get: $(STATEDIR)/tcl.get

tcl_get_deps = $(TCL_SOURCE)

$(STATEDIR)/tcl.get: $(tcl_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TCL))
	touch $@

$(TCL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TCL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tcl_extract: $(STATEDIR)/tcl.extract

tcl_extract_deps = $(STATEDIR)/tcl.get

$(STATEDIR)/tcl.extract: $(tcl_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TCL_DIR))
	@$(call extract, $(TCL_SOURCE))
	@$(call patchin, $(TCL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tcl_prepare: $(STATEDIR)/tcl.prepare

#
# dependencies
#
tcl_prepare_deps = \
	$(STATEDIR)/tcl.extract \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_XFREE430
tcl_prepare_deps += $(STATEDIR)/xfree430.install
endif

TCL_PATH	=  PATH=$(CROSS_PATH)
TCL_ENV 	=  $(CROSS_ENV)
#TCL_ENV	+=
TCL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TCL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
TCL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--enable-shared \
	--enable-threads

ifdef PTXCONF_XFREE430
TCL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TCL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/tcl.prepare: $(tcl_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TCL_DIR)/config.cache)
	mkdir $(TCL_DIR)/linux
	cd $(TCL_DIR)/linux && \
		$(TCL_PATH) $(TCL_ENV) \
		$(TCL_DIR)/unix/configure $(TCL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tcl_compile: $(STATEDIR)/tcl.compile

tcl_compile_deps = $(STATEDIR)/tcl.prepare

$(STATEDIR)/tcl.compile: $(tcl_compile_deps)
	@$(call targetinfo, $@)
	$(TCL_PATH) $(MAKE) -C $(TCL_DIR)/linux
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tcl_install: $(STATEDIR)/tcl.install

$(STATEDIR)/tcl.install: $(STATEDIR)/tcl.compile
	@$(call targetinfo, $@)
	rm -rf $(TCL_IPKG_TMP)
	$(TCL_PATH) $(MAKE) -C $(TCL_DIR)/linux INSTALL_ROOT=$(TCL_IPKG_TMP) install
	cp -a  $(TCL_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	rm -f $(CROSS_LIB_DIR)/lib/libtcl8.4.so
	cp -a  $(TCL_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(CROSS_LIB_DIR)/lib/tcl8.4
	rm -rf $(TCL_IPKG_TMP)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/tclConfig.sh
	perl -p -i -e "s/\/usr\/include/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/include | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/tclConfig.sh
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tcl_targetinstall: $(STATEDIR)/tcl.targetinstall

tcl_targetinstall_deps = $(STATEDIR)/tcl.compile

$(STATEDIR)/tcl.targetinstall: $(tcl_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(TCL_IPKG_TMP)
	$(TCL_PATH) $(MAKE) -C $(TCL_DIR)/linux INSTALL_ROOT=$(TCL_IPKG_TMP) install
	rm -rf $(TCL_IPKG_TMP)/usr/man
	rm -rf $(TCL_IPKG_TMP)/usr/include
	rm -rf $(TCL_IPKG_TMP)/usr/lib/*.a
	rm -rf $(TCL_IPKG_TMP)/usr/lib/*.sh
	$(CROSSSTRIP) $(TCL_IPKG_TMP)/usr/bin/tclsh8.4
	$(CROSSSTRIP) $(TCL_IPKG_TMP)/usr/lib/libtcl8.4.so
	mkdir -p $(TCL_IPKG_TMP)/CONTROL
	echo "Package: tcl" 				>$(TCL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(TCL_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(TCL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(TCL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(TCL_IPKG_TMP)/CONTROL/control
	echo "Version: $(TCL_VERSION)" 			>>$(TCL_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_XFREE430
	echo "Depends: xfree430" 			>>$(TCL_IPKG_TMP)/CONTROL/control
else
	echo "Depends: "	 			>>$(TCL_IPKG_TMP)/CONTROL/control
endif
	echo "Description: generated with pdaXrom builder">>$(TCL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TCL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TCL_INSTALL
ROMPACKAGES += $(STATEDIR)/tcl.imageinstall
endif

tcl_imageinstall_deps = $(STATEDIR)/tcl.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/tcl.imageinstall: $(tcl_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install tcl
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tcl_clean:
	rm -rf $(STATEDIR)/tcl.*
	rm -rf $(TCL_DIR)

# vim: syntax=make
