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
ifdef PTXCONF_DBUS
PACKAGES += dbus
endif

#
# Paths and names
#
DBUS_VERSION		= 0.21
DBUS			= dbus-$(DBUS_VERSION)
DBUS_SUFFIX		= tar.gz
DBUS_URL		= http://freedesktop.org/Software/dbus/releases/$(DBUS).$(DBUS_SUFFIX)
DBUS_SOURCE		= $(SRCDIR)/$(DBUS).$(DBUS_SUFFIX)
DBUS_DIR		= $(BUILDDIR)/$(DBUS)
DBUS_IPKG_TMP		= $(DBUS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dbus_get: $(STATEDIR)/dbus.get

dbus_get_deps = $(DBUS_SOURCE)

$(STATEDIR)/dbus.get: $(dbus_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(DBUS))
	touch $@

$(DBUS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(DBUS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dbus_extract: $(STATEDIR)/dbus.extract

dbus_extract_deps = $(STATEDIR)/dbus.get

$(STATEDIR)/dbus.extract: $(dbus_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DBUS_DIR))
	@$(call extract, $(DBUS_SOURCE))
	@$(call patchin, $(DBUS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dbus_prepare: $(STATEDIR)/dbus.prepare

#
# dependencies
#
dbus_prepare_deps = \
	$(STATEDIR)/dbus.extract \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/python.install \
	$(STATEDIR)/xchain-Pyrex.install \
	$(STATEDIR)/virtual-xchain.install

DBUS_PATH	=  PATH=$(CROSS_PATH)
DBUS_ENV 	=  $(CROSS_ENV)
DBUS_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
DBUS_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
DBUS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#DBUS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
DBUS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared \
	--disable-debug \
	--with-xml=expat \
	--with-init-scripts=redhat \
	--localstatedir=/var \
	--sysconfdir=/etc \
	--enable-python \
	--disable-qt \
	--with-system-socket=/var/run/system_bus_socket \
	--with-system-pid-file=/var/run/messagebus.pid

ifdef PTXCONF_XFREE430
DBUS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
DBUS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/dbus.prepare: $(dbus_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DBUS_DIR)/config.cache)
	cd $(DBUS_DIR) && \
		$(DBUS_PATH) $(DBUS_ENV) \
		./configure $(DBUS_AUTOCONF) -C
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(DBUS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dbus_compile: $(STATEDIR)/dbus.compile

dbus_compile_deps = $(STATEDIR)/dbus.prepare

$(STATEDIR)/dbus.compile: $(dbus_compile_deps)
	@$(call targetinfo, $@)
	$(DBUS_PATH) $(MAKE) -C $(DBUS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dbus_install: $(STATEDIR)/dbus.install

$(STATEDIR)/dbus.install: $(STATEDIR)/dbus.compile
	@$(call targetinfo, $@)
	$(DBUS_PATH) $(MAKE) -C $(DBUS_DIR) DESTDIR=$(DBUS_IPKG_TMP) install
	cp -a  $(DBUS_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(DBUS_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libdbus-1.la
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libdbus-glib-1.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/dbus-1.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/dbus-glib-1.pc
	rm -rf $(DBUS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dbus_targetinstall: $(STATEDIR)/dbus.targetinstall

dbus_targetinstall_deps = $(STATEDIR)/dbus.compile \
	$(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/glib22.targetinstall \
	$(STATEDIR)/libxml2.targetinstall

$(STATEDIR)/dbus.targetinstall: $(dbus_targetinstall_deps)
	@$(call targetinfo, $@)
	$(DBUS_PATH) $(MAKE) -C $(DBUS_DIR) DESTDIR=$(DBUS_IPKG_TMP) install
	rm -rf $(DBUS_IPKG_TMP)/usr/include
	rm -rf $(DBUS_IPKG_TMP)/usr/lib/dbus-1.0/include
	rm -rf $(DBUS_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(DBUS_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(DBUS_IPKG_TMP)/usr/lib/python2.3/site-packages/*.*a
	rm -rf $(DBUS_IPKG_TMP)/usr/lib/python2.3/site-packages/*.py
	rm -rf $(DBUS_IPKG_TMP)/usr/lib/python2.3/site-packages/*.pyo
	rm -rf $(DBUS_IPKG_TMP)/usr/man
	rm -rf $(DBUS_IPKG_TMP)/var/run
	for FILE in `find $(DBUS_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done

	rm -rf $(DBUS_IPKG_TMP)-pyhton
	mkdir -p $(DBUS_IPKG_TMP)-pyhton/usr/lib
	mv $(DBUS_IPKG_TMP)/usr/lib/python2.3 $(DBUS_IPKG_TMP)-pyhton/usr/lib
	rm -rf $(DBUS_IPKG_TMP)/usr/lib/python2.3
	mkdir -p $(DBUS_IPKG_TMP)-pyhton/CONTROL
	echo "Package: python-dbus" 			 >$(DBUS_IPKG_TMP)-pyhton/CONTROL/control
	echo "Priority: optional" 			>>$(DBUS_IPKG_TMP)-pyhton/CONTROL/control
	echo "Section: ROX"	 			>>$(DBUS_IPKG_TMP)-pyhton/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(DBUS_IPKG_TMP)-pyhton/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(DBUS_IPKG_TMP)-pyhton/CONTROL/control
	echo "Version: $(DBUS_VERSION)" 		>>$(DBUS_IPKG_TMP)-pyhton/CONTROL/control
	echo "Depends: python-core, dbus" 		>>$(DBUS_IPKG_TMP)-pyhton/CONTROL/control
	echo "Description: D-BUS python binding."	>>$(DBUS_IPKG_TMP)-pyhton/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(DBUS_IPKG_TMP)-pyhton
	
	mkdir -p $(DBUS_IPKG_TMP)/CONTROL
	echo "Package: dbus" 				>$(DBUS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(DBUS_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(DBUS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(DBUS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(DBUS_IPKG_TMP)/CONTROL/control
	echo "Version: $(DBUS_VERSION)" 		>>$(DBUS_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430, glib2, libxml2" 	>>$(DBUS_IPKG_TMP)/CONTROL/control
	echo "Description: D-BUS is a simple IPC library based on messages.">>$(DBUS_IPKG_TMP)/CONTROL/control
	$(INSTALL) -d $(DBUS_IPKG_TMP)/etc/rc.d/rc3.d
	$(INSTALL) -d $(DBUS_IPKG_TMP)/etc/rc.d/rc4.d
	$(INSTALL) -d $(DBUS_IPKG_TMP)/etc/rc.d/rc5.d
	ln -sf ../init.d/messagebus $(DBUS_IPKG_TMP)/etc/rc.d/rc5.d/S60messagebus
	ln -sf ../init.d/messagebus $(DBUS_IPKG_TMP)/etc/rc.d/rc4.d/S60messagebus
	ln -sf ../init.d/messagebus $(DBUS_IPKG_TMP)/etc/rc.d/rc3.d/S60messagebus
	cd $(FEEDDIR) && $(XMKIPKG) $(DBUS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_DBUS_INSTALL
ROMPACKAGES += $(STATEDIR)/dbus.imageinstall
endif

dbus_imageinstall_deps = $(STATEDIR)/dbus.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/dbus.imageinstall: $(dbus_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install dbus
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dbus_clean:
	rm -rf $(STATEDIR)/dbus.*
	rm -rf $(DBUS_DIR)

# vim: syntax=make
