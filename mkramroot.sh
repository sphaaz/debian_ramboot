#!/bin/sh

echo "----------------------------------------------------------------------"
echo "!!! RAMROOT GENERATION SCRIPT !!!"
echo "----------------------------------------------------------------------"
echo "example: mkramroot.sh source_initrd dest_initrd workdir"
echo "example: mkramroot.sh /boot/initrd.img-4.9.0-4-amd64 /boot/initrd.img-4.9.0-4-amd64-RAMROOT /tmp/"
echo "----------------------------------------------------------------------"

#variables
SOURCE.INITRD=$1
DEST.INITRD=$2
WORK.DIR=$3

echo "----------------------------------------------------------------------"

if [ -z $1 ]
  then echo "!!! SOURCE_INTRD missing !!!"
  exit 1
fi

if [ -z $2 ]
  then echo "!!! DEST_INTRD missing !!!"
  exit 1
fi

if [ -z $3 ]
  then echo "!!! WORK_DIR missing !!!"
  exit 1
fi

echo "----------------------------------------------------------------------"

#installing dependencies - packages needed for ramroot images creation
apt update
apt install squashfs-tools ntfs-3g 

#modifyig mkinitramfs generation configs

#saving old modeules to modules.ORIGINAL
mv /etc/initramfs-tools/modules /etc/initramfs-tools/modules.ORIGINAL

#Adding required modules for reading from usb and for making overlayfs
echo "loop" > /etc/initramfs-tools/modules
echo "squashfs" >> /etc/initramfs-tools/modules
echo "fuse" >> /etc/initramfs-tools/modules
echo "overlay" >> /etc/initramfs-tools/modules
echo "vfat" >> /etc/initramfs-tools/modules
echo "nfat" >> /etc/initramfs-tools/modules
echo "nls_cp437" >> /etc/initramfs-tools/modules
echo "nls_ascii" >> /etc/initramfs-tools/modules
echo "nls_iso8859_1" >> /etc/initramfs-tools/modules

#generating ramroot initrd boot script
echo '#!/bin/sh' > /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'PREREQ="ramroot_initrd"' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'prereqs()' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo '{' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'echo "$PREREQ"' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo '}' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'case $1 in' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'prereqs)' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'prereqs' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'exit 0' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo ';;' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'esac' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo '. /scripts/functions' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'mkdir /root.ro' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'mount -t squashfs -o loop /debian9_ramroot.sqsh /root.ro' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'mkdir /root.rw' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'mount -t tmpfs -o size=75% tmpfs /root.rw' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'mkdir /root.rw/upper' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'mkdir /root.rw/work' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'mount -t overlay -o lowerdir=/root.ro,upperdir=/root.rw/upper,workdir=/root.rw/work none ${rootmnt}' >> /etc/initramfs-tools/scripts/local-bottom/ramroot
echo 'exit 0' >> /etc/initramfs-tools/scripts/local-bottom/ramroot

#making the script executable
chmod +x /etc/initramfs-tools/scripts/local-bottom/ramroot

#generate ramroot_initrd init script
echo '#!/bin/sh' > /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'PREREQ=""' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'prereqs()' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo '{' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'echo "$PREREQ"' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo '}' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'case $1 in' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'prereqs)' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'prereqs' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'exit 0' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo ';;' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'esac' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo '. /scripts/functions' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'mkdir /root_dev' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'mkdir /root_cpio' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'if [ -z $root_devfs ]' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'then' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'exit 0' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'else' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'if [ -z $root_dev ]' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'then' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'exit 0' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'else' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'mount -t $root_devfs $root_dev /root_dev' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'fi' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'fi' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'cd /root_cpio' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'if [ -z $root_cpio ]' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'then' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'exit 0' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'else' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'gzip -cd /root_dev/$root_cpio | cpio -i' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'mv /root_cpio/debian9_ramroot.sqsh /' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'fi' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'umount /root_dev' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'rm -r /root_cpio' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd
echo 'exit 0' >> /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd

#making the script executable
chmod +x /etc/initramfs-tools/scripts/local-bottom/ramroot_initrd

#GENERATING RAMINITRD IMAGE
#this image loads minimal initrd into ram and searches initrd with squashfs
#root on specified device, specify root_dev=/disk/with/initrd_packed_with 
#squashfs_root root_devfs=filesystem_type root_cpio=/initrd_packed_with_sqsh 
#root.

mkinitramfs -o $2-RAMINITRD

#cleaning apt-caches
apt-get clean
#cleaning if there is leftovers in workdir
rm -r $3/initrd-src

#unpacking source initrd archive
mkdir $3/initrd-src
cd  $3/initrd-src
gzip -cd $1 | cpio -i

#removing sqsh archived old root filesystem in case we 
#selected initrd with sqsh root
rm $3/initrd-src/debian9_ramroot.sqsh

#here we pause if any modifications or checks are needed 
#in WORK_DIR
read -p "Modify andything in workdir and Press any key to CONTINUE..."

#generating exclusion list for root sqsh creation
echo "boot/*RAM*" > $3/initrd-src/exclude.sqsh
echo "tmp/*" >> $3/initrd-src/exclude.sqsh
echo "dev/*" >> $3/initrd-src/exclude.sqsh
echo "proc/*" >> $3/initrd-src/exclude.sqsh
echo "sys/*" >> $3/initrd-src/exclude.sqsh
echo "mnt/*" >> $3/initrd-src/exclude.sqsh
echo "media/*" >> $3/initrd-src/exclude.sqsh

#creating squashed rootfs
mksquashfs / $3/initrd-src/debian9_ramroot.sqsh -regex -wildcards -ef $3/initrd-src/exclude.sqsh

#generating new initrd from contents of $WORK_DIR
cd $3/initrd-src
find . | cpio --dereference -o -H newc | gzip > $2

#cleaning up $WORKDIR
rm -r $3/initrd-src
ls -l $2
