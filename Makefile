#
#   Copyright (C) MINZKN.COM
#   All rights reserved.
#
#   Maintainers
#     JaeHyuk Cho <mailto:minzkn@minzkn.com>
#

# hwport-leak-detective.so hook library

SHELL_BASH :=$(wildcard /bin/bash)#
ifneq ($(SHELL_BASH),)
SHELL :=$(SHELL_BASH)# bash shell default using
else
SHELL ?=/bin/sh#
endif
MAKE ?=make#

# .EXPORT_ALL_VARIABLES: # DO NOT USE !
MAKEFLAGS                    ?=#
export MAKEFLAGS
export PATH

HOST_NAME :=$(shell hostname --short)#
HOST_USER :=$(shell whoami)#
HOST_ARCH :=$(shell echo "$(shell uname -m)" | sed \
    -e s/sun4u/sparc64/ \
    -e s/arm.*/arm/ \
    -e s/sa110/arm/ \
    -e s/s390x/s390/ \
    -e s/parisc64/parisc/ \
    -e s/ppc.*/powerpc/ \
    -e s/mips.*/mips/ \
)# auto detect architecture
HOST_OS :=$(shell echo "$(shell uname)" | sed \
    -e  s/Linux/linux/ \
    -e  s/Darwin/darwin/ \
)# auto detect os
HOST_VENDOR :=pc#
HOST_LIBC :=gnu#
HOST_LABEL :=$(HOST_ARCH)#
HOST_BUILD_PROFILE :=$(HOST_ARCH)-$(HOST_VENDOR)-$(HOST_OS)-$(HOST_LIBC)#

TARGET_ARCH :=$(HOST_ARCH)#
TARGET_VENDOR :=$(HOST_VENDOR)#
TARGET_OS :=$(HOST_OS)#
TARGET_LIBC :=$(HOST_LIBC)#
TARGET_LABEL :=$(TARGET_ARCH)#
TARGET_BUILD_PROFILE :=$(TARGET_ARCH)-$(TARGET_VENDOR)-$(TARGET_OS)-$(TARGET_LIBC)#

EXT_DEPEND :=.d#
EXT_C_SOURCE :=.c#
EXT_CXX_SOURCE :=.cpp#
EXT_C_HEADER :=.h#
EXT_CXX_HEADER :=.h#
EXT_OBJECT :=.o#
EXT_LINK_OBJECT :=.lo#
EXT_ARCHIVE :=.a#
EXT_SHARED :=.so#
EXT_EXEC :=#
EXT_CONFIG :=.conf#

KERNEL_DIR ?=$(KERNEL_PATH)#

CROSS_COMPILE :=#

ECHO :=echo#
SYMLINK :=ln -sf#
SED :=sed#
INSTALL :=install#
INSTALL_BIN :=$(INSTALL) -m0755#
INSTALL_LIB :=$(INSTALL) -m0755#
INSTALL_DIR :=$(INSTALL) -d -m0755#
INSTALL_DATA :=$(INSTALL) -m0644#
INSTALL_CONF :=$(INSTALL) -m0644#

CC := $(CROSS_COMPILE)gcc#
LD := $(CROSS_COMPILE)ld#
AR := $(CROSS_COMPILE)ar#
RM := rm -f#
COPY_FILE := cp -f#
CAT :=cat#
STRIP := $(CROSS_COMPILE)strip#

DESTDIR :=./rootfs# default staging directory
CFLAGS_COMMON :=#
CFLAGS :=#
LDFLAGS_COMMON :=#
LDFLAGS :=#
LDFLAGS_EXEC :=-rdynamic -fPIE -pie#
LDFLAGS_SHARED_COMMON :=#
LDFLAGS_SHARED_LINK :=#
LDFLAGS_SHARED :=#
ARFLAGS_COMMON :=#
ARFLAGS :=#

