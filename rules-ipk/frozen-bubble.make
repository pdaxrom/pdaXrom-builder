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
ifdef PTXCONF_FROZEN-BUBBLE
PACKAGES += frozen-bubble
endif

#
# Paths and names
#
FROZEN-BUBBLE_VERSION		= 1.0.0
FROZEN-BUBBLE			= frozen-bubble-$(FROZEN-BUBBLE_VERSION)
FROZEN-BUBBLE_SUFFIX		= tar.bz2
FROZEN-BUBBLE_URL		= http://www.frozen-bubble.org/$(FROZEN-BUBBLE).$(FROZEN-BUBBLE_SUFFIX)
FROZEN-BUBBLE_SOURCE		= $(SRCDIR)/$(FROZEN-BUBBLE).$(FROZEN-BUBBLE_SUFFIX)
FROZEN-BUBBLE_DIR		= $(BUILDDIR)/$(FROZEN-BUBBLE)
FROZEN-BUBBLE_IPKG_TMP		= $(FROZEN-BUBBLE_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

frozen-bubble_get: $(STATEDIR)/frozen-bubble.get

frozen-bubble_get_deps = $(FROZEN-BUBBLE_SOURCE)

$(STATEDIR)/frozen-bubble.get: $(frozen-bubble_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(FROZEN-BUBBLE))
	touch $@

$(FROZEN-BUBBLE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(FROZEN-BUBBLE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

frozen-bubble_extract: $(STATEDIR)/frozen-bubble.extract

frozen-bubble_extract_deps = $(STATEDIR)/frozen-bubble.get

$(STATEDIR)/frozen-bubble.extract: $(frozen-bubble_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FROZEN-BUBBLE_DIR))
	@$(call extract, $(FROZEN-BUBBLE_SOURCE))
	@$(call patchin, $(FROZEN-BUBBLE))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

frozen-bubble_prepare: $(STATEDIR)/frozen-bubble.prepare

#
# dependencies
#
frozen-bubble_prepare_deps = \
	$(STATEDIR)/frozen-bubble.extract \
	$(STATEDIR)/SDL_perl.install \
	$(STATEDIR)/virtual-xchain.install

FROZEN-BUBBLE_PATH	=  PATH=$(CROSS_PATH)
FROZEN-BUBBLE_ENV 	=  $(CROSS_ENV)
#FROZEN-BUBBLE_ENV	+=
FROZEN-BUBBLE_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#FROZEN-BUBBLE_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
FROZEN-BUBBLE_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
FROZEN-BUBBLE_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
FROZEN-BUBBLE_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/frozen-bubble.prepare: $(frozen-bubble_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FROZEN-BUBBLE_DIR)/config.cache)
	perl -i -p -e "s,\@X11INC\@,$(CROSS_LIB_DIR)/lib,g" $(FROZEN-BUBBLE_DIR)/c_stuff/Makefile.PL
	cd $(FROZEN-BUBBLE_DIR)/c_stuff && \
		$(FROZEN-BUBBLE_PATH) $(FROZEN-BUBBLE_ENV) X11INC=$(CROSS_LIB_DIR)/include \
		perl -I$(PERL_DIR)/lib Makefile.PL
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

frozen-bubble_compile: $(STATEDIR)/frozen-bubble.compile

frozen-bubble_compile_deps = $(STATEDIR)/frozen-bubble.prepare

$(STATEDIR)/frozen-bubble.compile: $(frozen-bubble_compile_deps)
	@$(call targetinfo, $@)
	$(FROZEN-BUBBLE_PATH) $(MAKE) -C $(FROZEN-BUBBLE_DIR)/c_stuff PERLRUN=perl CC=$(PTXCONF_GNU_TARGET)-gcc LD=$(PTXCONF_GNU_TARGET)-gcc
	$(FROZEN-BUBBLE_PATH) $(MAKE) -C $(FROZEN-BUBBLE_DIR) PERLRUN=perl CC=$(PTXCONF_GNU_TARGET)-gcc LD=$(PTXCONF_GNU_TARGET)-gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

frozen-bubble_install: $(STATEDIR)/frozen-bubble.install

$(STATEDIR)/frozen-bubble.install: $(STATEDIR)/frozen-bubble.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

frozen-bubble_targetinstall: $(STATEDIR)/frozen-bubble.targetinstall

frozen-bubble_targetinstall_deps = $(STATEDIR)/frozen-bubble.compile \
	$(STATEDIR)/SDL_perl.targetinstall

$(STATEDIR)/frozen-bubble.targetinstall: $(frozen-bubble_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(PERL_IPKG_TMP)
	$(FROZEN-BUBBLE_PATH) $(MAKE) -C $(FROZEN-BUBBLE_DIR) PREFIX=$(FROZEN-BUBBLE_IPKG_TMP)/usr/local install PERLRUN=perl CC=$(PTXCONF_GNU_TARGET)-gcc LD=$(PTXCONF_GNU_TARGET)-gcc
	chmod -R +w $(PERL_IPKG_TMP)
	for FILE in `find $(PERL_IPKG_TMP)/usr/ -type f`; do		\
	    ZZZ=`file $$FILE | grep 'ELF 32-bit'`;			\
	    if [  "$$ZZZ" != "" ]; then					\
		$(CROSSSTRIP) $$FILE;					\
	    fi;								\
	done
	rm  -f `find $(PERL_IPKG_TMP) -name .packlist`
	rm  -f `find $(PERL_IPKG_TMP) -name *.a`
	rm  -f `find $(PERL_IPKG_TMP) -name *.h`
	rm  -f `find $(PERL_IPKG_TMP) -name *.pod`
	rm  -f `find $(PERL_IPKG_TMP) -name README`
	rm  -f `find $(PERL_IPKG_TMP) -name ChangeLog`
	cp  -a $(PERL_IPKG_TMP)/* $(FROZEN-BUBBLE_IPKG_TMP)
	rm -rf $(FROZEN-BUBBLE_IPKG_TMP)/usr/local/share/man
	mkdir -p $(FROZEN-BUBBLE_IPKG_TMP)/usr/share/applications
	mkdir -p $(FROZEN-BUBBLE_IPKG_TMP)/usr/share/pixmaps
	cp -a $(TOPDIR)/config/pics/frozen-bubble.desktop	$(FROZEN-BUBBLE_IPKG_TMP)/usr/share/applications
	cp -a $(TOPDIR)/config/pics/frozen-bubble.png		$(FROZEN-BUBBLE_IPKG_TMP)/usr/share/pixmaps
	cp -a $(TOPDIR)/config/pics/frozen-bubble.sh		$(FROZEN-BUBBLE_IPKG_TMP)/usr/local/bin
	mkdir -p $(FROZEN-BUBBLE_IPKG_TMP)/CONTROL
	echo "Package: frozen-bubble" 						>$(FROZEN-BUBBLE_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(FROZEN-BUBBLE_IPKG_TMP)/CONTROL/control
	echo "Section: Games" 							>>$(FROZEN-BUBBLE_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(FROZEN-BUBBLE_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(FROZEN-BUBBLE_IPKG_TMP)/CONTROL/control
	echo "Version: $(FROZEN-BUBBLE_VERSION)" 				>>$(FROZEN-BUBBLE_IPKG_TMP)/CONTROL/control
	echo "Depends: sdl-perl" 						>>$(FROZEN-BUBBLE_IPKG_TMP)/CONTROL/control
	echo "Description: Highly addictive game.  Requires perl and perl-sdl"	>>$(FROZEN-BUBBLE_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(FROZEN-BUBBLE_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_FROZEN-BUBBLE_INSTALL
ROMPACKAGES += $(STATEDIR)/frozen-bubble.imageinstall
endif

frozen-bubble_imageinstall_deps = $(STATEDIR)/frozen-bubble.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/frozen-bubble.imageinstall: $(frozen-bubble_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install frozen-bubble
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

frozen-bubble_clean:
	rm -rf $(STATEDIR)/frozen-bubble.*
	rm -rf $(FROZEN-BUBBLE_DIR)

# vim: syntax=make
