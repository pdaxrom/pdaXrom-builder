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
ifdef PTXCONF_NAUTILUS
PACKAGES += nautilus
endif

#
# Paths and names
#
NAUTILUS_VERSION	= 2.6.1
NAUTILUS		= nautilus-$(NAUTILUS_VERSION)
NAUTILUS_SUFFIX		= tar.bz2
NAUTILUS_URL		= ftp://ftp.acc.umu.se/pub/GNOME/sources/nautilus/2.6/$(NAUTILUS).$(NAUTILUS_SUFFIX)
NAUTILUS_SOURCE		= $(SRCDIR)/$(NAUTILUS).$(NAUTILUS_SUFFIX)
NAUTILUS_DIR		= $(BUILDDIR)/$(NAUTILUS)
NAUTILUS_IPKG_TMP	= $(NAUTILUS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

nautilus_get: $(STATEDIR)/nautilus.get

nautilus_get_deps = $(NAUTILUS_SOURCE)

$(STATEDIR)/nautilus.get: $(nautilus_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NAUTILUS))
	touch $@

$(NAUTILUS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NAUTILUS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

nautilus_extract: $(STATEDIR)/nautilus.extract

nautilus_extract_deps = $(STATEDIR)/nautilus.get

$(STATEDIR)/nautilus.extract: $(nautilus_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NAUTILUS_DIR))
	@$(call extract, $(NAUTILUS_SOURCE))
	@$(call patchin, $(NAUTILUS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

nautilus_prepare: $(STATEDIR)/nautilus.prepare

#
# dependencies
#
nautilus_prepare_deps = \
	$(STATEDIR)/nautilus.extract \
	$(STATEDIR)/esound.install \
	$(STATEDIR)/libbonoboui.install \
	$(STATEDIR)/libgnomeui.install \
	$(STATEDIR)/eel.install \
	$(STATEDIR)/librsvg.install \
	$(STATEDIR)/gnome-desktop.install \
	$(STATEDIR)/virtual-xchain.install

NAUTILUS_PATH	=  PATH=$(CROSS_PATH)
NAUTILUS_ENV 	=  $(CROSS_ENV)
NAUTILUS_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
NAUTILUS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#NAUTILUS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
NAUTILUS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
NAUTILUS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
NAUTILUS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/nautilus.prepare: $(nautilus_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NAUTILUS_DIR)/config.cache)
	cd $(NAUTILUS_DIR) && \
		$(NAUTILUS_PATH) $(NAUTILUS_ENV) \
		./configure $(NAUTILUS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

nautilus_compile: $(STATEDIR)/nautilus.compile

nautilus_compile_deps = $(STATEDIR)/nautilus.prepare

$(STATEDIR)/nautilus.compile: $(nautilus_compile_deps)
	@$(call targetinfo, $@)
	$(NAUTILUS_PATH) $(MAKE) -C $(NAUTILUS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

nautilus_install: $(STATEDIR)/nautilus.install

$(STATEDIR)/nautilus.install: $(STATEDIR)/nautilus.compile
	@$(call targetinfo, $@)
	$(NAUTILUS_PATH) $(MAKE) -C $(NAUTILUS_DIR) DESTDIR=$(NAUTILUS_IPKG_TMP) install
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

nautilus_targetinstall: $(STATEDIR)/nautilus.targetinstall

nautilus_targetinstall_deps = \
	$(STATEDIR)/nautilus.compile \
	$(STATEDIR)/esound.targetinstall \
	$(STATEDIR)/libbonoboui.targetinstall \
	$(STATEDIR)/libgnomeui.targetinstall \
	$(STATEDIR)/eel.targetinstall \
	$(STATEDIR)/gnome-desktop.targetinstall \
	$(STATEDIR)/librsvg.targetinstall

$(STATEDIR)/nautilus.targetinstall: $(nautilus_targetinstall_deps)
	@$(call targetinfo, $@)
	$(NAUTILUS_PATH) $(MAKE) -C $(NAUTILUS_DIR) DESTDIR=$(NAUTILUS_IPKG_TMP) install
	rm -rf $(NAUTILUS_IPKG_TMP)/usr/include
	rm -rf $(NAUTILUS_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(NAUTILUS_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(NAUTILUS_IPKG_TMP)/usr/share/locale
	for FILE in `find $(NAUTILUS_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(NAUTILUS_IPKG_TMP)/CONTROL
	echo "Package: nautilus" 			>$(NAUTILUS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(NAUTILUS_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(NAUTILUS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(NAUTILUS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(NAUTILUS_IPKG_TMP)/CONTROL/control
	echo "Version: $(NAUTILUS_VERSION)" 		>>$(NAUTILUS_IPKG_TMP)/CONTROL/control
	echo "Depends: libgnomeui, gnome-desktop, esound, libbonoboui, libgnomeui, eel, librsvg, gail" >>$(NAUTILUS_IPKG_TMP)/CONTROL/control
	echo "Description: This is Nautilus, the file manager for the GNOME desktop.">>$(NAUTILUS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(NAUTILUS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NAUTILUS_INSTALL
ROMPACKAGES += $(STATEDIR)/nautilus.imageinstall
endif

nautilus_imageinstall_deps = $(STATEDIR)/nautilus.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/nautilus.imageinstall: $(nautilus_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install nautilus
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

nautilus_clean:
	rm -rf $(STATEDIR)/nautilus.*
	rm -rf $(NAUTILUS_DIR)

# vim: syntax=make
