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
ifdef PTXCONF_EXIT
PACKAGES += eXit
endif

#
# Paths and names
#
EXIT_VERSION		= 1.0.0
EXIT			= eXit-$(EXIT_VERSION)
EXIT_SUFFIX		= tar.bz2
EXIT_URL		= http://www.pdaXrom.org/src/$(EXIT).$(EXIT_SUFFIX)
EXIT_SOURCE		= $(SRCDIR)/$(EXIT).$(EXIT_SUFFIX)
EXIT_DIR		= $(BUILDDIR)/$(EXIT)
EXIT_IPKG_TMP		= $(EXIT_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

eXit_get: $(STATEDIR)/eXit.get

eXit_get_deps = $(EXIT_SOURCE)

$(STATEDIR)/eXit.get: $(eXit_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(EXIT))
	touch $@

$(EXIT_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(EXIT_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

eXit_extract: $(STATEDIR)/eXit.extract

eXit_extract_deps = $(STATEDIR)/eXit.get

$(STATEDIR)/eXit.extract: $(eXit_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EXIT_DIR))
	@$(call extract, $(EXIT_SOURCE))
	@$(call patchin, $(EXIT))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

eXit_prepare: $(STATEDIR)/eXit.prepare

#
# dependencies
#
eXit_prepare_deps = \
	$(STATEDIR)/eXit.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/virtual-xchain.install

EXIT_PATH	=  PATH=$(CROSS_PATH)
EXIT_ENV 	=  $(CROSS_ENV)
#EXIT_ENV	+=
EXIT_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#EXIT_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
EXIT_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
EXIT_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
EXIT_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/eXit.prepare: $(eXit_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(EXIT_DIR)/config.cache)
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/install-sh $(EXIT_DIR)/install-sh
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/missing $(EXIT_DIR)/missing
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/depcomp $(EXIT_DIR)/depcomp
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/INSTALL $(EXIT_DIR)/INSTALL
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/COPYING $(EXIT_DIR)/COPYING
	#cd $(EXIT_DIR) && $(EXIT_PATH) aclocal
	#cd $(EXIT_DIR) && $(EXIT_PATH) automake --add-missing
	#cd $(EXIT_DIR) && $(EXIT_PATH) autoconf
	ln -sf $(PTXCONF_PREFIX)/share/automake-1.9/mkinstalldirs $(EXIT_DIR)/mkinstalldirs
	cd $(EXIT_DIR) && \
		$(EXIT_PATH) $(EXIT_ENV) \
		./configure $(EXIT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

eXit_compile: $(STATEDIR)/eXit.compile

eXit_compile_deps = $(STATEDIR)/eXit.prepare

$(STATEDIR)/eXit.compile: $(eXit_compile_deps)
	@$(call targetinfo, $@)
	$(EXIT_PATH) $(MAKE) -C $(EXIT_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

eXit_install: $(STATEDIR)/eXit.install

$(STATEDIR)/eXit.install: $(STATEDIR)/eXit.compile
	@$(call targetinfo, $@)
	$(EXIT_PATH) $(MAKE) -C $(EXIT_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

eXit_targetinstall: $(STATEDIR)/eXit.targetinstall

eXit_targetinstall_deps = $(STATEDIR)/eXit.compile \
	$(STATEDIR)/gtk22.targetinstall

$(STATEDIR)/eXit.targetinstall: $(eXit_targetinstall_deps)
	@$(call targetinfo, $@)
	$(EXIT_PATH) $(MAKE) -C $(EXIT_DIR) DESTDIR=$(EXIT_IPKG_TMP) install install_sh=install
	$(CROSSSTRIP) $(EXIT_IPKG_TMP)/usr/bin/*
	mkdir -p $(EXIT_IPKG_TMP)/usr/share/applications
	mkdir -p $(EXIT_IPKG_TMP)/usr/share/pixmaps
	cp -a $(EXIT_DIR)/cancel.png	$(EXIT_IPKG_TMP)/usr/share/pixmaps
	cp -a $(EXIT_DIR)/eXit.desktop	$(EXIT_IPKG_TMP)/usr/share/applications
	mkdir -p $(EXIT_IPKG_TMP)/CONTROL
	echo "Package: exit" 					>$(EXIT_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(EXIT_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 				>>$(EXIT_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(EXIT_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(EXIT_IPKG_TMP)/CONTROL/control
	echo "Version: $(EXIT_VERSION)" 			>>$(EXIT_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2" 					>>$(EXIT_IPKG_TMP)/CONTROL/control
	echo "Description: x11 killer app"			>>$(EXIT_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(EXIT_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_EXIT_INSTALL
ROMPACKAGES += $(STATEDIR)/eXit.imageinstall
endif

eXit_imageinstall_deps = $(STATEDIR)/eXit.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/eXit.imageinstall: $(eXit_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install exit
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

eXit_clean:
	rm -rf $(STATEDIR)/eXit.*
	rm -rf $(EXIT_DIR)

# vim: syntax=make
