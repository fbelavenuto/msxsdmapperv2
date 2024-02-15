# MSX SD Mapper V2

## WARNING: do not try to update the old SDMapper V1 (and its clones) with this new ROM using the old SDMUPD.COM utility, as the hardware is different, and it will brick your cartridge.

# Disclaimer

This documentation describes Open Hardware and is licensed under the CERN OHL v. 1.1.

You may redistribute and modify this documentation under the terms of the [CERN OHL v.1.1](http://ohwr.org/cernohl). This documentation is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.

Please see the CERN OHL v.1.1 for applicable conditions

# Project description

This project implements a cartridge-shaped interface to add a mass storage device using up to two SD (Secure Digital) and a 512K Mapper for MSX line computers.

[Nextor](http://www.konamiman.com/msx/msx-e.html#nextor) was used as operating system, being developed only the driver to have access to the two SD cards. Nextor is an open project.

Nextor is an evolution of MSX-DOS 2 natively supporting FAT16 partitions up to 4GB, and can have 4 partitions per SD card. 128KB of Mapper is required on the minimum to use Nextor with access to sub-directories, less than 128K mapper only allows the use of the MSXDOS1 kernel, limiting partitions with FAT12 and maximum 16MB per partition.

One of the switches enables or disables the Mapper in conjunction with a slot expander. The second key allows you to select between two driver options, useful for having a backup a stable version of the driver and use it to restore a new driver update failed.

A utility called "FBL-UPD.COM" was created to be able to update the flash by MSX itself.

To compile the FBL-UPD.COM driver and utility use the [Konaniman's Nestor80](https://github.com/Konamiman/Nestor80) and to compile the CPLD code use [Xilinx ISE Webpack](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive-ise.html).

Technical details:
 - The CPLD code implements all the necessary logic, implementing an expander of standard slots, one SPI mode 0 port, standard ASCII16 MegaROM control used by Nextor and the 512K Mapper control.
 - When activating the mapper, the interface activates the slot expander, and with that the interface works only on non-expanded slots. However, if you disable the mapper, the slot expander is disabled, allowing you to use the device of mass storage in expanded slots. the mass storage device is in subslot 0 and the mapper device in subslot 1.
 - There is a window in $7B00~7EFF for SPI data transfer.
 - There is a configuration and status register at address $7FF0 and a small timer at address $7FF1. More details in the driver source.

# Acknowledge

Thanks to FRS for rewriting the driver, to Luciano Sturaro for board routing and the MSXBR-L community for their support and encouragement.

# Quickstart guide

After assembling the device, or buying a ready-made one, get an SD card, put it in the interface and start MSX.

When dropping into BASIC, type `CALL FDISK` to start formatting the SD card. The FAT16 file system used by Nextor supports a maximum of 4GB.

After partitioning and formatting, shut down MSX, remove the SD card and put it on your PC, copy the contents of the ./SD folder into the first partition of the SD card and put it back in MSX.

For more information on how to use Nextor, visit [User Manual](https://github.com/Konamiman/Nextor/blob/v2.1/docs/Nextor%202.1%20User%20Manual.md)

# 3D case

I found [this design](https://www.printables.com/en/model/496236-msx-cartridge-for-fblabs-sd-mapper-v2) made by community.

# Readme in portuguese

Este projeto implementa uma interface em forma de cartucho para adicionar um dispositivo de armazenamento em massa utilizando até dois cartões SD (Secure Digital) e uma Mapper de 512K para computadores da linha MSX.

Foi utilizado como sistema operacional o [Nextor](http://www.konamiman.com/msx/msx-e.html#nextor) sendo desenvolvido somente o driver para se ter acesso aos dois cartões SD. O Nextor é um projeto aberto.

O Nextor é uma evolução do MSX-DOS 2 tendo nativamente suporte a partições FAT16 de até 4GB, podendo ter 4 partições por cartão SD. É necessário 128KB de Mapper no mínimo para utilizar o Nextor com acesso à sub-diretórios, menos que 128K de mapper permite somente o uso do kernel do MSXDOS1 limitando em partições com FAT12 e máximo de 16MB por partição.

Uma das chaves habilita ou não a Mapper em conjunto com um expansor de slot. A segunda chave permite selecionar entre duas opções de driver, útil para se ter um backup de uma versão estável do driver e utilizá-lo para restaurar um driver novo com falha na atualização.

Foi criado um utilitário chamado "FBL-UPD.COM" para poder atualizar a flash pelo próprio MSX.

Para compilar o driver e o utilitário FBL-UPD.COM utilize o [Nestor80 do Konaniman](https://github.com/Konamiman/Nestor80) e para compilar o código do CPLD utilize o [Xilinx ISE Webpack](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive-ise.html).

# Agradecimentos

Agradecimentos ao FRS pela re-escrita do driver, ao Luciano Sturaro pelo roteamento da placa e a comunidade MSXBR-L pelo apoio e incentivo.

# Detalhes técnicos:

 - O código do CPLD implementa toda a lógica necessária, implementando um expansor de slots padrão, uma porta SPI modo 0, o controle da MegaROM padrão ASCII16 utilizada pelo Nextor e o controle da Mapper de 512K.
 - Ao ativar a mapper, a interface ativa o expansor de slots, e com isso a interface funciona somente em slots não-expandidos. Porém, se desativar a mapper, o expansor de slots é desativado, permitindo utilizar o dispositivo de armazenamento em massa em slots expandidos. O dispositivo de armazenamento em massa fica no subslot 0 e a mapper no subslot 1.
 - Há uma janela em $7B00~7EFF para a transferência de dados SPI.
 - Existe um registro de configuração e status no endereço $7FF0 e um pequeno timer no endereço $7FF1. Mais detalhes no source do driver.

# Início rápido

Depois de montar o dispositivo, ou comprar um pronto, adquira um cartão SD, coloque na interface e inicie o MSX.

Ao cair no BASIC, digite `CALL FDISK` para iniciar a formatação do cartão SD. O sistema de arquivos FAT16 utilizado pelo Nextor suporta no máximo 4GB.

Após o particionamento e formatação, desligue o MSX, retire o cartão SD e coloque no seu PC, copie o conteúdo da pasta ./SD para dentro da primeira partição do cartão SD e recoloque no MSX.

Maiores informações de como usar o Nextor acesse o [Manual do usuário](https://github.com/Konamiman/Nextor/blob/v2.1/docs/Nextor%202.1%20User%20Manual.md)

# Case 3D

Eu achei [este desenho](https://www.printables.com/en/model/496236-msx-cartridge-for-fblabs-sd-mapper-v2) feito pela comunidade.
