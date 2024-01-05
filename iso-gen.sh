#!/bin/bash
lb config \
--distribution bookworm \
--debian-installer netinst \
--debian-installer-distribution bookworm \
--debian-installer-gui false \
--archive-areas "main contrib non-free non-free-firmware" \
--debootstrap-options "--variant=buildd" \
--initramfs none \
--system normal
