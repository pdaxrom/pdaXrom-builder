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
ifdef PTXCONF_TK
PACKAGES += tk
endif

#
# Paths and names
#
TK_VERSION	= 8.4.6
TK		= tk$(TK_VERSION)
TK_SUFFIX	= tar.gz
TK_URL		= http://heanet.dl.sourceforge.net/sourceforge/tcl/$(TK)-src.$(TK_SUFFIX)
TK_SOURCE	= $(SRCDIR)/$(TK)-src.$(TK_SUFFIX)
TK_DIR		= $(BUILDDIR)/$(TK)
TK_IPKG_TMP	= $(TK_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tk_get: $(STATEDIR)/tk.get

tk_get_deps = $(TK_SOURCE)

$(STATEDIR)/tk.get: $(tk_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(TK))
	touch $@

$(TK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(TK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tk_extract: $(STATEDIR)/tk.extract

tk_extract_deps = $(STATEDIR)/tk.get

$(STATEDIR)/tk.extract: $(tk_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TK_DIR))
	@$(call extract, $(TK_SOURCE))
	@$(call patchin, $(TK))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tk_prepare: $(STATEDIR)/tk.prepare

#
# dependencies
#
tk_prepare_deps = \
	$(STATEDIR)/tk.extract \
	$(STATEDIR)/tcl.install \
	$(STATEDIR)/virtual-xchain.install

TK_PATH	=  PATH=$(CROSS_PATH)
TK_ENV 	=  $(CROSS_ENV)
#TK_ENV	+=
TK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#TK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
TK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--enable-threads \
	--enable-shared \
	--with-tcl=$(CROSS_LIB_DIR)/lib

ifdef PTXCONF_XFREE430
TK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
TK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/tk.prepare: $(tk_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TK_DIR)/config.cache)
	rm -rf $(TK_DIR)/linux
	mkdir $(TK_DIR)/linux
	cd $(TK_DIR)/linux && \
		$(TK_PATH) $(TK_ENV) \
		$(TK_DIR)/unix/configure $(TK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tk_compile: $(STATEDIR)/tk.compile

tk_compile_deps = $(STATEDIR)/tk.prepare

$(STATEDIR)/tk.compile: $(tk_compile_deps)
	@$(call targetinfo, $@)
	$(TK_PATH) $(MAKE) -C $(TK_DIR)/linux
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tk_install: $(STATEDIR)/tk.install

$(STATEDIR)/tk.install: $(STATEDIR)/tk.compile
	@$(call targetinfo, $@)
	rm -rf $(TK_IPKG_TMP)
	$(TK_PATH) $(MAKE) -C $(TK_DIR)/linux INSTALL_ROOT=$(TK_IPKG_TMP) install
	cp -a  $(TK_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	rm -f $(CROSS_LIB_DIR)/lib/libtk8.4.so
	cp -a  $(TK_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(CROSS_LIB_DIR)/lib/tk8.4
	rm -rf $(TK_IPKG_TMP)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/tkConfig.sh
	perl -p -i -e "s/\/usr\/include/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/include | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/tkConfig.sh
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tk_targetinstall: $(STATEDIR)/tk.targetinstall

tk_targetinstall_deps = $(STATEDIR)/tk.compile

$(STATEDIR)/tk.targetinstall: $(tk_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TK_PATH) $(MAKE) -C $(TK_DIR)/linux INSTALL_ROOT=$(TK_IPKG_TMP) install
	rm -rf $(TK_IPKG_TMP)/usr/man
	rm -rf $(TK_IPKG_TMP)/usr/include
	rm -rf $(TK_IPKG_TMP)/usr/lib/*.a
	rm -rf $(TK_IPKG_TMP)/usr/lib/*.sh
	$(CROSSSTRIP) $(TK_IPKG_TMP)/usr/bin/wish8.4
	$(CROSSSTRIP) $(TK_IPKG_TMP)/usr/lib/libtk8.4.so
	mkdir -p $(TK_IPKG_TMP)/CONTROL
	echo "Package: tk" 				>$(TK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(TK_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(TK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(TK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(TK_IPKG_TMP)/CONTROL/control
	echo "Version: $(TK_VERSION)" 			>>$(TK_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(TK_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(TK_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(TK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_TK_INSTALL
ROMPACKAGES += $(STATEDIR)/tk.imageinstall
endif

tk_imageinstall_deps = $(STATEDIR)/tk.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/tk.imageinstall: $(tk_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install tk
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tk_clean:
	rm -rf $(STATEDIR)/tk.*
	rm -rf $(TK_DIR)

# vim: syntax=make
