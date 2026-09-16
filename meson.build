# ==============================================================================
# ext4 module — Meson build system
# ==============================================================================
#
#   meson setup build-meson --cross-file cross/i686-cact-clang.ini \
#       -Dkern_root=../CactKernel-x86_32 -Dlocal_repo=../LocalRepoCactOS-x86_32
#   ninja -C build-meson          # build-meson/ext4.cctk
#   ninja -C build-meson stage    # copy into <local_repo>/lib
#
# Several translation units, then `ld -r` into a single relocatable object
# (ET_REL), which is what the kernel's module loader maps and relocates.
# ==============================================================================

project('ext4-mod', 'c',
  meson_version: '>=1.0.0',
  default_options: [
    'c_std=gnu17',
    'warning_level=1',        # -Wall, as in the Makefile
    'buildtype=plain',
  ])

fs = import('fs')
bash = find_program('bash')
cc = meson.get_compiler('c')
ld = find_program('ld')

src_root = meson.project_source_root()

# Path options are relative to this repo's root unless absolute.
_kern = get_option('kern_root')
kern_root = _kern.startswith('/') ? _kern : src_root / _kern
_local = get_option('local_repo')
local_repo = _local.startswith('/') ? _local : src_root / _local
install_dir = local_repo / 'lib'

# Kernel headers this module compiles against.
mod_includes = [
  kern_root / 'Cact/kernel/core',
  kern_root / 'Cact/kernel/memory',
  kern_root / 'Cact/kernel/cpudev',
  kern_root / 'Cact/drivers/pci',
  kern_root / 'Cact/drivers/block/blkdev',
  kern_root / 'Cact/drivers/block/pagecache',
  kern_root / 'Cact/fs/vfs',
]

mod_c_args = [
  '-ffreestanding',
  '-fno-pie',
  '-fno-stack-protector',
  '-nostdlib',
  # Ring 0: the kernel has not enabled SSE for itself, so clang must not lower
  # struct copies to SSE2 (the same trap the kernel build hits).
  '-mno-mmx',
  '-mno-sse',
  '-mno-sse2',
  '-O2',
]
foreach d : mod_includes
  mod_c_args += '-I' + d
endforeach
mod_c_args += '-I' + src_root

# Same order as the Makefile's EX4_SRCS.
ext4_sources = [
  'ext4_blk.c',
  'ext4_jbd.c',
  'ext4_alloc.c',
  'ext4_extent.c',
  'ext4_dir.c',
  'ext4_vfs.c',
  'ext4_mod.c',
]

ext4_objs = []
foreach s : ext4_sources
  ext4_objs += custom_target('obj-' + s.underscorify(),
    input: s,
    output: s + '.o',
    command: cc.cmd_array() + ['-m32'] + mod_c_args +
             ['-MD', '-MF', '@DEPFILE@', '-c', '@INPUT@', '-o', '@OUTPUT@'],
    depfile: s + '.o.d')
endforeach

ext4_cctk = custom_target('ext4.cctk',
  input: ext4_objs,
  output: 'ext4.cctk',
  command: [ld, '-m', 'elf_i386', '-r', '-o', '@OUTPUT@'] + ext4_objs,
  build_by_default: true)

# Meson reserves the name "install" for itself, hence "stage".
run_target('stage',
  command: [bash, '-c', 'set -e; mkdir -p "$1"; cp -f "$2" "$1/ext4.cctk"',
            'bash', install_dir, ext4_cctk])
