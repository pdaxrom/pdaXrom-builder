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
ifdef PTXCONF_NX-X11
PACKAGES += nx-X11
endif

#
# Paths and names
#
NX-X11_VERSION		= 1.3.2-9
NX-X11			= nx-X11-$(NX-X11_VERSION)
NX-X11_SUFFIX		= tar.gz
NX-X11_URL		= http://www.nomachine.com/source/$(NX-X11).$(NX-X11_SUFFIX)
NX-X11_URL1		= http://www.nomachine.com/source/nxagent-1.3.2-23.$(NX-X11_SUFFIX)
NX-X11_URL2		= http://www.nomachine.com/source/nxkdrive-1.3.2-1.$(NX-X11_SUFFIX)
NX-X11_URL3		= http://www.nomachine.com/source/nxauth-1.3.2-1.$(NX-X11_SUFFIX)
NX-X11_SOURCE		= $(SRCDIR)/$(NX-X11).$(NX-X11_SUFFIX)
NX-X11_SOURCE1		= $(SRCDIR)/nxagent-1.3.2-23.$(NX-X11_SUFFIX)
NX-X11_SOURCE2		= $(SRCDIR)/nxkdrive-1.3.2-1.$(NX-X11_SUFFIX)
NX-X11_SOURCE3		= $(SRCDIR)/nxauth-1.3.2-1.$(NX-X11_SUFFIX)
NX-X11_DIR		= $(BUILDDIR)/nx-X11
NX-X11_IPKG_TMP		= $(NX-X11_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

nx-X11_get: $(STATEDIR)/nx-X11.get

nx-X11_get_deps = $(NX-X11_SOURCE)

$(STATEDIR)/nx-X11.get: $(nx-X11_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(NX-X11))
	touch $@

$(NX-X11_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(NX-X11_URL))
	@$(call get, $(NX-X11_URL1))
	@$(call get, $(NX-X11_URL2))
	@$(call get, $(NX-X11_URL3))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

nx-X11_extract: $(STATEDIR)/nx-X11.extract

nx-X11_extract_deps = $(STATEDIR)/nx-X11.get

$(STATEDIR)/nx-X11.extract: $(nx-X11_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NX-X11_DIR))
	@$(call extract, $(NX-X11_SOURCE))
	@$(call extract, $(NX-X11_SOURCE1))
	@$(call extract, $(NX-X11_SOURCE2))
	@$(call extract, $(NX-X11_SOURCE3))
	@$(call patchin, $(NX-X11), $(NX-X11_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

nx-X11_prepare: $(STATEDIR)/nx-X11.prepare

#
# dependencies
#
nx-X11_prepare_deps = \
	$(STATEDIR)/nx-X11.extract \
	$(STATEDIR)/virtual-xchain.install
nx-X11_prepare_deps += $(STATEDIR)/zlib.install
nx-X11_prepare_deps += $(STATEDIR)/ncurses.install
nx-X11_prepare_deps += $(STATEDIR)/libpng125.install
nx-X11_prepare_deps += $(STATEDIR)/jpeg.install
nx-X11_prepare_deps += $(STATEDIR)/expat.install
nx-X11_prepare_deps += $(STATEDIR)/freetype.install
nx-X11_prepare_deps += $(STATEDIR)/fontconfig.install

nx-X11_prepare_deps += $(STATEDIR)/nxcomp.compile
nx-X11_prepare_deps += $(STATEDIR)/nxcompext.prepare

NX-X11_PATH	=  PATH=$(CROSS_PATH)

$(STATEDIR)/nx-X11.prepare: $(nx-X11_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NX-X11_DIR)/config.cache)
	ln -sf $(PTXCONF_PREFIX)/bin/$(PTXCONF_GNU_TARGET)-cpp $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/cpp
	ln -sf $(PTXCONF_PREFIX)/bin/$(PTXCONF_GNU_TARGET)-gcc $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/cc
	perl -i -p -e "s,\@FREETYPE2DIR@,`$(PTXCONF_PREFIX)/bin/freetype-config --prefix`,g" $(NX-X11_DIR)/config/cf/NX-Linux.def
	perl -i -p -e "s,\@FONTCONFIGDIR@,$(CROSS_LIB_DIR),g" 	$(NX-X11_DIR)/config/cf/NX-Linux.def
	perl -i -p -e "s,\@EXPATDIR@,$(CROSS_LIB_DIR),g" 	$(NX-X11_DIR)/config/cf/NX-Linux.def
	perl -i -p -e "s,\@LIBPNGDIR@,$(CROSS_LIB_DIR),g"	$(NX-X11_DIR)/config/cf/NX-Linux.def
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

nx-X11_compile: $(STATEDIR)/nx-X11.compile

nx-X11_compile_deps = $(STATEDIR)/nx-X11.prepare

$(STATEDIR)/nx-X11.compile: $(nx-X11_compile_deps)
	@$(call targetinfo, $@)
	cd $(NX-X11_DIR) && \
		$(NX-X11_ENV) $(MAKE) World CROSSCOMPILEDIR=$(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

nx-X11_install: $(STATEDIR)/nx-X11.install

$(STATEDIR)/nx-X11.install: $(STATEDIR)/nx-X11.compile
	@$(call targetinfo, $@)
	asdasd
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

nx-X11_targetinstall: $(STATEDIR)/nx-X11.targetinstall

nx-X11_targetinstall_deps = $(STATEDIR)/nx-X11.compile
nx-X11_targetinstall_deps += $(STATEDIR)/ncurses.targetinstall
nx-X11_targetinstall_deps += $(STATEDIR)/libpng125.targetinstall
nx-X11_targetinstall_deps += $(STATEDIR)/jpeg.targetinstall
nx-X11_targetinstall_deps += $(STATEDIR)/zlib.targetinstall
nx-X11_targetinstall_deps += $(STATEDIR)/expat.targetinstall
nx-X11_targetinstall_deps += $(STATEDIR)/freetype.targetinstall
nx-X11_targetinstall_deps += $(STATEDIR)/fontconfig.targetinstall

$(STATEDIR)/nx-X11.targetinstall: $(nx-X11_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(NX-X11_PATH) $(MAKE) -C $(NX-X11_DIR) DESTDIR=$(NX-X11_IPKG_TMP) install
	mkdir -p $(NX-X11_IPKG_TMP)/CONTROL
	echo "Package: nx-x11" 			>$(NX-X11_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(NX-X11_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 			>>$(NX-X11_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(NX-X11_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(NX-X11_IPKG_TMP)/CONTROL/control
	echo "Version: $(NX-X11_VERSION)" 		>>$(NX-X11_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(NX-X11_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(NX-X11_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(NX-X11_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_NX-X11_INSTALL
ROMPACKAGES += $(STATEDIR)/nx-X11.imageinstall
endif

nx-X11_imageinstall_deps = $(STATEDIR)/nx-X11.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/nx-X11.imageinstall: $(nx-X11_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install nx-x11
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

nx-X11_clean:
	rm -rf $(STATEDIR)/nx-X11.*
	rm -rf $(NX-X11_DIR)

# vim: syntax=make
