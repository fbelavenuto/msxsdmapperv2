@echo off

set VER_MAIN=1
set VER_SEC=1
set VER_REV=0

echo VER_MAIN	equ	%VER_MAIN% > %cd%/driver/VERSION.INC
echo VER_SEC	equ	%VER_SEC% >> %cd%/driver/VERSION.INC
echo VER_REV	equ	%VER_REV% >> %cd%/driver/VERSION.INC

set /p NXT_VERSION=<Nextor\VERSION
set /p HW_VERSION=<CPLD\VERSION

echo Updating docker image
docker pull fbelavenuto/8bitcompilers
docker pull fbelavenuto/xilinxise

echo Building Driver Version %VER_MAIN%.%VER_SEC%.%VER_REV%
docker run --rm -it -v %cd%/driver:/src fbelavenuto/8bitcompilers N80 DRIVER.ASM DRIVER.BIN --listing-file DRIVER.LST
IF ERRORLEVEL 1 GOTO error

echo Building ROM with Nextor %NXT_VERSION%
docker run --rm -it -v %cd%:/src fbelavenuto/8bitcompilers mknexrom Nextor/Nextor-%NXT_VERSION%.base.dat driver/SDXC%VER_MAIN%%VER_SEC%%VER_REV%.ROM /d:driver/DRIVER.BIN /m:Nextor/Mapper.ASCII16.bin
IF ERRORLEVEL 1 GOTO error

echo Building Updater
docker run --rm -it -v %cd%/SW:/src fbelavenuto/8bitcompilers make -C Updater
IF ERRORLEVEL 1 GOTO error

echo Building CPLD bitstream Version %HW_VERSION%
docker run --rm -it -v %cd%/CPLD:/workdir fbelavenuto/xilinxise make VERSION=%HW_VERSION%
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Ocorreu algum erro!
:ok
echo.
pause
