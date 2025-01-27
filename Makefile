VM_NAME = dogebox-$(shell date +%s)

nanopc-T6:
	@echo "Generating nanopc-T6 image..."
	@nix build .#t6 -L --print-out-paths

pve-x86_64:
	@echo "Generating Proxmox LXC..."
	@nixos-generate -c nix/pve-builder.nix -f proxmox-lxc

qemu:
	@echo "Generating QEMU qcow2..."
	@nixos-generate -c nix/qemu-builder.nix -f qcow

raw:
	@echo "Generating raw image..."
	@nixos-generate -c nix/default-builder.nix -f raw

virtualbox-x86_64:
	@echo "Generating VirtualBox OVA..."
	@nix build .#vbox-x86_64 -L --print-out-paths

virtualbox-x86_64-launch: virtualbox
	@echo "Importing and launching the VirtualBox VM..."
	# Capture the generated OVA path from the nixos-generate output
	@nix build .#vbox-x86_64 -L --print-out-paths

	OVA_FILE=$$(nixos-generate -c nix/vbox-builder.nix -f virtualbox | grep -o '.*\.ova$$'); \
	BRIDGE_ADAPTER=$$(VBoxManage list bridgedifs | grep '^Name:' | head -n1 | awk '{print $$2}'); \
	VBoxManage import $$OVA_FILE --vsys 0 --vmname "$(VM_NAME)" && \
	VBoxManage modifyvm "$(VM_NAME)" --nic1 bridged --bridgeadapter1 $$BRIDGE_ADAPTER && \
	VBoxManage startvm "$(VM_NAME)"

vmware:
	@echo "Generating VMWare VMDK..."
	@nixos-generate -c nix/vmware-builder.nix -f vmware

.PHONY: pve qemu raw virtualbox virtualbox-launch vmware
