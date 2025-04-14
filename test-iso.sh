#!/bin/bash

# Remove previous VM if it exists
virsh destroy nixos-test 2>/dev/null
virsh undefine nixos-test --remove-all-storage 2>/dev/null

# Find iso
cd ./result
iso=$( find ./*iso | head -1 )
cd ..

# Launch new VM
virt-install \
  --name nixos-test \
  --memory 2048 \
  --vcpus 2 \
  --disk size=20 \
  --cdrom "./result/$iso" \
  --os-variant nixos-unknown \
  --virt-type kvm \
  --graphics spice \
  --autoconsole graphical

# virt-manager --connect qemu:///session
# virt-viewer --connect qemu:///session nixos-test

# Remove previous VM if it exists
virsh destroy nixos-test 2>/dev/null
virsh undefine nixos-test --remove-all-storage 2>/dev/null
