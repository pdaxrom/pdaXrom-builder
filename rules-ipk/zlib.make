# -*-makefile-*-
# $Id: zlib.make,v 1.10 2003/11/17 03:45:23 mkl Exp $
#
# Copyright (C) 2002 by Pengutronix e.K., Hildesheim, Germany
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifeq (y, $(PTXCONF_ZLIB))
PACKAGES += zlib
endif

#
# Paths and names 
#
ZLIB			= zlib-1.1.4
ZLIB_URL 		= ftp://ftp.info-zip.org/pub/infozip/zlib/$(ZLIB).tar.gz
ZLIB_SOURCE		= $(SRCDIR)/$(ZLIB).tar.gz
ZLIB_DIR		= $(BUILDDIR)/$(ZLIB)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

zlib_get: $(STATEDIR)/zlib.get

$(STATEDIR)/zlib.get: $(ZLIB_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(ZLIB_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ZLIB_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

zlib_extract: $(STATEDIR)/zlib.extract

$(STATEDIR)/zlib.extract: $(STATEDIR)/zlib.get
	@$(call targetinfo, $@)
	@$(call clean, $(ZLIB_DIR))
	@$(call extract, $(ZLIB_SOURCE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

zlib_prepare: $(STATEDIR)/zlib.prepare

zlib_prepare_deps = \
	$(STATEDIR)/virtual-xchain.install \
	$(STATEDIR)/zlib.extract

ZLIB_PATH	=  PATH=$(CROSS_PATH)
ZLIB_AUTOCONF 	=  --shared
ZLIB_AUTOCONF 	+= --prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/zlib.prepare: $(zlib_prepare_deps)
	@$(call targetinfo, $@)
	cd $(ZLIB_DIR) && \
		$(ZLIB_PATH) \
		./configure $(ZLIB_AUTOCONF)
	perl -i -p -e 's/=gcc/=$(PTXCONF_GNU_TARGET)-gcc/g' $(ZLIB_DIR)/Makefile
	perl -i -p -e 's/=ar/=$(PTXCONF_GNU_TARGET)-ar/g' $(ZLIB_DIR)/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

zlib_compile: $(STATEDIR)/zlib.compile

$(STATEDIR)/zlib.compile: $(STATEDIR)/zlib.prepare 
	@$(call targetinfo, $@)
	$(ZLIB_PATH) $(MAKE) -C $(ZLIB_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

zlib_install: $(STATEDIR)/zlib.install

$(STATEDIR)/zlib.install: $(STATEDIR)/zlib.compile
	@$(call targetinfo, $@)
	$(ZLIB_PATH) $(MAKE) -C $(ZLIB_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

zlib_targetinstall: $(STATEDIR)/zlib.targetinstall

$(STATEDIR)/zlib.targetinstall: $(STATEDIR)/zlib.install
	@$(call targetinfo, $@)
	rm -rf   $(ZLIB_DIR)/ipk
	mkdir -p $(ZLIB_DIR)/ipk/usr/lib
	cp -d $(ZLIB_DIR)/libz.so* 		$(ZLIB_DIR)/ipk/usr/lib/
	$(CROSSSTRIP) -R .note -R .comment 	$(ZLIB_DIR)/ipk/usr/lib/libz.so*
	mkdir -p $(ZLIB_DIR)/ipk/CONTROL
	echo "Package: libz" 							 >$(ZLIB_DIR)/ipk/CONTROL/control
	echo "Priority: optional" 						>>$(ZLIB_DIR)/ipk/CONTROL/control
	echo "Section: Libraries" 						>>$(ZLIB_DIR)/ipk/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(ZLIB_DIR)/ipk/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(ZLIB_DIR)/ipk/CONTROL/control
	echo "Version: $(ZIP_VERSION)" 						>>$(ZLIB_DIR)/ipk/CONTROL/control
	echo "Depends: " 							>>$(ZLIB_DIR)/ipk/CONTROL/control
	echo "Description: a general purpose data compression library."		>>$(ZLIB_DIR)/ipk/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ZLIB_DIR)/ipk
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ZLIB_INSTALL
ROMPACKAGES += $(STATEDIR)/zlib.imageinstall
endif

zlib_imageinstall_deps = $(STATEDIR)/zlib.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/zlib.imageinstall: $(zlib_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install libz
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

zlib_clean: 
	rm -rf $(STATEDIR)/zlib.* $(ZLIB_DIR)

# vim: syntax=make
