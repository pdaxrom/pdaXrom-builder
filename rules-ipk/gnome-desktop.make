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
ifdef PTXCONF_GNOME-DESKTOP
PACKAGES += gnome-desktop
endif

#
# Paths and names
#
GNOME-DESKTOP_VERSION	= 2.6.1
GNOME-DESKTOP		= gnome-desktop-$(GNOME-DESKTOP_VERSION)
GNOME-DESKTOP_SUFFIX	= tar.bz2
GNOME-DESKTOP_URL	= ftp://ftp.gnome.org/pub/GNOME/sources/gnome-desktop/2.6/$(GNOME-DESKTOP).$(GNOME-DESKTOP_SUFFIX)
GNOME-DESKTOP_SOURCE	= $(SRCDIR)/$(GNOME-DESKTOP).$(GNOME-DESKTOP_SUFFIX)
GNOME-DESKTOP_DIR	= $(BUILDDIR)/$(GNOME-DESKTOP)
GNOME-DESKTOP_IPKG_TMP	= $(GNOME-DESKTOP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gnome-desktop_get: $(STATEDIR)/gnome-desktop.get

gnome-desktop_get_deps = $(GNOME-DESKTOP_SOURCE)

$(STATEDIR)/gnome-desktop.get: $(gnome-desktop_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GNOME-DESKTOP))
	touch $@

$(GNOME-DESKTOP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GNOME-DESKTOP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gnome-desktop_extract: $(STATEDIR)/gnome-desktop.extract

gnome-desktop_extract_deps = $(STATEDIR)/gnome-desktop.get

$(STATEDIR)/gnome-desktop.extract: $(gnome-desktop_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNOME-DESKTOP_DIR))
	@$(call extract, $(GNOME-DESKTOP_SOURCE))
	@$(call patchin, $(GNOME-DESKTOP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gnome-desktop_prepare: $(STATEDIR)/gnome-desktop.prepare

#
# dependencies
#
gnome-desktop_prepare_deps = \
	$(STATEDIR)/gnome-desktop.extract \
	$(STATEDIR)/libgnomeui.install \
	$(STATEDIR)/gnome-vfs.install \
	$(STATEDIR)/libgnomecanvas.install \
	$(STATEDIR)/virtual-xchain.install

GNOME-DESKTOP_PATH	=  PATH=$(CROSS_PATH)
GNOME-DESKTOP_ENV 	=  $(CROSS_ENV)
GNOME-DESKTOP_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
GNOME-DESKTOP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GNOME-DESKTOP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GNOME-DESKTOP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
GNOME-DESKTOP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GNOME-DESKTOP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gnome-desktop.prepare: $(gnome-desktop_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNOME-DESKTOP_DIR)/config.cache)
	cd $(GNOME-DESKTOP_DIR) && \
		$(GNOME-DESKTOP_PATH) $(GNOME-DESKTOP_ENV) \
		./configure $(GNOME-DESKTOP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gnome-desktop_compile: $(STATEDIR)/gnome-desktop.compile

gnome-desktop_compile_deps = $(STATEDIR)/gnome-desktop.prepare

$(STATEDIR)/gnome-desktop.compile: $(gnome-desktop_compile_deps)
	@$(call targetinfo, $@)
	$(GNOME-DESKTOP_PATH) $(MAKE) -C $(GNOME-DESKTOP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gnome-desktop_install: $(STATEDIR)/gnome-desktop.install

$(STATEDIR)/gnome-desktop.install: $(STATEDIR)/gnome-desktop.compile
	@$(call targetinfo, $@)
	$(GNOME-DESKTOP_PATH) $(MAKE) -C $(GNOME-DESKTOP_DIR) DESTDIR=$(GNOME-DESKTOP_IPKG_TMP) install
	cp -a  $(GNOME-DESKTOP_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(GNOME-DESKTOP_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgnome-desktop-2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gnome-desktop-2.0.pc
	rm -rf $(GNOME-DESKTOP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gnome-desktop_targetinstall: $(STATEDIR)/gnome-desktop.targetinstall

gnome-desktop_targetinstall_deps = $(STATEDIR)/gnome-desktop.compile \
	$(STATEDIR)/libgnomeui.targetinstall \
	$(STATEDIR)/gnome-vfs.targetinstall \
	$(STATEDIR)/libgnomecanvas.targetinstall

$(STATEDIR)/gnome-desktop.targetinstall: $(gnome-desktop_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GNOME-DESKTOP_PATH) $(MAKE) -C $(GNOME-DESKTOP_DIR) DESTDIR=$(GNOME-DESKTOP_IPKG_TMP) install
	rm -rf $(GNOME-DESKTOP_IPKG_TMP)/usr/include
	rm -rf $(GNOME-DESKTOP_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(GNOME-DESKTOP_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(GNOME-DESKTOP_IPKG_TMP)/usr/man
	rm -rf $(GNOME-DESKTOP_IPKG_TMP)/usr/share/locale
	for FILE in `find $(GNOME-DESKTOP_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(GNOME-DESKTOP_IPKG_TMP)/CONTROL
	echo "Package: gnome-desktop" 			>$(GNOME-DESKTOP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(GNOME-DESKTOP_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(GNOME-DESKTOP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(GNOME-DESKTOP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(GNOME-DESKTOP_IPKG_TMP)/CONTROL/control
	echo "Version: $(GNOME-DESKTOP_VERSION)" 	>>$(GNOME-DESKTOP_IPKG_TMP)/CONTROL/control
	echo "Depends: libgnomeui, gnome-vfs, libgnomecanvas">>$(GNOME-DESKTOP_IPKG_TMP)/CONTROL/control
	echo "Description: The gnome desktop programs for the GNOME GUI desktop environment.">>$(GNOME-DESKTOP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GNOME-DESKTOP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gnome-desktop_clean:
	rm -rf $(STATEDIR)/gnome-desktop.*
	rm -rf $(GNOME-DESKTOP_DIR)

# vim: syntax=make
