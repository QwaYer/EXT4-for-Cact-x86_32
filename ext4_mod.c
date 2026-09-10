/*
 * Loadable ext4 filesystem for Cact kmod.
 *
 * Compiled as a relocatable ELF (ET_REL) and shipped as `ext4.cctk` inside
 * cctkfs.img. The kernel filesystem-module loader (fs_mod) loads this image,
 * relocates it, and resolves the exported `fs_mount` / `fs_unmount` symbols.
 * mntfs then uses `fs_mount(dev)` to mount an ext4 volume that lives on a
 * whole disk or on a single partition (dev carries the LBA offset).
 */

#include "ext4_internal.h"
#include "ext4.h"
#include "blkdev.h"

/* Exported generic filesystem-module entry: mount block device `dev`. */
vfs_node_t *fs_mount(struct blkdev *dev) {
    return ext4_mount_disk(dev);
}

/* Exported generic filesystem-module entry: teardown. */
int fs_unmount(void) {
    return 0;
}
