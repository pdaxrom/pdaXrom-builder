# -*-makefile-*-
# $Id: openssl.make,v 1.13 2003/10/28 02:21:54 mkl Exp $
#
# Copyright (C) 2002 by Jochen Striepe for Pengutronix e.K., Hildesheim, Germany
#               2003 by Pengutronix e.K., Hildesheim, Germany
#
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_OPENSSL
PACKAGES += openssl
endif

#
# Paths and names 
#
OPENSSL_VERSION		= 0.9.7c
OPENSSL			= openssl-$(OPENSSL_VERSION)
OPENSSL_URL 		= http://www.openssl.org/source/$(OPENSSL).tar.gz
OPENSSL_SOURCE		= $(SRCDIR)/$(OPENSSL).tar.gz
OPENSSL_DIR 		= $(BUILDDIR)/$(OPENSSL)
OPENSSL_IPKG_TMP	= $(OPENSSL_DIR)/ipkg_tmp


ifdef PTXCONF_ARCH_ARM
    THUD = linux-elf-arm
endif
ifdef PTXCONF_ARCH_SH
    THUD = linux-elf-sh
endif
ifdef PTXCONF_ARCH_X86
    THUD = linux-elf
endif
ifdef PTXCONF_OPT_i586
    THUD = linux-pentium
endif
ifdef PTXCONF_OPT_I686
    THUD = linux-ppro
endif
ifdef PTXCONF_ARCH_PPC
    THUD = linux-ppc
endif
ifdef PTXCONF_ARCH_SPARC
    THUD = linux-sparcv7
endif

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

openssl_get: $(STATEDIR)/openssl.get

$(STATEDIR)/openssl.get: $(OPENSSL_SOURCE)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OPENSSL))
	touch $@

$(OPENSSL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OPENSSL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

openssl_extract: $(STATEDIR)/openssl.extract

$(STATEDIR)/openssl.extract: $(STATEDIR)/openssl.get
	@$(call targetinfo, $@)
	@$(call clean, $(OPENSSL_DIR))
	@$(call extract, $(OPENSSL_SOURCE))
	@$(call patchin, $(OPENSSL))
	perl -p -i -e 's/-m486//' $(OPENSSL_DIR)/Configure
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

openssl_prepare: $(STATEDIR)/openssl.prepare

openssl_prepare_deps =  \
	$(STATEDIR)/virtual-xchain.install \
	$(STATEDIR)/openssl.extract 

OPENSSL_PATH	= PATH=$(CROSS_PATH)
OPENSSL_MAKEVARS = \
	$(CROSS_ENV_CC) \
	$(CROSS_ENV_RANLIB) \
	AR='$(PTXCONF_GNU_TARGET)-ar r' \
	MANDIR=/man

OPENSSL_AUTOCONF = \
	--prefix=/usr \
	--openssldir=/etc/ssl

ifdef PTXCONF_OPENSSL_SHARED
OPENSSL_AUTOCONF	+= shared
else
OPENSSL_AUTOCONF	+= no-shared
endif

$(STATEDIR)/openssl.prepare: $(openssl_prepare_deps)
	@$(call targetinfo, $@)
	cd $(OPENSSL_DIR) && \
		$(OPENSSL_PATH) \
		./Configure $(THUD) $(OPENSSL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

openssl_compile: $(STATEDIR)/openssl.compile

$(STATEDIR)/openssl.compile: $(STATEDIR)/openssl.prepare 
	@$(call targetinfo, $@)
#
# generate openssl.pc with correct path inside
#
	$(OPENSSL_PATH) $(MAKE) -C $(OPENSSL_DIR) INSTALLTOP=$(CROSS_LIB_DIR) EX_LIBS=-ldl openssl.pc
	$(OPENSSL_PATH) $(MAKE) -C $(OPENSSL_DIR) $(OPENSSL_MAKEVARS) EX_LIBS=-ldl
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

openssl_install: $(STATEDIR)/openssl.install

$(STATEDIR)/openssl.install: $(STATEDIR)/openssl.compile
	@$(call targetinfo, $@)
#
# broken Makfile, generates dir with wrong permissions...
# chmod 755 fixed that
#
	mkdir -p $(CROSS_LIB_DIR)/lib/pkgconfig
	chmod 755 $(CROSS_LIB_DIR)/lib/pkgconfig
	$(OPENSSL_PATH) $(MAKE) -C $(OPENSSL_DIR) install $(OPENSSL_MAKEVARS) \
		INSTALL_PREFIX=$(CROSS_LIB_DIR) INSTALLTOP=''
	chmod 755 $(CROSS_LIB_DIR)/lib/pkgconfig
#
# FIXME:
# 	OPENSSL=${D}/usr/bin/openssl /usr/bin/perl tools/c_rehash ${D}/etc/ssl/certs
#
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

openssl_targetinstall: $(STATEDIR)/openssl.targetinstall

openssl_targetinstall_deps = \
	$(STATEDIR)/openssl.install

$(STATEDIR)/openssl.targetinstall: $(openssl_targetinstall_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_OPENSSL_SHARED
	mkdir -p $(OPENSSL_IPKG_TMP)/usr/lib

	cp -d $(OPENSSL_DIR)/libssl.so*    $(OPENSSL_IPKG_TMP)/usr/lib/
	$(CROSSSTRIP) -R .note -R .comment $(OPENSSL_IPKG_TMP)/usr/lib/libssl.so*

	cp -d $(OPENSSL_DIR)/libcrypto.so* $(OPENSSL_IPKG_TMP)/usr/lib/
	$(CROSSSTRIP) -R .note -R .comment $(OPENSSL_IPKG_TMP)/usr/lib/libcrypto.so*

	mkdir -p $(OPENSSL_IPKG_TMP)/CONTROL
	echo "Package: openssl" 			>$(OPENSSL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(OPENSSL_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(OPENSSL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(OPENSSL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(OPENSSL_IPKG_TMP)/CONTROL/control
	echo "Version: $(OPENSSL_VERSION)" 		>>$(OPENSSL_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(OPENSSL_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder">>$(OPENSSL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OPENSSL_IPKG_TMP)
endif
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OPENSSL_INSTALL
ROMPACKAGES += $(STATEDIR)/openssl.imageinstall
endif

openssl_imageinstall_deps = $(STATEDIR)/openssl.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/openssl.imageinstall: $(openssl_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install openssl
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

openssl_clean: 
	rm -rf $(STATEDIR)/openssl.* $(OPENSSL_DIR)

# vim: syntax=make
