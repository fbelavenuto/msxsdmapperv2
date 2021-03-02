# MSX SD Mapper V2

## ATTENTION: do not try to update the old SDMapper (and its clones) using this firmware with the old SDMUPD.COM utility. SDMUPD.COM does not differentiate between new and old hardware and if the update occurs, the old SDMappers will brick !!

# readme in portuguese

Projeto SD Mapper/Megaram 512K para MSX

Copyright (c) 2014-2020
Fabio Belavenuto
Licenced under
CERN OHL v1.1
http://ohwr.org/cernohl

This documentation describes Open Hardware and is licensed under the CERN OHL v. 1.1.
You may redistribute and modify this documentation under the terms of the
CERN OHL v.1.1. (http://ohwr.org/cernohl). This documentation is distributed
WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY,
SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
Please see the CERN OHL v.1.1 for applicable conditions


  Este projeto implementa uma interface em forma de cartucho para adicionar um
dispositivo de armazenamento em massa utilizando até dois cartões SD (Secure
Digital) e uma Mapper de 512K para computadores da linha MSX.
  Foi utilizado como sistema operacional o Nextor [1] sendo desenvolvido somente
o driver para se ter acesso aos dois cartões SD. O Nextor é um projeto aberto.
  O Nextor é uma evolução do MSX-DOS 2 tendo nativamente suporte a partições FAT16
de até 4GB, podendo ter 4 partições por cartão SD. É necessário 128KB de Mapper no
mínimo para utilizar o Nextor com acesso à sub-diretórios, menos que 128K de mapper
permite somente o uso do kernel do MSXDOS1 limitando em partições com FAT12 e
máximo de 16MB por partição.
  Uma das chaves habilita ou não a Mapper em conjunto com um expansor de slot. A
segunda chave permite selecionar entre duas opções de driver, útil para se ter um
backup de uma versão estável do driver e utilizá-lo para restaurar um driver novo
com falha na atualização.
  Foi criado um utilitário chamado "FBL-UPD.COM" para poder atualizar a flash pelo
próprio MSX.
  Para compilar o driver e o utilitário FBL-UPD.COM utilize o cross-compiler
SJASMPLUS [2] e para compilar o código do CPLD utilize o Xilinx ISE Webpack [3].
  Agradecimentos ao FRS pela re-escrita do driver, ao Luciano Sturaro pelo 
roteamento da placa e a comunidade MSXBR-L pelo apoio e incentivo.
  Detalhes técnicos:
  - O código do CPLD implementa toda a lógica necessária, implementando um expansor
    de slots padrão, uma porta SPI modo 0, o controle da MegaROM padrão ASCII16
    utilizada pelo Nextor e o controle da Mapper de 512K.
  - Ao ativar a mapper, a interface ativa o expansor de slots, e com isso a
    interface funciona somente em slots não-expandidos. Porém, se desativar a
    mapper, o expansor de slots é desativado, permitindo utilizar o dispositivo
    de armazenamento em massa em slots expandidos. O dispositivo de armazenamento
    em massa fica no subslot 0 e a mapper no subslot 1.
  - Há uma janela em $7B00~7EFF para a transferência de dados SPI.
  - Existe um registro de configuração e status no endereço $7FF0 e um pequeno timer
    no endereço $7FF1. Mais detalhes no source do driver.


[1] http://www.konamiman.com/msx/msx-e.html#nextor

[2] http://sourceforge.net/projects/sjasmplus/

[3] http://www.xilinx.com/products/design-tools/ise-design-suite/ise-webpack.htm
