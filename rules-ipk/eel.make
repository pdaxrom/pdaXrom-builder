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
ifdef PTXCONF_EEL
PACKAGES += eel
endif

#
# Paths and names
#
EEL_VERSION	= 2.6.1
EEL		= eel-$(EEL_VERSION)
EEL_SUFFIX	= tar.bz2
EEL_URL		= ftp://ftp.acc.umu.se/pub/GNOME/sources/eel/2.6/$(EEL).$(EEL_SUFFIX)
EEL_SOURCE	= $(SRCDIR)/$(EEL).$(EEL_SUFFIX)
EEL_DIR		= $(BUILDDIR)/$(EEL)
EEL_IPKG_TMP	= $(EEL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

eel_get: $(STATEDIR)/eel.get

eel_get_deps = $(EEL_SOURCE)

$(STATEDIR)/eel.get: $(eel_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(EEL))
	touch $@

$(EEL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(EEL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

eel_extract: $(STATEDIR)/eel.extract

eel_extract_deps = $(STATEDIR)/eel.get

$(STATEDIR)/eel.extract: $(eel_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EEL_DIR))
	@$(call extract, $(EEL_SOURCE))
	@$(call patchin, $(EEL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

eel_prepare: $(STATEDIR)/eel.prepare

#
# dependencies
#
eel_prepare_deps = \
	$(STATEDIR)/eel.extract \
	$(STATEDIR)/GConf.install \
	$(STATEDIR)/gnome-vfs.install \
	$(STATEDIR)/libart_lgpl.install \
	$(STATEDIR)/libgnome.install \
	$(STATEDIR)/libgnomeui.install \
	$(STATEDIR)/libglade.install \
	$(STATEDIR)/gail.install \
	$(STATEDIR)/virtual-xchain.install

EEL_PATH	=  PATH=$(CROSS_PATH)
EEL_ENV 	=  $(CROSS_ENV)
EEL_ENV		+= CFLAGS="-O2 -fomit-frame-pointer"
EEL_ENV		+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#EEL_ENV		+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
EEL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
EEL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
EEL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/eel.prepare: $(eel_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EEL_DIR)/config.cache)
	cd $(EEL_DIR) && \
		$(EEL_PATH) $(EEL_ENV) \
		./configure $(EEL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

eel_compile: $(STATEDIR)/eel.compile

eel_compile_deps = $(STATEDIR)/eel.prepare

$(STATEDIR)/eel.compile: $(eel_compile_deps)
	@$(call targetinfo, $@)
	$(EEL_PATH) $(MAKE) -C $(EEL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

eel_install: $(STATEDIR)/eel.install

$(STATEDIR)/eel.install: $(STATEDIR)/eel.compile
	@$(call targetinfo, $@)
	$(EEL_PATH) $(MAKE) -C $(EEL_DIR) DESTDIR=$(EEL_IPKG_TMP) install
	cp -a  $(EEL_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(EEL_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libeel-2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/eel-2.0.pc
	rm -rf $(EEL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

eel_targetinstall: $(STATEDIR)/eel.targetinstall

eel_targetinstall_deps = \
	$(STATEDIR)/eel.compile \
	$(STATEDIR)/GConf.targetinstall \
	$(STATEDIR)/gnome-vfs.targetinstall \
	$(STATEDIR)/libart_lgpl.targetinstall \
	$(STATEDIR)/libgnome.targetinstall \
	$(STATEDIR)/libgnomeui.targetinstall \
	$(STATEDIR)/libglade.targetinstall \
	$(STATEDIR)/gail.targetinstall

$(STATEDIR)/eel.targetinstall: $(eel_targetinstall_deps)
	@$(call targetinfo, $@)
	$(EEL_PATH) $(MAKE) -C $(EEL_DIR) DESTDIR=$(EEL_IPKG_TMP) install
	rm -rf $(EEL_IPKG_TMP)/usr/include
	rm -rf $(EEL_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(EEL_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(EEL_IPKG_TMP)/usr/share
	for FILE in `find $(EEL_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(EEL_IPKG_TMP)/CONTROL
	echo "Package: eel" 				 >$(EEL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(EEL_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(EEL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(EEL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(EEL_IPKG_TMP)/CONTROL/control
	echo "Version: $(EEL_VERSION)" 			>>$(EEL_IPKG_TMP)/CONTROL/control
	echo "Depends: gconf, gnome-vfs, libart-lgpl, libgnome, libgnomeui, libglade">>$(EEL_IPKG_TMP)/CONTROL/control
	echo "Description: Eazel Extensions Library">>$(EEL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(EEL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

eel_clean:
	rm -rf $(STATEDIR)/eel.*
	rm -rf $(EEL_DIR)

# vim: syntax=make
