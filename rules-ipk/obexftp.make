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
ifdef PTXCONF_OBEXFTP
PACKAGES += obexftp
endif

#
# Paths and names
#
OBEXFTP_VERSION		= 0.10.3
OBEXFTP			= obexftp-$(OBEXFTP_VERSION)
OBEXFTP_SUFFIX		= tar.gz
OBEXFTP_URL		= http://heanet.dl.sourceforge.net/sourceforge/openobex/$(OBEXFTP).$(OBEXFTP_SUFFIX)
OBEXFTP_SOURCE		= $(SRCDIR)/$(OBEXFTP).$(OBEXFTP_SUFFIX)
OBEXFTP_DIR		= $(BUILDDIR)/$(OBEXFTP)
OBEXFTP_IPKG_TMP	= $(OBEXFTP_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

obexftp_get: $(STATEDIR)/obexftp.get

obexftp_get_deps = $(OBEXFTP_SOURCE)

$(STATEDIR)/obexftp.get: $(obexftp_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(OBEXFTP))
	touch $@

$(OBEXFTP_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(OBEXFTP_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

obexftp_extract: $(STATEDIR)/obexftp.extract

obexftp_extract_deps = $(STATEDIR)/obexftp.get

$(STATEDIR)/obexftp.extract: $(obexftp_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OBEXFTP_DIR))
	@$(call extract, $(OBEXFTP_SOURCE))
	@$(call patchin, $(OBEXFTP))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

obexftp_prepare: $(STATEDIR)/obexftp.prepare

#
# dependencies
#
obexftp_prepare_deps = \
	$(STATEDIR)/obexftp.extract \
	$(STATEDIR)/openobex.install \
	$(STATEDIR)/virtual-xchain.install

OBEXFTP_PATH	=  PATH=$(CROSS_PATH)
OBEXFTP_ENV 	=  $(CROSS_ENV)
OBEXFTP_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
OBEXFTP_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#OBEXFTP_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
OBEXFTP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
OBEXFTP_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
OBEXFTP_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/obexftp.prepare: $(obexftp_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OBEXFTP_DIR)/config.cache)
	cd $(OBEXFTP_DIR) && \
		$(OBEXFTP_PATH) $(OBEXFTP_ENV) \
		./configure $(OBEXFTP_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

obexftp_compile: $(STATEDIR)/obexftp.compile

obexftp_compile_deps = $(STATEDIR)/obexftp.prepare

$(STATEDIR)/obexftp.compile: $(obexftp_compile_deps)
	@$(call targetinfo, $@)
	$(OBEXFTP_PATH) $(MAKE) -C $(OBEXFTP_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

obexftp_install: $(STATEDIR)/obexftp.install

$(STATEDIR)/obexftp.install: $(STATEDIR)/obexftp.compile
	@$(call targetinfo, $@)
	$(OBEXFTP_PATH) $(MAKE) -C $(OBEXFTP_DIR) DESTDIR=$(OBEXFTP_IPKG_TMP) install
	asdasd
	rm -rf $(OBEXFTP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

obexftp_targetinstall: $(STATEDIR)/obexftp.targetinstall

obexftp_targetinstall_deps = $(STATEDIR)/obexftp.compile \
	$(STATEDIR)/openobex.targetinstall

$(STATEDIR)/obexftp.targetinstall: $(obexftp_targetinstall_deps)
	@$(call targetinfo, $@)
	$(OBEXFTP_PATH) $(MAKE) -C $(OBEXFTP_DIR) DESTDIR=$(OBEXFTP_IPKG_TMP) install
	rm -rf $(OBEXFTP_IPKG_TMP)/*.html
	rm -rf $(OBEXFTP_IPKG_TMP)/usr/include
	rm -rf $(OBEXFTP_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(OBEXFTP_IPKG_TMP)/usr/man
	$(CROSSSTRIP) $(OBEXFTP_IPKG_TMP)/usr/bin/*
	$(CROSSSTRIP) $(OBEXFTP_IPKG_TMP)/usr/lib/*.so*
	mkdir -p $(OBEXFTP_IPKG_TMP)/CONTROL
	echo "Package: obexftp" 				>$(OBEXFTP_IPKG_TMP)/CONTROL/control
	echo "Priority: optional"	 			>>$(OBEXFTP_IPKG_TMP)/CONTROL/control
	echo "Section: IrDA"		 			>>$(OBEXFTP_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 	>>$(OBEXFTP_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(OBEXFTP_IPKG_TMP)/CONTROL/control
	echo "Version: $(OBEXFTP_VERSION)" 			>>$(OBEXFTP_IPKG_TMP)/CONTROL/control
	echo "Depends: openobex" 				>>$(OBEXFTP_IPKG_TMP)/CONTROL/control
	echo "Description: ObexFTP implements the Object Exchange (OBEX) protocols file transfer feature.">>$(OBEXFTP_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(OBEXFTP_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_OBEXFTP_INSTALL
ROMPACKAGES += $(STATEDIR)/obexftp.imageinstall
endif

obexftp_imageinstall_deps = $(STATEDIR)/obexftp.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/obexftp.imageinstall: $(obexftp_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install obexftp
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

obexftp_clean:
	rm -rf $(STATEDIR)/obexftp.*
	rm -rf $(OBEXFTP_DIR)

# vim: syntax=make
