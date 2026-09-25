# 🌵 EXT4-for-Cact

<p align="center">
  <img src="https://img.shields.io/badge/version-2.0.0-green.svg?style=for-the-badge" alt="Version: 2.0.0">
  <img src="https://img.shields.io/badge/license-GPLv3-blue.svg?style=for-the-badge" alt="License: GPLv3">
  <img src="https://img.shields.io/badge/arch-i686-red.svg?style=for-the-badge" alt="Arch: i686">
  <img src="https://img.shields.io/badge/format-cctk-green.svg?style=for-the-badge" alt="Output: ext4.cctk">
  <img src="https://img.shields.io/badge/type-filesystem-blue.svg?style=for-the-badge" alt="Filesystem">
</p>

<p align="center">
  Out-of-tree <strong>ext4</strong> filesystem → <strong><code>ext4.cctk</code></strong> for the Cact filesystem-module loader (<code>fs_mod</code>).<br>
  Loaded by the kernel at boot before <code>mntfs_init</code>; mounts the root ext4 through <code>fs_mount(dev)</code>.
</p>

---

## 🔨 Building

**Recommended — full workspace**

```sh
ninja -C CactOS-x86_32/build-meson iso
```

**Standalone**

```sh
meson setup build-meson --cross-file cross/i686-cact-clang.ini
ninja -C build-meson          # → build-meson/ext4.cctk
ninja -C build-meson stage    # copy into ../LocalRepoCactOS-x86_32/lib/
ninja -C build-meson clean
```

Override paths if needed: `meson configure build-meson -Dkern_root=/custom/path -Dlocal_repo=/custom/path`.

---

## 📦 What it produces

| Output | Where it goes | Purpose |
|--------|---------------|---------|
| **`ext4.cctk`** | derived here | Relocatable ELF (ET_REL) loaded by the kernel's `fs_mod` loader |
| installed **`lib/ext4.cctk`** | `$(LOCAL_REPO)/lib/` | Packed into **cctkfs.img** and loaded at boot |

---

## 🔌 Module interface

The kernel calls two exported symbols:

```c
vfs_node_t *fs_mount(struct blkdev *dev);   // mount device `dev`, return root node or NULL
int         fs_unmount(void);          // teardown (currently a no-op)
```

Undefined kernel symbols (`kmalloc`, `blkdev_read_sector`, `pc_get_page`, …) are
resolved at load time via `ksym_resolve()`.
