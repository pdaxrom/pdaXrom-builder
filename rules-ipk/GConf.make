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
ifdef PTXCONF_GCONF
PACKAGES += GConf
endif

#
# Paths and names
#
GCONF_VERSION_VENDOR	= -1
GCONF_VERSION		= 2.4.0.1
###GCONF_VERSION		= 2.6.1
GCONF			= GConf-$(GCONF_VERSION)
GCONF_SUFFIX		= tar.bz2
GCONF_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/GConf/2.4/$(GCONF).$(GCONF_SUFFIX)
GCONF_SOURCE		= $(SRCDIR)/$(GCONF).$(GCONF_SUFFIX)
GCONF_DIR		= $(BUILDDIR)/$(GCONF)
GCONF_IPKG_TMP		= $(GCONF_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

GConf_get: $(STATEDIR)/GConf.get

GConf_get_deps = $(GCONF_SOURCE)

$(STATEDIR)/GConf.get: $(GConf_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GCONF))
	touch $@

$(GCONF_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GCONF_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

GConf_extract: $(STATEDIR)/GConf.extract

GConf_extract_deps = $(STATEDIR)/GConf.get

$(STATEDIR)/GConf.extract: $(GConf_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GCONF_DIR))
	@$(call extract, $(GCONF_SOURCE))
	@$(call patchin, $(GCONF))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

GConf_prepare: $(STATEDIR)/GConf.prepare

#
# dependencies
#
GConf_prepare_deps = \
	$(STATEDIR)/GConf.extract \
	$(STATEDIR)/ORBit2.install \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

###	$(STATEDIR)/xchain-GConf.install

GCONF_PATH	=  PATH=$(CROSS_PATH)
GCONF_ENV 	=  $(CROSS_ENV)
GCONF_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
GCONF_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GCONF_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GCONF_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
GCONF_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GCONF_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/GConf.prepare: $(GConf_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GCONF_DIR)/config.cache)
	cd $(GCONF_DIR) && \
		$(GCONF_PATH) $(GCONF_ENV) \
		./configure $(GCONF_AUTOCONF)
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(GCONF_DIR)/
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

GConf_compile: $(STATEDIR)/GConf.compile

GConf_compile_deps = $(STATEDIR)/GConf.prepare

$(STATEDIR)/GConf.compile: $(GConf_compile_deps)
	@$(call targetinfo, $@)
	$(GCONF_PATH) $(MAKE) -C $(GCONF_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

GConf_install: $(STATEDIR)/GConf.install

$(STATEDIR)/GConf.install: $(STATEDIR)/GConf.compile
	@$(call targetinfo, $@)
	$(GCONF_PATH) $(MAKE) -C $(GCONF_DIR) DESTDIR=$(GCONF_IPKG_TMP) install
	cp -a  $(GCONF_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(GCONF_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgconf-2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gconf-2.0.pc
	rm -rf $(GCONF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

GConf_targetinstall: $(STATEDIR)/GConf.targetinstall

GConf_targetinstall_deps = \
	$(STATEDIR)/ORBit2.targetinstall \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/GConf.compile

$(STATEDIR)/GConf.targetinstall: $(GConf_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GCONF_PATH) $(MAKE) -C $(GCONF_DIR) DESTDIR=$(GCONF_IPKG_TMP) install
	rm -rf $(GCONF_IPKG_TMP)/usr/include
	rm -rf $(GCONF_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(GCONF_IPKG_TMP)/usr/lib/GConf/2/*.a
	###rm -rf $(GCONF_IPKG_TMP)/usr/lib/GConf/2/*.la
	rm -rf $(GCONF_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(GCONF_IPKG_TMP)/usr/share/aclocal
	rm -rf $(GCONF_IPKG_TMP)/usr/share/gtk-doc
	rm -rf $(GCONF_IPKG_TMP)/usr/share/locale
	for FILE in `find $(GCONF_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(GCONF_IPKG_TMP)/CONTROL
	echo "Package: gconf" 									>$(GCONF_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 								>>$(GCONF_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome" 									>>$(GCONF_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 					>>$(GCONF_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 							>>$(GCONF_IPKG_TMP)/CONTROL/control
	echo "Version: $(GCONF_VERSION)$(GCONF_VERSION_VENDOR)" 				>>$(GCONF_IPKG_TMP)/CONTROL/control
	echo "Depends: orbit2, gtk2" 								>>$(GCONF_IPKG_TMP)/CONTROL/control
	echo "Description: GConf is a configuration database system, functionally similar to the Windows registry but lots better (sashz - i doubt...).">>$(GCONF_IPKG_TMP)/CONTROL/control

	echo "#!/bin/sh"				 >$(GCONF_IPKG_TMP)/CONTROL/postinst
	echo "if [ \$$DISPLAY ]; then"			>>$(GCONF_IPKG_TMP)/CONTROL/postinst
	echo " /usr/bin/gconfd-2 15 &"			>>$(GCONF_IPKG_TMP)/CONTROL/postinst
	echo "fi"					>>$(GCONF_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(GCONF_IPKG_TMP)/CONTROL/postinst

	cd $(FEEDDIR) && $(XMKIPKG) $(GCONF_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

GConf_clean:
	rm -rf $(STATEDIR)/GConf.*
	rm -rf $(GCONF_DIR)

# vim: syntax=make
