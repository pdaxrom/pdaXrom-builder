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
ifdef PTXCONF_ORBIT2
PACKAGES += ORBit2
endif

#
# Paths and names
#
ORBIT2_VERSION		= 2.10.2
ORBIT2			= ORBit2-$(ORBIT2_VERSION)
ORBIT2_SUFFIX		= tar.bz2
ORBIT2_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/ORBit2/2.10/$(ORBIT2).$(ORBIT2_SUFFIX)
ORBIT2_SOURCE		= $(SRCDIR)/$(ORBIT2).$(ORBIT2_SUFFIX)
ORBIT2_DIR		= $(BUILDDIR)/$(ORBIT2)
ORBIT2_IPKG_TMP		= $(ORBIT2_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ORBit2_get: $(STATEDIR)/ORBit2.get

ORBit2_get_deps = $(ORBIT2_SOURCE)

$(STATEDIR)/ORBit2.get: $(ORBit2_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(ORBIT2))
	touch $@

$(ORBIT2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(ORBIT2_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ORBit2_extract: $(STATEDIR)/ORBit2.extract

ORBit2_extract_deps = $(STATEDIR)/ORBit2.get

$(STATEDIR)/ORBit2.extract: $(ORBit2_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ORBIT2_DIR))
	@$(call extract, $(ORBIT2_SOURCE))
	@$(call patchin, $(ORBIT2))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ORBit2_prepare: $(STATEDIR)/ORBit2.prepare

#
# dependencies
#
ORBit2_prepare_deps = \
	$(STATEDIR)/ORBit2.extract \
	$(STATEDIR)/popt.install \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/libIDL082.install \
	$(STATEDIR)/xchain-ORBit2.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_LIBICONV
ORBit2_prepare_deps += 	$(STATEDIR)/libiconv.install
endif

ORBIT2_PATH	=  PATH=$(CROSS_PATH)
ORBIT2_ENV 	=  $(CROSS_ENV)
ORBIT2_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
ORBIT2_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#ORBIT2_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
ORBIT2_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static

ifdef PTXCONF_XFREE430
ORBIT2_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
ORBIT2_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ORBit2.prepare: $(ORBit2_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ORBIT2_DIR)/config.cache)
	cd $(ORBIT2_DIR) && \
		$(ORBIT2_PATH) $(ORBIT2_ENV) $(ORBIT2X_ENV) \
		./configure $(ORBIT2_AUTOCONF) -C
	cp -f $(PTXCONF_PREFIX)/bin/libtool $(ORBIT2_DIR)/
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ORBit2_compile: $(STATEDIR)/ORBit2.compile

ORBit2_compile_deps = $(STATEDIR)/ORBit2.prepare

$(STATEDIR)/ORBit2.compile: $(ORBit2_compile_deps)
	@$(call targetinfo, $@)
	$(ORBIT2_PATH) $(MAKE) -C $(ORBIT2_DIR) IDL_COMPILER=$(PTXCONF_PREFIX)/bin/orbit-idl-2
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ORBit2_install: $(STATEDIR)/ORBit2.install

$(STATEDIR)/ORBit2.install: $(STATEDIR)/ORBit2.compile
	@$(call targetinfo, $@)
	$(ORBIT2_PATH) $(MAKE) -C $(ORBIT2_DIR) DESTDIR=$(ORBIT2_IPKG_TMP) install IDL_COMPILER=$(PTXCONF_PREFIX)/bin/orbit-idl-2
	cp -a  $(ORBIT2_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(ORBIT2_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	cp -a  $(ORBIT2_IPKG_TMP)/usr/bin/orbit2-config  $(PTXCONF_PREFIX)/bin
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/bin/orbit2-config
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libORBit-2.la
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libORBit-imodule-2.la
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libORBitCosNaming-2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/ORBit-2.0.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/ORBit-CosNaming-2.0.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/ORBit-idl-2.0.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/ORBit-imodule-2.0.pc
	ln -sf $(PTXCONF_PREFIX)/bin/orbit-idl-2 $(CROSS_LIB_DIR)/bin/orbit-idl-2
	rm -rf $(ORBIT2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ORBit2_targetinstall: $(STATEDIR)/ORBit2.targetinstall

ORBit2_targetinstall_deps = \
	$(STATEDIR)/ORBit2.compile \
	$(STATEDIR)/popt.targetinstall \
	$(STATEDIR)/glib22.targetinstall

ifdef PTXCONF_LIBICONV
ORBit2_targetinstall_deps += $(STATEDIR)/libiconv.targetinstall
endif

$(STATEDIR)/ORBit2.targetinstall: $(ORBit2_targetinstall_deps)
	@$(call targetinfo, $@)
	$(ORBIT2_PATH) $(MAKE) -C $(ORBIT2_DIR) DESTDIR=$(ORBIT2_IPKG_TMP) install IDL_COMPILER=$(PTXCONF_PREFIX)/bin/orbit-idl-2
	rm -rf $(ORBIT2_IPKG_TMP)/usr/bin/orbit2-config
	rm -rf $(ORBIT2_IPKG_TMP)/usr/include
	rm -rf $(ORBIT2_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(ORBIT2_IPKG_TMP)/usr/lib/orbit-2.0/*.a
	###rm -rf $(ORBIT2_IPKG_TMP)/usr/lib/orbit-2.0/*.la
	rm -rf $(ORBIT2_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(ORBIT2_IPKG_TMP)/usr/share/aclocal
	rm -rf $(ORBIT2_IPKG_TMP)/usr/share/gtk-doc
	for FILE in `find $(ORBIT2_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(ORBIT2_IPKG_TMP)/CONTROL
	echo "Package: orbit2" 			>$(ORBIT2_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(ORBIT2_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 			>>$(ORBIT2_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(ORBIT2_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(ORBIT2_IPKG_TMP)/CONTROL/control
	echo "Version: $(ORBIT2_VERSION)" 		>>$(ORBIT2_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_LIBICONV
	echo "Depends: glib2, libiconv, popt" 		>>$(ORBIT2_IPKG_TMP)/CONTROL/control
else
	echo "Depends: glib2, popt" 			>>$(ORBIT2_IPKG_TMP)/CONTROL/control
endif
	echo "Description: High-performance CORBA Object Request Broker">>$(ORBIT2_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(ORBIT2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ORBit2_clean:
	rm -rf $(STATEDIR)/ORBit2.*
	rm -rf $(ORBIT2_DIR)

# vim: syntax=make
