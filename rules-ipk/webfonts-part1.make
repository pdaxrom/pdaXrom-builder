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
ifdef PTXCONF_WEBFONTS-PART1
PACKAGES += webfonts-part1
endif

#
# Paths and names
#
WEBFONTS-PART1_VERSION		= 1.0.0
WEBFONTS-PART1			= webfonts-part1
WEBFONTS-PART2			= webfonts-part2
WEBFONTS-PART1_SUFFIX		= tar.gz
WEBFONTS-PART1_URL		= http://www.pdaXrom.org/src/$(WEBFONTS-PART1).$(WEBFONTS-PART1_SUFFIX)
WEBFONTS-PART2_URL		= http://www.pdaXrom.org/src/$(WEBFONTS-PART2).$(WEBFONTS-PART1_SUFFIX)
WEBFONTS-PART1_SOURCE		= $(SRCDIR)/$(WEBFONTS-PART1).$(WEBFONTS-PART1_SUFFIX)
WEBFONTS-PART2_SOURCE		= $(SRCDIR)/$(WEBFONTS-PART2).$(WEBFONTS-PART1_SUFFIX)
WEBFONTS-PART1_DIR		= $(BUILDDIR)/$(WEBFONTS-PART1)
WEBFONTS-PART2_DIR		= $(BUILDDIR)/$(WEBFONTS-PART2)
WEBFONTS-PART1_IPKG_TMP		= $(WEBFONTS-PART1_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

webfonts-part1_get: $(STATEDIR)/webfonts-part1.get

webfonts-part1_get_deps = $(WEBFONTS-PART1_SOURCE)

$(STATEDIR)/webfonts-part1.get: $(webfonts-part1_get_deps)
	@$(call targetinfo, $@)
	###@$(call get_patches, $(WEBFONTS-PART1))
	touch $@

$(WEBFONTS-PART1_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(WEBFONTS-PART1_URL))
	@$(call get, $(WEBFONTS-PART2_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

webfonts-part1_extract: $(STATEDIR)/webfonts-part1.extract

webfonts-part1_extract_deps = $(STATEDIR)/webfonts-part1.get

$(STATEDIR)/webfonts-part1.extract: $(webfonts-part1_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WEBFONTS-PART1_DIR))
	@$(call clean, $(WEBFONTS-PART2_DIR))
	@$(call extract, $(WEBFONTS-PART1_SOURCE))
	@$(call extract, $(WEBFONTS-PART2_SOURCE))
	###@$(call patchin, $(WEBFONTS-PART1))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

webfonts-part1_prepare: $(STATEDIR)/webfonts-part1.prepare

#
# dependencies
#
webfonts-part1_prepare_deps = \
	$(STATEDIR)/webfonts-part1.extract \
	$(STATEDIR)/virtual-xchain.install

WEBFONTS-PART1_PATH	=  PATH=$(CROSS_PATH)
WEBFONTS-PART1_ENV 	=  $(CROSS_ENV)
#WEBFONTS-PART1_ENV	+=
WEBFONTS-PART1_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#WEBFONTS-PART1_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
WEBFONTS-PART1_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
WEBFONTS-PART1_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
WEBFONTS-PART1_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/webfonts-part1.prepare: $(webfonts-part1_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(WEBFONTS-PART1_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

webfonts-part1_compile: $(STATEDIR)/webfonts-part1.compile

webfonts-part1_compile_deps = $(STATEDIR)/webfonts-part1.prepare

$(STATEDIR)/webfonts-part1.compile: $(webfonts-part1_compile_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

webfonts-part1_install: $(STATEDIR)/webfonts-part1.install

$(STATEDIR)/webfonts-part1.install: $(STATEDIR)/webfonts-part1.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

webfonts-part1_targetinstall: $(STATEDIR)/webfonts-part1.targetinstall

webfonts-part1_targetinstall_deps = $(STATEDIR)/webfonts-part1.compile

$(STATEDIR)/webfonts-part1.targetinstall: $(webfonts-part1_targetinstall_deps)
	@$(call targetinfo, $@)
	###
	rm -rf $(WEBFONTS-PART1_IPKG_TMP)
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	cp -a $(WEBFONTS-PART1_DIR)/andalemo*.ttf $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/CONTROL
	echo "Package: webfonts-andalemo" 			>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Version: $(WEBFONTS-PART1_VERSION)" 		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Description: MS web fonts: andalemo"		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WEBFONTS-PART1_IPKG_TMP)
	###
	rm -rf $(WEBFONTS-PART1_IPKG_TMP)
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	cp -a $(WEBFONTS-PART1_DIR)/arial*.ttf $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/CONTROL
	echo "Package: webfonts-arial" 				>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Version: $(WEBFONTS-PART1_VERSION)" 		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Description: MS web fonts: Arial"			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WEBFONTS-PART1_IPKG_TMP)
	###
	rm -rf $(WEBFONTS-PART1_IPKG_TMP)
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	cp -a $(WEBFONTS-PART1_DIR)/ariblk.ttf $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/CONTROL
	echo "Package: webfonts-ariblk" 			>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Version: $(WEBFONTS-PART1_VERSION)" 		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Description: MS web fonts: Arial Black"		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WEBFONTS-PART1_IPKG_TMP)
	###
	rm -rf $(WEBFONTS-PART1_IPKG_TMP)
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	cp -a $(WEBFONTS-PART1_DIR)/comic*.ttf $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/CONTROL
	echo "Package: webfonts-comic" 				>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Version: $(WEBFONTS-PART1_VERSION)" 		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Description: MS web fonts: Comic"			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WEBFONTS-PART1_IPKG_TMP)
	###
	rm -rf $(WEBFONTS-PART1_IPKG_TMP)
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	cp -a $(WEBFONTS-PART1_DIR)/cour*.ttf $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/CONTROL
	echo "Package: webfonts-courier" 			>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Version: $(WEBFONTS-PART1_VERSION)" 		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Description: MS web fonts: Courier"		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WEBFONTS-PART1_IPKG_TMP)
	###
	rm -rf $(WEBFONTS-PART1_IPKG_TMP)
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	cp -a $(WEBFONTS-PART1_DIR)/georgi*.ttf $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/CONTROL
	echo "Package: webfonts-georgia" 			>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Version: $(WEBFONTS-PART1_VERSION)" 		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Description: MS web fonts: Georgia"		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WEBFONTS-PART1_IPKG_TMP)
	###
	rm -rf $(WEBFONTS-PART1_IPKG_TMP)
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	cp -a $(WEBFONTS-PART1_DIR)/georgia*.ttf $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/CONTROL
	echo "Package: webfonts-georgia" 			>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Version: $(WEBFONTS-PART1_VERSION)" 		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Description: MS web fonts: Georgia"		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WEBFONTS-PART1_IPKG_TMP)
	###
	rm -rf $(WEBFONTS-PART1_IPKG_TMP)
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	cp -a $(WEBFONTS-PART2_DIR)/times*.ttf $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/CONTROL
	echo "Package: webfonts-times"	 			>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Version: $(WEBFONTS-PART1_VERSION)" 		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Description: MS web fonts: Times"			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WEBFONTS-PART1_IPKG_TMP)
	###
	rm -rf $(WEBFONTS-PART1_IPKG_TMP)
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	cp -a $(WEBFONTS-PART2_DIR)/trebuc*.ttf $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/CONTROL
	echo "Package: webfonts-trebuchet"	 		>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Version: $(WEBFONTS-PART1_VERSION)" 		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Description: MS web fonts: Trebuchet"		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WEBFONTS-PART1_IPKG_TMP)
	###
	rm -rf $(WEBFONTS-PART1_IPKG_TMP)
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	cp -a $(WEBFONTS-PART2_DIR)/verdana*.ttf $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/CONTROL
	echo "Package: webfonts-verdana"	 		>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Version: $(WEBFONTS-PART1_VERSION)" 		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Description: MS web fonts: Verdana"		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WEBFONTS-PART1_IPKG_TMP)
	###
	rm -rf $(WEBFONTS-PART1_IPKG_TMP)
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	cp -a $(WEBFONTS-PART2_DIR)/impact*.ttf $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/CONTROL
	echo "Package: webfonts-impact"		 		>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Version: $(WEBFONTS-PART1_VERSION)" 		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Description: MS web fonts: Impact"		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WEBFONTS-PART1_IPKG_TMP)
	###
	rm -rf $(WEBFONTS-PART1_IPKG_TMP)
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	cp -a $(WEBFONTS-PART2_DIR)/lucon*.ttf $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/CONTROL
	echo "Package: webfonts-lucon"		 		>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Version: $(WEBFONTS-PART1_VERSION)" 		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Description: MS web fonts: Lucida console"	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WEBFONTS-PART1_IPKG_TMP)
	###
	rm -rf $(WEBFONTS-PART1_IPKG_TMP)
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	cp -a $(WEBFONTS-PART2_DIR)/webdings*.ttf $(WEBFONTS-PART1_IPKG_TMP)/usr/X11R6/lib/X11/fonts/TTF
	mkdir -p $(WEBFONTS-PART1_IPKG_TMP)/CONTROL
	echo "Package: webfonts-webdings"	 		>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Version: $(WEBFONTS-PART1_VERSION)" 		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Depends: " 					>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	echo "Description: MS web fonts: Webdings"		>>$(WEBFONTS-PART1_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(WEBFONTS-PART1_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_WEBFONTS-PART1_INSTALL
ROMPACKAGES += $(STATEDIR)/webfonts-part1.imageinstall
endif

webfonts-part1_imageinstall_deps = $(STATEDIR)/webfonts-part1.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/webfonts-part1.imageinstall: $(webfonts-part1_imageinstall_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_WEBFONTS-PART1_INSTALL_ARIAL
	cd $(FEEDDIR) && $(XIPKG) install webfonts-arial
endif
ifdef PTXCONF_WEBFONTS-PART1_INSTALL_COURIER
	cd $(FEEDDIR) && $(XIPKG) install webfonts-courier
endif
ifdef PTXCONF_WEBFONTS-PART1_INSTALL_TIMES
	cd $(FEEDDIR) && $(XIPKG) install webfonts-times
endif
ifdef PTXCONF_WEBFONTS-PART1_INSTALL_LUCON
	cd $(FEEDDIR) && $(XIPKG) install webfonts-lucon
endif
ifdef PTXCONF_WEBFONTS-PART1_INSTALL_VERDANA
	cd $(FEEDDIR) && $(XIPKG) install webfonts-verdana
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

webfonts-part1_clean:
	rm -rf $(STATEDIR)/webfonts-part1.*
	rm -rf $(WEBFONTS-PART1_DIR)

# vim: syntax=make
