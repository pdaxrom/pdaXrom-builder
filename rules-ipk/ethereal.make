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
ifdef PTXCONF_ETHEREAL
PACKAGES += ethereal
endif

#
# Paths and names
#
ETHEREAL_VENDOR_VERSION	= 1
ETHEREAL_VERSION	= 0.10.9
ETHEREAL		= ethereal-$(ETHEREAL_VERSION)
ETHEREAL_SUFFIX		= tar.bz2
ETHEREAL_URL		= http://www.ethereal.com/distribution/$(ETHEREAL).$(ETHEREAL_SUFFIX)
ETHEREAL_SOURCE		= $(SRCDIR)/$(ETHEREAL).$(ETHEREAL_SUFFIX)
ETHEREAL_DIR		= $(BUILDDIR)/$(ETHEREAL)
ETHEREAL_IPKG_TMP	= $(ETHEREAL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ethereal_get: $(STATEDIR)/ethereal.get

ethereal_get_deps = $(ETHEREAL_SOURCE)

$(STATEDIR)/ethereal.get: $(ethereal_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ETHEREAL))
	touch $@

$(ETHEREAL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ETHEREAL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ethereal_extract: $(STATEDIR)/ethereal.extract

ethereal_extract_deps = $(STATEDIR)/ethereal.get

$(STATEDIR)/ethereal.extract: $(ethereal_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ETHEREAL_DIR))
	@$(call extract, $(ETHEREAL_SOURCE))
	@$(call patchin, $(ETHEREAL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ethereal_prepare: $(STATEDIR)/ethereal.prepare

#
# dependencies
#
ethereal_prepare_deps = \
	$(STATEDIR)/ethereal.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libpcap.install \
	$(STATEDIR)/pcre.install \
	$(STATEDIR)/virtual-xchain.install

ETHEREAL_PATH	=  PATH=$(CROSS_PATH)
ETHEREAL_ENV 	=  $(CROSS_ENV)
ETHEREAL_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
ETHEREAL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ETHEREAL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/X11R6/lib
#endif

#
# autoconf
#
ETHEREAL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--with-ssl=$(CROSS_LIB_DIR) \
	--enable-randpkt \
	--enable-shared \
	--disable-static \
	--disable-usr-local \
	--sysconfdir=/etc

ifdef PTXCONF_XFREE430
ETHEREAL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ETHEREAL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ethereal.prepare: $(ethereal_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ETHEREAL_DIR)/config.cache)
	##cd $(ETHEREAL_DIR) && $(ETHEREAL_PATH) ./autogen.sh
	cd $(ETHEREAL_DIR) && \
		$(ETHEREAL_PATH) $(ETHEREAL_ENV) \
		ac_cv_path_POD2MAN=true \
		ac_cv_path_POD2HTML=true \
		./configure $(ETHEREAL_AUTOCONF)
	###cp -a $(PTXCONF_PREFIX)/bin/libtool $(ETHEREAL_DIR)/
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ethereal_compile: $(STATEDIR)/ethereal.compile

ethereal_compile_deps = $(STATEDIR)/ethereal.prepare

$(STATEDIR)/ethereal.compile: $(ethereal_compile_deps)
	@$(call targetinfo, $@)
	$(ETHEREAL_PATH) $(MAKE) -C $(ETHEREAL_DIR) HOST_CC=gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ethereal_install: $(STATEDIR)/ethereal.install

$(STATEDIR)/ethereal.install: $(STATEDIR)/ethereal.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ethereal_targetinstall: $(STATEDIR)/ethereal.targetinstall

ethereal_targetinstall_deps = $(STATEDIR)/ethereal.compile

$(STATEDIR)/ethereal.targetinstall: $(ethereal_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ETHEREAL_PATH) $(MAKE) -C $(ETHEREAL_DIR) DESTDIR=$(ETHEREAL_IPKG_TMP) install
	rm -rf $(ETHEREAL_IPKG_TMP)/usr/man
	rm  -f $(ETHEREAL_IPKG_TMP)/usr/share/ethereal/*.html
	rm  -f $(ETHEREAL_IPKG_TMP)/usr/lib/*.*a
	rm  -f $(ETHEREAL_IPKG_TMP)/usr/lib/ethereal/plugins/$(ETHEREAL_VERSION)/*.*a

	for FILE in `find $(ETHEREAL_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done

	$(INSTALL) -D -m 644 $(TOPDIR)/config/pics/ethereal.desktop $(ETHEREAL_IPKG_TMP)/usr/share/applications/ethereal.desktop
	$(INSTALL) -D -m 644 $(ETHEREAL_DIR)/image/elogo3d48x48.png $(ETHEREAL_IPKG_TMP)/usr/share/pixmaps/elogo3d48x48.png

	mkdir -p $(ETHEREAL_IPKG_TMP)/CONTROL
	echo "Package: ethereal" 							 >$(ETHEREAL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 							>>$(ETHEREAL_IPKG_TMP)/CONTROL/control
	echo "Section: Network" 							>>$(ETHEREAL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 				>>$(ETHEREAL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 						>>$(ETHEREAL_IPKG_TMP)/CONTROL/control
	echo "Version: $(ETHEREAL_VERSION)-$(ETHEREAL_VENDOR_VERSION)" 			>>$(ETHEREAL_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, pcre" 							>>$(ETHEREAL_IPKG_TMP)/CONTROL/control
	echo "Description: Ethereal is used by network professionals around the world for troubleshooting, analysis, software and protocol development, and education." >>$(ETHEREAL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ETHEREAL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_ETHEREAL_INSTALL
ROMPACKAGES += $(STATEDIR)/ethereal.imageinstall
endif

ethereal_imageinstall_deps = $(STATEDIR)/ethereal.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/ethereal.imageinstall: $(ethereal_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install ethereal
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ethereal_clean:
	rm -rf $(STATEDIR)/ethereal.*
	rm -rf $(ETHEREAL_DIR)

# vim: syntax=make
