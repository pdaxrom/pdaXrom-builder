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
ifdef PTXCONF_FILE
PACKAGES += file
endif

#
# Paths and names
#
FILE_VERSION		= 4.09
FILE			= file-$(FILE_VERSION)
FILE_SUFFIX		= tar.gz
FILE_URL		= ftp://ftp.gw.com/mirrors/pub/unix/file/$(FILE).$(FILE_SUFFIX)
FILE_SOURCE		= $(SRCDIR)/$(FILE).$(FILE_SUFFIX)
FILE_DIR		= $(BUILDDIR)/$(FILE)
FILE_IPKG_TMP		= $(FILE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

file_get: $(STATEDIR)/file.get

file_get_deps = $(FILE_SOURCE)

$(STATEDIR)/file.get: $(file_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FILE))
	touch $@

$(FILE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FILE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

file_extract: $(STATEDIR)/file.extract

file_extract_deps = $(STATEDIR)/file.get

$(STATEDIR)/file.extract: $(file_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FILE_DIR))
	@$(call extract, $(FILE_SOURCE))
	@$(call patchin, $(FILE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

file_prepare: $(STATEDIR)/file.prepare

#
# dependencies
#
file_prepare_deps = \
	$(STATEDIR)/file.extract \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/virtual-xchain.install

FILE_PATH	=  PATH=$(CROSS_PATH)
FILE_ENV 	=  $(CROSS_ENV)
#FILE_ENV	+=
FILE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FILE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
FILE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-static \
	--disable-shared

ifdef PTXCONF_XFREE430
FILE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FILE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/file.prepare: $(file_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FILE_DIR)/config.cache)
	cd $(FILE_DIR) && \
		$(FILE_PATH) $(FILE_ENV) \
		./configure $(FILE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

file_compile: $(STATEDIR)/file.compile

file_compile_deps = $(STATEDIR)/file.prepare

$(STATEDIR)/file.compile: $(file_compile_deps)
	@$(call targetinfo, $@)
	$(FILE_PATH) $(MAKE) -C $(FILE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

file_install: $(STATEDIR)/file.install

$(STATEDIR)/file.install: $(STATEDIR)/file.compile
	@$(call targetinfo, $@)
	###$(FILE_PATH) $(MAKE) -C $(FILE_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

file_targetinstall: $(STATEDIR)/file.targetinstall

file_targetinstall_deps = \
	$(STATEDIR)/file.compile \
	$(STATEDIR)/zlib.targetinstall

$(STATEDIR)/file.targetinstall: $(file_targetinstall_deps)
	@$(call targetinfo, $@)
	$(FILE_PATH) $(MAKE) -C $(FILE_DIR) DESTDIR=$(FILE_IPKG_TMP) install
	$(CROSSSTRIP) $(FILE_IPKG_TMP)/usr/bin/file
	rm -rf $(FILE_IPKG_TMP)/usr/include
	rm -rf $(FILE_IPKG_TMP)/usr/lib
	rm -rf $(FILE_IPKG_TMP)/usr/man
	rm  -f $(FILE_IPKG_TMP)/usr/share/file/magic.mgc
	rm  -f $(FILE_IPKG_TMP)/usr/share/file/magic.mime.mgc
	mkdir -p $(FILE_IPKG_TMP)/CONTROL
	echo "Package: file" 				>$(FILE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(FILE_IPKG_TMP)/CONTROL/control
	echo "Section: Utils"	 			>>$(FILE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(FILE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(FILE_IPKG_TMP)/CONTROL/control
	echo "Version: $(FILE_VERSION)" 		>>$(FILE_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(FILE_IPKG_TMP)/CONTROL/control
	echo "Description: file - determine file type.">>$(FILE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FILE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FILE_INSTALL
ROMPACKAGES += $(STATEDIR)/file.imageinstall
endif

file_imageinstall_deps = $(STATEDIR)/file.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/file.imageinstall: $(file_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install file
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

file_clean:
	rm -rf $(STATEDIR)/file.*
	rm -rf $(FILE_DIR)

# vim: syntax=make
