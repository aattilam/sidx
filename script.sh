#!/bin/bash
lb config \
--distribution testing \
--debian-installer-gui true \
--debian-installer-distribution testing \
--debootstrap-options "--variant=minbase" \
--architecture amd64 \
--archive-areas "main contrib non-free non-free-firmware" 
