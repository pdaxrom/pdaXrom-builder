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
ifdef PTXCONF_IPUTILS
PACKAGES += iputils
endif

#
# Paths and names
#
IPUTILS_VENDOR_VERSION	= 1
IPUTILS_VERSION		= 020927
IPUTILS			= iputils-ss$(IPUTILS_VERSION)
IPUTILS_SUFFIX		= tar.gz
IPUTILS_URL		= http://www.tux.org/pub/people/alexey-kuznetsov/ip-routing/$(IPUTILS).$(IPUTILS_SUFFIX)
IPUTILS_SOURCE		= $(SRCDIR)/$(IPUTILS).$(IPUTILS_SUFFIX)
IPUTILS_DIR		= $(BUILDDIR)/iputils
IPUTILS_IPKG_TMP	= $(IPUTILS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

iputils_get: $(STATEDIR)/iputils.get

iputils_get_deps = $(IPUTILS_SOURCE)

$(STATEDIR)/iputils.get: $(iputils_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(IPUTILS))
	touch $@

$(IPUTILS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(IPUTILS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

iputils_extract: $(STATEDIR)/iputils.extract

iputils_extract_deps = $(STATEDIR)/iputils.get

$(STATEDIR)/iputils.extract: $(iputils_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(IPUTILS_DIR))
	@$(call extract, $(IPUTILS_SOURCE))
	@$(call patchin, $(IPUTILS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

iputils_prepare: $(STATEDIR)/iputils.prepare

#
# dependencies
#
iputils_prepare_deps = \
	$(STATEDIR)/iputils.extract \
	$(STATEDIR)/virtual-xchain.install

IPUTILS_PATH	=  PATH=$(CROSS_PATH)
IPUTILS_ENV 	=  $(CROSS_ENV)
#IPUTILS_ENV	+=
IPUTILS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#IPUTILS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
IPUTILS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
IPUTILS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
IPUTILS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/iputils.prepare: $(iputils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(IPUTILS_DIR)/config.cache)
	#cd $(IPUTILS_DIR) && \
	#	$(IPUTILS_PATH) $(IPUTILS_ENV) \
	#	./configure $(IPUTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

iputils_compile: $(STATEDIR)/iputils.compile

iputils_compile_deps = $(STATEDIR)/iputils.prepare

$(STATEDIR)/iputils.compile: $(iputils_compile_deps)
	@$(call targetinfo, $@)
	$(IPUTILS_PATH) $(MAKE) -C $(IPUTILS_DIR) $(CROSS_ENV_CC) KERNEL_INCLUDE=$(KERNEL_DIR)/include LIBC_INCLUDE=$(CROSS_LIB_DIR)/include
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

iputils_install: $(STATEDIR)/iputils.install

$(STATEDIR)/iputils.install: $(STATEDIR)/iputils.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

iputils_targetinstall: $(STATEDIR)/iputils.targetinstall

iputils_targetinstall_deps = $(STATEDIR)/iputils.compile

$(STATEDIR)/iputils.targetinstall: $(iputils_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(IPUTILS_IPKG_TMP)/usr/{bin,sbin}
	cp -a $(IPUTILS_DIR)/ping $(IPUTILS_IPKG_TMP)/usr/bin/
	cp -a $(IPUTILS_DIR)/{ipg,tracepath,clockdiff,rdisc,arping,tftpd,rarpd,tracepath6,traceroute6,ping6} $(IPUTILS_IPKG_TMP)/usr/sbin/
	$(CROSSSTRIP) $(IPUTILS_IPKG_TMP)/usr/bin/ping
	$(CROSSSTRIP) $(IPUTILS_IPKG_TMP)/usr/sbin/{tracepath,clockdiff,rdisc,arping,tftpd,rarpd,tracepath6,traceroute6,ping6}
	mkdir -p $(IPUTILS_IPKG_TMP)/CONTROL
	echo "Package: iputils" 							 >$(IPUTILS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(IPUTILS_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(IPUTILS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(IPUTILS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(IPUTILS_IPKG_TMP)/CONTROL/control
	echo "Version: $(IPUTILS_VERSION)-$(IPUTILS_VENDOR_VERSION)" 			>>$(IPUTILS_IPKG_TMP)/CONTROL/control
	echo "Depends: " 								>>$(IPUTILS_IPKG_TMP)/CONTROL/control
	echo "Description: IP utilities"						>>$(IPUTILS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(IPUTILS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_IPUTILS_INSTALL
ROMPACKAGES += $(STATEDIR)/iputils.imageinstall
endif

iputils_imageinstall_deps = $(STATEDIR)/iputils.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/iputils.imageinstall: $(iputils_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install iputils
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

iputils_clean:
	rm -rf $(STATEDIR)/iputils.*
	rm -rf $(IPUTILS_DIR)

# vim: syntax=make
