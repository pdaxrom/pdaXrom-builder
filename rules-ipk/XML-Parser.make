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
ifdef PTXCONF_XML-PARSER
PACKAGES += XML-Parser
endif

#
# Paths and names
#
XML-PARSER_VERSION	= 2.34
XML-PARSER		= XML-Parser-$(XML-PARSER_VERSION)
XML-PARSER_SUFFIX	= tar.gz
XML-PARSER_URL		= http://www.cpan.org/modules/by-module/XML/$(XML-PARSER).$(XML-PARSER_SUFFIX)
XML-PARSER_SOURCE	= $(SRCDIR)/$(XML-PARSER).$(XML-PARSER_SUFFIX)
XML-PARSER_DIR		= $(BUILDDIR)/$(XML-PARSER)
XML-PARSER_IPKG_TMP	= $(PERL_IPKG_TMP)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

XML-Parser_get: $(STATEDIR)/XML-Parser.get

XML-Parser_get_deps = $(XML-PARSER_SOURCE)

$(STATEDIR)/XML-Parser.get: $(XML-Parser_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XML-PARSER))
	touch $@

$(XML-PARSER_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(XML-PARSER_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

XML-Parser_extract: $(STATEDIR)/XML-Parser.extract

XML-Parser_extract_deps = $(STATEDIR)/XML-Parser.get

$(STATEDIR)/XML-Parser.extract: $(XML-Parser_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XML-PARSER_DIR))
	@$(call extract, $(XML-PARSER_SOURCE))
	@$(call patchin, $(XML-PARSER))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

XML-Parser_prepare: $(STATEDIR)/XML-Parser.prepare

#
# dependencies
#
XML-Parser_prepare_deps = \
	$(STATEDIR)/XML-Parser.extract \
	$(STATEDIR)/perl.compile \
	$(STATEDIR)/expat.install \
	$(STATEDIR)/virtual-xchain.install

XML-PARSER_PATH	=  PATH=$(CROSS_PATH)
XML-PARSER_ENV 	=  $(CROSS_ENV)
#XML-PARSER_ENV	+=
XML-PARSER_ENV	+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
#ifdef PTXCONF_XFREE430
#XML-PARSER_ENV	+= LDFLAGS=-Wl,-rpath-link,$(CROSS_LIB_DIR)/lib
#endif

#
# autoconf
#
XML-PARSER_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=/usr

ifdef PTXCONF_XFREE430
XML-PARSER_AUTOCONF += --x-includes=$(CROSS_LIB_DIR)/include
XML-PARSER_AUTOCONF += --x-libraries=$(CROSS_LIB_DIR)/lib
endif

$(STATEDIR)/XML-Parser.prepare: $(XML-Parser_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XML-PARSER_DIR)/config.cache)
	cd $(XML-PARSER_DIR) && \
	    $(XML-PARSER_PATH) $(XML-PARSER_ENV) perl -I$(PERL_DIR)/lib Makefile.PL
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

XML-Parser_compile: $(STATEDIR)/XML-Parser.compile

XML-Parser_compile_deps = $(STATEDIR)/XML-Parser.prepare

$(STATEDIR)/XML-Parser.compile: $(XML-Parser_compile_deps)
	@$(call targetinfo, $@)
	$(XML-PARSER_PATH) $(MAKE) -C $(XML-PARSER_DIR) PERLRUN=perl CC=$(PTXCONF_GNU_TARGET)-gcc LD=$(PTXCONF_GNU_TARGET)-gcc
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

XML-Parser_install: $(STATEDIR)/XML-Parser.install

$(STATEDIR)/XML-Parser.install: $(STATEDIR)/XML-Parser.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

XML-Parser_targetinstall: $(STATEDIR)/XML-Parser.targetinstall

XML-Parser_targetinstall_deps = $(STATEDIR)/XML-Parser.compile \
	$(STATEDIR)/perl.targetinstall \
	$(STATEDIR)/expat.targetinstall

$(STATEDIR)/XML-Parser.targetinstall: $(XML-Parser_targetinstall_deps)
	@$(call targetinfo, $@)
	rm -rf $(XML-PARSER_IPKG_TMP)
	$(XML-PARSER_PATH) $(MAKE) -C $(XML-PARSER_DIR) PERLRUN=perl install CC=$(PTXCONF_GNU_TARGET)-gcc LD=$(PTXCONF_GNU_TARGET)-gcc
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
	mkdir -p $(XML-PARSER_IPKG_TMP)/CONTROL
	echo "Package: xml-parser" 						>$(XML-PARSER_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(XML-PARSER_IPKG_TMP)/CONTROL/control
	echo "Section: Libraries" 						>>$(XML-PARSER_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(XML-PARSER_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(XML-PARSER_IPKG_TMP)/CONTROL/control
	echo "Version: $(XML-PARSER_VERSION)" 					>>$(XML-PARSER_IPKG_TMP)/CONTROL/control
	echo "Depends: perl, expat" 						>>$(XML-PARSER_IPKG_TMP)/CONTROL/control
	echo "Description: XML::Parser"						>>$(XML-PARSER_IPKG_TMP)/CONTROL/control
	cd $(FEEDDIR) && $(XMKIPKG) $(XML-PARSER_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_XML-PARSER_INSTALL
ROMPACKAGES += $(STATEDIR)/XML-Parser.imageinstall
endif

XML-Parser_imageinstall_deps = $(STATEDIR)/XML-Parser.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/XML-Parser.imageinstall: $(XML-Parser_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install xml-parser
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

XML-Parser_clean:
	rm -rf $(STATEDIR)/XML-Parser.*
	rm -rf $(XML-PARSER_DIR)

# vim: syntax=make
