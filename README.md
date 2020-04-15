# msxsdmapper

MSX SD Mapper V2

Projeto SD Mapper/Megaram 512K para MSX

Copyright (c) 2014
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
Digital) e uma Mapper ou Megaram de 512K para computadores da linha MSX.
  Foi utilizado como sistema operacional o Nextor [1] sendo desenvolvido somente
o driver para se ter acesso aos dois cartões SD. O Nextor é um projeto fechado,
sendo permitido o desenvolvimento de um driver open-source.
  O Nextor é uma evolução do MSX-DOS 2 tendo nativamente suporte a partições FAT16
de até 4GB, podendo ter 4 partições por cartão SD. É necessário 128KB de Mapper no
mínimo para utilizar o Nextor com acesso à sub-diretórios, menos que 128K de mapper
permite somente o uso do kernel do MSXDOS1 limitando em partições com FAT12 e
máximo de 16MB por partição.
  Uma chave seleciona entre os modos Mapper ou Megaram. A Megaram é um projeto do
Ademir Carchano e permite executar ROMs de jogos/programas de cartuchos Megarom.
  A função Mapper/Megaram pode ser desativada por uma outra chave e é útil no caso
de usar a interface em um MSX que já tenha Mapper e não quiser usar a Megaram.
  Foi criado um utilitário chamado "sdmupd.com" para poder atualizar a flash pelo
próprio MSX.
  Para compilar o driver e o utilitário sdmupd.com utilize o cross-compiler
SJASMPLUS [2] e para compilar o código do CPLD utilize o Xilinx ISE Webpack [3].
  Agradecimentos ao Ademir Carchano pela invenção da Megaram, ao Luciano Sturaro
pelo roteamento da placa e a comunidade MSXBR-L pelo apoio e incentivo.
  Detalhes técnicos:
  - O código do CPLD implementa toda a lógica necessária, implementando um expansor
    de slots padrão, uma porta SPI modo 0, o controle da MegaROM padrão ASCII16
    utilizada pelo Nextor e o controle da Mapper ou Megaram de 512K.
  - Ao ativar a mapper/megaram, a interface ativa o expansor de slots, e com isso a
    interface funciona somente em slots não-expandidos. Porém, se desativar a
    mapper/megaram, o expansor de slots é desativado, permitindo utilizar o
    dispositivo de armazenamento em massa em slots expandidos.
  - A porta SPI implementada utiliza mapa de memória de $4000 a $48FF, sendo o 
    chaveamento entre ROM e SPI configurado pela escrita no endereço $6001.
  - Foi previsto a atualização da memória flash por software. Para isto foi
    implementado a porta 0x5F que controla a ativação ou não da gravação da flash.
    O bit 7 controla a permissão de gravação e os bits 2, 1 e 0 controlam a paginação
    de 16KB. Ao ativar o bit 7 a flash é mapeada em qualquer página (repete o mesmo
    espaço de 16K nas 4 páginas) e os bits 2, 1 e 0 controlam qual das 8 páginas da
    flash será mapeada. O sinal /WR da flash só é gerado quando o bit 7 está ativo.
    O utilitário sdmupd.com utiliza esta porta para poder atualizar a flash pelo
    próprio MSX.


[1] http://www.konamiman.com/msx/msx-e.html#nextor
[2] http://sourceforge.net/projects/sjasmplus/
[3] http://www.xilinx.com/products/design-tools/ise-design-suite/ise-webpack.htm
