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
ifdef PTXCONF_GAIL
PACKAGES += gail
endif

#
# Paths and names
#
GAIL_VERSION		= 1.6.5
GAIL			= gail-$(GAIL_VERSION)
GAIL_SUFFIX		= tar.bz2
GAIL_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/gail/1.6/$(GAIL).$(GAIL_SUFFIX)
GAIL_SOURCE		= $(SRCDIR)/$(GAIL).$(GAIL_SUFFIX)
GAIL_DIR		= $(BUILDDIR)/$(GAIL)
GAIL_IPKG_TMP		= $(GAIL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gail_get: $(STATEDIR)/gail.get

gail_get_deps = $(GAIL_SOURCE)

$(STATEDIR)/gail.get: $(gail_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GAIL))
	touch $@

$(GAIL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GAIL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gail_extract: $(STATEDIR)/gail.extract

gail_extract_deps = $(STATEDIR)/gail.get

$(STATEDIR)/gail.extract: $(gail_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GAIL_DIR))
	@$(call extract, $(GAIL_SOURCE))
	@$(call patchin, $(GAIL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gail_prepare: $(STATEDIR)/gail.prepare

#
# dependencies
#
gail_prepare_deps = \
	$(STATEDIR)/gail.extract \
	$(STATEDIR)/gtk22.install \
	$(STATEDIR)/libgnomecanvas.install \
	$(STATEDIR)/virtual-xchain.install

GAIL_PATH	=  PATH=$(CROSS_PATH)
GAIL_ENV 	=  $(CROSS_ENV)
GAIL_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
GAIL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GAIL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GAIL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug

ifdef PTXCONF_XFREE430
GAIL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GAIL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gail.prepare: $(gail_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GAIL_DIR)/config.cache)
	cd $(GAIL_DIR) && \
		$(GAIL_PATH) $(GAIL_ENV) \
		./configure $(GAIL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gail_compile: $(STATEDIR)/gail.compile

gail_compile_deps = $(STATEDIR)/gail.prepare

$(STATEDIR)/gail.compile: $(gail_compile_deps)
	@$(call targetinfo, $@)
	$(GAIL_PATH) $(MAKE) -C $(GAIL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gail_install: $(STATEDIR)/gail.install

$(STATEDIR)/gail.install: $(STATEDIR)/gail.compile
	@$(call targetinfo, $@)
	$(GAIL_PATH) $(MAKE) -C $(GAIL_DIR) DESTDIR=$(GAIL_IPKG_TMP) install
	cp -a  $(GAIL_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(GAIL_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgailutil.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gail.pc
	rm -rf $(GAIL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gail_targetinstall: $(STATEDIR)/gail.targetinstall

gail_targetinstall_deps = $(STATEDIR)/gail.compile \
	$(STATEDIR)/gtk22.targetinstall \
	$(STATEDIR)/libgnomecanvas.targetinstall

$(STATEDIR)/gail.targetinstall: $(gail_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GAIL_PATH) $(MAKE) -C $(GAIL_DIR) DESTDIR=$(GAIL_IPKG_TMP) install
	rm -rf $(GAIL_IPKG_TMP)/usr/include
	rm -rf $(GAIL_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(GAIL_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(GAIL_IPKG_TMP)/usr/share
	for FILE in `find $(GAIL_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(GAIL_IPKG_TMP)/CONTROL
	echo "Package: gail" 				>$(GAIL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(GAIL_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome"	 			>>$(GAIL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(GAIL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(GAIL_IPKG_TMP)/CONTROL/control
	echo "Version: $(GAIL_VERSION)" 		>>$(GAIL_IPKG_TMP)/CONTROL/control
	echo "Depends: libgnomecanvas, gtk2" 		>>$(GAIL_IPKG_TMP)/CONTROL/control
	echo "Description: GNOME Accessibility Implementation Library">>$(GAIL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GAIL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gail_clean:
	rm -rf $(STATEDIR)/gail.*
	rm -rf $(GAIL_DIR)

# vim: syntax=make
