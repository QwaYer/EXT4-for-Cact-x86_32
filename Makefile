KERN_ROOT ?= $(abspath ../CactKernel-x86_32)
LOCAL_REPO ?= $(abspath ../LocalRepoCactOS-x86_32)

_ACTIVE := $(filter-out clean,$(or $(MAKECMDGOALS),all))
ifneq ($(_ACTIVE),)
ifndef KERN_ROOT
$(error KERN_ROOT is required — path to kernel sources with Cact/ headers)
endif
ifndef LOCAL_REPO
$(error LOCAL_REPO is required — directory whose lib/ receives *.cctk)
endif
endif

INSTALL_DIR := $(LOCAL_REPO)/lib

MOD_CFLAGS := -m32 -ffreestanding -fno-pie -fno-stack-protector -nostdlib \
	-I$(KERN_ROOT)/Cact/kernel/core \
	-I$(KERN_ROOT)/Cact/kernel/memory \
	-I$(KERN_ROOT)/Cact/kernel/cpudev \
	-I$(KERN_ROOT)/Cact/drivers/pci \
	-I$(KERN_ROOT)/Cact/drivers/block/blkdev \
	-I$(KERN_ROOT)/Cact/drivers/block/pagecache \
	-I$(KERN_ROOT)/Cact/fs/vfs \
	-I. \
	-Wall -O2

EX4_SRCS := ext4_blk.c ext4_jbd.c ext4_alloc.c ext4_extent.c ext4_dir.c \
	ext4_vfs.c ext4_mod.c
EX4_OBJS := $(EX4_SRCS:.c=.o)

.PHONY: all install clean
all: ext4.cctk

ext4.cctk: $(EX4_OBJS)
	ld -m elf_i386 -r -o $@ $(EX4_OBJS)

%.o: %.c ext4.h ext4_internal.h
	gcc $(MOD_CFLAGS) -c $< -o $@

install: ext4.cctk
	@mkdir -p $(INSTALL_DIR)
	cp -f ext4.cctk $(INSTALL_DIR)/ext4.cctk
	@echo "installed: $(INSTALL_DIR)/ext4.cctk"

clean:
	rm -f $(EX4_OBJS) ext4.cctk
