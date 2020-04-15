cd Driver
sjasmplus --lst=../debug.aux/Driver.prn Driver.asm
if [ $? -gt 0 ] ;then exit ;fi

cd ../Updater
sjasmplus --lst=../debug.aux/sdmupd.prn sdmupd.asm
if [ $? -gt 0 ] ;then exit ;fi

cd ..
wine Nextor/mknexrom Nextor\\Nextor-2.1.0-beta1.base.dat Driver\\SDMAPPER.ROM /d:Driver\\driver.bin /m:Nextor\\Mapper.ASCII16.bin

