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
ifdef PTXCONF_GNUMERIC
PACKAGES += gnumeric
endif

#
# Paths and names
#
GNUMERIC_VERSION	= 1.2.13
#GNUMERIC_VERSION	= 1.4.2
GNUMERIC		= gnumeric-$(GNUMERIC_VERSION)
GNUMERIC_SUFFIX		= tar.bz2
GNUMERIC_URL		= http://ftp.acc.umu.se/pub/GNOME/sources/gnumeric/1.2/$(GNUMERIC).$(GNUMERIC_SUFFIX)
GNUMERIC_SOURCE		= $(SRCDIR)/$(GNUMERIC).$(GNUMERIC_SUFFIX)
GNUMERIC_DIR		= $(BUILDDIR)/$(GNUMERIC)
GNUMERIC_IPKG_TMP	= $(GNUMERIC_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gnumeric_get: $(STATEDIR)/gnumeric.get

gnumeric_get_deps = $(GNUMERIC_SOURCE)

$(STATEDIR)/gnumeric.get: $(gnumeric_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GNUMERIC))
	touch $@

$(GNUMERIC_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GNUMERIC_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gnumeric_extract: $(STATEDIR)/gnumeric.extract

gnumeric_extract_deps = $(STATEDIR)/gnumeric.get

$(STATEDIR)/gnumeric.extract: $(gnumeric_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNUMERIC_DIR))
	@$(call extract, $(GNUMERIC_SOURCE))
	@$(call patchin, $(GNUMERIC))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gnumeric_prepare: $(STATEDIR)/gnumeric.prepare

#
# dependencies
#
gnumeric_prepare_deps = \
	$(STATEDIR)/gnumeric.extract \
	$(STATEDIR)/libxml2.install \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/atk124.install \
	$(STATEDIR)/pango12.install \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libglade.install \
	$(STATEDIR)/libgsf.install \
	$(STATEDIR)/libgnome.install \
	$(STATEDIR)/libgnomeui.install \
	$(STATEDIR)/libgnomeprint.install \
	$(STATEDIR)/libgnomeprintui.install \
	$(STATEDIR)/virtual-xchain.install

#	$(STATEDIR)/libbonobo.install \
#	$(STATEDIR)/libbonoboui.install \

GNUMERIC_PATH	=  PATH=$(CROSS_PATH)
GNUMERIC_ENV 	=  $(CROSS_ENV)
GNUMERIC_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
GNUMERIC_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GNUMERIC_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GNUMERIC_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug \
	--disable-ssconvert

#	--without-gnome

ifndef PTXCONF_GNUMERIC_BONOBO
GNUMERIC_AUTOCONF += --without-bonobo
endif

ifdef PTXCONF_XFREE430
GNUMERIC_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GNUMERIC_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gnumeric.prepare: $(gnumeric_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNUMERIC_DIR)/config.cache)
	cd $(GNUMERIC_DIR) && \
		$(GNUMERIC_PATH) $(GNUMERIC_ENV) \
		./configure $(GNUMERIC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gnumeric_compile: $(STATEDIR)/gnumeric.compile

gnumeric_compile_deps = $(STATEDIR)/gnumeric.prepare

$(STATEDIR)/gnumeric.compile: $(gnumeric_compile_deps)
	@$(call targetinfo, $@)
	$(GNUMERIC_PATH) $(MAKE) -C $(GNUMERIC_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gnumeric_install: $(STATEDIR)/gnumeric.install

$(STATEDIR)/gnumeric.install: $(STATEDIR)/gnumeric.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gnumeric_targetinstall: $(STATEDIR)/gnumeric.targetinstall

gnumeric_targetinstall_deps = \
	$(STATEDIR)/gnumeric.compile \
	$(STATEDIR)/libglade.targetinstall \
	$(STATEDIR)/libgsf.targetinstall \
	$(STATEDIR)/libgnome.targetinstall \
	$(STATEDIR)/libgnomeui.targetinstall \
	$(STATEDIR)/libgnomeprint.targetinstall \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libgnomeprintui.targetinstall

#	$(STATEDIR)/libbonobo.targetinstall \
#	$(STATEDIR)/libbonoboui.targetinstall \

$(STATEDIR)/gnumeric.targetinstall: $(gnumeric_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GNUMERIC_PATH) $(MAKE) -C $(GNUMERIC_DIR) DESTDIR=$(GNUMERIC_IPKG_TMP) install
	rm -rf $(GNUMERIC_IPKG_TMP)/usr/man
	rm -rf $(GNUMERIC_IPKG_TMP)/usr/share/locale
	rm -rf $(GNUMERIC_IPKG_TMP)/usr/share/gnome/help
ifndef PTXCONF_GNUMERIC_BONOBO
	rm -rf $(GNUMERIC_IPKG_TMP)/usr/bin/ssconvert
	rm -rf $(GNUMERIC_IPKG_TMP)/usr/share/gnumeric/$(GNUMERIC_VERSION)/share/gnome/help
	for FILE in `find $(GNUMERIC_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	##for FILE in `find $(GNUMERIC_IPKG_TMP)/usr/lib/gnumeric/$(GNUMERIC_VERSION)/plugins -type f | grep '\.la'`; do \
	##    rm -f $$FILE;						\
	##done
else
	rm -rf $(GNUMERIC_IPKG_TMP)/usr/bin/ssconvert
	rm -rf $(GNUMERIC_IPKG_TMP)/usr/bin/gnumeric-component
	rm -rf $(GNUMERIC_IPKG_TMP)/usr/share/gnumeric/$(GNUMERIC_VERSION)-bonobo/share/gnome/help
	for FILE in `find $(GNUMERIC_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	##for FILE in `find $(GNUMERIC_IPKG_TMP)/usr/lib/gnumeric/$(GNUMERIC_VERSION)-bonobo/plugins -type f | grep '\.la'`; do \
	##    rm -f $$FILE;						\
	##done
endif
	perl -p -i -e "s/gnumeric \%F/gnumeric/g" $(GNUMERIC_IPKG_TMP)/usr/share/applications/gnumeric.desktop
	mkdir -p $(GNUMERIC_IPKG_TMP)/CONTROL
	echo "Package: gnumeric" 			>$(GNUMERIC_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(GNUMERIC_IPKG_TMP)/CONTROL/control
	echo "Section: Office"	 			>>$(GNUMERIC_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(GNUMERIC_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(GNUMERIC_IPKG_TMP)/CONTROL/control
	echo "Version: $(GNUMERIC_VERSION)" 		>>$(GNUMERIC_IPKG_TMP)/CONTROL/control
	###echo "Depends: gtk2, libglade, libgsf, libgnomeprint, libgnomeprintui" >>$(GNUMERIC_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, libglade, libgsf, libgnome, libgnomeui, libgnomeprint, libgnomeprintui" >>$(GNUMERIC_IPKG_TMP)/CONTROL/control
	echo "Description: The Gnumeric spreadsheet is a versatile application developed as part of the GNOME Office project.">>$(GNUMERIC_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GNUMERIC_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GNUMERIC_INSTALL
ROMPACKAGES += $(STATEDIR)/gnumeric.imageinstall
endif

gnumeric_imageinstall_deps = $(STATEDIR)/gnumeric.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gnumeric.imageinstall: $(gnumeric_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gnumeric
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gnumeric_clean:
	rm -rf $(STATEDIR)/gnumeric.*
	rm -rf $(GNUMERIC_DIR)

# vim: syntax=make
