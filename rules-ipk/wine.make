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
ifdef PTXCONF_WINE
PACKAGES += wine
endif

#
# Paths and names
#
WINE_VENDOR_VERSION	= 1
WINE_VERSION		= 20050201
WINE			= wine-$(WINE_VERSION)
WINE_SUFFIX		= tar.bz2
WINE_URL		= http://www.pdaXrom.org/src/$(WINE).$(WINE_SUFFIX)
WINE_SOURCE		= $(SRCDIR)/$(WINE).$(WINE_SUFFIX)
WINE_DIR		= $(BUILDDIR)/$(WINE)
WINE_IPKG_TMP		= $(WINE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

wine_get: $(STATEDIR)/wine.get

wine_get_deps = $(WINE_SOURCE)

$(STATEDIR)/wine.get: $(wine_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(WINE))
	touch $@

$(WINE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(WINE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

wine_extract: $(STATEDIR)/wine.extract

wine_extract_deps = $(STATEDIR)/wine.get

$(STATEDIR)/wine.extract: $(wine_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WINE_DIR))
	@$(call extract, $(WINE_SOURCE))
	@$(call patchin, $(WINE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

wine_prepare: $(STATEDIR)/wine.prepare

#
# dependencies
#
wine_prepare_deps = \
	$(STATEDIR)/wine.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/virtual-xchain.install

WINE_PATH	=  PATH=$(CROSS_PATH)
WINE_ENV 	=  $(CROSS_ENV)
#WINE_ENV	+=
WINE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#WINE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
WINE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-trace \
	--with-wine-tools=$(WINE_DIR) \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
WINE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
WINE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/wine.prepare: $(wine_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WINE_DIR)/config.cache)
	cd $(WINE_DIR) && \
		$(WINE_PATH) $(WINE_ENV) \
		./configure $(WINE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

wine_compile: $(STATEDIR)/wine.compile

wine_compile_deps = $(STATEDIR)/wine.prepare

$(STATEDIR)/wine.compile: $(wine_compile_deps)
	@$(call targetinfo, $@)
	$(WINE_PATH) $(MAKE) -C $(WINE_DIR) depend
	$(WINE_PATH) $(MAKE) -C $(WINE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

wine_install: $(STATEDIR)/wine.install

$(STATEDIR)/wine.install: $(STATEDIR)/wine.compile
	@$(call targetinfo, $@)
	###$(WINE_PATH) $(MAKE) -C $(WINE_DIR) install
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

wine_targetinstall: $(STATEDIR)/wine.targetinstall

wine_targetinstall_deps = $(STATEDIR)/wine.compile \
	$(STATEDIR)/xfree430.targetinstall

$(STATEDIR)/wine.targetinstall: $(wine_targetinstall_deps)
	@$(call targetinfo, $@)
	$(WINE_PATH) $(MAKE) -C $(WINE_DIR) prefix=$(WINE_IPKG_TMP)/usr install
	rm -rf $(WINE_IPKG_TMP)/usr/include
	rm -rf $(WINE_IPKG_TMP)/usr/man
	rm -rf $(WINE_IPKG_TMP)/usr/share/aclocal
	for FILE in `find $(WINE_IPKG_TMP)/usr/ -type f`; do			\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;				\
	    if [  "$$ZZZ" != "" ]; then						\
		$(CROSSSTRIP) $$FILE;						\
	    fi;									\
	done
	mkdir -p $(WINE_IPKG_TMP)/CONTROL
	echo "Package: wine" 											 >$(WINE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(WINE_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 										>>$(WINE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(WINE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(WINE_IPKG_TMP)/CONTROL/control
	echo "Version: $(WINE_VERSION)-$(WINE_VENDOR_VERSION)" 							>>$(WINE_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430" 										>>$(WINE_IPKG_TMP)/CONTROL/control
	echo "Description: Wine Windows Emulator"								>>$(WINE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WINE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_WINE_INSTALL
ROMPACKAGES += $(STATEDIR)/wine.imageinstall
endif

wine_imageinstall_deps = $(STATEDIR)/wine.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/wine.imageinstall: $(wine_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install wine
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

wine_clean:
	rm -rf $(STATEDIR)/wine.*
	rm -rf $(WINE_DIR)

# vim: syntax=make
