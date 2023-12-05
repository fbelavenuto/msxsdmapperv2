@echo off

set VER_MAIN=1
set VER_SEC=1
set VER_REV=0

echo VER_MAIN	equ	%VER_MAIN% > %cd%/driver/VERSION.INC
echo VER_SEC	equ	%VER_SEC% >> %cd%/driver/VERSION.INC
echo VER_REV	equ	%VER_REV% >> %cd%/driver/VERSION.INC

echo Updating docker image
docker pull fbelavenuto/8bitcompilers

echo Building Driver
docker run --rm -it -v %cd%/driver:/src fbelavenuto/8bitcompilers N80 DRIVER.ASM DRIVER.BIN --listing-file DRIVER.LST
IF ERRORLEVEL 1 GOTO error

echo Building ROM
docker run --rm -it -v %cd%:/src fbelavenuto/8bitcompilers mknexrom Nextor/Nextor-2.1.0.base.dat driver/SDM%VER_MAIN%%VER_SEC%%VER_REV%.ROM /d:driver/DRIVER.BIN /m:Nextor/Mapper.ASCII16.bin
IF ERRORLEVEL 1 GOTO error

echo Building Updater
docker run --rm -it -v %cd%/SW:/src fbelavenuto/8bitcompilers make -C Updater
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Ocorreu algum erro!
:ok
echo.
pause
