# -*-makefile-*-
# $Id: cameron-efco.make,v 1.1 2003/12/24 13:39:44 robert Exp $
#
# Copyright (C) 2004 by Alexander Chukov <sash@cacko.biz>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

VENDORTWEAKS = cacko

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

cacko_targetinstall: $(STATEDIR)/cacko.targetinstall

$(STATEDIR)/cacko.targetinstall:
	@$(call targetinfo, vendor-tweaks.targetinstall)

#	install/fix specific X11 stuff
ifdef PTXCONF_XFREE430
	ln -sf Xfbdev $(ROOTDIR)/usr/X11R6/bin/X
	chmod u+s $(ROOTDIR)/usr/X11R6/bin/Xfbdev

	#$(INSTALL) -m 755 $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libqte.so.2.3.2 $(ROOTDIR)/usr/lib
	#ln -sf libqte.so.2.3.2 $(ROOTDIR)/usr/lib/libqte.so.2.3
	#ln -sf libqte.so.2.3.2 $(ROOTDIR)/usr/lib/libqte.so.2

	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/x11 $(ROOTDIR)/etc/rc.d/init.d
ifdef PTXCONF_XFREE430_XDM
	ln -sf ../init.d/x11 $(ROOTDIR)/etc/rc.d/rc5.d/S50x11
endif
	cp -af $(TOPDIR)/config/pdaXrom/kb $(ROOTDIR)/etc/X11
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/fonts.conf $(ROOTDIR)/etc/fonts
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/xinitrc.twm $(ROOTDIR)/etc/X11/xinitrc
	ln -sf ../kb/corgi.xmodmap $(ROOTDIR)/etc/X11/xinit/.Xmodmap
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/Xservers   $(ROOTDIR)/etc/X11/xdm
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/Xsetup_0   $(ROOTDIR)/etc/X11/xdm
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/xdm-config $(ROOTDIR)/etc/X11/xdm
	$(INSTALL) -m 644 $(TOPDIR)/config/pdaXrom/system.twmrc $(ROOTDIR)/etc/X11/twm
	$(INSTALL) -m 755 $(TOPDIR)/config/pdaXrom/startx     $(ROOTDIR)/usr/X11R6/bin
endif

#	remove CVS stuff
	find $(ROOTDIR) -name "CVS" | xargs rm -fr 
	rm -f $(ROOTDIR)/JUST_FOR_CVS

#	make scripts executable
	chmod 755 $(ROOTDIR)/etc/rc.d/init.d/*

#	generate version stamps
	#perl -i -p -e "s,\@VERSION@,$(VERSION),g"           $(ROOTDIR)/etc/rc.d/init.d/banner
	#perl -i -p -e "s,\@PATCHLEVEL@,$(PATCHLEVEL),g"     $(ROOTDIR)/etc/rc.d/init.d/banner
	#perl -i -p -e "s,\@SUBLEVEL@,$(SUBLEVEL),g"         $(ROOTDIR)/etc/rc.d/init.d/banner
	#perl -i -p -e "s,\@PROJECT@,$(PROJECT),g"           $(ROOTDIR)/etc/rc.d/init.d/banner
	#perl -i -p -e "s,\@EXTRAVERSION@,$(EXTRAVERSION),g" $(ROOTDIR)/etc/rc.d/init.d/banner
	perl -i -p -e "s,\@DATE@,$(shell date -Iseconds),g" $(ROOTDIR)/etc/issue

#	create some directories
	install -m 755 -d $(ROOTDIR)/mnt/cf
	install -m 755 -d $(ROOTDIR)/mnt/card
	install -m 755 -d $(ROOTDIR)/mnt/net
	install -m 755 -d $(ROOTDIR)/mnt/ide
	install -m 755 -d $(ROOTDIR)/root
	install -m 775 -d $(ROOTDIR)/var
	install -m 755 -d $(ROOTDIR)/var/empty
	install -m 775 -d $(ROOTDIR)/var/home
	install -m 775 -d $(ROOTDIR)/var/lib/pcmcia
	install -m 777 -d $(ROOTDIR)/var/lock
	install -m 755 -d $(ROOTDIR)/var/lock/subsys
	install -m 755 -d $(ROOTDIR)/var/log
	install -m 775 -d $(ROOTDIR)/var/spool
	install -m 775 -d $(ROOTDIR)/var/tmp
	cd $(ROOTDIR) && ln -sf /var/tmp/tmp tmp
	#chmod 777 $(ROOTDIR)/tmp
	cd $(ROOTDIR)/var && ln -sf /var/tmp/run run
	#cd $(ROOTDIR) && tar c var > $(ROOTDIR)/root/.var_default.tar
	#cd $(ROOTDIR)/dev && ln -sf tty1 console
	#cp $(TOPDIR)/config/bootdisk/.dev_default.tar $(ROOTDIR)/root/
#ifdef PTXCONF_GCC_SHARED
	cp -arf $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libgcc_s.so* $(ROOTDIR)/lib/
	$(CROSSSTRIP) $(ROOTDIR)/lib/libgcc_s.so*
	cp -arf  $(PTXCONF_PREFIX)/$(PTXCONF_GNU_TARGET)/lib/libstdc++.so.* $(ROOTDIR)/lib/
	$(CROSSSTRIP) $(ROOTDIR)/lib/libstdc++.so.*
#endif
	chmod u+s $(ROOTDIR)/bin/busybox
### hotplug files ###
	cp -af $(TOPDIR)/config/pdaXrom-ipaq/hotplug/* $(ROOTDIR)/
#####################
ifdef PTXCONF_MATCHBOX-DESKTOP
	cp -af $(TOPDIR)/config/pdaXrom/matchbox/* $(ROOTDIR)/
endif
ifdef PTXCONF_MATCHBOX-PANEL
	rm -f $(ROOTDIR)/usr/share/applications/mb-show-desktop.desktop
endif
ifdef PTXCONF_APMD_APM
	if [ ! -f $(ROOTDIR)/usr/bin/apm.x ]; then					\
	    mv $(ROOTDIR)/usr/bin/apm $(ROOTDIR)/usr/bin/apm.x			;	\
	    $(INSTALL) -m 755 $(TOPDIR)/config/pdaXrom/apm $(ROOTDIR)/usr/bin	;	\
	fi
endif
	#cd $(TOPDIR)/config/pdaXrom && tar c home > $(ROOTDIR)/root/.home_default.tar
	#ln -sf /home/user $(ROOTDIR)/mnt/user
### sd module ###
	#cp -af $(TOPDIR)/config/pdaXrom/sdmodule/* $(ROOTDIR)/
### remove locale man ###
	rm -rf $(ROOTDIR)/usr/include
	rm -rf $(ROOTDIR)/usr/man
	rm -rf $(ROOTDIR)/usr/share/locale
#########################
	echo $(PROJECT) $(FULLVERSION) "(`date +"%H:%M %d/%m/%y"`)" > $(ROOTDIR)/etc/.buildver
	echo $(PROJECT) $(FULLVERSION) > $(ROOTDIR)/etc/issue
	$(PTXCONF_PREFIX)/bin/mkfs.jffs2 -r $(ROOTDIR) -e 0x40000 -p -q -f > $(TOPDIR)/bootdisk/initrd.jffs2
	gzip -9 $(TOPDIR)/bootdisk/initrd.jffs2
	#cd $(TOPDIR)/bootdisk && cat $(TOPDIR)/config/bootdisk/sharp.bin initrd.jffs2 >initrd.bin
	#rm -f cd $(TOPDIR)/bootdisk/initrd.jffs2
	touch $@

# vim: syntax=make
