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
ifdef PTXCONF_GNOME-VFS
PACKAGES += gnome-vfs
endif

#
# Paths and names
#
GNOME-VFS_VERSION	= 2.4.3
###GNOME-VFS_VERSION	= 2.6.1.1
GNOME-VFS		= gnome-vfs-$(GNOME-VFS_VERSION)
GNOME-VFS_SUFFIX	= tar.bz2
GNOME-VFS_URL		= ftp://ftp.gnome.org/pub/GNOME/sources/gnome-vfs/2.6/$(GNOME-VFS).$(GNOME-VFS_SUFFIX)
GNOME-VFS_SOURCE	= $(SRCDIR)/$(GNOME-VFS).$(GNOME-VFS_SUFFIX)
GNOME-VFS_DIR		= $(BUILDDIR)/$(GNOME-VFS)
GNOME-VFS_IPKG_TMP	= $(GNOME-VFS_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gnome-vfs_get: $(STATEDIR)/gnome-vfs.get

gnome-vfs_get_deps = $(GNOME-VFS_SOURCE)

$(STATEDIR)/gnome-vfs.get: $(gnome-vfs_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(GNOME-VFS))
	touch $@

$(GNOME-VFS_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(GNOME-VFS_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gnome-vfs_extract: $(STATEDIR)/gnome-vfs.extract

gnome-vfs_extract_deps = $(STATEDIR)/gnome-vfs.get

$(STATEDIR)/gnome-vfs.extract: $(gnome-vfs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNOME-VFS_DIR))
	@$(call extract, $(GNOME-VFS_SOURCE))
	@$(call patchin, $(GNOME-VFS))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gnome-vfs_prepare: $(STATEDIR)/gnome-vfs.prepare

#
# dependencies
#
gnome-vfs_prepare_deps = \
	$(STATEDIR)/gnome-vfs.extract \
	$(STATEDIR)/popt.install \
	$(STATEDIR)/ubzip2.install \
	$(STATEDIR)/gnome-mime-data.install \
	$(STATEDIR)/glib22.install \
	$(STATEDIR)/virtual-xchain.install

#	$(STATEDIR)/xchain-GConf.install

GNOME-VFS_PATH	=  PATH=$(CROSS_PATH)
GNOME-VFS_ENV 	=  $(CROSS_ENV)
GNOME-VFS_ENV	+= CFLAGS="-O2 -fomit-frame-pointer"
GNOME-VFS_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#GNOME-VFS_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
GNOME-VFS_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--sysconfdir=/etc \
	--libexecdir=/usr/bin \
	--disable-debug


ifdef PTXCONF_XFREE430
GNOME-VFS_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
GNOME-VFS_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/gnome-vfs.prepare: $(gnome-vfs_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(GNOME-VFS_DIR)/config.cache)
	cd $(GNOME-VFS_DIR) && \
		$(GNOME-VFS_PATH) $(GNOME-VFS_ENV) \
		./configure $(GNOME-VFS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gnome-vfs_compile: $(STATEDIR)/gnome-vfs.compile

gnome-vfs_compile_deps = $(STATEDIR)/gnome-vfs.prepare

$(STATEDIR)/gnome-vfs.compile: $(gnome-vfs_compile_deps)
	@$(call targetinfo, $@)
	$(GNOME-VFS_PATH) $(MAKE) -C $(GNOME-VFS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gnome-vfs_install: $(STATEDIR)/gnome-vfs.install

$(STATEDIR)/gnome-vfs.install: $(STATEDIR)/gnome-vfs.compile
	@$(call targetinfo, $@)
	$(GNOME-VFS_PATH) $(MAKE) -C $(GNOME-VFS_DIR) DESTDIR=$(GNOME-VFS_IPKG_TMP) install
	cp -a  $(GNOME-VFS_IPKG_TMP)/usr/include/*          $(CROSS_LIB_DIR)/include
	cp -a  $(GNOME-VFS_IPKG_TMP)/usr/lib/*              $(CROSS_LIB_DIR)/lib
	perl -p -i -e "s/\/usr\/lib/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgnomevfs-2.la
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gnome-vfs-2.0.pc
	perl -p -i -e "s/\/usr/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET) | sed -e '/\//s//\\\\\//g'`/g" $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/pkgconfig/gnome-vfs-module-2.0.pc
	rm -rf $(GNOME-VFS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gnome-vfs_targetinstall: $(STATEDIR)/gnome-vfs.targetinstall

gnome-vfs_targetinstall_deps = \
	$(STATEDIR)/gnome-vfs.compile \
	$(STATEDIR)/gnome-mime-data.targetinstall \
	$(STATEDIR)/glib22.targetinstall \
	$(STATEDIR)/ubzip2.targetinstall

$(STATEDIR)/gnome-vfs.targetinstall: $(gnome-vfs_targetinstall_deps)
	@$(call targetinfo, $@)
	$(GNOME-VFS_PATH) $(MAKE) -C $(GNOME-VFS_DIR) DESTDIR=$(GNOME-VFS_IPKG_TMP) install
	rm -rf $(GNOME-VFS_IPKG_TMP)/usr/doc
	rm -rf $(GNOME-VFS_IPKG_TMP)/usr/include
	rm -rf $(GNOME-VFS_IPKG_TMP)/usr/lib/*.*a
	rm -rf $(GNOME-VFS_IPKG_TMP)/usr/lib/pkgconfig
	rm -rf $(GNOME-VFS_IPKG_TMP)/usr/lib/bonobo/monikers/*.a
	###rm -rf $(GNOME-VFS_IPKG_TMP)/usr/lib/bonobo/monikers/*.la
	rm -rf $(GNOME-VFS_IPKG_TMP)/usr/lib/gnome-vfs-2.0/include
	rm -rf $(GNOME-VFS_IPKG_TMP)/usr/lib/gnome-vfs-2.0/modules/*.a
	###rm -rf $(GNOME-VFS_IPKG_TMP)/usr/lib/gnome-vfs-2.0/modules/*.la
	rm -rf $(GNOME-VFS_IPKG_TMP)/usr/lib/vfs/2.0/extfs/README
	rm -rf $(GNOME-VFS_IPKG_TMP)/usr/share
	for FILE in `find $(GNOME-VFS_IPKG_TMP)/usr/ -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	mkdir -p $(GNOME-VFS_IPKG_TMP)/CONTROL
	echo "Package: gnome-vfs" 			>$(GNOME-VFS_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(GNOME-VFS_IPKG_TMP)/CONTROL/control
	echo "Section: Gnome" 				>>$(GNOME-VFS_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" >>$(GNOME-VFS_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(GNOME-VFS_IPKG_TMP)/CONTROL/control
	echo "Version: $(GNOME-VFS_VERSION)" 		>>$(GNOME-VFS_IPKG_TMP)/CONTROL/control
	echo "Depends: gtk2, bzip2, gnome-mime-data, gconf, libbonobo, orbit2">>$(GNOME-VFS_IPKG_TMP)/CONTROL/control
	echo "Description: This is the GNOME Virtual File System.">>$(GNOME-VFS_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(GNOME-VFS_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gnome-vfs_clean:
	rm -rf $(STATEDIR)/gnome-vfs.*
	rm -rf $(GNOME-VFS_DIR)

# vim: syntax=make
