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
ifdef PTXCONF_PYGTK
PACKAGES += pygtk
endif

#
# Paths and names
#
#PYGTK_VERSION		= 2.4.1
#PYGTK			= pygtk-$(PYGTK_VERSION)
#PYGTK_SUFFIX		= tar.bz2
#PYGTK_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/pygtk/2.4/$(PYGTK).$(PYGTK_SUFFIX)

PYGTK_VERSION		= 2.5.3
PYGTK			= pygtk-$(PYGTK_VERSION)
PYGTK_SUFFIX		= tar.bz2
PYGTK_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/pygtk/2.5/$(PYGTK).$(PYGTK_SUFFIX)

PYGTK_SOURCE		= $(SRCDIR)/$(PYGTK).$(PYGTK_SUFFIX)
PYGTK_DIR		= $(BUILDDIR)/$(PYGTK)
PYGTK_IPKG_TMP		= $(PYGTK_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pygtk_get: $(STATEDIR)/pygtk.get

pygtk_get_deps = $(PYGTK_SOURCE)

$(STATEDIR)/pygtk.get: $(pygtk_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PYGTK))
	touch $@

$(PYGTK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PYGTK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pygtk_extract: $(STATEDIR)/pygtk.extract

pygtk_extract_deps = $(STATEDIR)/pygtk.get

$(STATEDIR)/pygtk.extract: $(pygtk_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PYGTK_DIR))
	@$(call extract, $(PYGTK_SOURCE))
	@$(call patchin, $(PYGTK))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pygtk_prepare: $(STATEDIR)/pygtk.prepare

#
# dependencies
#
pygtk_prepare_deps = \
	$(STATEDIR)/pygtk.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libglade.install \
	$(STATEDIR)/python.install \
	$(STATEDIR)/xchain-python.install \
	$(STATEDIR)/dbus.install \
	$(STATEDIR)/virtual-xchain.install

PYGTK_PATH	=  PATH=$(CROSS_PATH)
PYGTK_ENV 	=  $(CROSS_ENV)
PYGTK_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
PYGTK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#PYGTK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
PYGTK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
PYGTK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
PYGTK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/pygtk.prepare: $(pygtk_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PYGTK_DIR)/config.cache)
	#cd $(PYGTK_DIR) && $(PYGTK_PATH) aclocal
	#cd $(PYGTK_DIR) && $(PYGTK_PATH) automake --add-missing
	#cd $(PYGTK_DIR) && $(PYGTK_PATH) autoconf
	cd $(PYGTK_DIR) && \
		$(PYGTK_PATH) $(PYGTK_ENV) \
		./configure $(PYGTK_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(PYGTK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pygtk_compile: $(STATEDIR)/pygtk.compile

pygtk_compile_deps = $(STATEDIR)/pygtk.prepare

$(STATEDIR)/pygtk.compile: $(pygtk_compile_deps)
	@$(call targetinfo, $@)
	$(PYGTK_ENV) $(PYGTK_PATH) $(MAKE) -C $(PYGTK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pygtk_install: $(STATEDIR)/pygtk.install

$(STATEDIR)/pygtk.install: $(STATEDIR)/pygtk.compile
	@$(call targetinfo, $@)
	###$(PYGTK_ENV) $(PYGTK_PATH) $(MAKE) -C $(PYGTK_DIR) DESTDIR=$(PYGTK_IPKG_TMP) install
	###rm -rf $(PYGTK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pygtk_targetinstall: $(STATEDIR)/pygtk.targetinstall

pygtk_targetinstall_deps = $(STATEDIR)/pygtk.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libglade.targetinstall \
	$(STATEDIR)/dbus.targetinstall \
	$(STATEDIR)/python.targetinstall

$(STATEDIR)/pygtk.targetinstall: $(pygtk_targetinstall_deps)
	@$(call targetinfo, $@)
	$(PYGTK_ENV) $(PYGTK_PATH) $(MAKE) -C $(PYGTK_DIR) DESTDIR=$(PYGTK_IPKG_TMP) install
	perl -p -i -e "s/`echo $(PTXCONF_NATIVE_PREFIX) | sed -e '/\//s//\\\\\//g'`/\/usr/g" $(PYGTK_IPKG_TMP)/usr/bin/pygtk-codegen-2.0
	rm -rf $(PYGTK_IPKG_TMP)/usr/include
	rm -rf $(PYGTK_IPKG_TMP)/usr/lib/pkgconfig
	rm  -f $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/*.*a
	rm  -f $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/*.py
	rm  -f $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/*.pyo

	###rm  -f $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/gtk2/*.*a
	###rm  -f $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/gtk2/*.py
	###rm  -f $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/gtk2/*.pyo
	###$(CROSSSTRIP) $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/*.so
	###$(CROSSSTRIP) $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/gtk2/*.so

	rm  -f $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/gtk-2.0/*.*a
	rm  -f $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/gtk-2.0/*.py
	rm  -f $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/gtk-2.0/*.pyo
	rm  -f $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/gtk-2.0/gtk/*.*a
	rm  -f $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/gtk-2.0/gtk/*.py
	rm  -f $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/gtk-2.0/gtk/*.pyo
	$(CROSSSTRIP) $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/gtk-2.0/*.so
	$(CROSSSTRIP) $(PYGTK_IPKG_TMP)/usr/lib/python2.3/site-packages/gtk-2.0/gtk/*.so
	
	rm -rf $(PYGTK_IPKG_TMP)/usr/share
	rm  -f $(PYGTK_IPKG_TMP)/usr/bin/pygtk-codegen-2.0
	mkdir -p $(PYGTK_IPKG_TMP)/CONTROL
	echo "Package: pygtk" 				 >$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Section: ROX"	 			>>$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Version: $(PYGTK_VERSION)" 		>>$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, python-core, python-codecs, python-dbus, python-fcntl, python-stringold, python-xml, libglade" >>$(PYGTK_IPKG_TMP)/CONTROL/control
	echo "Description: Modules that allow you to use gtk in Python programs.">>$(PYGTK_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PYGTK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PYGTK_INSTALL
ROMPACKAGES += $(STATEDIR)/pygtk.imageinstall
endif

pygtk_imageinstall_deps = $(STATEDIR)/pygtk.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/pygtk.imageinstall: $(pygtk_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install pygtk
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pygtk_clean:
	rm -rf $(STATEDIR)/pygtk.*
	rm -rf $(PYGTK_DIR)

# vim: syntax=make
