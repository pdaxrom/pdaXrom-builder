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
ifdef PTXCONF_MONO
PACKAGES += mono
endif

#
# Paths and names
#
MONO_VENDOR_VERSION	= 1
MONO_VERSION		= 1.0.5
MONO			= mono-$(MONO_VERSION)
MONO_SUFFIX		= tar.gz
MONO_URL		= http://www.go-mono.com/archive/1.0.5/$(MONO).$(MONO_SUFFIX)
MONO_SOURCE		= $(SRCDIR)/$(MONO).$(MONO_SUFFIX)
MONO_DIR		= $(BUILDDIR)/$(MONO)
MONO_IPKG_TMP		= $(MONO_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mono_get: $(STATEDIR)/mono.get

mono_get_deps = $(MONO_SOURCE)

$(STATEDIR)/mono.get: $(mono_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(MONO))
	touch $@

$(MONO_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(MONO_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mono_extract: $(STATEDIR)/mono.extract

mono_extract_deps = $(STATEDIR)/mono.get

$(STATEDIR)/mono.extract: $(mono_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MONO_DIR))
	@$(call extract, $(MONO_SOURCE))
	@$(call patchin, $(MONO))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mono_prepare: $(STATEDIR)/mono.prepare

#
# dependencies
#
mono_prepare_deps = \
	$(STATEDIR)/mono.extract \
	$(STATEDIR)/xchain-mono.install \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LIBICONV
mono_prepare_deps += $(STATEDIR)/libiconv.install
endif

MONO_PATH	=  PATH=$(CROSS_PATH)
MONO_ENV 	=  $(CROSS_ENV)
MONO_ENV	+= CFLAGS="$(TARGET_OPT_CFLAGS)"
MONO_ENV	+= CXXFLAGS="$(TARGET_OPT_CFLAGS)"
MONO_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#MONO_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
MONO_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--target=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--with-tls=pthread \
	--sysconfdir=/etc \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
MONO_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
MONO_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/mono.prepare: $(mono_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MONO_DIR)/config.cache)
	cd $(MONO_DIR) && \
		$(MONO_PATH) $(MONO_ENV) \
		./configure $(MONO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mono_compile: $(STATEDIR)/mono.compile

mono_compile_deps = $(STATEDIR)/mono.prepare

$(STATEDIR)/mono.compile: $(mono_compile_deps)
	@$(call targetinfo, $@)
	$(MONO_PATH) $(MAKE) -C $(MONO_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mono_install: $(STATEDIR)/mono.install

$(STATEDIR)/mono.install: $(STATEDIR)/mono.compile
	@$(call targetinfo, $@)
	rm -rf $(MONO_IPKG_TMP)
	$(MONO_PATH) $(MAKE) -C $(MONO_DIR) DESTDIR=$(MONO_IPKG_TMP) install mkdir_p="mkdir -p" mono_runtime=$(XCHAIN_MONO_DIR)/mono/interpreter/mint
	asdasd
	rm -rf $(MONO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mono_targetinstall: $(STATEDIR)/mono.targetinstall

mono_targetinstall_deps = $(STATEDIR)/mono.compile \
	$(STATEDIR)/glib22.targetinstall

ifdef PTXCONF_LIBICONV
mono_targetinstall_deps += $(STATEDIR)/libiconv.targetinstall
endif

$(STATEDIR)/mono.targetinstall: $(mono_targetinstall_deps)
	@$(call targetinfo, $@)
	$(MONO_PATH) $(MAKE) -C $(MONO_DIR) DESTDIR=$(MONO_IPKG_TMP) install mkdir_p="mkdir -p" mono_runtime=$(XCHAIN_MONO_DIR)/mono/interpreter/mint
	rm -rf $(MONO_IPKG_TMP)/usr/include
	rm -rf $(MONO_IPKG_TMP)/usr/lib/pkgconfig
	rm  -f $(MONO_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(MONO_IPKG_TMP)/usr/man
	rm -rf $(MONO_IPKG_TMP)/usr/share/libgc-mono
	$(CROSSSTRIP) $(MONO_IPKG_TMP)/usr/bin/$(PTXCONF_GNU_TARGET)-mint
	$(CROSSSTRIP) $(MONO_IPKG_TMP)/usr/bin/$(PTXCONF_GNU_TARGET)-monodis
	$(CROSSSTRIP) $(MONO_IPKG_TMP)/usr/bin/$(PTXCONF_GNU_TARGET)-monograph
	$(CROSSSTRIP) $(MONO_IPKG_TMP)/usr/bin/$(PTXCONF_GNU_TARGET)-pedump
	$(CROSSSTRIP) $(MONO_IPKG_TMP)/usr/lib/*.so*

	cd $(MONO_IPKG_TMP)/usr/bin && \
	for file in $(PTXCONF_GNU_TARGET)-*; do \
	    ln -sf "$$file" "`echo $$file | cut -d'-' -f 4`"; \
	done

	mkdir -p $(MONO_IPKG_TMP)/CONTROL
	echo "Package: mono" 							 				 >$(MONO_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 										>>$(MONO_IPKG_TMP)/CONTROL/control
	echo "Section: NET" 											>>$(MONO_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 							>>$(MONO_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 									>>$(MONO_IPKG_TMP)/CONTROL/control
	echo "Version: $(MONO_VERSION)-$(MONO_VENDOR_VERSION)" 							>>$(MONO_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_LIBICONV
	echo "Depends: glib2, libiconv" 									>>$(MONO_IPKG_TMP)/CONTROL/control
else
	echo "Depends: glib2"		 									>>$(MONO_IPKG_TMP)/CONTROL/control
endif
	echo "Description: Mono Runtime"									>>$(MONO_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(MONO_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_MONO_INSTALL
ROMPACKAGES += $(STATEDIR)/mono.imageinstall
endif

mono_imageinstall_deps = $(STATEDIR)/mono.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/mono.imageinstall: $(mono_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install mono
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mono_clean:
	rm -rf $(STATEDIR)/mono.*
	rm -rf $(MONO_DIR)

# vim: syntax=make
