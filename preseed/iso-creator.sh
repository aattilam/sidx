#!/bin/bash

udevil mount og-debian.iso
wait
cp -rT /media/og-debian.iso isofiles/
wait

chmod +w -R isofiles/install.amd/
gunzip isofiles/install.amd/initrd.gz
echo preseed.cfg | cpio -H newc -o -A -F isofiles/install.amd/initrd
gzip isofiles/install.amd/initrd
chmod -w -R isofiles/install.amd/

cd isofiles
chmod +w md5sum.txt
find -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt
chmod -w md5sum.txt
cd ..

genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat \
            -no-emul-boot -boot-load-size 4 -boot-info-table \
            -o preseed-sidx.iso isofiles

rm -r isofiles/
udevil umount og-debian.iso