CFLAGS_COMMON +=-O2#
#CFLAGS_COMMON +=-g#
CFLAGS_COMMON +=-pipe#
CFLAGS_COMMON +=-fPIC#
#CFLAGS_COMMON +=-fomit-frame-pointer# backtrace() daes not work !
CFLAGS_COMMON +=-fno-omit-frame-pointer# backtrace() will work normally.
CFLAGS_COMMON +=-Wno-deprecated-declarations# malloc.h specific
#CFLAGS_COMMON +=-ansi#
CFLAGS_COMMON +=-Wall -W#
CFLAGS_COMMON +=-Wshadow#
CFLAGS_COMMON +=-Wcast-qual#
CFLAGS_COMMON +=-Wcast-align#
CFLAGS_COMMON +=-Wpointer-arith#
CFLAGS_COMMON +=-Wbad-function-cast#
CFLAGS_COMMON +=-Wstrict-prototypes#
CFLAGS_COMMON +=-Wmissing-prototypes#
CFLAGS_COMMON +=-Wmissing-declarations#
CFLAGS_COMMON +=-Wnested-externs#
CFLAGS_COMMON +=-Winline#
CFLAGS_COMMON +=-Wwrite-strings#
CFLAGS_COMMON +=-Wchar-subscripts#
CFLAGS_COMMON +=-Wformat#
CFLAGS_COMMON +=-Wformat-security#
CFLAGS_COMMON +=-Wimplicit#
CFLAGS_COMMON +=-Wmain#
CFLAGS_COMMON +=-Wmissing-braces#
CFLAGS_COMMON +=-Wnested-externs#
CFLAGS_COMMON +=-Wparentheses#
CFLAGS_COMMON +=-Wredundant-decls#
CFLAGS_COMMON +=-Wreturn-type#
CFLAGS_COMMON +=-Wsequence-point#
CFLAGS_COMMON +=-Wsign-compare#
CFLAGS_COMMON +=-Wswitch#
CFLAGS_COMMON +=-Wuninitialized#
CFLAGS_COMMON +=-Wunknown-pragmas#
CFLAGS_COMMON +=-Wcomment#
CFLAGS_COMMON +=-Wundef#
CFLAGS_COMMON +=-Wunused#
#CFLAGS_COMMON +=-Wunreachable-code#
CFLAGS_COMMON +=-Wconversion#
#CFLAGS_COMMON +=-Wpadded#
CFLAGS_COMMON +=-I./include#
#CFLAGS_COMMON +=-I/home/jhcho/work/hwport_pgl/pgl/include -I/home/jhcho/work/hwport_pgl/thirdparty/objs/x86_64-pc-linux-gnu.release/local/usr/include#
ifneq ($(STAGING_DIR),)
CFLAGS_COMMON +=-I$(STAGING_DIR)/usr/include#
endif
CFLAGS_COMMON +=-D_REENTRANT# thread safety (optional)
CFLAGS_COMMON +=-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64# enable 64-bits file i/o compatibility (optional)
CFLAGS_COMMON +=-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0# glibc run-time compatibility compile (optional)

#LDFLAGS_SHARED_COMMON +=-nostartfiles#
LDFLAGS_SHARED_COMMON +=-L.#
#LDFLAGS_SHARED_COMMON +=-L/home/jhcho/work/hwport_pgl/thirdparty/objs/x86_64-pc-linux-gnu.release/local/usr/lib#
ifneq ($(STAGING_DIR),)
LDFLAGS_SHARED_COMMON +=-L$(STAGING_DIR)/lib#
LDFLAGS_SHARED_COMMON +=-L$(STAGING_DIR)/usr/lib#
endif
LDFLAGS_SHARED_LINK +=-ldl#
LDFLAGS +=-s#

ARFLAGS_COMMON +=rcs#

LIBRARY_LIST :=hwport-leak-detective#

TARGET :=$(foreach s_this_name,$(LIBRARY_LIST),$(s_this_name)$(EXT_SHARED))#

# default make goal
.PHONY: all world rebuild install
all world: __build_all
rebuild: clean all

install: all
	@$(ECHO) "[**] installing (DESTDIR=\"$(DESTDIR)\")"
	@$(INSTALL_DIR) "$(DESTDIR)/"
	@$(INSTALL_DIR) "$(DESTDIR)/usr/"
	@$(INSTALL_DIR) "$(DESTDIR)/usr/include/"
	@$(foreach s_this_name,$(LIBRARY_LIST),$(INSTALL_DATA) "./include/$(s_this_name)$(EXT_C_HEADER)" "$(DESTDIR)/usr/include/";)
	@$(INSTALL_DIR) "$(DESTDIR)/usr/lib/"
	@$(foreach s_this_name,$(LIBRARY_LIST),$(INSTALL_LIB) "$(s_this_name)$(EXT_SHARED)" "$(DESTDIR)/usr/lib/";)
	@$(ECHO) "[**] installed (DESTDIR=\"$(DESTDIR)\")"

