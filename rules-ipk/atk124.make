# -*-makefile-*-
# $Id: atk124.make,v 1.3 2003/10/23 15:01:19 mkl Exp $
#
# Copyright (C) 2003 by Robert Schwebel <r.schwebel@pengutronix.de>
#                       Pengutronix <info@pengutronix.de>, Germany
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_ATK124
PACKAGES += atk124
endif

#
# Paths and names
#
#ATK124_VERSION		= 1.6.1
ATK124_VERSION		= 1.9.0
ATK124			= atk-$(ATK124_VERSION)
ATK124_SUFFIX		= tar.bz2
ATK124_URL		= ftp://ftp.gtk.org/pub/gtk/v2.6/$(ATK124).$(ATK124_SUFFIX)
ATK124_SOURCE		= $(SRCDIR)/$(ATK124).$(ATK124_SUFFIX)
ATK124_DIR		= $(BUILDDIR)/$(ATK124)
ATK124_IPKG_TMP		= $(ATK124_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

atk124_get: $(STATEDIR)/atk124.get

atk124_get_deps	=  $(ATK124_SOURCE)

$(STATEDIR)/atk124.get: $(atk124_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(ATK124_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ATK124_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

atk124_extract: $(STATEDIR)/atk124.extract

atk124_extract_deps	=  $(STATEDIR)/atk124.get

$(STATEDIR)/atk124.extract: $(atk124_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ATK124_DIR))
	@$(call extract, $(ATK124_SOURCE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

atk124_prepare: $(STATEDIR)/atk124.prepare

#
# dependencies
#
atk124_prepare_deps =  \
	$(STATEDIR)/atk124.extract \
	$(STATEDIR)/pango12.install \
	$(STATEDIR)/virtual-xchain.install

ATK124_PATH	=  PATH=$(CROSS_PATH)
ATK124_ENV 	=  $(CROSS_ENV)
##ATK124_ENV	+= PKG_CONFIG_PATH=../$(GLIB22):../$(ATK124):../$(PANGO12):../$(GTK22)
#ATK123_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
ATK124_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig

ATK124_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"

#
# autoconf
#
ATK124_AUTOCONF	=  --prefix=/usr
ATK124_AUTOCONF	+= --build=$(GNU_HOST)
ATK124_AUTOCONF	+= --host=$(PTXCONF_GNU_TARGET)
ATK124_AUTOCONF	+= --disable-debug --enable-shared --disable-static --sysconfdir=/etc
ATK124_AUTOCONF	+= --x-includes=$(CROSS_LIB_DIR)/include
ATK124_AUTOCONF	+= --x-libraries=$(CROSS_LIB_DIR)/lib

ifdef PTXCONF_ATK124_FOO
ATK124_AUTOCONF	+= --enable-foo
endif

$(STATEDIR)/atk124.prepare: $(atk124_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ATK124_BUILDDIR))
	cd $(ATK124_DIR) && \
		$(ATK124_PATH) $(ATK124_ENV) \
		./configure $(ATK124_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(ATK124_DIR)/
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

atk124_compile: $(STATEDIR)/atk124.compile

atk124_compile_deps =  $(STATEDIR)/atk124.prepare

$(STATEDIR)/atk124.compile: $(atk124_compile_deps)
	@$(call targetinfo, $@)
	$(ATK124_PATH) $(MAKE) -C $(ATK124_DIR) 
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

atk124_install: $(STATEDIR)/atk124.install

$(STATEDIR)/atk124.install: $(STATEDIR)/atk124.compile
	@$(call targetinfo, $@)

	$(ATK124_PATH) $(MAKE) -C $(ATK124_DIR) prefix=$(CROSS_LIB_DIR) install
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/atk.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libatk-1.0.la

	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

atk124_targetinstall: $(STATEDIR)/atk124.targetinstall

atk124_targetinstall_deps	=  \
	$(STATEDIR)/atk124.compile \
	$(STATEDIR)/pango12.targetinstall

$(STATEDIR)/atk124.targetinstall: $(atk124_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ATK124_PATH) $(MAKE) -C $(ATK124_DIR) DESTDIR=$(ATK124_IPKG_TMP) install
	$(CROSSSTRIP) $(ATK124_IPKG_TMP)/usr/lib/libatk-1.0.so.*
	rm -rf $(ATK124_IPKG_TMP)/usr/lib/libatk-1.0.*a
	rm -rf $(ATK124_IPKG_TMP)/usr/include
	rm -rf $(ATK124_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(ATK124_IPKG_TMP)/usr/share/gtk-doc
	rm -rf $(ATK124_IPKG_TMP)/usr/share/locale
	mkdir -p $(ATK124_IPKG_TMP)/CONTROL
	echo "Package: atk"	 				 >$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 				>>$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"	>>$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Version: $(ATK124_VERSION)" 			>>$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Depends: pango, xfree430"		 		>>$(ATK124_IPKG_TMP)/CONTROL/control
	echo "Description: ATK Library"				>>$(ATK124_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ATK124_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ATK124_INSTALL
ROMPACKAGES += $(STATEDIR)/atk124.imageinstall
endif

atk124_imageinstall_deps = $(STATEDIR)/atk124.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/atk124.imageinstall: $(atk124_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install atk124
	touch $@


# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

atk124_clean:
	rm -rf $(STATEDIR)/atk124.*
	rm -rf $(ATK124_DIR)
	rm -f $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/share/pkg-config/atk*.pc

# vim: syntax=make
