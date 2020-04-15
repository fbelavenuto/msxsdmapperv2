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

-- Implementa um expansor de slots padrao.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity exp_slot is
	port(
		reset_n	: in    std_logic;								-- /RESET
		sltsl_n	: in    std_logic;								-- Sinal de selecao do slot a ser expandido
		cpu_rd_n	: in    std_logic;								-- /RD da CPU
		cpu_wr_n	: in    std_logic;								-- /WR da CPU
		ffff		: in    std_logic;								-- 1 quando CPU_A = FFFF
		cpu_a		: in    std_logic_vector(15 downto 14);	-- Barramento de endereco da CPU (bits 15 e 14)
		cpu_d		: inout std_logic_vector(7 downto 0);		-- Barramento de dados da CPU
		exp_n		: out   std_logic_vector(3 downto 0)		-- Saida 4 bits do expansor (ativo em 0)
	);
end exp_slot;

architecture rtl of exp_slot is

	signal exp_reg  : std_logic_vector(7 downto 0);
	signal exp_sel  : std_logic_vector(1 downto 0);
	signal exp_wr   : std_logic;
	signal exp_rd   : std_logic;

begin

	-- Sinais de selecao do slot
	exp_wr <= '1' when sltsl_n = '0' and cpu_wr_n = '0' and ffff = '1'	else '0';
	exp_rd <= '1' when sltsl_n = '0' and cpu_rd_n = '0' and ffff = '1'	else '0';

	process(reset_n, exp_wr)
	begin
		if (reset_n = '0') then				-- Zerar registrador do expansor em um reset
			exp_reg <= X"00";
		elsif (falling_edge(exp_wr)) then	-- Escrita no endereco &HFFFF
			exp_reg <= cpu_d;
		end if;
 	end process;

	-- Leitura dos registros
	cpu_d <= (not exp_reg) when exp_rd = '1' else
				(OTHERS => 'Z');

	-- Seleciona qual subslot acionar de acordo com endereco do barramento e registros
	with cpu_a(15 downto 14) select exp_sel <=
		exp_reg(1 downto 0) when "00",
		exp_reg(3 downto 2) when "01",
		exp_reg(5 downto 4) when "10",
		exp_reg(7 downto 6) when others;

	-- Demux 2-to-4
	exp_n <= "1111" when ffff = '1' or sltsl_n = '1'      else
				"1110" when sltsl_n = '0' and exp_sel = "00" else
				"1101" when sltsl_n = '0' and exp_sel = "01" else
				"1011" when sltsl_n = '0' and exp_sel = "10" else
				"0111";
		
end rtl;
