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

#
ifdef PTXCONF_XFREE430
	ln -sf Xfbdev $(ROOTDIR)/usr/X11R6/bin/X
	chmod u+s $(ROOTDIR)/usr/X11R6/bin/Xfbdev
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
	install -m 755 -d $(ROOTDIR)/mnt/floppy
	install -m 755 -d $(ROOTDIR)/mnt/cdrom
	install -m 755 -d $(ROOTDIR)/mnt/hd
	install -m 755 -d $(ROOTDIR)/mnt/net
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
	install -m 777 -d $(ROOTDIR)/var/run
	#cd $(ROOTDIR) && ln -sf /dev/shm/tmp tmp
	chmod 777 $(ROOTDIR)/tmp
	#cd $(ROOTDIR)/var && ln -sf /dev/shm/run run
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
	#$(PTXCONF_PREFIX)/bin/mkfs.jffs2 --eraseblock=16k --root=$(ROOTDIR) --little-endian --squash --faketime --devtable=$(TOPDIR)/config/bootdisk/device_table-minimal.txt -n --output=$(TOPDIR)/bootdisk/initrd.jffs2
	#cd $(TOPDIR)/bootdisk && cat $(TOPDIR)/config/bootdisk/sharp.bin initrd.jffs2 >initrd.bin
	#rm -f cd $(TOPDIR)/bootdisk/initrd.jffs2
	$(PTXCONF_PREFIX)/bin/genext2fs -r 0 -d $(ROOTDIR) \
	-b 8192 \
	-f $(TOPDIR)/config/bootdisk/dev_ext2.txt \
	$(TOPDIR)/bootdisk/initrd
	#-f $(BOOTDISK_DEV) \

	touch $@

# vim: syntax=make
