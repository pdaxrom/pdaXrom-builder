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
ifdef PTXCONF_QT-EMBEDDED
PACKAGES += qt-embedded
endif

#
# Paths and names
#
ifndef PTXCONF_QTOPIA-FREE2
QT-EMBEDDED_VERSION	= 2.3.8
QT-EMBEDDED		= qt-embedded-$(QT-EMBEDDED_VERSION)
QT-EMBEDDED_DIR		= $(BUILDDIR)/qt-$(QT-EMBEDDED_VERSION)
QT-EMBEDDED_SUFFIX	= tar.bz2
else
QT-EMBEDDED_VERSION	= 2.3.9
QT-EMBEDDED		= qt-embedded-$(QT-EMBEDDED_VERSION)-snapshot-20041223
QT-EMBEDDED_DIR		= $(BUILDDIR)/qt-$(QT-EMBEDDED_VERSION)-snapshot-20041223
QT-EMBEDDED_SUFFIX	= tar.gz
###QT-EMBEDDED_VERSION	= 4.0.0-b1
###QT-EMBEDDED		= qt-embedded-opensource-$(QT-EMBEDDED_VERSION)
###QT-EMBEDDED_DIR	= $(BUILDDIR)/qt-embedded-opensource-$(QT-EMBEDDED_VERSION)
###QT-EMBEDDED_SUFFIX	= tar.bz2
endif
QT-EMBEDDED_URL		= ftp://ftp.trolltech.com/qt/source/$(QT-EMBEDDED).$(QT-EMBEDDED_SUFFIX)
QT-EMBEDDED_SOURCE	= $(SRCDIR)/$(QT-EMBEDDED).$(QT-EMBEDDED_SUFFIX)
QT-EMBEDDED_IPKG_TMP	= $(QT-EMBEDDED_DIR)/ipkg_tmp

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

qt-embedded_get: $(STATEDIR)/qt-embedded.get

qt-embedded_get_deps = $(QT-EMBEDDED_SOURCE)

$(STATEDIR)/qt-embedded.get: $(qt-embedded_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QT-EMBEDDED))
	touch $@

