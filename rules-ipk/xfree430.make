# -*-makefile-*-
# $Id: xfree430.make,v 1.8 2003/11/10 00:51:39 mkl Exp $
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
ifdef PTXCONF_XFREE430
PACKAGES += xfree430
endif

#
# Paths and names
#
XFREE430_VERSION	= 430
XFREE430		= X$(XFREE430_VERSION)src
XFREE430_SUFFIX		= tgz
XFREE430_DIR		= $(BUILDDIR)/xc
XFREE430_IPKG_TMP	= $(XFREE430_DIR)/ipkg_tmp

XFREE430_1_URL		= ftp://ftp.xfree86.org/pub/XFree86/4.3.0/source/$(XFREE430)-1.$(XFREE430_SUFFIX)
XFREE430_1_SOURCE	= $(SRCDIR)/$(XFREE430)-1.$(XFREE430_SUFFIX)
XFREE430_2_URL		= ftp://ftp.xfree86.org/pub/XFree86/4.3.0/source/$(XFREE430)-2.$(XFREE430_SUFFIX)
XFREE430_2_SOURCE	= $(SRCDIR)/$(XFREE430)-2.$(XFREE430_SUFFIX)
XFREE430_3_URL		= ftp://ftp.xfree86.org/pub/XFree86/4.3.0/source/$(XFREE430)-3.$(XFREE430_SUFFIX)
XFREE430_3_SOURCE	= $(SRCDIR)/$(XFREE430)-3.$(XFREE430_SUFFIX)
ifdef PTX_CONF_ARCH_X86
XFREE430_4_URL		= ftp://ftp.xfree86.org/pub/XFree86/4.3.0/source/$(XFREE430)-4.$(XFREE430_SUFFIX)
XFREE430_4_SOURCE	= $(SRCDIR)/$(XFREE430)-4.$(XFREE430_SUFFIX)
XFREE430_5_URL		= ftp://ftp.xfree86.org/pub/XFree86/4.3.0/source/$(XFREE430)-5.$(XFREE430_SUFFIX)
XFREE430_5_SOURCE	= $(SRCDIR)/$(XFREE430)-5.$(XFREE430_SUFFIX)
endif

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfree430_get: $(STATEDIR)/xfree430.get

xfree430_get_deps	=  $(XFREE430_1_SOURCE)
xfree430_get_deps	+= $(XFREE430_2_SOURCE)
xfree430_get_deps	+= $(XFREE430_3_SOURCE)
ifdef PTX_CONF_ARCH_X86
xfree430_get_deps	+= $(XFREE430_4_SOURCE)
xfree430_get_deps	+= $(XFREE430_5_SOURCE)
endif

$(STATEDIR)/xfree430.get: $(xfree430_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFREE430))
	touch $@

$(XFREE430_1_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFREE430_1_URL))

$(XFREE430_2_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFREE430_2_URL))

$(XFREE430_3_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFREE430_3_URL))

ifdef PTX_CONF_ARCH_X86
$(XFREE430_4_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFREE430_4_URL))

$(XFREE430_5_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XFREE430_5_URL))
endif
# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfree430_extract: $(STATEDIR)/xfree430.extract

xfree430_extract_deps	=  $(STATEDIR)/xfree430.get

$(STATEDIR)/xfree430.extract: $(xfree430_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFREE430_DIR))
	@$(call extract, $(XFREE430_1_SOURCE))
	@$(call extract, $(XFREE430_2_SOURCE))
	@$(call extract, $(XFREE430_3_SOURCE))
ifdef PTX_CONF_ARCH_X86
	@$(call extract, $(XFREE430_4_SOURCE))
	@$(call extract, $(XFREE430_5_SOURCE))
