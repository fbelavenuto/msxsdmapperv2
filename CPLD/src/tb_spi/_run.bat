vlib work
IF ERRORLEVEL 1 GOTO error

vcom ..\spi.vhd
IF ERRORLEVEL 1 GOTO error

vcom tb_spi.vht
IF ERRORLEVEL 1 GOTO error

vsim -t ns tb -do all.do
IF ERRORLEVEL 1 GOTO error

goto ok

:error
echo Error!
pause

:ok
