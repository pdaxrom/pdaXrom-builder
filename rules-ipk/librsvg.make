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
ifdef PTXCONF_LIBRSVG
PACKAGES += librsvg
endif

#
# Paths and names
#
LIBRSVG_VERSION		= 2.7.1
LIBRSVG			= librsvg-$(LIBRSVG_VERSION)
LIBRSVG_SUFFIX		= tar.bz2
LIBRSVG_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/librsvg/2.7/$(LIBRSVG).$(LIBRSVG_SUFFIX)
LIBRSVG_SOURCE		= $(SRCDIR)/$(LIBRSVG).$(LIBRSVG_SUFFIX)
LIBRSVG_DIR		= $(BUILDDIR)/$(LIBRSVG)
LIBRSVG_IPKG_TMP	= $(LIBRSVG_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

librsvg_get: $(STATEDIR)/librsvg.get

librsvg_get_deps = $(LIBRSVG_SOURCE)

$(STATEDIR)/librsvg.get: $(librsvg_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(LIBRSVG))
	touch $@

$(LIBRSVG_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBRSVG_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

librsvg_extract: $(STATEDIR)/librsvg.extract

librsvg_extract_deps = $(STATEDIR)/librsvg.get

$(STATEDIR)/librsvg.extract: $(librsvg_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBRSVG_DIR))
	@$(call extract, $(LIBRSVG_SOURCE))
	@$(call patchin, $(LIBRSVG))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

librsvg_prepare: $(STATEDIR)/librsvg.prepare

#
# dependencies
#
librsvg_prepare_deps = \
	$(STATEDIR)/librsvg.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libart_lgpl.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/libgsf.install \
	$(STATEDIR)/virtual-xchain.install

LIBRSVG_PATH	=  PATH=$(CROSS_PATH)
LIBRSVG_ENV 	=  $(CROSS_ENV)
LIBRSVG_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
LIBRSVG_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#LIBRSVG_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
LIBRSVG_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
LIBRSVG_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
LIBRSVG_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/librsvg.prepare: $(librsvg_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBRSVG_DIR)/config.cache)
	cd $(LIBRSVG_DIR) && \
		$(LIBRSVG_PATH) $(LIBRSVG_ENV) \
		./configure $(LIBRSVG_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(LIBRSVG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

librsvg_compile: $(STATEDIR)/librsvg.compile

librsvg_compile_deps = $(STATEDIR)/librsvg.prepare

$(STATEDIR)/librsvg.compile: $(librsvg_compile_deps)
	@$(call targetinfo, $@)
	$(LIBRSVG_PATH) $(MAKE) -C $(LIBRSVG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

librsvg_install: $(STATEDIR)/librsvg.install

$(STATEDIR)/librsvg.install: $(STATEDIR)/librsvg.compile
	@$(call targetinfo, $@)
	$(LIBRSVG_PATH) $(MAKE) -C $(LIBRSVG_DIR) DESTDIR=$(LIBRSVG_IPKG_TMP) install
	cp -a  $(LIBRSVG_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(LIBRSVG_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/librsvg-2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/librsvg-2.0.pc
	rm -rf $(LIBRSVG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

librsvg_targetinstall: $(STATEDIR)/librsvg.targetinstall

librsvg_targetinstall_deps = $(STATEDIR)/librsvg.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libart_lgpl.targetinstall \
	$(STATEDIR)/libxml2.targetinstall \
	$(STATEDIR)/libgsf.targetinstall

$(STATEDIR)/librsvg.targetinstall: $(librsvg_targetinstall_deps)
	@$(call targetinfo, $@)
	$(LIBRSVG_PATH) $(MAKE) -C $(LIBRSVG_DIR) DESTDIR=$(LIBRSVG_IPKG_TMP) install
	rm -rf $(LIBRSVG_IPKG_TMP)/usr/include
	rm -rf $(LIBRSVG_IPKG_TMP)/usr/lib/gtk-2.0/$(GTK22_VERSION_MAJOR).$(GTK22_VERSION_MINOR).0/engines/*.a
	rm -rf $(LIBRSVG_IPKG_TMP)/usr/lib/gtk-2.0/$(GTK22_VERSION_MAJOR).$(GTK22_VERSION_MINOR).0/loaders/*.a
	rm -rf $(LIBRSVG_IPKG_TMP)/usr/lib/mozilla
	rm -rf $(LIBRSVG_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(LIBRSVG_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(LIBRSVG_IPKG_TMP)/usr/man
	rm -rf $(LIBRSVG_IPKG_TMP)/usr/share/doc
	for FILE in `find $(LIBRSVG_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(LIBRSVG_IPKG_TMP)/CONTROL
	echo "Package: librsvg" 			>$(LIBRSVG_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(LIBRSVG_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(LIBRSVG_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(LIBRSVG_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(LIBRSVG_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBRSVG_VERSION)" 		>>$(LIBRSVG_IPKG_TMP)/CONTROL/control
	echo "Depends: libart-lgpl, libgsf, gtk2" 	>>$(LIBRSVG_IPKG_TMP)/CONTROL/control
	echo "Description: An SVG library based on libart.">>$(LIBRSVG_IPKG_TMP)/CONTROL/control
	echo "#!/bin/sh"								 >$(LIBRSVG_IPKG_TMP)/CONTROL/postinst
	echo "/usr/bin/gdk-pixbuf-query-loaders > /etc/gtk-2.0/gdk-pixbuf.loaders"	>>$(LIBRSVG_IPKG_TMP)/CONTROL/postinst
	echo "#!/bin/sh"								 >$(LIBRSVG_IPKG_TMP)/CONTROL/postrm
	echo "/usr/bin/gdk-pixbuf-query-loaders > /etc/gtk-2.0/gdk-pixbuf.loaders"	>>$(LIBRSVG_IPKG_TMP)/CONTROL/postrm
	chmod 755 $(LIBRSVG_IPKG_TMP)/CONTROL/postinst $(LIBRSVG_IPKG_TMP)/CONTROL/postrm
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBRSVG_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

librsvg_clean:
	rm -rf $(STATEDIR)/librsvg.*
	rm -rf $(LIBRSVG_DIR)

# vim: syntax=make