# clean project
.PHONY: distclean clean
distclean clean:
	@$(ECHO) "[**] $(@)"
	@$(RM) -f $(wildcard *$(EXT_OBJECT) *$(EXT_DEPEND) *$(EXT_LINK_OBJECT) *$(EXT_ARCHIVE) *$(EXT_SHARED) *$(EXT_SHARED).*) $(TARGET)

# real build depend
.PHONY: __build_all
__build_all: $(TARGET)
	@$(ECHO) "[**] build complete ($(^))"
	$(if $(TARGET_BUILD_PROFILE),@$(ECHO) "   - TARGET_BUILD_PROFILE=\"$(TARGET_BUILD_PROFILE)\"")
	$(if $(CROSS_COMPILE),@$(ECHO) "   - CROSS_COMPILE=\"$(CROSS_COMPILE)\"")
	$(if $(strip $(CFLAGS_COMMON) $(CFLAGS)),@$(ECHO) "   - CFLAGS=\"$(strip $(CFLAGS_COMMON) $(CFLAGS))\"")
	$(if $(strip $(LDFLAGS_COMMON) $(LDFLAGS)),@$(ECHO) "   - LDFLAGS=\"$(strip $(LDFLAGS_COMMON) $(LDFLAGS))\"")
	$(if $(strip $(LDFLAGS_EXEC)),@$(ECHO) "   - LDFLAGS_EXEC=\"$(strip $(LDFLAGS_EXEC))\"")
	$(if $(strip $(LDFLAGS_SHARED_COMMON) $(LDFLAGS_SHARED)),@$(ECHO) "   - LDFLAGS_SHARED=\"$(strip $(LDFLAGS_SHARED_COMMON) $(LDFLAGS_SHARED))\"")
	$(if $(strip $(ARFLAGS_COMMON) $(ARFLAGS)),@$(ECHO) "   - ARFLAGS=\"$(strip $(ARFLAGS_COMMON) $(ARFLAGS))\"")
	$(if $(KERNEL_PATH),@$(ECHO) "   - KERNEL_PATH=\"$(KERNEL_PATH)\"",$(if $(KERNEL_DIR),@$(ECHO) "   - KERNEL_DIR=\"$(KERNEL_DIR)\""))

# library
PLUGIN_SOURCE_LIST_ZLIB :=$(notdir $(wildcard ./source/*$(EXT_C_SOURCE)))# auto detect source
PLUGIN_OBJECTS_ZLIB :=$(PLUGIN_SOURCE_LIST_ZLIB:%$(EXT_C_SOURCE)=%$(EXT_OBJECT))# auto generate object by source
hwport-leak-detective$(EXT_SHARED): $(PLUGIN_OBJECTS_ZLIB)
	@$(ECHO) "[SO] $(notdir $(@)) <= $(notdir $(^)) (LDFLAGS=\"$(strip $(LDFLAGS_SHARED_COMMON) $(LDFLAGS_SHARED) $(LDFLAGS_COMMON) $(LDFLAGS) $(LDFLAGS_SHARED_LINK))\")"
	@$(CC) $(LDFLAGS_SHARED_COMMON) $(LDFLAGS_SHARED) $(LDFLAGS_COMMON) $(LDFLAGS) -shared -Wl,-soname,$(@) -o "$(@)" $(^) $(LDFLAGS_SHARED_LINK)
	@$(ECHO) "[SL] lib$(notdir $(@)) <= $(notdir $(@))"
#	@$(SYMLINK) "$(@)" "lib$(@)"

# common compile
%$(EXT_OBJECT): ./source/%$(EXT_C_SOURCE) Makefile
	@$(ECHO) "[CC] $(notdir $(@)) <= $(notdir $(<))"
	@$(CC) $(CFLAGS_COMMON) $(CFLAGS) -c -o "$(@)" "$(<)"
	@$(CC) -MMD $(CFLAGS_COMMON) $(CFLAGS) -c -o "$(@)" "$(<)" # create depend rule file (strong depend check, optional)

# include depend rules (strong depend check, optional)
override THIS_DEPEND_RULES_LIST:=$(wildcard *$(EXT_DEPEND))#
ifneq ($(THIS_DEPEND_RULES_LIST),)
sinclude $(THIS_DEPEND_RULES_LIST)
endif

.DEFAULT:
	@$(ECHO) "[!!] unknown goal ($(@))"

# End of Makefile
