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
ifdef PTXCONF_QIV
PACKAGES += qiv
endif

#
# Paths and names
#
QIV_VENDOR_VERSION	= 1
QIV_VERSION		= 2.0
QIV			= qiv-$(QIV_VERSION)-src
QIV_SUFFIX		= tgz
QIV_URL			= http://www.kdown1.de/files/$(QIV).$(QIV_SUFFIX)
QIV_SOURCE		= $(SRCDIR)/$(QIV).$(QIV_SUFFIX)
QIV_DIR			= $(BUILDDIR)/qiv-$(QIV_VERSION)
QIV_IPKG_TMP		= $(QIV_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

qiv_get: $(STATEDIR)/qiv.get

qiv_get_deps = $(QIV_SOURCE)

$(STATEDIR)/qiv.get: $(qiv_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QIV))
	touch $@

$(QIV_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QIV_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

qiv_extract: $(STATEDIR)/qiv.extract

qiv_extract_deps = $(STATEDIR)/qiv.get

$(STATEDIR)/qiv.extract: $(qiv_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean,   $(QIV_DIR))
	@$(call extract, $(QIV_SOURCE))
	@$(call patchin, $(QIV), $(QIV_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

qiv_prepare: $(STATEDIR)/qiv.prepare

#
# dependencies
#
qiv_prepare_deps = \
	$(STATEDIR)/qiv.extract \
	$(STATEDIR)/gtk1210.install \
	$(STATEDIR)/imlib.install \
	$(STATEDIR)/virtual-xchain.install

QIV_PATH	=  PATH=$(CROSS_PATH)
QIV_ENV 	=  $(CROSS_ENV)
#QIV_ENV	+=
QIV_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#QIV_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
QIV_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
QIV_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
QIV_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/qiv.prepare: $(qiv_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QIV_DIR)/config.cache)
#	cd $(QIV_DIR) && \
#		$(QIV_PATH) $(QIV_ENV) \
#		./configure $(QIV_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

qiv_compile: $(STATEDIR)/qiv.compile

qiv_compile_deps = $(STATEDIR)/qiv.prepare

$(STATEDIR)/qiv.compile: $(qiv_compile_deps)
	@$(call targetinfo, $@)
	$(QIV_PATH) $(QIV_ENV) $(MAKE) -C $(QIV_DIR) $(CROSS_ENV_CC) OPT_LIBS=""
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

qiv_install: $(STATEDIR)/qiv.install

$(STATEDIR)/qiv.install: $(STATEDIR)/qiv.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

qiv_targetinstall: $(STATEDIR)/qiv.targetinstall

qiv_targetinstall_deps = $(STATEDIR)/qiv.compile \
	$(STATEDIR)/imlib.targetinstall \
	$(STATEDIR)/gtk1210.targetinstall

$(STATEDIR)/qiv.targetinstall: $(qiv_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(QIV_PATH) $(MAKE) -C $(QIV_DIR) DESTDIR=$(QIV_IPKG_TMP) install
	$(INSTALL) -D -m 755 $(QIV_DIR)/qiv $(QIV_IPKG_TMP)/usr/bin/qiv
	$(CROSSSTRIP) $(QIV_IPKG_TMP)/usr/bin/qiv
	mkdir -p $(QIV_IPKG_TMP)/CONTROL
	echo "Package: qiv" 											 >$(QIV_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(QIV_IPKG_TMP)/CONTROL/control
	echo "Section: Multimedia" 										>>$(QIV_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(QIV_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(QIV_IPKG_TMP)/CONTROL/control
	echo "Version: $(QIV_VERSION)-$(QIV_VENDOR_VERSION)" 							>>$(QIV_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk, imlib" 										>>$(QIV_IPKG_TMP)/CONTROL/control
	echo "Description: Quick image viewer"									>>$(QIV_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(QIV_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_QIV_INSTALL
ROMPACKAGES += $(STATEDIR)/qiv.imageinstall
endif

qiv_imageinstall_deps = $(STATEDIR)/qiv.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/qiv.imageinstall: $(qiv_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install qiv
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

qiv_clean:
	rm -rf $(STATEDIR)/qiv.*
	rm -rf $(QIV_DIR)

# vim: syntax=make
