#!/usr/bin/env sh
set -e

export VER_MAIN=1
export VER_SEC=1
export VER_REV=0

echo "VER_MAIN	equ	$VER_MAIN" > $PWD/driver/VERSION.INC
echo "VER_SEC	equ	$VER_SEC" >> $PWD/driver/VERSION.INC
echo "VER_REV	equ	$VER_REV" >> $PWD/driver/VERSION.INC

echo Updating docker image
docker pull fbelavenuto/8bitcompilers

echo Building Driver
docker run --rm -it -v $PWD/driver:/src fbelavenuto/8bitcompilers N80 DRIVER.ASM DRIVER.BIN --listing-file DRIVER.LST

echo Building ROM
docker run --rm -it -v $PWD:/src fbelavenuto/8bitcompilers mknexrom Nextor/Nextor-2.1.0.base.dat driver/SDM${VER_MAIN}${VER_SEC}${VER_REV}.ROM /d:driver/driver.bin /m:Nextor/Mapper.ASCII16.bin

echo Building Updater
docker run --rm -it -v $PWD/SW:/src fbelavenuto/8bitcompilers make -C Updater
