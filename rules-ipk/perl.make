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
ifdef PTXCONF_PERL
PACKAGES += perl
endif

#
# Paths and names
#
PERL_VERSION		= 5.8.5
PERL			= perl-$(PERL_VERSION)
PERL_SUFFIX		= tar.bz2
PERL_URL		= http://ftp.funet.fi/pub/CPAN/src//$(PERL).$(PERL_SUFFIX)
PERL_SOURCE		= $(SRCDIR)/$(PERL).$(PERL_SUFFIX)
PERL_DIR		= $(BUILDDIR)/$(PERL)
PERL_IPKG_TMP		= $(PERL_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

perl_get: $(STATEDIR)/perl.get

perl_get_deps = $(PERL_SOURCE)

$(STATEDIR)/perl.get: $(perl_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(PERL))
	touch $@

$(PERL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(PERL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

perl_extract: $(STATEDIR)/perl.extract

perl_extract_deps = $(STATEDIR)/perl.get

$(STATEDIR)/perl.extract: $(perl_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PERL_DIR))
	@$(call extract, $(PERL_SOURCE))
	@$(call patchin, $(PERL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

perl_prepare: $(STATEDIR)/perl.prepare

#
# dependencies
#
perl_prepare_deps = \
	$(STATEDIR)/perl.extract \
	$(STATEDIR)/gdbm.install \
	$(STATEDIR)/virtual-xchain.install

PERL_PATH	=  PATH=$(CROSS_PATH)

$(STATEDIR)/perl.prepare: $(perl_prepare_deps)
	@$(call targetinfo, $@)
ifdef PTXCONF_OPT_I686
	perl -i -p -e "s,\@IPKG_TMP\@,$(PERL_IPKG_TMP),g" $(PERL_DIR)/Cross/config.sh-i686-linux
else
	perl -i -p -e "s,\@IPKG_TMP\@,$(PERL_IPKG_TMP),g" $(PERL_DIR)/Cross/config.sh-$(PTXCONF_ARCH)-linux
endif
	perl -i -p -e "s,\@CROSS_LIB_DIR@,$(CROSS_LIB_DIR),g"	$(PERL_DIR)/ext/Errno/Errno_pm.PL
	cd $(PERL_DIR)/Cross && $(PERL_PATH) $(MAKE) patch
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

perl_compile: $(STATEDIR)/perl.compile

perl_compile_deps = $(STATEDIR)/perl.prepare

$(STATEDIR)/perl.compile: $(perl_compile_deps)
	@$(call targetinfo, $@)
	cd $(PERL_DIR)/Cross && $(PERL_PATH) $(MAKE) perl
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

perl_install: $(STATEDIR)/perl.install

$(STATEDIR)/perl.install: $(STATEDIR)/perl.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

perl_targetinstall: $(STATEDIR)/perl.targetinstall

perl_targetinstall_deps = \
	$(STATEDIR)/gdbm.targetinstall \
	$(STATEDIR)/perl.compile

$(STATEDIR)/perl.targetinstall: $(perl_targetinstall_deps)
	@$(call targetinfo, $@)
	###$(PERL_PATH) $(MAKE) -C $(PERL_DIR) DESTDIR=$(PERL_IPKG_TMP) install
	rm -rf $(PERL_IPKG_TMP)
	cd $(PERL_DIR) && $(PERL_PATH) $(MAKE) install-strip
	cd $(PERL_DIR) && $(PERL_PATH) sh -x Cross/warp
	chmod -R +w $(PERL_IPKG_TMP)
	mv $(PERL_IPKG_TMP)/usr/bin/perl$(PERL_VERSION) $(PERL_IPKG_TMP)/usr
	rm -rf $(PERL_IPKG_TMP)/usr/bin/*
	mv $(PERL_IPKG_TMP)/usr/perl$(PERL_VERSION) $(PERL_IPKG_TMP)/usr/bin
	ln -sf perl$(PERL_VERSION) $(PERL_IPKG_TMP)/usr/bin/perl
	for FILE in `find $(PERL_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	rm  -rf $(PERL_IPKG_TMP)/usr/lib/perl5/$(PERL_VERSION)/$(PTXCONF_ARCH)-linux/auto/Encode/{CN,JP,KR,TW}
	#rm -rf $(PERL_IPKG_TMP)/usr/lib/perl5/$(PERL_VERSION)/$(PTXCONF_ARCH)-linux/CORE
	rm   -f $(PERL_IPKG_TMP)/usr/lib/perl5/$(PERL_VERSION)/unicore/*.txt
	rm  -f `find $(PERL_IPKG_TMP) -name .packlist`
	rm  -f `find $(PERL_IPKG_TMP) -name *.a`
	rm  -f `find $(PERL_IPKG_TMP) -name *.h`
	rm  -f `find $(PERL_IPKG_TMP) -name *.pod`
	rm  -f `find $(PERL_IPKG_TMP) -name README`
	rm  -f `find $(PERL_IPKG_TMP) -name ChangeLog`

	mkdir -p $(PERL_IPKG_TMP)/CONTROL
	echo "Package: perl" 			>$(PERL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 			>>$(PERL_IPKG_TMP)/CONTROL/control
	echo "Section: Development" 			>>$(PERL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>">>$(PERL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 		>>$(PERL_IPKG_TMP)/CONTROL/control
	echo "Version: $(PERL_VERSION)" 		>>$(PERL_IPKG_TMP)/CONTROL/control
	echo "Depends: gdbm" 				>>$(PERL_IPKG_TMP)/CONTROL/control
	echo "Description: Perl is a stable, cross platform programming language.">>$(PERL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(PERL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_PERL_INSTALL
ROMPACKAGES += $(STATEDIR)/perl.imageinstall
endif

perl_imageinstall_deps = $(STATEDIR)/perl.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/perl.imageinstall: $(perl_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install perl
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

perl_clean:
	rm -rf $(STATEDIR)/perl.*
	rm -rf $(PERL_DIR)

# vim: syntax=make
