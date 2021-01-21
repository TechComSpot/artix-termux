#!/data/data/com.termux/files/usr/bin/bash
pkg update -y
pkg update
pkg install pulseaudio wget openssl proot tar -y
folder=artix-fs
if [ -d "$folder" ]; then
	first=1
	echo "skipping downloading"
fi
tarball="artix-rootfs.tar.xz"
if [ "$first" != 1 ];then
	if [ ! -f $tarball ]; then
		echo "Download Rootfs, this may take a while base on your internet speed."
		case `dpkg --print-architecture` in
		aarch64)
			archurl="aarch64" ;;
		*)
			echo "not support architecture"; exit 1 ;;
		esac
		wget "https://armtix.artixlinux.org/images/armtix-openrc-20210101.tar.xz" -O $tarball
	fi
	cur=`pwd`
	mkdir -p "$folder"
	cd "$folder"
	echo "Decompressing Rootfs, please be patient."
	proot --link2symlink tar -xf ${cur}/${tarball}||:
	cd "$cur"
fi
mkdir -p artix-binds
bin=start-artix.sh
echo "writing launch script"
cat > $bin <<- EOM
#!/bin/bash
nohup watch pulseaudio --start > /dev/zero 2>&1&
cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --kill-on-exit"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A artix-binds)" ]; then
    for f in artix-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b ./proc/stat:/proc/stat"
command+=" -b ./proc/version:/proc/version"
command+=" -b artix-fs/root:/dev/shm"
## uncomment the following line to have access to the home directory of termux
## uncomment the following line to mount /sdcard directly to / 
command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" PULSE_SERVER=127.0.0.1"
command+=" LANG=en_US.UTF-8"
command+=" /bin/su"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM

echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
echo "removing image for some space"
rm $tarball
echo 'nameserver 8.8.8.8'>./artix-fs/etc/resolv.conf
touch ./artix-fs/root/.bashrc
cat > ./artix-fs/root/.bashrc << EOF
#!/bin/bash
echo 'remove trash'
pacman -R linux-aarch64-headers linux-api-headers linux-aarch64 --noconfirm
echo 'updateing artix'
pacman -Syu --noconfirm
echo 'setting local'
sed -i 's|#en_US.UTF-8 UTF-8|en_US.UTF-8 UTF-8|g'  /etc/locale.gen
locale-gen
rm .bashrc
echo "You can now launch Artix Linux with the ./${bin} script"
exit
EOF
echo 'makeing fakeing /proc'
mkdir ./proc
cat  > ./proc/version << EOF
Linux version 5.9.12-artix1-1 (linux@artixlinux) (gcc (GCC) 10.2.0, GNU ld (GNU Binutils) 2.35.1) #1 SMP PREEMPT Wed, 02 Dec 2020 22:03:38 +0000
EOF
cat > ./proc/stat << EOC
cpu  84663 6 28703 449941 118351 2015 1255 0 0 0
cpu0 21192 0 7042 108949 33618 263 189 0 0 0
cpu1 20796 2 7067 108074 34481 361 543 0 0 0
cpu2 21218 1 7525 123676 17473 1045 233 0 0 0
cpu3 21456 1 7067 109241 32777 344 288 0 0 0
intr 4095093 5 2178 0 0 0 0 0 0 62 4 0 0 6 0 0 0 20269 0 3 0 0 0 0 35 0 0 2200 132279 26 69842 342352 890 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
ctxt 19186647
btime 1608054667
processes 82281
procs_running 1
procs_blocked 1
softirq 2417755 20210 271643 349 69842 63309 0 133492 760379 1864 1096667
EOC
echo 'setup audio'
echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> ~/../usr/etc/pulse/default.pa
./start-artix.sh
