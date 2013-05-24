VERSION= 0.1

ARCH            ?= sandbox
CROSS_COMPILE   ?=

MAKEFLAGS = --no-print-directory

srctree		:= $(CURDIR)

INCLUDES       := -I$(srctree)/include \
                  -I$(srctree)/arch/$(ARCH)/include \
                  -include $(srctree)/include/generated/autoconf.h \
                  -include $(srctree)/include/kconfig.h

CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld
CFLAGS=-W -Wall -ansi -pedantic -MMD $(INCLUDES) -Wno-variadic-macros
LDFLAGS=
EXEC=hello
SRC= $(wildcard *.c)
OBJ= $(SRC:.c=.o)
BOARD=

LD_LIBRARY_PATH=$(srctree)/scripts/kconfig/lib

MCONF=./scripts/kconfig/bin/kconfig-mconf
CONF=./scripts/kconfig/bin/kconfig-conf

# Read in config
-include $(srctree)/include/config/auto.conf

#include $(srctree)/arch/$(ARCH)/Makefile

SRCARCH 	:= $(ARCH)

export CC CFLAGS LDFLAGS BOARD SUBDIRS Q MAKEFLAGS SRCARCH ARCH VERSION srctree

SUBDIRS := drivers/i2c/ \
           arch/$(ARCH)/

.PHONY: $(SUBDIRS)

all: $(SUBDIRS) bmc
	@:

$(SUBDIRS):
	@$(MAKE) -w -C $@ $(MAKECMDGOALS) $(MAKEFLAGS)

bmc:
	@echo '   [CC]' $@
	@$(CC) $(shell find . | grep built-in.o) -o bmc

clean: $(SUBDIRS)
	@rm -rf bmc

distclean: clean
	@rm -rf include/config include/generated

.PHONY: menuconfig

menuconfig: _menuconfig config

_menuconfig:

ifneq ($(MCONF),)
	@export LD_LIBRARY_PATH; \
	$(MCONF) Kconfig
endif

.PHONY: config

config:
ifneq ($(CONF),)
	@mkdir -p include/
	@mkdir -p include/config include/generated
	@export LD_LIBRARY_PATH; \
	$(CONF) --silentoldconfig Kconfig
endif

savedefconfig:

ifneq ($(CONF),)
	@export LD_LIBRARY_PATH; \
	$(CONF) --savedefconfig defconfig Kconfig
endif
