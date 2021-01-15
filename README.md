# msxsdmapper

MSX SD Mapper V2

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
dispositivo de armazenamento em massa utilizando at� dois cart�es SD (Secure
Digital) e uma Mapper de 512K para computadores da linha MSX.
  Foi utilizado como sistema operacional o Nextor [1] sendo desenvolvido somente
o driver para se ter acesso aos dois cart�es SD. O Nextor � um projeto aberto.
  O Nextor � uma evolu��o do MSX-DOS 2 tendo nativamente suporte a parti��es FAT16
de at� 4GB, podendo ter 4 parti��es por cart�o SD. � necess�rio 128KB de Mapper no
m�nimo para utilizar o Nextor com acesso � sub-diret�rios, menos que 128K de mapper
permite somente o uso do kernel do MSXDOS1 limitando em parti��es com FAT12 e
m�ximo de 16MB por parti��o.
  Uma das chaves habilita ou n�o a Mapper em conjunto com um expansor de slot. A
segunda chave permite selecionar entre duas op��es de driver, �til para se ter um
backup de uma vers�o est�vel do driver e utiliz�-lo para restaurar um driver novo
com falha na atualiza��o.
  Foi criado um utilit�rio chamado "FBL-UPD.COM" para poder atualizar a flash pelo
pr�prio MSX.
  Para compilar o driver e o utilit�rio FBL-UPD.COM utilize o cross-compiler
SJASMPLUS [2] e para compilar o c�digo do CPLD utilize o Xilinx ISE Webpack [3].
  Agradecimentos ao FRS pela re-escrita do driver, ao Luciano Sturaro pelo 
roteamento da placa e a comunidade MSXBR-L pelo apoio e incentivo.
  Detalhes t�cnicos:
  - O c�digo do CPLD implementa toda a l�gica necess�ria, implementando um expansor
    de slots padr�o, uma porta SPI modo 0, o controle da MegaROM padr�o ASCII16
    utilizada pelo Nextor e o controle da Mapper de 512K.
  - Ao ativar a mapper, a interface ativa o expansor de slots, e com isso a
    interface funciona somente em slots n�o-expandidos. Por�m, se desativar a
    mapper, o expansor de slots � desativado, permitindo utilizar o dispositivo
    de armazenamento em massa em slots expandidos. O dispositivo de armazenamento
    em massa fica no subslot 0 e a mapper no subslot 1.
  - H� uma janela em $7B00~7EFF para a transfer�ncia de dados SPI.
  - Existe um registro de configura��o e status no endere�o $7FF0 e um pequeno timer
    no endere�o $7FF1. Mais detalhes no source do driver.


[1] http://www.konamiman.com/msx/msx-e.html#nextor

[2] http://sourceforge.net/projects/sjasmplus/

[3] http://www.xilinx.com/products/design-tools/ise-design-suite/ise-webpack.htm
