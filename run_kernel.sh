#!/bin/bash


print_help() {
    echo "Usage: run_kernel.sh [-a <append>] -m <method>"
    echo "    -h: Show this message."
    echo "    -a: append cmdline argument to the kernel running in the qemu. This argument should set before -m."
    echo "    -m: Choose method."
    echo "         'debug': Start a qemu virtual machine."
    echo "         'init': Package the initramfs directory to the initramfs.cpio.gz. It used in qemu."
}

if [ $# -eq 0 ]
then
    print_help
fi

while getopts "hm:a:" optname
do
    case "$optname" in
        "h")
            print_help
            ;;
        "a")
            CMDLINE="$OPTARG"
            ;;
        "m")
            if [ "$OPTARG"x = "debug"x ]
            then
                echo run kernel in qemu for debug
                qemu-system-x86_64 --enable-kvm -s -kernel ./vmlinux -initrd ./initramfs.cpio.gz -nographic -append "console=ttyS0 $CMDLINE"
            elif [ "$OPTARG"x = "init"x ]
            then
                echo package the initramfs
                echo "Copy Device file, permission needed!"
                sudo rm -rf ./initramfs/dev/*
                sudo cp -a /dev/null /dev/console /dev/tty /dev/tty1 /dev/tty2 /dev/tty3/ /dev/tty4 ./initramfs/dev/ 

                cd initramfs
                find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
                cd -
            fi
            ;;
        "?")
            print_help
            ;;
    esac
done

