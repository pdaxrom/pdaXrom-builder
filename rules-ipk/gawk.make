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
ifdef PTXCONF_GAWK
PACKAGES += gawk
endif

#
# Paths and names
#
GAWK_VERSION		= 3.1.3
GAWK			= gawk-$(GAWK_VERSION)
GAWK_SUFFIX		= tar.gz
GAWK_URL		= ftp://ftp.gnu.org/gnu/gawk/$(GAWK).$(GAWK_SUFFIX)
GAWK_SOURCE		= $(SRCDIR)/$(GAWK).$(GAWK_SUFFIX)
GAWK_DIR		= $(BUILDDIR)/$(GAWK)
GAWK_IPKG_TMP		= $(GAWK_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gawk_get: $(STATEDIR)/gawk.get

gawk_get_deps = $(GAWK_SOURCE)

$(STATEDIR)/gawk.get: $(gawk_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GAWK))
	touch $@

$(GAWK_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GAWK_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gawk_extract: $(STATEDIR)/gawk.extract

gawk_extract_deps = $(STATEDIR)/gawk.get

$(STATEDIR)/gawk.extract: $(gawk_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GAWK_DIR))
	@$(call extract, $(GAWK_SOURCE))
	@$(call patchin, $(GAWK))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gawk_prepare: $(STATEDIR)/gawk.prepare

#
# dependencies
#
gawk_prepare_deps = \
	$(STATEDIR)/gawk.extract \
	$(STATEDIR)/virtual-xchain.install

GAWK_PATH	=  PATH=$(CROSS_PATH)
GAWK_ENV 	=  $(CROSS_ENV)
#GAWK_ENV	+=
GAWK_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GAWK_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GAWK_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(PTXCONF_NATIVE_PREFIX)

ifdef PTXCONF_XFREE430
GAWK_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GAWK_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gawk.prepare: $(gawk_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GAWK_DIR)/config.cache)
	cd $(GAWK_DIR) && \
		$(GAWK_PATH) $(GAWK_ENV) \
		./configure $(GAWK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gawk_compile: $(STATEDIR)/gawk.compile

gawk_compile_deps = $(STATEDIR)/gawk.prepare

$(STATEDIR)/gawk.compile: $(gawk_compile_deps)
	@$(call targetinfo, $@)
	$(GAWK_PATH) $(MAKE) -C $(GAWK_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gawk_install: $(STATEDIR)/gawk.install

$(STATEDIR)/gawk.install: $(STATEDIR)/gawk.compile
	@$(call targetinfo, $@)
	###$(GAWK_PATH) $(MAKE) -C $(GAWK_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gawk_targetinstall: $(STATEDIR)/gawk.targetinstall

gawk_targetinstall_deps = $(STATEDIR)/gawk.compile

$(STATEDIR)/gawk.targetinstall: $(gawk_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GAWK_PATH) $(MAKE) -C $(GAWK_DIR) DESTDIR=$(GAWK_IPKG_TMP) install
	rm  -f $(GAWK_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/gawk-
	rm  -f $(GAWK_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/pgawk-
	ln -sf gawk $(GAWK_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/gawk-
	ln -sf pgawk $(GAWK_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/pgawk-
	$(CROSSSTRIP) $(GAWK_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/gawk
	$(CROSSSTRIP) $(GAWK_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/bin/pgawk
	$(CROSSSTRIP) $(GAWK_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/libexec/awk/*
	rm -rf $(GAWK_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/info
	rm -rf $(GAWK_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/man
	rm -rf $(GAWK_IPKG_TMP)$(PTXCONF_NATIVE_PREFIX)/share/locale
	mkdir -p $(GAWK_IPKG_TMP)/CONTROL
	echo "Package: gawk" 				>$(GAWK_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(GAWK_IPKG_TMP)/CONTROL/control
	echo "Section: Utils"	 			>>$(GAWK_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(GAWK_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(GAWK_IPKG_TMP)/CONTROL/control
	echo "Version: $(GAWK_VERSION)" 		>>$(GAWK_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(GAWK_IPKG_TMP)/CONTROL/control
	echo "Description: Pattern scanning and processing language.">>$(GAWK_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GAWK_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_GAWK_INSTALL
ROMPACKAGES += $(STATEDIR)/gawk.imageinstall
endif

gawk_imageinstall_deps = $(STATEDIR)/gawk.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/gawk.imageinstall: $(gawk_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install gawk
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gawk_clean:
	rm -rf $(STATEDIR)/gawk.*
	rm -rf $(GAWK_DIR)

# vim: syntax=make
