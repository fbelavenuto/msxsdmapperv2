--
-- Projeto MSX SD Mapper
--
-- Copyright (c) 2014
-- Fabio Belavenuto

-- This documentation describes Open Hardware and is licensed under the CERN OHL v. 1.1.
-- You may redistribute and modify this documentation under the terms of the
-- CERN OHL v.1.1. (http://ohwr.org/cernohl). This documentation is distributed
-- WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY,
-- SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
-- Please see the CERN OHL v.1.1 for applicable conditions

-- Implementa uma mapper ou megaram de 512K para SRAM
-- Agradecimentos ao Ademir Carchano pela invenção da Megaram.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity megamapper is
	port(
		reset_n		: in    std_logic;								-- /RESET
		cpu_a			: in    std_logic_vector(15 downto 0);		-- Barramento de enderecos da CPU
		cpu_d			: inout std_logic_vector(7 downto 0);		-- Barramento de dados da CPU
		mr_mp			: in    std_logic;								-- Se for 1 implementa mapper, se for 0 implementa megaram
		ioFx			: in    std_logic;								-- Sinal de selecao de I/O portas FC a FF
		io8x			: in    std_logic;								-- Sinal de selecao de I/O portas 8E e 8F
		cpu_rd_n		: in    std_logic;								-- /RD da CPU
		cpu_wr_n		: in    std_logic;								-- /WR da CPU
		sltsl_n		: in    std_logic;								-- /SLTSL do slot/subslot da RAM
		sram_ma		: out   std_logic_vector(5 downto 0);		-- Saida do banco para SRAM
		sram_cs_n	: out   std_logic;								-- Saida de selecao para SRAM
		sram_we_n	: out   std_logic;								-- Saida de escrita para SRAM
		busdir_n		: out   std_logic
	);
end entity;

architecture rtl of megamapper is

	type ram_t is array(natural range 0 to 3) of std_logic_vector(5 downto 0);

	signal ram_q : ram_t := (others => (others => '0'));

	signal mp_rd			: std_logic;	-- Mapper read (se habilitada)
	signal mp_wr			: std_logic;	-- Mapper write (se habilitada)
	signal mr_rd			: std_logic;	-- Megaram read (se habilitada)
	signal mr_wr			: std_logic;	-- Megaram write (se habilitada)
	signal mr_wr_en		: std_logic;
	signal mr_escrita		: std_logic;
	signal reg_wr			: std_logic;
	signal reg_wr_addr	: unsigned(1 downto 0);

begin

	-- Sinais de selecao escrita/leitura nas portas da mapper e megaram
	mp_rd		<= '1' when mr_mp = '1' and ioFx = '1'	and cpu_rd_n = '0' 		else '0';
	mp_wr		<= '1' when mr_mp = '1' and ioFx = '1'	and cpu_wr_n = '0' 		else '0';
	mr_rd		<= '1' when mr_mp = '0' and io8x = '1'	and cpu_rd_n = '0' 		else '0';
	mr_wr		<= '1' when mr_mp = '0' and io8x = '1'	and cpu_wr_n = '0' 		else '0';

	-- Porta 8E - Habilita leitura ou escrita da megaram
	process (reset_n, mr_wr, mr_rd)
	begin
		if reset_n = '0' or mr_wr = '1' then
			mr_wr_en <= '0';							-- desabilita escrita na memoria ram (habilita chaveamento)
		elsif rising_edge(mr_rd) then
			mr_wr_en <= '1';							-- habilita escrita na memoria ram (desabilita chaveamento)
		end if;
	end process;

	-- Registros da Mapper/Megaram (74670)
	mr_escrita	<= '1' when mr_mp = '0' and mr_wr_en = '0' and sltsl_n = '0' and cpu_wr_n = '0'	else '0';
	reg_wr		<= mr_escrita or mp_wr;
	reg_wr_addr	<= unsigned(cpu_a(14 downto 13)) when mr_mp = '0' else unsigned(cpu_a( 1 downto  0));

	-- Escrita dos registros da mapper ou megaram
	process (reset_n, reg_wr)
	begin
		if reset_n = '0' then
			ram_q(0) <= "000000";
			ram_q(1) <= "000001";
			ram_q(2) <= "000010";
			ram_q(3) <= "000011";
		elsif falling_edge(reg_wr) then
			ram_q(to_integer(reg_wr_addr)) <= cpu_d(5 downto 0);
		end if;
	end process;

	-- Leitura do registro da mapper (megaram nao tem leitura de registro)
	cpu_d		<= (others => 'Z') when mp_rd = '0' 	else 
					"111" & ram_q(to_integer(unsigned(cpu_a(1 downto 0))))(4 downto 0);
--	cpu_d	<= "111" & ram_q(to_integer(unsigned(cpu_a(1 downto 0))))(4 downto 0)  when mp_rd = '1' 	else 
--				(others => 'Z');

	busdir_n <= not mp_rd;

	-- Multiplex do endereco alto da SRAM
	sram_ma	<= ram_q(to_integer(unsigned(cpu_a(15 downto 14))))(4 downto 0) & cpu_a(13) when mr_mp = '1' else		-- Mapper
					ram_q(to_integer(unsigned(cpu_a(14 downto 13))));																	-- Megaram

	sram_cs_n <= sltsl_n;

	sram_we_n <=                   cpu_wr_n		when mr_mp = '1' else				-- Mapper
					 (not mr_wr_en) or cpu_wr_n;													-- Megaram

end rtl;