endif
	@$(call patchin, $(XFREE430), $(XFREE430_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfree430_prepare: $(STATEDIR)/xfree430.prepare

#
# dependencies
#
xfree430_prepare_deps = $(STATEDIR)/xfree430.extract
xfree430_prepare_deps += $(STATEDIR)/zlib.install
xfree430_prepare_deps += $(STATEDIR)/ncurses.install
xfree430_prepare_deps += $(STATEDIR)/libpng125.install
xfree430_prepare_deps += $(STATEDIR)/jpeg.install
xfree430_prepare_deps += $(STATEDIR)/expat.install
xfree430_prepare_deps += $(STATEDIR)/freetype.install
xfree430_prepare_deps += $(STATEDIR)/fontconfig.install
ifdef PTXCONF_ATICORE
xfree430_prepare_deps += $(STATEDIR)/AtiCore.install
endif
ifdef PTXCONF_TSLIB
xfree430_prepare_deps += $(STATEDIR)/tslib.install
endif
xfree430_prepare_deps += $(STATEDIR)/virtual-xchain.install

XFREE430_PATH	=  PATH=$(CROSS_PATH)

$(STATEDIR)/xfree430.prepare: $(xfree430_prepare_deps)
	@$(call targetinfo, $@)
	ln -sf $(PTXCONF_PREFIX)/bin/$(PTXCONF_GNU_TARGET)-cpp $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/cpp
	ln -sf $(PTXCONF_PREFIX)/bin/$(PTXCONF_GNU_TARGET)-gcc $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin/cc
	cp $(PTXCONF_XFREE430_CONFIG) $(XFREE430_DIR)/config/cf/host.def
	perl -i -p -e "s,\@FREETYPE2DIR@,`$(PTXCONF_PREFIX)/bin/freetype-config --prefix`,g" $(XFREE430_DIR)/config/cf/host.def
	perl -i -p -e "s,\@FONTCONFIGDIR@,$(CROSS_LIB_DIR),g" $(XFREE430_DIR)/config/cf/host.def
	perl -i -p -e "s,\@EXPATDIR@,$(CROSS_LIB_DIR),g" $(XFREE430_DIR)/config/cf/host.def
	perl -i -p -e "s,\@LIBPNGDIR@,$(CROSS_LIB_DIR),g" $(XFREE430_DIR)/config/cf/host.def
	touch $(XFREE430_DIR)/xf86Date.h
	touch $(XFREE430_DIR)/xf86Version.h
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfree430_compile: $(STATEDIR)/xfree430.compile

xfree430_compile_deps =  $(STATEDIR)/xfree430.prepare

$(STATEDIR)/xfree430.compile: $(xfree430_compile_deps)
	@$(call targetinfo, $@)

	cd $(XFREE430_DIR) && \
		$(XFREE430_ENV) $(MAKE) World CROSSCOMPILEDIR=$(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin

	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfree430_install: $(STATEDIR)/xfree430.install

$(STATEDIR)/xfree430.install: $(STATEDIR)/xfree430.compile
	@$(call targetinfo, $@)

	cd $(XFREE430_DIR) && \
		$(XFREE430_ENV) $(MAKE) CROSSCOMPILEDIR=$(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin \
		    DESTDIR=$(XFREE430_IPKG_TMP) install

	#rm -rf $(CROSS_LIB_DIR)
	#mkdir -p $(CROSS_LIB_DIR)/lib
	cp -a $(XFREE430_IPKG_TMP)/usr/X11R6/include/*		$(CROSS_LIB_DIR)/include/
	cp -a $(XFREE430_IPKG_TMP)/usr/X11R6/lib/*      	$(CROSS_LIB_DIR)/lib/
	mv -f $(XFREE430_IPKG_TMP)/usr/X11R6/bin/*-config	$(PTXCONF_PREFIX)/bin

	perl -i -p -e "s,\/usr/X11R6,$(CROSS_LIB_DIR),g"	$(PTXCONF_PREFIX)/bin/xcursor-config
	perl -i -p -e "s,\/usr/X11R6,$(CROSS_LIB_DIR),g"	$(PTXCONF_PREFIX)/bin/xft-config
	perl -i -p -e "s,\/usr/X11R6,$(CROSS_LIB_DIR),g"	$(CROSS_LIB_DIR)/lib/pkgconfig/xcursor.pc
	perl -i -p -e "s,\/usr/X11R6,$(CROSS_LIB_DIR),g"	$(CROSS_LIB_DIR)/lib/pkgconfig/xft.pc

	rm -rf $(XFREE430_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfree430_targetinstall: $(STATEDIR)/xfree430.targetinstall

xfree430_targetinstall_deps =  $(STATEDIR)/xfree430.compile
xfree430_targetinstall_deps += $(STATEDIR)/ncurses.targetinstall
xfree430_targetinstall_deps += $(STATEDIR)/libpng125.targetinstall
xfree430_targetinstall_deps += $(STATEDIR)/jpeg.targetinstall
xfree430_targetinstall_deps += $(STATEDIR)/zlib.targetinstall
xfree430_targetinstall_deps += $(STATEDIR)/expat.targetinstall
xfree430_targetinstall_deps += $(STATEDIR)/freetype.targetinstall
xfree430_targetinstall_deps += $(STATEDIR)/fontconfig.targetinstall
ifdef PTXCONF_TSLIB
xfree430_targetinstall_deps += $(STATEDIR)/tslib.targetinstall
endif
ifdef PTXCONF_ATICORE
xfree430_targetinstall_deps += $(STATEDIR)/AtiCore.targetinstall
endif

$(STATEDIR)/xfree430.targetinstall: $(xfree430_targetinstall_deps)
	@$(call targetinfo, $@)

	rm -rf $(XFREE430_IPKG_TMP)

	cd $(XFREE430_DIR) && \
		$(XFREE430_ENV) $(MAKE) CROSSCOMPILEDIR=$(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin \
		    DESTDIR=$(XFREE430_IPKG_TMP) install

	rm -rf $(XFREE430_IPKG_TMP)/usr/X11R6/include
	rm -rf $(XFREE430_IPKG_TMP)/usr/X11R6/bin/*-config

	rm -rf $(XFREE430_IPKG_TMP)/usr/X11R6/lib/*.a
	rm -rf $(XFREE430_IPKG_TMP)/usr/X11R6/lib/pkgconfig
	rm -rf $(XFREE430_IPKG_TMP)/usr/include

	for FILE in `find $(XFREE430_IPKG_TMP)/usr/X11R6 -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;		\
	    if [  "$$ZZZ" != "" ]; then				\
		$(CROSSSTRIP) $$FILE;				\
	    fi;							\
	done

	for FILE in `find $(XFREE430_IPKG_TMP)/etc/X11 -type f`; do	\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;		\
	    if [  "$$ZZZ" != "" ]; then				\
		$(CROSSSTRIP) $$FILE;				\
	    fi;							\
	done

	##if [ -f $(XFREE430_IPKG_TMP)/etc/X11/xkb/xkbcomp ]; then 	\
	##    $(CROSSSTRIP) $(XFREE430_IPKG_TMP)/etc/X11/xkb/xkbcomp; 	\
	##fi
	##rm -rf $(XFREE430_IPKG_TMP)/usr/X11R6/lib/X11/config

ifdef PTXCONF_ARCH_ARM
	ln -sf Xfbdev $(XFREE430_IPKG_TMP)/usr/X11R6/bin/X
	chmod 4755    $(XFREE430_IPKG_TMP)/usr/X11R6/bin/X

	mkdir -p $(XFREE430_IPKG_TMP)/etc/rc.d/init.d
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/x11 $(XFREE430_IPKG_TMP)/etc/rc.d/init.d
ifdef PTXCONF_XFREE430_XDM
	mkdir -p $(XFREE430_IPKG_TMP)/etc/rc.d/rc5.d
	ln -sf ../init.d/x11 $(XFREE430_IPKG_TMP)/etc/rc.d/rc5.d/S50x11
endif
	###cp -af $(TOPDIR)/config/pdaXrom/kb 		       $(XFREE430_IPKG_TMP)/etc/X11
	###ln -sf ../kb/corgi.xmodmap                             $(XFREE430_IPKG_TMP)/etc/X11/xinit/.Xmodmap
	###$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/fonts.conf  $(XFREE430_IPKG_TMP)/etc/fonts
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/xinitrc.twm $(XFREE430_IPKG_TMP)/etc/X11/
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/Xservers    $(XFREE430_IPKG_TMP)/etc/X11/xdm
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/Xsetup_0    $(XFREE430_IPKG_TMP)/etc/X11/xdm
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/xdm-config  $(XFREE430_IPKG_TMP)/etc/X11/xdm
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/system.twmrc $(XFREE430_IPKG_TMP)/etc/X11/twm
ifdef PTXCONF_XFREE430_SCREENSIZE
	$(INSTALL) -m 755 $(TOPDIR)/config/pdaXrom/startx.pdaXrom $(XFREE430_IPKG_TMP)/usr/X11R6/bin/startx
	perl -i -p -e "s,\@OPTSCR\@,$(PTXCONF_XFREE430_SCREENWIDTH)x$(PTXCONF_XFREE430_SCREENHEIGHT)\@$(PTXCONF_XFREE430_ROTATION),g" \
	    $(XFREE430_IPKG_TMP)/usr/X11R6/bin/startx
else
	$(INSTALL) -m 755 $(TOPDIR)/config/pdaXrom/startx         $(XFREE430_IPKG_TMP)/usr/X11R6/bin
endif
else
ifdef PTXCONF_XFREE430_XFBDEV
	ln -sf Xfbdev $(XFREE430_IPKG_TMP)/usr/X11R6/bin/X
endif
endif

	rm -f $(XFREE430_IPKG_TMP)/usr/X11R6/lib/libdps.*
	rm -f $(XFREE430_IPKG_TMP)/usr/X11R6/bin/{dpsexec,dpsinfo,texteroids}

	rm -rf   $(XFREE430_IPKG_TMP)-addon
	mkdir -p $(XFREE430_IPKG_TMP)-addon/usr/X11R6/bin
	mv -f $(XFREE430_IPKG_TMP)/usr/X11R6/bin/{bmtoa,editres,mergelib,viewres,xeyes,xmkmf,ccmakedep,gccmakedep,mkdirhier,x11perf,xgc,appres,cleanlinks,ico,mkhtmlindex,x11perfcomp,xlogo,atobm,cxpm,listres,oclock,xcmsdb,xmag,beforelight,makeg,xditview,xman,bitmap,makepsres,xedit,xmh,xcalc} \
	      $(XFREE430_IPKG_TMP)-addon/usr/X11R6/bin
	mkdir -p $(XFREE430_IPKG_TMP)-addon/usr/X11R6/lib/X11/locale
	mkdir -p $(XFREE430_IPKG_TMP)-addon/usr/X11R6/lib/X11/config/cf
	mv -f $(XFREE430_IPKG_TMP)/usr/X11R6/lib/X11/x11perfcomp \
	      $(XFREE430_IPKG_TMP)-addon/usr/X11R6/lib/X11
	mv -f $(XFREE430_IPKG_TMP)/usr/X11R6/lib/X11/xedit \
	      $(XFREE430_IPKG_TMP)-addon/usr/X11R6/lib/X11
	mv -f $(XFREE430_IPKG_TMP)/usr/X11R6/lib/X11/locale/{armscii-8,el_GR.UTF-8,georgian-academy,georgian-ps,ibm-cp1133,iscii-dev,isiri-3342,iso8859-10,iso8859-11,iso8859-13,iso8859-14,iso8859-3,iso8859-4,iso8859-6,iso8859-7,iso8859-8,iso8859-9,iso8859-9e,ja,ja.JIS,ja_JP.UTF-8,ja.SJIS,ko,koi8-u,ko_KR.UTF-8,microsoft-cp1255,microsoft-cp1256,mulelao-1,nokhchi-1,tatar-cyr,th_TH,th_TH.UTF-8,tscii-0,vi_VN.tcvn,vi_VN.viscii,zh_CN,zh_CN.gbk,zh_HK.big5,zh_HK.big5hkscs,zh_TW,zh_TW.big5,zh_TW.UTF-8} \
	      $(XFREE430_IPKG_TMP)-addon/usr/X11R6/lib/X11/locale
	cp -a $(XFREE430_IPKG_TMP)/usr/X11R6/lib/X11/config \
	      $(XFREE430_IPKG_TMP)-addon/usr/X11R6/lib/X11
	rm -rf $(XFREE430_IPKG_TMP)/usr/X11R6/lib/X11/config
	cp -f $(XFREE430_DIR)/config/cf/{kdrive.cf,TinyX.cf,cross.def,cross.rules} \
	      $(XFREE430_IPKG_TMP)-addon/usr/X11R6/lib/X11/config

	mv -f $(XFREE430_IPKG_TMP)/usr/X11R6/lib/{libdpstk.so*,libpsres.so*,libxrx.so*} \
	      $(XFREE430_IPKG_TMP)-addon/usr/X11R6/lib/

	$(MAKE) -C $(XFREE430_DIR)/config/imake clean
	PATH=$(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/bin:$(PATH) $(MAKE) -C $(XFREE430_DIR)/config/imake
	
	cp -f $(XFREE430_DIR)/config/imake/imake \
	      $(XFREE430_IPKG_TMP)-addon/usr/X11R6/bin
	$(CROSSSTRIP) $(XFREE430_IPKG_TMP)-addon/usr/X11R6/bin/imake
	
	mkdir -p $(XFREE430_IPKG_TMP)-addon/CONTROL
	echo "Package: xfree430-addon" 			 >$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Priority: optional" 			>>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Section: X11"	 			>>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Version: $(XFREE430_VERSION)" 		>>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Depends: xfree430"	 		>>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Description:  not necessary X11 apps"	>>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XFREE430_IPKG_TMP)-addon

	###
	rm -rf $(XFREE430_IPKG_TMP)-addon
	mkdir -p $(XFREE430_IPKG_TMP)-addon/etc/X11
	mkdir -p $(XFREE430_IPKG_TMP)-addon/usr/X11R6/bin
	mkdir -p $(XFREE430_IPKG_TMP)-addon/var/lib
	mv -f $(XFREE430_IPKG_TMP)/etc/X11/xkb		$(XFREE430_IPKG_TMP)-addon/etc/X11/
	mv -f $(XFREE430_IPKG_TMP)/usr/X11R6/bin/*xkb*	$(XFREE430_IPKG_TMP)-addon/usr/X11R6/bin/
	mv -f $(XFREE430_IPKG_TMP)/var/lib/xkb		$(XFREE430_IPKG_TMP)-addon/var/lib/

	mkdir -p $(XFREE430_IPKG_TMP)-addon/CONTROL
	echo "Package: xfree430-xkb-utils" 		 >$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Priority: optional" 			>>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Section: X11"	 			>>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Version: $(XFREE430_VERSION)" 		>>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Depends: xfree430"	 		>>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	echo "Description: xkb utilities"		>>$(XFREE430_IPKG_TMP)-addon/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XFREE430_IPKG_TMP)-addon
	###

	mkdir -p $(XFREE430_IPKG_TMP)/CONTROL
	echo "Package: xfree430" 			 >$(XFREE430_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(XFREE430_IPKG_TMP)/CONTROL/control
	echo "Section: X11"	 			>>$(XFREE430_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(XFREE430_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(XFREE430_IPKG_TMP)/CONTROL/control
	echo "Version: $(XFREE430_VERSION)" 		>>$(XFREE430_IPKG_TMP)/CONTROL/control
ifdef PTXCONF_ATICORE
	echo "Depends: aticore, tslib, libpng, libjpeg, expat, freetype, fontconfig, ncurses" >>$(XFREE430_IPKG_TMP)/CONTROL/control
else
ifdef PTXCONF_TSLIB
	echo "Depends: tslib, libpng, libjpeg, expat, freetype, fontconfig, ncurses" >>$(XFREE430_IPKG_TMP)/CONTROL/control
else
	echo "Depends: libpng, libjpeg, expat, freetype, fontconfig, ncurses" >>$(XFREE430_IPKG_TMP)/CONTROL/control
endif
endif
	echo "Description:  X11 Server, apps and libraries">>$(XFREE430_IPKG_TMP)/CONTROL/control

	echo "#!/bin/sh"				 >$(XFREE430_IPKG_TMP)/CONTROL/postinst
	echo "chmod 4755 /usr/X11R6/bin/Xfbdev"		>>$(XFREE430_IPKG_TMP)/CONTROL/postinst
	echo "chmod 4755 /usr/X11R6/bin/xterm"		>>$(XFREE430_IPKG_TMP)/CONTROL/postinst
	chmod 755 $(XFREE430_IPKG_TMP)/CONTROL/postinst
	cd $(FEEDDIR) && $(XMKIPKG) $(XFREE430_IPKG_TMP)

	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XFREE430_INSTALL
ROMPACKAGES += $(STATEDIR)/xfree430.imageinstall
endif

xfree430_imageinstall_deps = $(STATEDIR)/xfree430.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/xfree430.imageinstall: $(xfree430_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xfree430
ifdef PTXCONF_XFREE430_INSTALL_ADDON
	cd $(FEEDDIR) && $(XIPKG) install xfree430-addon
endif
ifdef PTXCONF_XFREE430_INSTALL_XKB
	cd $(FEEDDIR) && $(XIPKG) install xfree430-xkb-utils
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfree430_clean:
	rm -rf $(STATEDIR)/xfree430.*
	rm -rf $(XFREE430_DIR) $(XFREE430_BUILDDIR)

# vim: syntax=make
