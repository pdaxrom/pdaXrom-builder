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
ifdef PTXCONF_SQLITE
PACKAGES += sqlite
endif

#
# Paths and names
#
###SQLITE_VERSION		= 2.8.13
SQLITE_VERSION		= 3.0.8
SQLITE			= sqlite-$(SQLITE_VERSION)
SQLITE_SUFFIX		= tar.gz
SQLITE_URL		= http://www.sqlite.org/$(SQLITE).$(SQLITE_SUFFIX)
SQLITE_SOURCE		= $(SRCDIR)/$(SQLITE).$(SQLITE_SUFFIX)
SQLITE_DIR		= $(BUILDDIR)/sqlite
SQLITE_IPKG_TMP		= $(SQLITE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sqlite_get: $(STATEDIR)/sqlite.get

sqlite_get_deps = $(SQLITE_SOURCE)

$(STATEDIR)/sqlite.get: $(sqlite_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SQLITE))
	touch $@

$(SQLITE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SQLITE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sqlite_extract: $(STATEDIR)/sqlite.extract

sqlite_extract_deps = $(STATEDIR)/sqlite.get

$(STATEDIR)/sqlite.extract: $(sqlite_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SQLITE_DIR))
	@$(call extract, $(SQLITE_SOURCE))
	@$(call patchin, $(SQLITE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sqlite_prepare: $(STATEDIR)/sqlite.prepare

#
# dependencies
#
sqlite_prepare_deps = \
	$(STATEDIR)/sqlite.extract \
	$(STATEDIR)/readline.install \
	$(STATEDIR)/virtual-xchain.install

##ifdef PTXCONF_TCL
sqlite_prepare_deps += $(STATEDIR)/tcl.install
##endif

SQLITE_PATH	=  PATH=$(CROSS_PATH)
SQLITE_ENV 	=  $(CROSS_ENV)
SQLITE_ENV	+= config_TARGET_CFLAGS="$(TARGET_OPT_CFLAGS)"
SQLITE_ENV	+= config_TARGET_CXXFLAGS="$(TARGET_OPT_CFLAGS)"
SQLITE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SQLITE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SQLITE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-utf8 \
	--enable-shared \
	--disable-static \
	--disable-debug \
	--enable-releasemode

ifdef PTXCONF_XFREE430
SQLITE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SQLITE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/sqlite.prepare: $(sqlite_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SQLITE_DIR)/config.cache)
	#cd $(SQLITE_DIR) && aclocal
	#cd $(SQLITE_DIR) && automake --add-missing
	#cd $(SQLITE_DIR) && autoconf
	cd $(SQLITE_DIR) && \
		$(SQLITE_PATH) $(SQLITE_ENV) \
		config_TARGET_CC=$(PTXCONF_GNU_TARGET)-gcc config_BUILD_CC=gcc ./configure $(SQLITE_AUTOCONF)
	#cp -f $(PTXCONF_PREFIX)/bin/libtool $(SQLITE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sqlite_compile: $(STATEDIR)/sqlite.compile

sqlite_compile_deps = $(STATEDIR)/sqlite.prepare

$(STATEDIR)/sqlite.compile: $(sqlite_compile_deps)
	@$(call targetinfo, $@)
	$(SQLITE_PATH) $(MAKE) -C $(SQLITE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sqlite_install: $(STATEDIR)/sqlite.install

$(STATEDIR)/sqlite.install: $(STATEDIR)/sqlite.compile
	@$(call targetinfo, $@)
	$(SQLITE_PATH) $(MAKE) -C $(SQLITE_DIR) DESTDIR=$(SQLITE_IPKG_TMP) install
	cp -a  $(SQLITE_IPKG_TMP)/usr/include/* $(CROSS_LIB_DIR)/include
	cp -a  $(SQLITE_IPKG_TMP)/usr/lib/*     $(CROSS_LIB_DIR)/lib
	rm -rf $(SQLITE_IPKG_TMP)
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libsqlite3.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/sqlite3.pc
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sqlite_targetinstall: $(STATEDIR)/sqlite.targetinstall

sqlite_targetinstall_deps = \
	$(STATEDIR)/sqlite.compile \
	$(STATEDIR)/readline.targetinstall

##ifdef PTXCONF_TCL
sqlite_targetinstall_deps += $(STATEDIR)/tcl.targetinstall
##endif

$(STATEDIR)/sqlite.targetinstall: $(sqlite_targetinstall_deps)
	@$(call targetinfo, $@)
	$(SQLITE_PATH) $(MAKE) -C $(SQLITE_DIR) DESTDIR=$(SQLITE_IPKG_TMP) install
	rm -rf $(SQLITE_IPKG_TMP)/usr/include
	rm -rf $(SQLITE_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(SQLITE_IPKG_TMP)/usr/lib/*.la
	$(CROSSSTRIP) $(SQLITE_IPKG_TMP)/usr/bin/sqlite3
	$(CROSSSTRIP) $(SQLITE_IPKG_TMP)/usr/lib/*.so*
	ln -sf sqlite3 $(SQLITE_IPKG_TMP)/usr/bin/sqlite
	mkdir -p $(SQLITE_IPKG_TMP)/CONTROL
	echo "Package: sqlite" 				>$(SQLITE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(SQLITE_IPKG_TMP)/CONTROL/control
	echo "Section: Database" 			>>$(SQLITE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(SQLITE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(SQLITE_IPKG_TMP)/CONTROL/control
	echo "Version: $(SQLITE_VERSION)" 		>>$(SQLITE_IPKG_TMP)/CONTROL/control
	echo "Depends: readline" 			>>$(SQLITE_IPKG_TMP)/CONTROL/control
	echo "Description: An Embeddable SQL Database Engine">>$(SQLITE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SQLITE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SQLITE_INSTALL
ROMPACKAGES += $(STATEDIR)/sqlite.imageinstall
endif

sqlite_imageinstall_deps = $(STATEDIR)/sqlite.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/sqlite.imageinstall: $(sqlite_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sqlite
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sqlite_clean:
	rm -rf $(STATEDIR)/sqlite.*
	rm -rf $(SQLITE_DIR)

# vim: syntax=make
