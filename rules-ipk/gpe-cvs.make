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
ifdef PTXCONF_GPE-CVS
PACKAGES += gpe-cvs
endif

#
# Paths and names
#
GPE-CVS_VENDOR_VERSION	= 1
GPE-CVS_VERSION		= 20050207
GPE-CVS			= gpe-cvs-$(GPE-CVS_VERSION)
GPE-CVS_SUFFIX		= tar.bz2
GPE-CVS_URL		= http://www.pdaXrom.org/src/$(GPE-CVS).$(GPE-CVS_SUFFIX)
GPE-CVS_SOURCE		= $(SRCDIR)/$(GPE-CVS).$(GPE-CVS_SUFFIX)
GPE-CVS_DIR		= $(BUILDDIR)/gpe
GPE-CVS_IPKG_TMP	= $(GPE-CVS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gpe-cvs_get: $(STATEDIR)/gpe-cvs.get

gpe-cvs_get_deps = $(GPE-CVS_SOURCE)

$(STATEDIR)/gpe-cvs.get: $(gpe-cvs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GPE-CVS))
	touch $@

$(GPE-CVS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GPE-CVS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gpe-cvs_extract: $(STATEDIR)/gpe-cvs.extract

gpe-cvs_extract_deps = $(STATEDIR)/gpe-cvs.get

$(STATEDIR)/gpe-cvs.extract: $(gpe-cvs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(GPE-CVS_DIR))
	@$(call extract, $(GPE-CVS_SOURCE))
	@$(call patchin, $(GPE-CVS), $(GPE-CVS_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gpe-cvs_prepare: $(STATEDIR)/gpe-cvs.prepare

#
# dependencies
#
gpe-cvs_prepare_deps = \
	$(STATEDIR)/gpe-cvs.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libgcrypt.install \
	$(STATEDIR)/sqlite.install \
	$(STATEDIR)/Xsettings-client.install \
	$(STATEDIR)/xchain-intltool.install \
	$(STATEDIR)/virtual-xchain.install

GPE-CVS_PATH	=  PATH=$(GPE-CVS_DIR)/base/bin-x:$(CROSS_PATH)
GPE-CVS_ENV 	=  $(CROSS_ENV)
GPE-CVS_ENV	+= HOSTCC=gcc
GPE-CVS_ENV	+= HOSTCFLAGS="-Wall -Wstrict-prototypes -O2 -fomit-frame-pointer"
GPE-CVS_ENV	+= PREFIX=/usr
GPE-CVS_ENV	+= NATIVE=no
GPE-CVS_ENV	+= IPAQ=0
GPE-CVS_ENV	+= CROSS_COMPILE=$(PTXCONF_ARCH)-linux-
GPE-CVS_ENV	+= TARGET=$(PTXCONF_ARCH)-linux-
GPE-CVS_ENV	+= HOSTARCH=$(PTXCONF_ARCH)-linux-
GPE-CVS_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
GPE-CVS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
GPE-CVS_ENV	+= CPP="$(PTXCONF_GNU_TARGET)-gcc -E"
GPE-CVS_ENV	+= PERL=perl

#
# autoconf
#
GPE-CVS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
GPE-CVS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GPE-CVS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gpe-cvs.prepare: $(gpe-cvs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GPE-CVS_DIR)/config.cache)
	mkdir -p $(GPE-CVS_DIR)/base/bin-x
	#cd $(GPE-CVS_DIR) && \
	#	$(GPE-CVS_PATH) $(GPE-CVS_ENV) \
	#	./configure $(GPE-CVS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gpe-cvs_compile: $(STATEDIR)/gpe-cvs.compile

gpe-cvs_compile_deps = $(STATEDIR)/gpe-cvs.prepare

$(STATEDIR)/gpe-cvs.compile: $(gpe-cvs_compile_deps)
	@$(call targetinfo, $@)
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/libgpewidget
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/libdisplaymigration
ifdef PTXCONF_GPE-WORD
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/gpe-word
endif
ifdef PTXCONF_GPE-EDIT
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/gpe-edit
endif
ifdef PTXCONF_GPE-GALLERY
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/gpe-gallery
endif
ifdef PTXCONF_GPE-CALCULATOR
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/gpe-calculator
endif
ifdef PTXCONF_GPE-CONF
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/gpe-conf
endif
ifdef PTXCONF_GPE-CLOCK
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/gpe-clock
endif
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gpe-cvs_install: $(STATEDIR)/gpe-cvs.install

$(STATEDIR)/gpe-cvs.install: $(STATEDIR)/gpe-cvs.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gpe-cvs_targetinstall: $(STATEDIR)/gpe-cvs.targetinstall

gpe-cvs_targetinstall_deps = $(STATEDIR)/gpe-cvs.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libgcrypt.targetinstall \
	$(STATEDIR)/Xsettings-client.targetinstall \
	$(STATEDIR)/sqlite.targetinstall

$(STATEDIR)/gpe-cvs.targetinstall: $(gpe-cvs_targetinstall_deps)
	@$(call targetinfo, $@)

	rm -rf $(GPE-CVS_IPKG_TMP)
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/gpe-icons DESTDIR=$(GPE-CVS_IPKG_TMP) install
	mkdir -p $(GPE-CVS_IPKG_TMP)/CONTROL
	echo "Package: gpe-icons" 							 >$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Section: GPE"	 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPE-CVS_VERSION)-$(GPE-CVS_VENDOR_VERSION)" 			>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Description: Common icons used by GPE programs"				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GPE-CVS_IPKG_TMP)

	rm -rf $(GPE-CVS_IPKG_TMP)
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/libgpewidget DESTDIR=$(GPE-CVS_IPKG_TMP) install
	$(CROSSSTRIP) $(GPE-CVS_IPKG_TMP)/usr/lib/*.so*
	rm -rf $(GPE-CVS_IPKG_TMP)/usr/share/locale
	mkdir -p $(GPE-CVS_IPKG_TMP)/CONTROL
	echo "Package: libgpewidget" 							 >$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Section: GPE"	 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPE-CVS_VERSION)-$(GPE-CVS_VENDOR_VERSION)" 			>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, gpe-icons" 						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Description: GPE Widget Library"						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GPE-CVS_IPKG_TMP)
	
	rm -rf $(GPE-CVS_IPKG_TMP)
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/libdisplaymigration DESTDIR=$(GPE-CVS_IPKG_TMP) install
	$(CROSSSTRIP) $(GPE-CVS_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(GPE-CVS_IPKG_TMP)/CONTROL
	echo "Package: libdisplaymigration" 						 >$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Section: GPE"	 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPE-CVS_VERSION)-$(GPE-CVS_VENDOR_VERSION)" 			>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, libgcrypt" 						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Description: Display migration support for GTK"				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GPE-CVS_IPKG_TMP)

ifdef PTXCONF_GPE-EDIT
	rm -rf $(GPE-CVS_IPKG_TMP)
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/gpe-edit DESTDIR=$(GPE-CVS_IPKG_TMP) install
	$(CROSSSTRIP) $(GPE-CVS_IPKG_TMP)/usr/bin/*
	rm -rf $(GPE-CVS_IPKG_TMP)/etc/mime-handlers
	rm -rf $(GPE-CVS_IPKG_TMP)/usr/share/application-registry
	rm -rf $(GPE-CVS_IPKG_TMP)/usr/share/locale
	mkdir -p $(GPE-CVS_IPKG_TMP)/CONTROL
	echo "Package: gpe-edit" 							 >$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Section: GPE"	 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPE-CVS_VERSION)-$(GPE-CVS_VENDOR_VERSION)" 			>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Depends: libgpewidget, libdisplaymigration" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Description: GPE Text Editor"						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GPE-CVS_IPKG_TMP)
endif

ifdef PTXCONF_GPE-WORD
	rm -rf $(GPE-CVS_IPKG_TMP)
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/gpe-word DESTDIR=$(GPE-CVS_IPKG_TMP) install
	$(CROSSSTRIP) $(GPE-CVS_IPKG_TMP)/usr/bin/*
	rm -rf $(GPE-CVS_IPKG_TMP)/usr/share/locale
	mkdir -p $(GPE-CVS_IPKG_TMP)/CONTROL
	echo "Package: gpe-word" 							 >$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Section: GPE"	 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPE-CVS_VERSION)-$(GPE-CVS_VENDOR_VERSION)" 			>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Depends: libgpewidget, libdisplaymigration" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Description: GPE Word Processor"						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GPE-CVS_IPKG_TMP)
endif

ifdef PTXCONF_GPE-GALLERY
	rm -rf $(GPE-CVS_IPKG_TMP)
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/gpe-gallery DESTDIR=$(GPE-CVS_IPKG_TMP) install
	$(CROSSSTRIP) $(GPE-CVS_IPKG_TMP)/usr/bin/*
	rm -rf $(GPE-CVS_IPKG_TMP)/usr/share/application-registry
	rm -rf $(GPE-CVS_IPKG_TMP)/usr/share/locale
	mkdir -p $(GPE-CVS_IPKG_TMP)/CONTROL
	echo "Package: gpe-gallery" 							 >$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Section: GPE"	 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPE-CVS_VERSION)-$(GPE-CVS_VENDOR_VERSION)" 			>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Depends: libgpewidget, libdisplaymigration" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Description: GPE Image Gallery"						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GPE-CVS_IPKG_TMP)
endif

ifdef PTXCONF_GPE-CALCULATOR
	rm -rf $(GPE-CVS_IPKG_TMP)
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/gpe-calculator DESTDIR=$(GPE-CVS_IPKG_TMP) install
	$(CROSSSTRIP) $(GPE-CVS_IPKG_TMP)/usr/bin/*
	rm -rf $(GPE-CVS_IPKG_TMP)/usr/share/application-registry
	rm -rf $(GPE-CVS_IPKG_TMP)/usr/share/locale
	mkdir -p $(GPE-CVS_IPKG_TMP)/CONTROL
	echo "Package: gpe-calculator" 							 >$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Section: GPE"	 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPE-CVS_VERSION)-$(GPE-CVS_VENDOR_VERSION)" 			>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Depends: libgpewidget, libdisplaymigration" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Description: GPE Calculator"						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GPE-CVS_IPKG_TMP)
endif

ifdef PTXCONF_GPE-CONF
	rm -rf $(GPE-CVS_IPKG_TMP)
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/gpe-conf DESTDIR=$(GPE-CVS_IPKG_TMP) install
	$(CROSSSTRIP) $(GPE-CVS_IPKG_TMP)/usr/bin/*
	rm -rf $(GPE-CVS_IPKG_TMP)/usr/share/application-registry
	rm -rf $(GPE-CVS_IPKG_TMP)/usr/share/locale
	rm  -f $(GPE-CVS_IPKG_TMP)/usr/share/applications/gpe-conf.desktop
	mkdir -p $(GPE-CVS_IPKG_TMP)/CONTROL
	echo "Package: gpe-conf" 							 >$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Section: GPE"	 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPE-CVS_VERSION)-$(GPE-CVS_VENDOR_VERSION)" 			>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Depends: libgpewidget, x11settings-client" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Description: GPE System settings"						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GPE-CVS_IPKG_TMP)
endif

ifdef PTXCONF_GPE-CLOCK
	rm -rf $(GPE-CVS_IPKG_TMP)
	$(GPE-CVS_PATH) $(GPE-CVS_ENV) $(MAKE) -C $(GPE-CVS_DIR)/base/gpe-conf DESTDIR=$(GPE-CVS_IPKG_TMP) install
	$(CROSSSTRIP) $(GPE-CVS_IPKG_TMP)/usr/bin/*
	rm -rf $(GPE-CVS_IPKG_TMP)/usr/share/application-registry
	rm -rf $(GPE-CVS_IPKG_TMP)/usr/share/locale
	rm  -f $(GPE-CVS_IPKG_TMP)/usr/share/applications/gpe-conf.desktop
	mkdir -p $(GPE-CVS_IPKG_TMP)/CONTROL
	echo "Package: gpe-clock" 							 >$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Section: GPE"	 							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Version: $(GPE-CVS_VERSION)-$(GPE-CVS_VENDOR_VERSION)" 			>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Depends: libgpewidget"			 				>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	echo "Description: GPE Clock"							>>$(GPE-CVS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GPE-CVS_IPKG_TMP)
endif
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GPE-CVS_INSTALL
ROMPACKAGES += $(STATEDIR)/gpe-cvs.imageinstall
endif

gpe-cvs_imageinstall_deps = $(STATEDIR)/gpe-cvs.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gpe-cvs.imageinstall: $(gpe-cvs_imageinstall_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_GPE-EDIT_INSTALL
	cd $(FEEDDIR) && $(XIPKG) install gpe-edit
endif
ifdef PTXCONF_GPE-WORD_INSTALL
	cd $(FEEDDIR) && $(XIPKG) install gpe-word
endif
ifdef PTXCONF_GPE-GALLERY_INSTALL
	cd $(FEEDDIR) && $(XIPKG) install gpe-gallery
endif
ifdef PTXCONF_GPE-CALCULATOR_INSTALL
	cd $(FEEDDIR) && $(XIPKG) install gpe-calculator
endif
ifdef PTXCONF_GPE-CONF_INSTALL
	cd $(FEEDDIR) && $(XIPKG) install gpe-conf
endif
ifdef PTXCONF_GPE-CLOCK_INSTALL
	cd $(FEEDDIR) && $(XIPKG) install gpe-clock
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gpe-cvs_clean:
	rm -rf $(STATEDIR)/gpe-cvs.*
	rm -rf $(GPE-CVS_DIR)

# vim: syntax=make
