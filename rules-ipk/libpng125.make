# -*-makefile-*-
# $Id: libpng125.make,v 1.2 2003/10/23 15:01:19 mkl Exp $
#
# Copyright (C) 2003 by Robert Schwebel <r.schwebel@pengutronix.de>
#                       Pengutronix <info@pengutronix.de>, Germany
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_LIBPNG125
PACKAGES += libpng125
endif

#
# Paths and names
#
LIBPNG125_VERSION	= 1.2.5
LIBPNG125		= libpng-$(LIBPNG125_VERSION)
LIBPNG125_SUFFIX	= tar.gz
LIBPNG125_URL		= http://download.sourceforge.net/libpng/$(LIBPNG125).$(LIBPNG125_SUFFIX)
LIBPNG125_SOURCE	= $(SRCDIR)/$(LIBPNG125).$(LIBPNG125_SUFFIX)
LIBPNG125_DIR		= $(BUILDDIR)/$(LIBPNG125)
LIBPNG125_IPKG_TMP	= $(LIBPNG125_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libpng125_get: $(STATEDIR)/libpng125.get

libpng125_get_deps	=  $(LIBPNG125_SOURCE)

$(STATEDIR)/libpng125.get: $(libpng125_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(LIBPNG125_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(LIBPNG125_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libpng125_extract: $(STATEDIR)/libpng125.extract

libpng125_extract_deps	=  $(STATEDIR)/libpng125.get

$(STATEDIR)/libpng125.extract: $(libpng125_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBPNG125_DIR))
	@$(call extract, $(LIBPNG125_SOURCE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libpng125_prepare: $(STATEDIR)/libpng125.prepare

#
# dependencies
#
libpng125_prepare_deps =  \
	$(STATEDIR)/libpng125.extract \
	$(STATEDIR)/virtual-xchain.install

LIBPNG125_PATH	=  PATH=$(CROSS_PATH)
LIBPNG125_ENV 	=  $(CROSS_ENV)
#LIBPNG125_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"

ifdef PTXCONF_LIBPNG125_FOO
LIBPNG125_AUTOCONF	+= --enable-foo
endif

$(STATEDIR)/libpng125.prepare: $(libpng125_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBPNG125_BUILDDIR))
	cp $(LIBPNG125_DIR)/scripts/makefile.linux $(LIBPNG125_DIR)/Makefile
	perl -i -p -e "s/CC=/CC?=/g" $(LIBPNG125_DIR)/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libpng125_compile: $(STATEDIR)/libpng125.compile

libpng125_compile_deps =  $(STATEDIR)/libpng125.prepare
libpng125_compile_deps += $(STATEDIR)/zlib.install

$(STATEDIR)/libpng125.compile: $(libpng125_compile_deps)
	@$(call targetinfo, $@)
	$(LIBPNG125_PATH) $(LIBPNG125_ENV) $(MAKE) -C $(LIBPNG125_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libpng125_install: $(STATEDIR)/libpng125.install

$(STATEDIR)/libpng125.install: $(STATEDIR)/libpng125.compile
	@$(call targetinfo, $@)
	install -d $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib
	install $(LIBPNG125_DIR)/libpng12.so.0.1.2.5 $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib
	ln -sf libpng12.so.0.1.2.5 $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libpng12.so.0
	ln -sf libpng12.so.0.1.2.5 $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libpng12.so
	ln -sf libpng12.so.0.1.2.5 $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libpng.so.0
	ln -sf libpng12.so.0.1.2.5 $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libpng.so
	install $(LIBPNG125_DIR)/*.h $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/include/
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libpng125_targetinstall: $(STATEDIR)/libpng125.targetinstall

libpng125_targetinstall_deps	=  $(STATEDIR)/libpng125.compile

$(STATEDIR)/libpng125.targetinstall: $(libpng125_targetinstall_deps)
	@$(call targetinfo, $@)
	install -d    $(LIBPNG125_IPKG_TMP)/usr/lib
	install $(LIBPNG125_DIR)/libpng12.so.0.1.2.5 $(LIBPNG125_IPKG_TMP)/usr/lib
	$(CROSSSTRIP) $(LIBPNG125_IPKG_TMP)/usr/lib/libpng12.so.0.1.2.5
	ln -sf libpng12.so.0.1.2.5 $(LIBPNG125_IPKG_TMP)/usr/lib/libpng12.so.0
	ln -sf libpng12.so.0.1.2.5 $(LIBPNG125_IPKG_TMP)/usr/lib/libpng12.so
	ln -sf libpng12.so.0.1.2.5 $(LIBPNG125_IPKG_TMP)/usr/lib/libpng.so.3
	ln -sf libpng12.so.0.1.2.5 $(LIBPNG125_IPKG_TMP)/usr/lib/libpng.so

	mkdir -p $(LIBPNG125_IPKG_TMP)/CONTROL
	echo "Package: libpng"	 				 >$(LIBPNG125_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 				>>$(LIBPNG125_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries"	 			>>$(LIBPNG125_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"	>>$(LIBPNG125_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(LIBPNG125_IPKG_TMP)/CONTROL/control
	echo "Version: $(LIBPNG125_VERSION)" 			>>$(LIBPNG125_IPKG_TMP)/CONTROL/control
	echo "Depends: "			 		>>$(LIBPNG125_IPKG_TMP)/CONTROL/control
	echo "Description: Loads and saves PNG files"		>>$(LIBPNG125_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(LIBPNG125_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libpng125_clean:
	rm -rf $(STATEDIR)/libpng125.*
	rm -rf $(LIBPNG125_DIR)

# vim: syntax=make
