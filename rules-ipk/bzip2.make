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
ifdef PTXCONF_UBZIP2
PACKAGES += ubzip2
endif

#
# Paths and names
#
UBZIP2_VERSION		= 1.0.2
UBZIP2			= bzip2-$(UBZIP2_VERSION)
UBZIP2_SUFFIX		= tar.gz
UBZIP2_URL		= ftp://sources.redhat.com/pub/bzip2/v102/$(UBZIP2).$(UBZIP2_SUFFIX)
UBZIP2_SOURCE		= $(SRCDIR)/$(UBZIP2).$(UBZIP2_SUFFIX)
UBZIP2_DIR		= $(BUILDDIR)/$(UBZIP2)
UBZIP2_IPKG_TMP		= $(UBZIP2_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ubzip2_get: $(STATEDIR)/ubzip2.get

ubzip2_get_deps = $(UBZIP2_SOURCE)

$(STATEDIR)/ubzip2.get: $(ubzip2_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(UBZIP2))
	touch $@

$(UBZIP2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(UBZIP2_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ubzip2_extract: $(STATEDIR)/ubzip2.extract

ubzip2_extract_deps = $(STATEDIR)/ubzip2.get

$(STATEDIR)/ubzip2.extract: $(ubzip2_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UBZIP2_DIR))
	@$(call extract, $(UBZIP2_SOURCE))
	@$(call patchin, $(UBZIP2))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ubzip2_prepare: $(STATEDIR)/ubzip2.prepare

#
# dependencies
#
ubzip2_prepare_deps = \
	$(STATEDIR)/ubzip2.extract \
	$(STATEDIR)/virtual-xchain.install

UBZIP2_PATH	=  PATH=$(CROSS_PATH)
UBZIP2_ENV 	=  $(CROSS_ENV)
###UBZIP2_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
UBZIP2_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#UBZIP2_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
UBZIP2_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--disable-debug \
	--disable-static \
	--enable-shared

ifdef PTXCONF_XFREE430
UBZIP2_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
UBZIP2_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/ubzip2.prepare: $(ubzip2_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UBZIP2_DIR)/config.cache)
	#cd $(UBZIP2_DIR) && \
	#	$(UBZIP2_PATH) $(UBZIP2_ENV) \
	#	./configure $(UBZIP2_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ubzip2_compile: $(STATEDIR)/ubzip2.compile

ubzip2_compile_deps = $(STATEDIR)/ubzip2.prepare

$(STATEDIR)/ubzip2.compile: $(ubzip2_compile_deps)
	@$(call targetinfo, $@)
	$(UBZIP2_PATH) $(MAKE) -C $(UBZIP2_DIR) -f Makefile-libbz2_so $(UBZIP2_ENV)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ubzip2_install: $(STATEDIR)/ubzip2.install

$(STATEDIR)/ubzip2.install: $(STATEDIR)/ubzip2.compile
	@$(call targetinfo, $@)
	###$(UBZIP2_PATH) $(MAKE) -C $(UBZIP2_DIR) DESTDIR=$(UBZIP2_IPKG_TMP) install $(UBZIP2_ENV)
	cp -a $(UBZIP2_DIR)/libbz2.so* $(CROSS_LIB_DIR)/lib
	cp -a $(UBZIP2_DIR)/bzlib.h    $(CROSS_LIB_DIR)/include
	ln -sf libbz2.so.1.0          $(CROSS_LIB_DIR)/lib/libbz2.so
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ubzip2_targetinstall: $(STATEDIR)/ubzip2.targetinstall

ubzip2_targetinstall_deps = $(STATEDIR)/ubzip2.compile

$(STATEDIR)/ubzip2.targetinstall: $(ubzip2_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(UBZIP2_PATH) $(MAKE) -C $(UBZIP2_DIR) DESTDIR=$(UBZIP2_IPKG_TMP) install
	mkdir -p $(UBZIP2_IPKG_TMP)/usr/bin
	mkdir -p $(UBZIP2_IPKG_TMP)/usr/lib
	cp -a $(UBZIP2_DIR)/libbz2.so*   $(UBZIP2_IPKG_TMP)/usr/lib
	cp -a $(UBZIP2_DIR)/bzip2-shared $(UBZIP2_IPKG_TMP)/usr/bin/bzip2
	ln -sf libbz2.so.1.0             $(UBZIP2_IPKG_TMP)/usr/lib/libbz2.so
	ln -sf bzip2			 $(UBZIP2_IPKG_TMP)/usr/bin/bunzip2
	ln -sf bzip2			 $(UBZIP2_IPKG_TMP)/usr/bin/bzcat
	for FILE in `find $(UBZIP2_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(UBZIP2_IPKG_TMP)/CONTROL
	echo "Package: bzip2" 				>$(UBZIP2_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(UBZIP2_IPKG_TMP)/CONTROL/control
	echo "Section: Utils" 				>>$(UBZIP2_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(UBZIP2_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(UBZIP2_IPKG_TMP)/CONTROL/control
	echo "Version: $(UBZIP2_VERSION)" 		>>$(UBZIP2_IPKG_TMP)/CONTROL/control
	echo "Depends: " 				>>$(UBZIP2_IPKG_TMP)/CONTROL/control
	echo "Description: a block-sorting file compressor">>$(UBZIP2_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(UBZIP2_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ubzip2_clean:
	rm -rf $(STATEDIR)/ubzip2.*
	rm -rf $(UBZIP2_DIR)

# vim: syntax=make
