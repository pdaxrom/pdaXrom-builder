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
ifdef PTXCONF_MINICOM
PACKAGES += minicom
endif

#
# Paths and names
#
MINICOM_VERSION		= 2.1
MINICOM			= minicom-$(MINICOM_VERSION)
MINICOM_SUFFIX		= tar.gz
MINICOM_URL		= http://alioth.debian.org/download.php/123//$(MINICOM).$(MINICOM_SUFFIX)
MINICOM_SOURCE		= $(SRCDIR)/$(MINICOM).$(MINICOM_SUFFIX)
MINICOM_DIR		= $(BUILDDIR)/$(MINICOM)
MINICOM_IPKG_TMP	= $(MINICOM_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

minicom_get: $(STATEDIR)/minicom.get

minicom_get_deps = $(MINICOM_SOURCE)

$(STATEDIR)/minicom.get: $(minicom_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MINICOM))
	touch $@

$(MINICOM_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MINICOM_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

minicom_extract: $(STATEDIR)/minicom.extract

minicom_extract_deps = $(STATEDIR)/minicom.get

$(STATEDIR)/minicom.extract: $(minicom_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MINICOM_DIR))
	@$(call extract, $(MINICOM_SOURCE))
	@$(call patchin, $(MINICOM))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

minicom_prepare: $(STATEDIR)/minicom.prepare

#
# dependencies
#
minicom_prepare_deps = \
	$(STATEDIR)/minicom.extract \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/virtual-xchain.install

MINICOM_PATH	=  PATH=$(CROSS_PATH)
MINICOM_ENV 	=  $(CROSS_ENV)
#MINICOM_ENV	+=
MINICOM_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MINICOM_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
MINICOM_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
MINICOM_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MINICOM_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/minicom.prepare: $(minicom_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MINICOM_DIR)/config.cache)
	cd $(MINICOM_DIR) && \
		$(MINICOM_PATH) $(MINICOM_ENV) \
		./configure $(MINICOM_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

minicom_compile: $(STATEDIR)/minicom.compile

minicom_compile_deps = $(STATEDIR)/minicom.prepare

$(STATEDIR)/minicom.compile: $(minicom_compile_deps)
	@$(call targetinfo, $@)
	$(MINICOM_PATH) $(MAKE) -C $(MINICOM_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

minicom_install: $(STATEDIR)/minicom.install

$(STATEDIR)/minicom.install: $(STATEDIR)/minicom.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

minicom_targetinstall: $(STATEDIR)/minicom.targetinstall

minicom_targetinstall_deps = $(STATEDIR)/minicom.compile \
	$(STATEDIR)/ncurses.targetinstall

$(STATEDIR)/minicom.targetinstall: $(minicom_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MINICOM_PATH) $(MAKE) -C $(MINICOM_DIR) DESTDIR=$(MINICOM_IPKG_TMP) install
	$(CROSSSTRIP) $(MINICOM_IPKG_TMP)/usr/bin/ascii-xfr
	$(CROSSSTRIP) $(MINICOM_IPKG_TMP)/usr/bin/minicom
	$(CROSSSTRIP) $(MINICOM_IPKG_TMP)/usr/bin/runscript
	rm -rf $(MINICOM_IPKG_TMP)/usr/man
	rm -rf $(MINICOM_IPKG_TMP)/usr/share/locale
	mkdir -p $(MINICOM_IPKG_TMP)/usr/share/pixmaps
	mkdir -p $(MINICOM_IPKG_TMP)/usr/share/applications
	cp $(TOPDIR)/config/pics/terminal.png     $(MINICOM_IPKG_TMP)/usr/share/pixmaps
	cp $(TOPDIR)/config/pics/terminal.desktop $(MINICOM_IPKG_TMP)/usr/share/applications
	mkdir -p $(MINICOM_IPKG_TMP)/CONTROL
	echo "Package: minicom" 				  >$(MINICOM_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(MINICOM_IPKG_TMP)/CONTROL/control
	echo "Section: Utils"	 				>>$(MINICOM_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(MINICOM_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(MINICOM_IPKG_TMP)/CONTROL/control
	echo "Version: $(MINICOM_VERSION)" 			>>$(MINICOM_IPKG_TMP)/CONTROL/control
	echo "Depends: ncurses" 				>>$(MINICOM_IPKG_TMP)/CONTROL/control
	echo "Description: Minicom is a menu driven communications program. It emulates ANSI and VT102 terminals. It has a dialing directory and auto zmodem download."	>>$(MINICOM_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MINICOM_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MINICOM_INSTALL
ROMPACKAGES += $(STATEDIR)/minicom.imageinstall
endif

minicom_imageinstall_deps = $(STATEDIR)/minicom.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/minicom.imageinstall: $(minicom_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install minicom
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

minicom_clean:
	rm -rf $(STATEDIR)/minicom.*
	rm -rf $(MINICOM_DIR)

# vim: syntax=make
