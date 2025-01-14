# Building Dogebox

## SD and SD installer images

Start by building a disk image containing the root filesystem (covered in the README At the root of this repository). Assuming you are in an environment containing nix-shell, from the root of this repository run

```
nix-shell
make nanopc-T6
```

The last line of output should tell you where the resulting image is located (/nix/store/..../...). Copy it into the build tree (or somewhere that has write access) and take note of it's location.

The SD images are built with a fork of FriendlyElec's sd-fuse_rk3588 for now. They need to be run on a debian-based x86_64 machine (eg Ubuntu should work). The following steps will be automated or replaced soon.

### SD

Clone sd-fuse and create a directory for the components

```
git clone https://github.com/dogeorg/sd-fuse_rk3588 https://github.com/dogeorg/sd-fuse_rk3588.git
cd sd-fuse_rk3588
mkdir nixos-arm64
```

sd-fuse wants an android sparse image and we have a raw full-disk image. The following mount command mounts the partition inside the full disk image and build-rootfs-img.sh builds an android sparse image from the mounted directory and puts the result in nixos-arm64/rootfs.img

If /mnt is in use, use another location for the temporary mount.

```
mount -o loop,offset=$((2048 * 512)) <location of the image created in the first step> /mnt
./build-rootfs-img.sh /mnt nixos-arm64
umount /mnt
```

This should give you a 'rootfs.img' and a 'parameter.txt' in the nixos-arm64 output directory.

Clone the bootloader (u-boot)'s repository and build for the nanopc-t6.
If aarch64 cross compiling is not set up, the build script shoul fail with instructions containing what it's looking for.

```
cd out
git clone https://github.com/dogeorg/uboot-rockchip.git uboot-rk3588
cd uboot-rk3588
git checkout nanopi6-v2017.09
cd ../../
./build-uboot.sh nixos-arm64 nanopc-t6
```

This should give you a 'uboot.img' in the nixos-arm64 output directory.

Copy the first stage bootloader from the prebuilt directory.
(Building this from source isn't covered here yet, the tooling is in https://github.com/friendlyarm/rkbin)

```
cp prebuilt/idbloader.img nixos-arm64
```

Run the image builing script

```
./mk-sd-image.sh nixos-arm64
```

This will output an image to out/<rk3588-sd-nixos-arm64-YYYYMMDD.img>

u-boot's 'distro boot' expects to find an active partition, so we'll need to set that flag on the rootfs partition.

```
fdisk <image>
x
A
8
r
w
```

## Container/VM images

Quick notes on building a container or VM image from a configuration.nix file:

- Make sure the configuration.nix doesn't mention a bootloader, an appropriate one is included automatically and one defined here can conflict.

- Install `nixos-generators`, if you have the nix package manager or are running NixOS you can just run 'nix-shell -p nixos-generators'

- Build the desired image with `nixos-generate -c configuration.nix -f $format`

Tested image formats include: `docker`, `install-iso`, `iso`, `lxc`, `lxc-metadata`, `proxmox-lxc`, `qcow`, `vmware`

- The build output should tell you the name and location of the built image.

### 'docker' for docker/podman

Use `docker import` or 'podman import' to generate a container image. You will need to manually specify a run CMD.

### 'install-iso / iso' for optical media images

Generates a bootable iso, `install-iso` will give you an installer, `iso` will be a live CD.

### 'lxc / lxc-metadata, proxmox-lxc' for linux containers

Use `lxc` and `lxc-metadata` for a manual container, or load the file generated by `proxmox-lxc` as a CT template to generate a container in proxmox.

### 'qcow' for qemu qcow2

Can be used as a disk image for qemu.

### 'vmware' for VMWare and VirtualBox

Generates a VMDK file that can be used by VMware or VirtualBox VMs directly

If you'd prefer a VDI, you can convert with `VBoxManage clonehd --format VDI <from>.vmdk <to>.vdi`

Generating a VDI out of the box with `-f virtualbox` doesn't appear to be working currently with the default config.
