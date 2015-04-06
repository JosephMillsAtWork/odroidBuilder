#!/bin/bash
## WARNING this is under heavey development
## Odroid U Series MangoES ARM build

## 3 mk the img file with dd and the partitions
## 4 mk the rootfs stage one two
## 2 mk kernel 
## 1 mk uboot 
## 5 cleanup
## 6 mk compression and m5dsum

. common/extraPackages
. common/htmlHelper
. common/errorChecker
. config/web.config

if [[ $# -eq 0 ]] ; then
    echo "Please pass version number, and codename Please note that only debian works for now"
    echo "example:     ./run 0.1 jessie "
    echo ""
    exit 0
fi

mkdir -p ${basedir}
mkdir -p ${basedir}/bootp
mkdir -p ${basedir}/root

mkdir -p ${basedir}/bootp.tmp
mkdir -p ${basedir}/root.tmp

## fixme later crossCompileCheck
export packages="${odroidCRepo} ${arm} ${base} ${services} ${tools} ${wireless}" 
export architecture=$buildArch
export mirror=$mainMirror
export security=$securityMirror

## setup bootstrap and index html pages
createLogIndex
setupIndex
setupHtmlPages
for i in ${packages};
do
  echo "<a class=\"list-group-item\" href=\"https://packages.debian.org/testing/$i\">$i</a>"   >> $basedir/web/index.html
done
echo "</ul>" >> $basedir/web/index.html




cd ${basedir}



# Build the latest u-boot bootloader, and then use the Hardkernel script to fuse

## export our new path for the eabi compile of u-boot
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH=/home/joseph/Work/sandy/odroidBuilder/toolchains/gcc-linaro-arm-none-eabi-4.8-2014.04_linux/bin:$PATH
export ARCH=arm
export CROSS_COMPILE=arm-none-eabi

## came from html helper
echo "<h3>Compilers PATH</h3>" >> $ubootLogfile
echo $PATH >> $ubootLogfile
echo "<h3>Arch</h3>" >> $ubootLogfile
echo $ARCH >> $ubootLogfile
echo "<h3>CROSS COMPILE</h3>" >> $ubootLogfile
echo $CROSS_COMPILE >> $ubootLogfile
echo "<h3>Arm EABI Specs</h3>" >> $ubootLogfile
echo "<pre>" >> $ubootLogfile
arm-none-eabi-gcc  -v >> $ubootLogfile 2>&1
echo "</pre>" >> $ubootLogfile

# echo "Building UBoot Please Be patient"
echo "<h3>Cloning Uboot from Git</h3>" >> $ubootLogfile
echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $ubootLogfile
git clone https://github.com/hardkernel/u-boot.git -b odroidc-v2011.03 >> $ubootLogfile 2>&1
echo "</textarea>" >> $ubootLogfile

cd ${basedir}/u-boot

echo "<h3>Make odroidc_config</h3>" >> $ubootLogfile
echo "<pre>" >> $ubootLogfile
make odroidc_config >> $ubootLogfile 2>&1 
echo "</pre>" >> $ubootLogfile

echo "<h3>Build config<h3>" >> $ubootLogfile
echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $ubootLogfile
cat  $basedir/u-boot/build/.boards.depend >> $ubootLogfile
echo "</textarea>" >> $ubootLogfile
## Fix me we can get back all the deatials also from .board.config if last command was all good. 

echo "<h3>From make</h3>" >> $ubootLogfile
echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $ubootLogfile
make -j $cnum >> $ubootLogfile 2>&1
echo "</textarea>" >> $ubootLogfile


cd ${basedir}
## Set up the gcc linaro cross compiler fo the linux kernel
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH=/home/joseph/Work/sandy/odroidBuilder/toolchains/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin/:$PATH

## HTMLHELPER KERNEL
echo "<h3>Compilers PATH</h3>" >> $kernelCompileLogfile
echo $PATH >> $kernelCompileLogfile
echo "<h3>Arch</h3>" >> $kernelCompileLogfile
echo $ARCH >> $kernelCompileLogfile
echo "<h3>CROSS COMPILE</h3>" >> $kernelCompileLogfile
echo $CROSS_COMPILE >> $kernelCompileLogfile
echo "<h3>Arm EABI Specs</h3>" >> $kernelCompileLogfile
echo "<pre>" >> $kernelCompileLogfile
arm-linux-gnueabihf-gcc -v >> $kernelCompileLogfile 2>&1
echo "</pre>" >> $kernelCompileLogfile



echo "<h3>Cloning the kernel</h3><hr>" >> $kernelCompileLogfile
echo "<textarea class='form-control' rows='4' cols='50' overview='auto'>" >> $kernelCompileLogfile
git clone --depth 1 https://github.com/hardkernel/linux.git -b odroidc-3.10.y ${basedir}/kernel >> $kernelCompileLogfile 2>&1
echo "</textarea><hr>" >> $kernelCompileLogfile

cd ${basedir}/kernel

echo "<h3>Output of make odroidc_defconfig</h3><hr>" >> $kernelCompileLogfile
echo "<textarea class='form-control' rows='4' cols='50' overview='auto'>" >> $kernelCompileLogfile
make odroidc_defconfig >> $kernelCompileLogfile 2>&1
echo "</textarea>" >> $kernelCompileLogfile

echo "<h3>Output of make uImage</h3><hr>" >> $kernelCompileLogfile
echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $kernelCompileLogfile
make -j $cnum uImage >> $kernelCompileLogfile 2>&1
echo "</textarea>" >> $kernelCompileLogfile

echo "<h3>Output of make Dtbs</h3><hr>" >> $kernelCompileLogfile
echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $kernelCompileLogfile
make -j $cnum dtbs >> $kernelCompileLogfile 2>&1
echo "</textarea>" >> $kernelCompileLogfile

echo "<h3>Output of make moduels</h3><hr>" >> $kernelCompileLogfile
echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $kernelCompileLogfile
make -j $cnum modules >> $kernelCompileLogfile 2>&1
echo "</textarea>" >> $kernelCompileLogfile

echo "<h3>Output of modules_install</h3><hr>" >> $kernelCompileLogfile
echo "<textarea rows='4' cols='50' overview='auto' class='form-control'>" >> $kernelCompileLogfile
make modules_install ARCH=arm INSTALL_MOD_PATH=${basedir}/root.tmp >> $kernelCompileLogfile 2>&1
echo "</textarea>" >> $kernelCompileLogfile

cp arch/arm/boot/uImage ${basedir}/bootp.tmp/
cp arch/arm/boot/dts/meson8b_odroidc.dtb ${basedir}/bootp.tmp/
_VER=`make kernelversion`
cp .config ${basedir}/bootp.tmp/config-$_VER

cd ${basedir}

## HTMLHelper IMAGE
dd if=/dev/zero of=${basedir}/mangoes-$1-$2-odroid-C.img bs=1M count=4000 >> $mkImageMountLog 2>&1

sync
echo "</pre>" >> $mkImageMountLog ## This is the End of the HTMLHelper IMAGE

# Set the partition variables 
## See http://odroid.com/dokuwiki/doku.php?id=en:u3_partition_table#ubuntu_partition_table for details on sectors
parted mangoes-$1-$2-odroid-C.img --script -- mklabel msdos
parted mangoes-$1-$2-odroid-C.img --script -- mkpart primary fat32 3072s 266239s
parted mangoes-$1-$2-odroid-C.img --script -- mkpart primary ext4 266240s 100%


##HTMLHELPER DeBootsttrap
debootstrap --foreign --arch $architecture $2 mangoes-$architecture $mirror  >> $debootstrapLogFile 2>&1
echo "	</textarea>" >> $debootstrapLogFile
##echo "moving qemu-arm-static over to mangoes-$architecture So We can chroot in"
cp /usr/bin/qemu-arm-static mangoes-$architecture/usr/bin/
cat <<EOF>> $debootstrapLogFile
<h3>Stage Two Log</h3>
<hr>
<label for="stageTwo">debootstrap part 2:</label>
<textarea class="form-control" overview="auto" rows="5" id="stageTwo">
EOF

echo "Stage2"

LANG=C chroot mangoes-$architecture /debootstrap/debootstrap --second-stage >> $debootstrapLogFile  2>&1
echo "</textarea>" >> $debootstrapLogFile

echo "<h3>Adding debian to the sources list </h3>" >> $debootstrapLogFile
cat << EOF > mangoes-$architecture/etc/apt/sources.list
deb http://ftp.debian.org/debian $2 main contrib non-free
deb http://security.debian.org/debian-security $2/updates main contrib non-free
EOF

echo "<h3>changing the host name and setting up the networking</h3>" >> $debootstrapLogFile; 

echo "mangoES" > mangoes-$architecture/etc/hostname
cat << EOF > mangoes-$architecture/etc/hosts
127.0.0.1       mangoES    localhost
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF

cat << EOF > mangoes-$architecture/etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

cat << EOF > mangoes-$architecture/etc/resolv.conf
nameserver 8.8.8.8
EOF

export MALLOC_CHECK_=0 # workaround for LP: #520465
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive
mount -t proc proc mangoes-$architecture/proc
mount -o bind /dev/ mangoes-$architecture/dev/
mount -o bind /dev/pts mangoes-$architecture/dev/pts
cat << EOF > mangoes-$architecture/debconf.set
console-common console-data/keymap/policy select Select keymap from full list
console-common console-data/keymap/full select us
EOF

##HTMLHelper Stage3 
cd $basedir
cp ../common/customizeBuild mangoes-$architecture/third-stage
## Run the 3rd stage,
chmod +x mangoes-$architecture/third-stage
echo "Stage3"
LANG=C chroot mangoes-$architecture /third-stage >> $stage3Logfile 2>&1
echo "</textarea>" >> $stage3Logfile


cat <<EOF>> $stage3Logfile
<h3>Adding C1 odroid Repo</h3>
<pre>
EOF
cat << EOF > mangoes-$architecture/addOdroidRepo
#!/bin/bash
echo "deb http://deb.odroid.in/c1/ trusty main" >> /etc/apt/sources.list
echo "deb http://deb.odroid.in/ trusty main" >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AB19BAC9
rm -f addOdroidRepo
EOF
chmod +x mangoes-$architecture/addOdroidRepo
LANG=C chroot mangoes-$architecture /addOdroidRepo >> $stage3Logfile 2>&1 
echo "</pre>" >> $stage3Logfile

cat <<EOF>> $stage3Logfile
<h3>Stage Three Clean Up</h3>
<pre>
EOF
cat << EOF > mangoes-$architecture/cleanup
#!/bin/bash
rm -rf /root/.bash_history
apt-get update
apt-get clean
rm -f /0
rm -f /hs_err*
rm -f cleanup
rm -f /usr/bin/qemu*
echo "all cleaned up"
EOF
chmod +x mangoes-$architecture/cleanup
LANG=C chroot mangoes-$architecture /cleanup >> $stage3Logfile 2>&1 
echo "</pre>" >> $stage3Logfile

## FIXME run checks /proc/sys/fs/binfmt_misc WHY YOU NO MOUNTED ? 
#umount mangoes-$architecture/proc/sys/fs/binfmt_misc
umount mangoes-$architecture/dev/pts
umount mangoes-$architecture/dev/
umount mangoes-$architecture/proc


# Put the patrtitions on a loop device so we can alter them 
modprobe loop
loopdevice=$(losetup -f)
losetup $loopdevice ${basedir}/mangoes-$1-$2-odroid-C.img
partprobe $loopdevice
bootp=${loopdevice}p1
rootp=${loopdevice}p2

## this is for debusing to make sure that we are getting the right partitions
echo "<h3>Partitions that where mounted<h3>" >> $mkImageMountLog 
echo "<div class='row'> <div class='col-md-6'>" >> $mkImageMountLog
echo "<h3>ROOT FS </h3>" >> $mkImageMountLog 
echo  $rootp >> $mkImageMountLog 
echo "</div> <div class='col-md-6'><h3> BOOT FS </h3>" >> $mkImageMountLog 
echo  $bootp >> $mkImageMountLog 
echo "</div></div>" >> $mkImageMountLog
# Create file systems on the looped partitions

echo "<h3>mkfs.vfat and mkfs.ext4</h3>" >> $mkImageMountLog
echo "<pre>" >> $mkImageMountLog

mkfs.vfat -F 32 -n boot $bootp >> $mkImageMountLog 2>&1
fatuuid=$(blkid -s UUID -o value $bootp);

mkfs.ext4 -F -L MangoES $rootp >> $mkImageMountLog 2>&1
ext4uuid=$(blkid -s UUID -o value $rootp)

echo "</pre>" >> $mkImageMountLog

mount $bootp ${basedir}/bootp
mount $rootp ${basedir}/root

echo "stage5"
cp ${basedir}/bootp.tmp/uImage ${basedir}/bootp/
cp ${basedir}/bootp.tmp/meson8b_odroidc.dtb ${basedir}/bootp/
cp ../boards/odroid/C/files/boot.ini ${basedir}/bootp/boot.ini
chmod +x ${basedir}/bootp/boot.ini
sed -i "s/\${BOOT_UUID}/$fatuuid/g"  ${basedir}/bootp/boot.ini
sed -i "s/\${ROOT_UUID}/$ext4uuid/g" ${basedir}/bootp/boot.ini


## Use rsync to copy the root file system to the 2nd partition
# echo "Rsyncing $rootp aka Root File system into the image file" 
echo "<label>Rsyncing $rootp aka Root File system into the image file</label>" >> $mkImageMountLog
rsync -HPavz --exclude '/boot/' --exclude '/tmp/' --exclude '/media/' --exclude '/root/' -q ${basedir}/mangoes-$architecture/ ${basedir}/root/
mkdir -p ${basedir}/root/boot
cp ${basedir}/bootp.tmp/config-$_VER  ${basedir}/root/boot/config-$_VER
mkdir -p ${basedir}/root/media
mkdir -p ${basedir}/root/root
mkdir -p ${basedir}/root/tmp


## the kernel mods
cp -rp ${basedir}/root.tmp/lib  ${basedir}/root/

cp /usr/bin/qemu-arm-static ${basedir}/root/usr/bin/
cat << EOF > ${basedir}/root/uinitram
cd /boot
update-initramfs -c -t -k $_VER
EOF
chmod +x ${basedir}/root/uinitram
LANG=C chroot ${basedir}/root /uinitram >> $kernelCompileLogfile 2>&1
rm  ${basedir}/root/usr/bin/qemu-arm-static

## Make the uInitrd
echo "<h3>uInitrd</h3><hr><pre>" >> $mkImageMountLog
mkimage -A arm -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d ${basedir}/root/boot/initrd.img-$_VER ${basedir}/root/boot/uInitrd-$_VER >> $mkImageMountLog 2>&1 
cp ${basedir}/root/boot/uInitrd-$_VER ${basedir}/bootp/uInitrd
echo "</pre>" >> $mkImageMountLog




touch ${basedir}/root/etc/fstab
echo "# Odroid fstab" > ${basedir}/root/etc/fstab
echo "" >> ${basedir}/root/etc/fstab
echo "UUID=${ext4uuid}  /  ext4  errors=remount-ro,noatime,nodiratime  0 1" >> ${basedir}/root/etc/fstab
echo "UUID=${fatuuid}  /media/boot  vfat  defaults,rw,owner,flush,umask=000  0 0" >> ${basedir}/root/etc/fstab
echo "tmpfs /tmp  tmpfs nodev,nosuid,mode=1777  0 0" >> ${basedir}/root/etc/fstab


## FILES AREA FROM BOARD DIR HERE 
cd ${basedir}

touch ${basedir}/root/etc/securetty
# touch ${basedir}/root/boot/boot.txt
touch ${basedir}/root/etc/X11/xorg.conf
touch ${basedir}/root/etc/smsc95xx_mac_addr

cat ../common/securetty > ${basedir}/root/etc/securetty
# cat ../boards/odroid/C/files/boot.txt > ${basedir}/root/boot/boot.txt
cat ../boards/odroid/C/files/xorg.conf > ${basedir}/root/etc/X11/xorg.conf
cat ../boards/odroid/C/files/smsc95xx_mac_addr > ${basedir}/root/etc/smsc95xx_mac_addr

## FIX ME GET THIS ELSEWHERE 
## Add new sources list

EOF



# echo "<h3>Boot Scr</h3><hr></pre>" >> $mkImageMountLog
# ## make the boot.src 
# mkimage -A arm -T script -C none -d ${basedir}/root/boot/boot.txt ${basedir}/root/boot/boot.scr  >> $mkImageMountLog 2>&1
# echo "</pre>" >> $mkImageMountLog







cd ${basedir}
umount $bootp
umount $rootp




# echo -e "\x55\xaa" | dd bs=1 count=2 seek=510 of=${basedir}/mangoes-$1-$2-odroid-C.img conv=notrunc >> $mkImageMountLog 2>&1
# dd if=${basedir}/u-boot/sd_fuse/bl1.bin.hardkernel of=${basedir}/mangoes-$1-$2-odroid-C.img bs=1 count=442 conv=notrunc >> $mkImageMountLog 2>&1
# dd if=${basedir}/u-boot/sd_fuse/bl1.bin.hardkernel of=${basedir}/mangoes-$1-$2-odroid-C.img bs=512 skip=1 seek=1 conv=notrunc >> $mkImageMountLog 2>&1
# dd if=${basedir}/u-boot/sd_fuse/u-boot.bin of=${basedir}/mangoes-$1-$2-odroid-C.img bs=512 seek=64 conv=notrunc >> $mkImageMountLog 2>&1


losetup -d $loopdevice








# echo " Clean up all the temporary build stuff and remove the directories."
# Comment this out to keep things around if you need to debug
#rm -rf ${basedir}/kernel ${basedir}/bootp ${basedir}/root ${basedir}/mangoes-$architecture 
##${basedir}/patches
##${basedir}/u-boot

## FIXME Cut up the image, 
#cd ${basedir}
#num=$(fdisk -l mangoes-$1-$2-odroid-C.img |awk '/img2/ {print $3}')
#truncate --size=$[($num+1)*512] mangoes-$1-$2-odroid-C.img
 
 
 
#  
# echo "Stage8"
# 
## HTMLHELPER COMPRESSION
# sha1sum mangoes-$1-$2-odroid-C.img > ${basedir}/mangoes-$1-$2-odroid-C.img.sha1sum >> $compressLogFile 2>&1
# echo "</pre>" >> $compressLogFile;
# 
# machineType=$(uname -m)
# if [ ${machineType} == 'x86_64' ]; 
# then
#   echo "<h3>Compressing mangoes-$1-$2-odroid-C.img</h3>" >> $compressLogFile;
#     pixz ${basedir}/mangoes-$1-$2-odroid-C.img ${basedir}/mangoes-$1-$2-odroid-C.img.xz >> $compressLogFile 2>&1
#   
# 
#   echo "<h3>Generating sha1sum for mangoes-$1-$2-odroid-C.img</h3><pre>" >> $compressLogFile;
#     sha1sum mangoes-$1-$2-odroid-C.img.xz > ${basedir}/mangoes-$1-$2-odroid-C.img.xz.sha1sum >> $compressLogFile 2>&1
#   echo "</pre>" >> $compressLogFile  
# 
#   
#   
#   cat $basedir/web/footer.html >> $compressLogFile
#   
#   
#     echo "Moving mangoes-$1-$2-odroid-C.img to /home/joseph/Work/MangoES/U3/mangoes-daily-$2-odroid-C.img"
#     mkdir -p /home/joseph/Work/MangoES/U3/
#     mv ${basedir}mangoes-$1-$2-odroid-C.img /home/joseph/Work/MangoES/U3/mangoes-daily-$2-odroid-C.img
#   
#   
#   
#   
#   else 
#   echo "Please Don't pixz on non 64bit, there isn't enough memory to compress the images."
#   cat $basedir/web/footer.html >> $compressLogFile
#   fi  

addFooter;
tidyUp;

##Comming soon  Upload to the server.
##    $scpCMD $basedir/web
