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
ifdef PTXCONF_XCHAIN_QT-X11-FREE
PACKAGES += xchain-qt-x11-free
endif

#
# Paths and names
#
XCHAIN_QT-X11-FREE_DIR		= $(XCHAIN_BUILDDIR)/$(QT-X11-FREE)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xchain-qt-x11-free_get: $(STATEDIR)/xchain-qt-x11-free.get

xchain-qt-x11-free_get_deps = $(XCHAIN_QT-X11-FREE_SOURCE)

$(STATEDIR)/xchain-qt-x11-free.get: $(xchain-qt-x11-free_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(QT-X11-FREE))
	touch $@

$(XCHAIN_QT-X11-FREE_SOURCE):
	@$(call targetinfo, $@)
	@$(call get, $(QT-X11-FREE_URL))

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xchain-qt-x11-free_extract: $(STATEDIR)/xchain-qt-x11-free.extract

xchain-qt-x11-free_extract_deps = $(STATEDIR)/xchain-qt-x11-free.get

$(STATEDIR)/xchain-qt-x11-free.extract: $(xchain-qt-x11-free_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_QT-X11-FREE_DIR))
	@$(call extract, $(QT-X11-FREE_SOURCE), $(XCHAIN_BUILDDIR))
	@$(call patchin, $(QT-X11-FREE), $(XCHAIN_QT-X11-FREE_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xchain-qt-x11-free_prepare: $(STATEDIR)/xchain-qt-x11-free.prepare

#
# dependencies
#
xchain-qt-x11-free_prepare_deps = \
	$(STATEDIR)/xchain-qt-x11-free.extract

XCHAIN_QT-X11-FREE_PATH	=  PATH=$(CROSS_PATH)
XCHAIN_QT-X11-FREE_ENV 	=  $(HOSTCC_ENV)
XCHAIN_QT-X11-FREE_ENV += QTDIR=$(QT-X11-FREE_DIR)

#
# autoconf
#
#XCHAIN_QT-X11-FREE_AUTOCONF = \
#	--prefix=$(PTXCONF_PREFIX) \
#	--build=$(GNU_HOST)
# 	--host=$(GNU_HOST)
# 	--target=$(PTXCONF_GNU_TARGET)

$(STATEDIR)/xchain-qt-x11-free.prepare: $(xchain-qt-x11-free_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XCHAIN_QT-X11-FREE_DIR)/config.cache)
	perl -p -i -e "s/\@X11INC@/`echo $(NATIVE_SDK_FILES_PREFIX)/include | sed -e '/\//s//\\\\\//g'`/g"	$(XCHAIN_QT-X11-FREE_DIR)/mkspecs/linux-g++/qmake.conf
	perl -p -i -e "s/\@X11LIB@/`echo /usr/X11R6/lib | sed -e '/\//s//\\\\\//g'`/g"				$(XCHAIN_QT-X11-FREE_DIR)/mkspecs/linux-g++/qmake.conf
	perl -p -i -e "s/\@INCDIR@/`echo $(NATIVE_SDK_FILES_PREFIX)/include | sed -e '/\//s//\\\\\//g'`/g"	$(XCHAIN_QT-X11-FREE_DIR)/mkspecs/linux-g++/qmake.conf
	perl -p -i -e "s/\@LIBDIR@/`echo $(NATIVE_SDK_FILES_PREFIX)/lib | sed -e '/\//s//\\\\\//g'`/g"		$(XCHAIN_QT-X11-FREE_DIR)/mkspecs/linux-g++/qmake.conf
ifndef PTXCONF_QT-X11-FREE-QT4
	cd $(XCHAIN_QT-X11-FREE_DIR) && \
		$(XCHAIN_QT-X11-FREE_PATH) $(XCHAIN_QT-X11-FREE_ENV) \
		echo yes | ./configure -static -thread -release
else
	###mkdir $(XCHAIN_QT-X11-FREE_DIR)/src/plugins/styles/pocketpc
	cd $(XCHAIN_QT-X11-FREE_DIR) && \
		$(XCHAIN_QT-X11-FREE_PATH) $(XCHAIN_QT-X11-FREE_ENV) \
		echo yes | ./configure -static -release
endif
	perl -p -i -e "s/all\:/all\: \#/g" $(XCHAIN_QT-X11-FREE_DIR)/tutorial/Makefile
	perl -p -i -e "s/all\:/all\: \#/g" $(XCHAIN_QT-X11-FREE_DIR)/examples/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xchain-qt-x11-free_compile: $(STATEDIR)/xchain-qt-x11-free.compile

xchain-qt-x11-free_compile_deps = $(STATEDIR)/xchain-qt-x11-free.prepare

$(STATEDIR)/xchain-qt-x11-free.compile: $(xchain-qt-x11-free_compile_deps)
	@$(call targetinfo, $@)
	$(XCHAIN_QT-X11-FREE_PATH) $(MAKE) -C $(XCHAIN_QT-X11-FREE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xchain-qt-x11-free_install: $(STATEDIR)/xchain-qt-x11-free.install

$(STATEDIR)/xchain-qt-x11-free.install: $(STATEDIR)/xchain-qt-x11-free.compile
	@$(call targetinfo, $@)
	##$(XCHAIN_QT-X11-FREE_PATH) $(MAKE) -C $(XCHAIN_QT-X11-FREE_DIR) install
	install -s -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/assistant $(PTXCONF_PREFIX)/bin
	install -s -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/designer  $(PTXCONF_PREFIX)/bin
	install    -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/findtr    $(PTXCONF_PREFIX)/bin
	install -s -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/linguist  $(PTXCONF_PREFIX)/bin
	install -s -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/lrelease  $(PTXCONF_PREFIX)/bin
	install -s -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/lupdate   $(PTXCONF_PREFIX)/bin
	install -s -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/moc       $(PTXCONF_PREFIX)/bin
	install -s -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/qm2ts     $(PTXCONF_PREFIX)/bin
	install -s -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/qmake     $(PTXCONF_PREFIX)/bin
	##install -s -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/qtconfig  $(PTXCONF_PREFIX)/bin
	install -s -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/uic       $(PTXCONF_PREFIX)/bin
ifdef PTXCONF_QT-X11-FREE-QT4
	install -s -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/qt3to4    $(PTXCONF_PREFIX)/bin
	install -s -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/rcc       $(PTXCONF_PREFIX)/bin
	install -s -m 755 $(XCHAIN_QT-X11-FREE_DIR)/bin/uic3      $(PTXCONF_PREFIX)/bin
endif
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xchain-qt-x11-free_targetinstall: $(STATEDIR)/xchain-qt-x11-free.targetinstall

xchain-qt-x11-free_targetinstall_deps = $(STATEDIR)/xchain-qt-x11-free.compile

$(STATEDIR)/xchain-qt-x11-free.targetinstall: $(xchain-qt-x11-free_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xchain-qt-x11-free_clean:
	rm -rf $(STATEDIR)/xchain-qt-x11-free.*
	rm -rf $(XCHAIN_QT-X11-FREE_DIR)

# vim: syntax=make