$(QT-EMBEDDED_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QT-EMBEDDED_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

qt-embedded_extract: $(STATEDIR)/qt-embedded.extract

qt-embedded_extract_deps = $(STATEDIR)/qt-embedded.get

$(STATEDIR)/qt-embedded.extract: $(qt-embedded_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QT-EMBEDDED_DIR))
	@$(call extract, $(QT-EMBEDDED_SOURCE))
	@$(call patchin, $(QT-EMBEDDED), $(QT-EMBEDDED_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

qt-embedded_prepare: $(STATEDIR)/qt-embedded.prepare

#
# dependencies
#
qt-embedded_prepare_deps = \
	$(STATEDIR)/qt-embedded.extract \
	$(STATEDIR)/libpng125.install \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/jpeg.install \
	$(STATEDIR)/virtual-xchain.install

ifdef PTXCONF_QTOPIA
qt-embedded_prepare_deps += $(STATEDIR)/qtopia-free.extract
endif

QT-EMBEDDED_PATH	=  PATH=$(QT-EMBEDDED_DIR)/bin:$(CROSS_PATH)
QT-EMBEDDED_ENV 	=  $(CROSS_ENV)
#QT-EMBEDDED_ENV	+=
QT-EMBEDDED_ENV		+= PKG_CONFIG_PATH=$(CROSS_LIB_DIR)/lib/pkgconfig:$(CROSS_LIB_DIR)/lib/pkgconfig
QT-EMBEDDED_ENV		+= QTDIR=$(QT-EMBEDDED_DIR)
QT-EMBEDDED_ENV		+= QTEDIR=$(QT-EMBEDDED_DIR)
#
# autoconf
#
QT-EMBEDDED_AUTOCONF = -gif -system-libpng -system-jpeg -system-zlib -no-g++-exceptions -I$(CROSS_LIB_DIR)/include -L$(CROSS_LIB_DIR)/lib -R$(CROSS_LIB_DIR)/lib

ifdef PTXCONF_QTOPIA-FREE-SL5500
ifndef PTXCONF_QTOPIA-FREE2
QT-EMBEDDED_AUTOCONF += -xplatform linux-sharp-g++ -shared -release -qconfig qpe -depths 16 -no-qvfb
else
QT-EMBEDDED_AUTOCONF += -xplatform linux-sharp-g++ -shared -release -qconfig qpe -depths 16,32 -no-qvfb
###QT-EMBEDDED_AUTOCONF += -embedded sharp -shared -release -depths 16 -no-qvfb -qconfig qpe
endif
endif

ifdef PTXCONF_QTOPIA-FREE-IPAQ
ifndef PTXCONF_QTOPIA-FREE2
QT-EMBEDDED_AUTOCONF += -xplatform linux-ipaq-g++ -shared -release -qconfig qpe -depths 16 -no-qvfb
else
QT-EMBEDDED_AUTOCONF += -xplatform linux-ipaq-g++ -shared -release -qconfig qpe -depths 16,32 -no-qvfb
###QT-EMBEDDED_AUTOCONF += -embedded ipaq -shared -release -depths 16 -no-qvfb
endif
endif

$(STATEDIR)/qt-embedded.prepare: $(qt-embedded_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(QT-EMBEDDED_DIR)/config.cache)
ifdef PTXCONF_QTOPIA-FREE
ifndef PTXCONF_QTOPIA-FREE2
	cp -f $(QTOPIA-FREE_DIR)/src/qt/qconfig-qpe.h $(QT-EMBEDDED_DIR)/src/tools/
else
	###touch $(QT-EMBEDDED_DIR)/src/core/arch/arm/qatomic.cpp
	cp -f $(QTOPIA-FREE_DIR)/src/qt/qconfig-qpe.h $(QT-EMBEDDED_DIR)/src/tools/
endif
endif
	cd $(QT-EMBEDDED_DIR) && \
		echo yes | \
		$(QT-EMBEDDED_PATH) $(QT-EMBEDDED_ENV) \
		./configure $(QT-EMBEDDED_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

qt-embedded_compile: $(STATEDIR)/qt-embedded.compile

qt-embedded_compile_deps = $(STATEDIR)/qt-embedded.prepare

$(STATEDIR)/qt-embedded.compile: $(qt-embedded_compile_deps)
	@$(call targetinfo, $@)
	$(QT-EMBEDDED_PATH) $(QT-EMBEDDED_ENV) $(MAKE) -C $(QT-EMBEDDED_DIR) sub-src
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

qt-embedded_install: $(STATEDIR)/qt-embedded.install

$(STATEDIR)/qt-embedded.install: $(STATEDIR)/qt-embedded.compile
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

qt-embedded_targetinstall: $(STATEDIR)/qt-embedded.targetinstall

qt-embedded_targetinstall_deps = $(STATEDIR)/qt-embedded.compile \
	$(STATEDIR)/libpng125.targetinstall \
	$(STATEDIR)/jpeg.targetinstall \
	$(STATEDIR)/zlib.targetinstall

$(STATEDIR)/qt-embedded.targetinstall: $(qt-embedded_targetinstall_deps)
	@$(call targetinfo, $@)
	#$(QT-EMBEDDED_PATH) $(MAKE) -C $(QT-EMBEDDED_DIR) DESTDIR=$(QT-EMBEDDED_IPKG_TMP) install
	mkdir -p $(QT-EMBEDDED_IPKG_TMP)/CONTROL
	echo "Package: qt-embedded" 						>$(QT-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Priority: optional" 						>>$(QT-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Section: pdaXrom" 						>>$(QT-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Maintainer: Alexander Chukov <sash@pdaXrom.org>" 			>>$(QT-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Architecture: $(SHORT_TARGET)" 					>>$(QT-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Version: $(QT-EMBEDDED_VERSION)" 					>>$(QT-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Depends: " 							>>$(QT-EMBEDDED_IPKG_TMP)/CONTROL/control
	echo "Description: generated with pdaXrom builder"			>>$(QT-EMBEDDED_IPKG_TMP)/CONTROL/control
	asdasd
	cd $(FEEDDIR) && $(XMKIPKG) $(QT-EMBEDDED_IPKG_TMP)
	touch $@

# ----------------------------------------------------------------------------
# Image-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_QT-EMBEDDED_INSTALL
ROMPACKAGES += $(STATEDIR)/qt-embedded.imageinstall
endif

qt-embedded_imageinstall_deps = $(STATEDIR)/qt-embedded.targetinstall \
	$(STATEDIR)/virtual-image.install

$(STATEDIR)/qt-embedded.imageinstall: $(qt-embedded_imageinstall_deps)
	@$(call targetinfo, $@)
	cd $(FEEDDIR) && $(XIPKG) install qt-embedded
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

qt-embedded_clean:
	rm -rf $(STATEDIR)/qt-embedded.*
	rm -rf $(QT-EMBEDDED_DIR)

# vim: syntax=make
