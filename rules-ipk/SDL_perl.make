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
ifdef PTXCONF_SDL_PERL
PACKAGES += SDL_perl
endif

#
# Paths and names
#
SDL_PERL_VERSION	= 1.19.2
SDL_PERL		= SDL_perl-$(SDL_PERL_VERSION)
SDL_PERL_SUFFIX		= tar.gz
SDL_PERL_URL		= http://sdlperl.org/$(SDL_PERL).$(SDL_PERL_SUFFIX)
SDL_PERL_SOURCE		= $(SRCDIR)/$(SDL_PERL).$(SDL_PERL_SUFFIX)
SDL_PERL_DIR		= $(BUILDDIR)/$(SDL_PERL)
SDL_PERL_IPKG_TMP	= $(PERL_IPKG_TMP)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

SDL_perl_get: $(STATEDIR)/SDL_perl.get

SDL_perl_get_deps = $(SDL_PERL_SOURCE)

$(STATEDIR)/SDL_perl.get: $(SDL_perl_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(SDL_PERL))
	touch $@

$(SDL_PERL_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(SDL_PERL_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

SDL_perl_extract: $(STATEDIR)/SDL_perl.extract

SDL_perl_extract_deps = $(STATEDIR)/SDL_perl.get

$(STATEDIR)/SDL_perl.extract: $(SDL_perl_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDL_PERL_DIR))
	@$(call extract, $(SDL_PERL_SOURCE))
	@$(call patchin, $(SDL_PERL))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

SDL_perl_prepare: $(STATEDIR)/SDL_perl.prepare

#
# dependencies
#
SDL_perl_prepare_deps = \
	$(STATEDIR)/SDL_perl.extract \
	$(STATEDIR)/SDL.install \
	$(STATEDIR)/SDL_mixer.install \
	$(STATEDIR)/SDL_net.install \
	$(STATEDIR)/SDL_image.install \
	$(STATEDIR)/SDL_ttf.install \
	$(STATEDIR)/perl.install \
	$(STATEDIR)/virtual-xchain.install

SDL_PERL_PATH	=  PATH=$(CROSS_PATH)
SDL_PERL_ENV 	=  $(CROSS_ENV)
#SDL_PERL_ENV	+=
SDL_PERL_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#SDL_PERL_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
SDL_PERL_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
SDL_PERL_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
SDL_PERL_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/SDL_perl.prepare: $(SDL_perl_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(SDL_PERL_DIR)/config.cache)
	perl -i -p -e "s,\@INC_PATH\@,$(CROSS_LIB_DIR),g" $(SDL_PERL_DIR)/Makefile.linux
	cd $(SDL_PERL_DIR) && \
		$(SDL_PERL_PATH) $(SDL_PERL_ENV) perl -I$(PERL_DIR)/lib Makefile.PL
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

SDL_perl_compile: $(STATEDIR)/SDL_perl.compile

SDL_perl_compile_deps = $(STATEDIR)/SDL_perl.prepare

$(STATEDIR)/SDL_perl.compile: $(SDL_perl_compile_deps)
	@$(call targetinfo, $@)
	$(SDL_PERL_PATH) $(MAKE) -C $(SDL_PERL_DIR) PERLRUN=perl CC=$(PTXCONF_GNU_TARGET)-gcc LD=$(PTXCONF_GNU_TARGET)-gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

SDL_perl_install: $(STATEDIR)/SDL_perl.install

$(STATEDIR)/SDL_perl.install: $(STATEDIR)/SDL_perl.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

SDL_perl_targetinstall: $(STATEDIR)/SDL_perl.targetinstall

SDL_perl_targetinstall_deps = $(STATEDIR)/SDL_perl.compile \
	$(STATEDIR)/SDL.targetinstall \
	$(STATEDIR)/SDL_mixer.targetinstall \
	$(STATEDIR)/SDL_net.targetinstall \
	$(STATEDIR)/SDL_image.targetinstall \
	$(STATEDIR)/SDL_ttf.targetinstall \
	$(STATEDIR)/perl.targetinstall

$(STATEDIR)/SDL_perl.targetinstall: $(SDL_perl_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(PERL_IPKG_TMP)
	$(SDL_PERL_PATH) $(MAKE) -C $(SDL_PERL_DIR) install PERLRUN=perl CC=$(PTXCONF_GNU_TARGET)-gcc LD=$(PTXCONF_GNU_TARGET)-gcc
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
	mkdir -p $(SDL_PERL_IPKG_TMP)/CONTROL
	echo "Package: sdl-perl" 						>$(SDL_PERL_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(SDL_PERL_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 						>>$(SDL_PERL_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(SDL_PERL_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(SDL_PERL_IPKG_TMP)/CONTROL/control
	echo "Version: $(SDL_PERL_VERSION)" 					>>$(SDL_PERL_IPKG_TMP)/CONTROL/control
	echo "Depends: perl, sdl, sdl-image, sdl-mixer, sdl-net, sdl-ttf, libjpeg, libpng" >>$(SDL_PERL_IPKG_TMP)/CONTROL/control
	echo "Description: SDL_perl Multimedia Perl Extension"			>>$(SDL_PERL_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(SDL_PERL_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SDL_PERL_INSTALL
ROMPACKAGES += $(STATEDIR)/SDL_perl.imageinstall
endif

SDL_perl_imageinstall_deps = $(STATEDIR)/SDL_perl.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/SDL_perl.imageinstall: $(SDL_perl_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install sdl-perl
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

SDL_perl_clean:
	rm -rf $(STATEDIR)/SDL_perl.*
	rm -rf $(SDL_PERL_DIR)

# vim: syntax=make
