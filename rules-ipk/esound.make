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
ifdef PTXCONF_ESOUND
PACKAGES += esound
endif

#
# Paths and names
#
ESOUND_VERSION		= 0.2.34
ESOUND			= esound-$(ESOUND_VERSION)
ESOUND_SUFFIX		= tar.bz2
ESOUND_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/esound/0.2/$(ESOUND).$(ESOUND_SUFFIX)
ESOUND_SOURCE		= $(SRCDIR)/$(ESOUND).$(ESOUND_SUFFIX)
ESOUND_DIR		= $(BUILDDIR)/$(ESOUND)
ESOUND_IPKG_TMP		= $(ESOUND_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

esound_get: $(STATEDIR)/esound.get

esound_get_deps = $(ESOUND_SOURCE)

$(STATEDIR)/esound.get: $(esound_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ESOUND))
	touch $@

$(ESOUND_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ESOUND_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

esound_extract: $(STATEDIR)/esound.extract

esound_extract_deps = $(STATEDIR)/esound.get

$(STATEDIR)/esound.extract: $(esound_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ESOUND_DIR))
	@$(call extract, $(ESOUND_SOURCE))
	@$(call patchin, $(ESOUND))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

esound_prepare: $(STATEDIR)/esound.prepare

#
# dependencies
#
esound_prepare_deps = \
	$(STATEDIR)/esound.extract \
	$(STATEDIR)/audiofile.install \
	$(STATEDIR)/virtual-xchain.install

ESOUND_PATH	=  PATH=$(CROSS_PATH)
ESOUND_ENV 	=  $(CROSS_ENV)
ESOUND_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS) -DPTYS_ARE_GETPT -DPTYS_ARE_SEARCHED"
ESOUND_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ESOUND_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ESOUND_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--disable-debug \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin

ifdef PTXCONF_XFREE430
ESOUND_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ESOUND_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/esound.prepare: $(esound_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ESOUND_DIR)/config.cache)
	cd $(ESOUND_DIR) && \
		$(ESOUND_PATH) $(ESOUND_ENV) \
		./configure $(ESOUND_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

esound_compile: $(STATEDIR)/esound.compile

esound_compile_deps = $(STATEDIR)/esound.prepare

$(STATEDIR)/esound.compile: $(esound_compile_deps)
	@$(call targetinfo, $@)
	$(ESOUND_PATH) $(MAKE) -C $(ESOUND_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

esound_install: $(STATEDIR)/esound.install

$(STATEDIR)/esound.install: $(STATEDIR)/esound.compile
	@$(call targetinfo, $@)
	$(ESOUND_PATH) $(MAKE) -C $(ESOUND_DIR) DESTDIR=$(ESOUND_IPKG_TMP) install
	cp -a  $(ESOUND_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(ESOUND_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	cp -a  $(ESOUND_IPKG_TMP)/usr/bin/esd-config     $(PTXCONF_PREFIX)/bin
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/esd-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libesd.la
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libesddsp.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/esound.pc
	rm -rf $(ESOUND_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

esound_targetinstall: $(STATEDIR)/esound.targetinstall

esound_targetinstall_deps = \
	$(STATEDIR)/audiofile.targetinstall \
	$(STATEDIR)/esound.compile

$(STATEDIR)/esound.targetinstall: $(esound_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ESOUND_PATH) $(MAKE) -C $(ESOUND_DIR) DESTDIR=$(ESOUND_IPKG_TMP) install
	rm -rf $(ESOUND_IPKG_TMP)/usr/bin/esd-config
	rm -rf $(ESOUND_IPKG_TMP)/usr/include
	rm -rf $(ESOUND_IPKG_TMP)/usr/lib/pkgconfig
	rm  -f $(ESOUND_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(ESOUND_IPKG_TMP)/usr/man
	rm -rf $(ESOUND_IPKG_TMP)/usr/share
	ln -sf esdplay $(ESOUND_IPKG_TMP)/usr/bin/play
	#perl -p -i -e "s/\-terminate//g" $(ESOUND_IPKG_TMP)/etc/esd.conf
	perl -p -i -e "s/\=100/\=1000/g" $(ESOUND_IPKG_TMP)/etc/esd.conf
	for FILE in `find $(ESOUND_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(ESOUND_IPKG_TMP)/CONTROL
	echo "Package: esound" 				>$(ESOUND_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(ESOUND_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 			>>$(ESOUND_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(ESOUND_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(ESOUND_IPKG_TMP)/CONTROL/control
	echo "Version: $(ESOUND_VERSION)" 		>>$(ESOUND_IPKG_TMP)/CONTROL/control
	echo "Depends: audiofile" 			>>$(ESOUND_IPKG_TMP)/CONTROL/control
	echo "Description: Enlightened Sound Daemon">>$(ESOUND_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ESOUND_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ESOUND_INSTALL
ROMPACKAGES += $(STATEDIR)/esound.imageinstall
endif

esound_imageinstall_deps = $(STATEDIR)/esound.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/esound.imageinstall: $(esound_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install esound
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

esound_clean:
	rm -rf $(STATEDIR)/esound.*
	rm -rf $(ESOUND_DIR)

# vim: syntax=make
