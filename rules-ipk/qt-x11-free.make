# -*-makefile-*-
# $Id: template,v 1.10 2004/01/24 15:50:34 mkl Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef PTXCONF_QT-X11-FREE
PACKAGES += qt-x11-free
endif

#
# Paths and names
#
ifndef PTXCONF_QT-X11-FREE-QT4
QT-X11-FREE_VERSION-MAJOR = 3
QT-X11-FREE_VERSION-MINOR = 3
QT-X11-FREE_VERSION-MICRO = 3

QT-X11-FREE_VERSION	= $(QT-X11-FREE_VERSION-MAJOR).$(QT-X11-FREE_VERSION-MINOR).$(QT-X11-FREE_VERSION-MICRO)
QT-X11-FREE		= qt-x11-free-$(QT-X11-FREE_VERSION)
else
QT-X11-FREE_VERSION-MAJOR = 4
QT-X11-FREE_VERSION-MINOR = 0
QT-X11-FREE_VERSION-MICRO = 0-b1

QT-X11-FREE_VERSION	= $(QT-X11-FREE_VERSION-MAJOR).$(QT-X11-FREE_VERSION-MINOR).$(QT-X11-FREE_VERSION-MICRO)
QT-X11-FREE		= qt-x11-opensource-$(QT-X11-FREE_VERSION)
endif
QT-X11-FREE_SUFFIX	= tar.bz2
QT-X11-FREE_URL		= ftp://ftp.trolltech.com/qt/source/$(QT-X11-FREE).$(QT-X11-FREE_SUFFIX)
QT-X11-FREE_SOURCE	= $(SRCDIR)/$(QT-X11-FREE).$(QT-X11-FREE_SUFFIX)
QT-X11-FREE_DIR		= $(BUILDDIR)/$(QT-X11-FREE)
QT-X11-FREE_IPKG_TMP	= $(QT-X11-FREE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

qt-x11-free_get: $(STATEDIR)/qt-x11-free.get

qt-x11-free_get_deps = $(QT-X11-FREE_SOURCE)

$(STATEDIR)/qt-x11-free.get: $(qt-x11-free_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QT-X11-FREE))
	touch $@

