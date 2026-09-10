# 🌵 EXT4-for-Cact

<p align="center">
  <img src="https://img.shields.io/badge/version-2.0.0-green.svg?style=for-the-badge" alt="Version: 2.0.0">
  <img src="https://img.shields.io/badge/license-GPLv3-blue.svg?style=for-the-badge" alt="License: GPLv3">
  <img src="https://img.shields.io/badge/arch-i686-red.svg?style=for-the-badge" alt="Arch: i686">
  <img src="https://img.shields.io/badge/format-cctk-green.svg?style=for-the-badge" alt="Output: ext4.cctk">
  <img src="https://img.shields.io/badge/type-filesystem-blue.svg?style=for-the-badge" alt="Filesystem">
</p>

<p align="center">
  <strong>English.</strong> Out-of-tree <strong>ext4</strong> filesystem → <strong><code>ext4.cctk</code></strong> for the Cact filesystem-module loader (<code>fs_mod</code>).<br>
  <strong>Русский.</strong> Вынесенная из ядра файловая система <strong>ext4</strong> → <strong><code>ext4.cctk</code></strong>.<br>
  Загружается ядром при старте до <code>mntfs_init</code> и монтирует корневую ext4 через <code>fs_mount(dev)</code>.
</p>

---

## 🔨 Building

**Recommended — full workspace**

```sh
make -C CactOS-x86_32 iso
```

**Standalone**

```sh
make install   # auto-detects ../CactKernel-x86_32 and ../LocalRepoCactOS
make clean
```

Override paths if needed: `make KERN_ROOT=/custom/path LOCAL_REPO=/custom/path install`.

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
vfs_node_t *fs_mount(uint32_t dev);   // mount device `dev`, return root node or NULL
int         fs_unmount(void);          // teardown (currently a no-op)
```

Undefined kernel symbols (`kmalloc`, `blkdev_read_sector`, `pc_get_page`, …) are
resolved at load time via `ksym_resolve()`.