$(QT-X11-FREE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QT-X11-FREE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

qt-x11-free_extract: $(STATEDIR)/qt-x11-free.extract

qt-x11-free_extract_deps = $(STATEDIR)/qt-x11-free.get

$(STATEDIR)/qt-x11-free.extract: $(qt-x11-free_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QT-X11-FREE_DIR))
	@$(call extract, $(QT-X11-FREE_SOURCE))
	@$(call patchin, $(QT-X11-FREE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

qt-x11-free_prepare: $(STATEDIR)/qt-x11-free.prepare

#
# dependencies
#
qt-x11-free_prepare_deps = \
	$(STATEDIR)/qt-x11-free.extract \
	$(STATEDIR)/libpng125.install \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/jpeg.install \
	$(STATEDIR)/xfree430.install \
	$(STATEDIR)/xchain-qt-x11-free.install \
	$(STATEDIR)/virtual-xchain.install

QT-X11-FREE_PATH	=  PATH=$(CROSS_PATH)
QT-X11-FREE_ENV 	=  $(CROSS_ENV)
QT-X11-FREE_ENV		+= QTDIR=$(QT-X11-FREE_DIR)

#
# autoconf
#
#QT-X11-FREE_AUTOCONF = \
#	--build=$(GNU_HOST) \
#	--host=$(PTXCONF_GNU_TARGET) \
#	--prefix=$(CROSS_LIB_DIR)

QT-X11-FREE_AUTOCONF =
ifdef   PTXCONF_ARCH_ARM
 ifdef	PTXCONF_ARM_ARCH_PXA
 QT-X11-FREE_AUTOCONF += -xplatform armv5tel-linux-g++
 else
  ifdef	PTXCONF_ARM_ARCH_LE
  QT-X11-FREE_AUTOCONF += -xplatform armv4l-linux-g++
  endif
 endif
endif

ifdef PTXCONF_ARCH_X86
QT-X11-FREE_AUTOCONF += -xplatform x86-linux-g++
endif

QT-X11-FREE_AUTOCONF += -release 
QT-X11-FREE_AUTOCONF += -shared
QT-X11-FREE_AUTOCONF += -system-libjpeg
QT-X11-FREE_AUTOCONF += -system-libpng
QT-X11-FREE_AUTOCONF += -system-zlib
QT-X11-FREE_AUTOCONF += -qt-gif
QT-X11-FREE_AUTOCONF += -xft
QT-X11-FREE_AUTOCONF += -xrender
QT-X11-FREE_AUTOCONF += -sm
QT-X11-FREE_AUTOCONF += -no-stl
QT-X11-FREE_AUTOCONF += -no-g++-exceptions
QT-X11-FREE_AUTOCONF += -no-cups
QT-X11-FREE_AUTOCONF += -no-nis
QT-X11-FREE_AUTOCONF += -no-nas-sound
QT-X11-FREE_AUTOCONF += -no-tablet 
#QT-X11-FREE_AUTOCONF += -no-exceptions
QT-X11-FREE_AUTOCONF += -no-xkb
#QT-X11-FREE_AUTOCONF += -plugin-sql-sqlite

ifndef PTXCONF_QT-X11-FREE-QT4
QT-X11-FREE_AUTOCONF += -thread
QT-X11-FREE_AUTOCONF += -disable-opengl
QT-X11-FREE_AUTOCONF += -no-ipv6
QT-X11-FREE_AUTOCONF += -plugin-imgfmt-mng
endif

$(STATEDIR)/qt-x11-free.prepare: $(qt-x11-free_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QT-X11-FREE_DIR)/config.cache)
	perl -p -i -e "s/\@X11INC@/`echo $(NATIVE_SDK_FILES_PREFIX)/include | sed -e '/\//s//\\\\\//g'`/g"	$(QT-X11-FREE_DIR)/mkspecs/linux-g++/qmake.conf
	perl -p -i -e "s/\@X11LIB@/`echo /usr/X11R6/lib | sed -e '/\//s//\\\\\//g'`/g"				$(QT-X11-FREE_DIR)/mkspecs/linux-g++/qmake.conf
	perl -p -i -e "s/\@INCDIR@/`echo $(NATIVE_SDK_FILES_PREFIX)/include | sed -e '/\//s//\\\\\//g'`/g"	$(QT-X11-FREE_DIR)/mkspecs/linux-g++/qmake.conf
	perl -p -i -e "s/\@LIBDIR@/`echo $(NATIVE_SDK_FILES_PREFIX)/lib | sed -e '/\//s//\\\\\//g'`/g"		$(QT-X11-FREE_DIR)/mkspecs/linux-g++/qmake.conf
ifdef   PTXCONF_ARCH_ARM
 ifdef	PTXCONF_ARM_ARCH_PXA
	cp -a $(TOPDIR)/config/pdaXrom/$(QT-X11-FREE_VERSION)-armv5tel-linux-g++ $(QT-X11-FREE_DIR)/mkspecs
	mv $(QT-X11-FREE_DIR)/mkspecs/$(QT-X11-FREE_VERSION)-armv5tel-linux-g++ $(QT-X11-FREE_DIR)/mkspecs/armv5tel-linux-g++
	perl -p -i -e "s/\@X11INC@/`echo $(CROSS_LIB_DIR)/include | sed -e '/\//s//\\\\\//g'`/g" $(QT-X11-FREE_DIR)/mkspecs/armv5tel-linux-g++/qmake.conf
	perl -p -i -e "s/\@X11LIB@/`echo $(CROSS_LIB_DIR)/lib | sed -e '/\//s//\\\\\//g'`/g" $(QT-X11-FREE_DIR)/mkspecs/armv5tel-linux-g++/qmake.conf
	perl -p -i -e "s/\@INCDIR@/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/include | sed -e '/\//s//\\\\\//g'`/g" $(QT-X11-FREE_DIR)/mkspecs/armv5tel-linux-g++/qmake.conf
	perl -p -i -e "s/\@LIBDIR@/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(QT-X11-FREE_DIR)/mkspecs/armv5tel-linux-g++/qmake.conf
 else
  ifdef	PTXCONF_ARM_ARCH_LE
	cp -a $(TOPDIR)/config/pdaXrom/$(QT-X11-FREE_VERSION)-armv4l-linux-g++ $(QT-X11-FREE_DIR)/mkspecs
	mv $(QT-X11-FREE_DIR)/mkspecs/$(QT-X11-FREE_VERSION)-armv4l-linux-g++ $(QT-X11-FREE_DIR)/mkspecs/armv4l-linux-g++
	perl -p -i -e "s/\@X11INC@/`echo $(CROSS_LIB_DIR)/include | sed -e '/\//s//\\\\\//g'`/g" $(QT-X11-FREE_DIR)/mkspecs/armv4l-linux-g++/qmake.conf
	perl -p -i -e "s/\@X11LIB@/`echo $(CROSS_LIB_DIR)/lib | sed -e '/\//s//\\\\\//g'`/g" $(QT-X11-FREE_DIR)/mkspecs/armv4l-linux-g++/qmake.conf
	perl -p -i -e "s/\@INCDIR@/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/include | sed -e '/\//s//\\\\\//g'`/g" $(QT-X11-FREE_DIR)/mkspecs/armv4l-linux-g++/qmake.conf
	perl -p -i -e "s/\@LIBDIR@/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(QT-X11-FREE_DIR)/mkspecs/armv4l-linux-g++/qmake.conf
  endif
 endif
endif
ifdef   PTXCONF_ARCH_X86
	rm -rf  $(QT-X11-FREE_DIR)/mkspecs/x86-linux-g++
	cp -a $(TOPDIR)/config/pdaXrom-x86/$(QT-X11-FREE_VERSION)-x86-linux-g++ $(QT-X11-FREE_DIR)/mkspecs
	mv $(QT-X11-FREE_DIR)/mkspecs/$(QT-X11-FREE_VERSION)-x86-linux-g++ $(QT-X11-FREE_DIR)/mkspecs/x86-linux-g++
	perl -p -i -e "s/\@X11INC@/`echo $(CROSS_LIB_DIR)/include | sed -e '/\//s//\\\\\//g'`/g" $(QT-X11-FREE_DIR)/mkspecs/x86-linux-g++/qmake.conf
	perl -p -i -e "s/\@X11LIB@/`echo $(CROSS_LIB_DIR)/lib | sed -e '/\//s//\\\\\//g'`/g" $(QT-X11-FREE_DIR)/mkspecs/x86-linux-g++/qmake.conf
	perl -p -i -e "s/\@INCDIR@/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/include | sed -e '/\//s//\\\\\//g'`/g" $(QT-X11-FREE_DIR)/mkspecs/x86-linux-g++/qmake.conf
	perl -p -i -e "s/\@LIBDIR@/`echo $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib | sed -e '/\//s//\\\\\//g'`/g" $(QT-X11-FREE_DIR)/mkspecs/x86-linux-g++/qmake.conf
endif
	cd $(QT-X11-FREE_DIR) && \
		$(QT-X11-FREE_PATH) $(QT-X11-FREE_ENV) \
		echo yes | ./configure $(QT-X11-FREE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

qt-x11-free_compile: $(STATEDIR)/qt-x11-free.compile

qt-x11-free_compile_deps = $(STATEDIR)/qt-x11-free.prepare

$(STATEDIR)/qt-x11-free.compile: $(qt-x11-free_compile_deps)
	@$(call targetinfo, $@)
	$(QT-X11-FREE_PATH) $(MAKE) -C $(QT-X11-FREE_DIR)/src/moc
	$(QT-X11-FREE_PATH) $(MAKE) -C $(QT-X11-FREE_DIR)/src
ifndef PTXCONF_QT-X11-FREE-QT4
	$(QT-X11-FREE_PATH) $(MAKE) -C $(QT-X11-FREE_DIR)/plugins/src
	perl -i -p -e "s,REQUIRES\=,\#REQUIRES\=,g" $(QT-X11-FREE_DIR)/tools/qtconfig/qtconfig.pro
	$(QT-X11-FREE_PATH) $(MAKE) -C $(QT-X11-FREE_DIR)/tools/qtconfig UIC=uic
else
	$(QT-X11-FREE_PATH) $(MAKE) -C $(QT-X11-FREE_DIR)/src/plugins/styles
	perl -i -p -e "s,REQUIRES\=,\#REQUIRES\=,g" $(QT-X11-FREE_DIR)/tools/qtconfig/qtconfig.pro
	$(QT-X11-FREE_PATH) $(MAKE) -C $(QT-X11-FREE_DIR)/tools/qtconfig UIC=uic
endif
ifdef   PTXCONF_ARCH_ARM
 ifdef	PTXCONF_ARM_ARCH_PXA
	rm -f $(QT-X11-FREE_DIR)/mkspecs/default
	ln -sf armv5tel-linux-g++ $(QT-X11-FREE_DIR)/mkspecs/default
 else
  ifdef	PTXCONF_ARM_ARCH_LE
	rm -f $(QT-X11-FREE_DIR)/mkspecs/default
	ln -sf armv4l-linux-g++   $(QT-X11-FREE_DIR)/mkspecs/default
  endif
 endif
endif
ifdef   PTXCONF_ARCH_X86
	rm -f $(QT-X11-FREE_DIR)/mkspecs/default
	ln -sf x86-linux-g++   $(QT-X11-FREE_DIR)/mkspecs/default
endif
ifndef PTXCONF_QT-X11-FREE-QT4
	rm -f $(QT-X11-FREE_DIR)/bin/qmake
	cp -f $(QT-X11-FREE_DIR)/qmake/qmake $(QT-X11-FREE_DIR)/bin
	cp -f $(QT-X11-FREE_DIR)/qmake/qmake $(PTXCONF_PREFIX)/bin
else
	cp -f $(QT-X11-FREE_DIR)/bin/qmake $(PTXCONF_PREFIX)/bin
endif
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

qt-x11-free_install: $(STATEDIR)/qt-x11-free.install

$(STATEDIR)/qt-x11-free.install: $(STATEDIR)/qt-x11-free.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

qt-x11-free_targetinstall: $(STATEDIR)/qt-x11-free.targetinstall

qt-x11-free_targetinstall_deps = $(STATEDIR)/qt-x11-free.compile

$(STATEDIR)/qt-x11-free.targetinstall: $(qt-x11-free_targetinstall_deps)
	@$(call targetinfo, $@)

	mkdir -p $(QT-X11-FREE_IPKG_TMP)
	
	$(INSTALL) -d $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/bin
	$(INSTALL) -d $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/lib
	$(INSTALL) -d $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/plugins/imageformats
ifndef PTXCONF_QT-X11-FREE-QT4
	$(INSTALL) -m 755 $(QT-X11-FREE_DIR)/lib/libqt-mt.so.$(QT-X11-FREE_VERSION-MAJOR).$(QT-X11-FREE_VERSION-MINOR).$(QT-X11-FREE_VERSION-MICRO) $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/lib
	ln -sf libqt-mt.so.$(QT-X11-FREE_VERSION) $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/lib/libqt-mt.so.$(QT-X11-FREE_VERSION-MAJOR).$(QT-X11-FREE_VERSION-MINOR)
	ln -sf libqt-mt.so.$(QT-X11-FREE_VERSION) $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/lib/libqt-mt.so.$(QT-X11-FREE_VERSION-MAJOR)
	ln -sf libqt-mt.so.$(QT-X11-FREE_VERSION) $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/lib/libqt-mt.so
	$(INSTALL) -m 755 $(QT-X11-FREE_DIR)/plugins/imageformats/libqjpeg.so $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/plugins/imageformats
	$(INSTALL) -m 755 $(QT-X11-FREE_DIR)/plugins/imageformats/libqmng.so  $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/plugins/imageformats
	$(INSTALL) -m 755 $(QT-X11-FREE_DIR)/bin/qtconfig  $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/bin
	$(CROSSSTRIP) $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/lib/libqt-mt.so.$(QT-X11-FREE_VERSION)
	$(CROSSSTRIP) $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/plugins/imageformats/libqjpeg.so
	$(CROSSSTRIP) $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/plugins/imageformats/libqmng.so
	$(CROSSSTRIP) $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/bin/qtconfig
else
	cp -a $(QT-X11-FREE_DIR)/lib/libQt*.so* 			$(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/lib/
	cp -a $(QT-X11-FREE_DIR)/plugins/imageformats			$(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/plugins/
	$(INSTALL) -m 755 $(QT-X11-FREE_DIR)/bin/qtconfig		$(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/bin/
	$(CROSSSTRIP) $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/lib/*.so*
	$(CROSSSTRIP) $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/bin/*
	$(CROSSSTRIP) $(QT-X11-FREE_IPKG_TMP)/usr/lib/qt/plugins/imageformats/*
endif
	$(INSTALL) -d $(QT-X11-FREE_IPKG_TMP)/usr/share/applications
	$(INSTALL) -d $(QT-X11-FREE_IPKG_TMP)/usr/share/pixmaps
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/qt/qtconfig.desktop $(QT-X11-FREE_IPKG_TMP)/usr/share/applications
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/qt/qtconfig.png     $(QT-X11-FREE_IPKG_TMP)/usr/share/pixmaps

	mkdir -p $(QT-X11-FREE_IPKG_TMP)/CONTROL
ifndef PTXCONF_QT-X11-FREE-QT4
	echo "Package: qt-mt" 					 >$(QT-X11-FREE_IPKG_TMP)/CONTROL/control
else
	echo "Package: qt4" 					 >$(QT-X11-FREE_IPKG_TMP)/CONTROL/control
endif
	echo "Priority: optional"	 			>>$(QT-X11-FREE_IPKG_TMP)/CONTROL/control
	echo "Section: X11"		 			>>$(QT-X11-FREE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>"  >>$(QT-X11-FREE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 			>>$(QT-X11-FREE_IPKG_TMP)/CONTROL/control
	echo "Version: $(QT-X11-FREE_VERSION)"	 		>>$(QT-X11-FREE_IPKG_TMP)/CONTROL/control
	echo "Depends: xfree430, libjpeg, libpng"	 	>>$(QT-X11-FREE_IPKG_TMP)/CONTROL/control
	echo "Description: QT."	>>$(QT-X11-FREE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(QT-X11-FREE_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_QT-X11-FREE_INSTALL
ROMPACKAGES += $(STATEDIR)/qt-x11-free.imageinstall
endif

qt-x11-free_imageinstall_deps = $(STATEDIR)/qt-x11-free.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/qt-x11-free.imageinstall: $(qt-x11-free_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install qt-mt
ifdef PTXCONF_QT-X11-FREE-HEADERS_INSTALL
	cd $(FEEDDIR) && $(XIPKG) install qt-headers
endif
	touch $@


# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

qt-x11-free_clean:
	rm -rf $(STATEDIR)/qt-x11-free.*
	rm -rf $(QT-X11-FREE_DIR)

# vim: syntax=make
