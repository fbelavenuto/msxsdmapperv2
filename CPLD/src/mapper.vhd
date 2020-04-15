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

-- Implementa uma mapper padrao de 512K para SRAM

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mapper is
	port(
		reset_n_i	: in    std_logic;								-- /RESET
		cpu_a_i		: in    std_logic_vector(15 downto 0);		-- Barramento de enderecos da CPU
		cpu_d_io		: inout std_logic_vector(7 downto 0);		-- Barramento de dados da CPU
		ioFx_i		: in    std_logic;								-- Sinal de selecao de I/O portas FC a FF
		cpu_rd_n_i	: in    std_logic;								-- /RD da CPU
		cpu_wr_n_i	: in    std_logic;								-- /WR da CPU
		sltsl_n_i	: in    std_logic;								-- /SLTSL do slot/subslot da RAM
		sram_ma_o	: out   std_logic_vector(5 downto 0);		-- Saida do banco da SRAM
		sram_cs_n_o	: out   std_logic;								-- Saida de selecao da SRAM
		sram_we_n_o	: out   std_logic;
		busdir_n_o	: out   std_logic
	);
end mapper;

architecture rtl of mapper is

	signal mp_rd_s			: std_logic;
	signal mp_wr_s			: std_logic;
	signal MapBank0_q		: std_logic_vector(4 downto 0);
	signal MapBank1_q		: std_logic_vector(4 downto 0);
	signal MapBank2_q		: std_logic_vector(4 downto 0);
	signal MapBank3_q		: std_logic_vector(4 downto 0);
	signal ram_ma_s		: std_logic_vector(4 downto 0);

begin

  ----------------------------------------------------------------
  -- Mapper bank register access
  ----------------------------------------------------------------

	mp_rd_s	<= '1'	when ioFx_i = '1' and cpu_rd_n_i = '0'		else '0';
	mp_wr_s	<= '1'	when ioFx_i = '1' and cpu_wr_n_i = '0'		else '0';

	process(reset_n_i, mp_wr_s)
	begin
		if reset_n_i = '0' then
			MapBank0_q   <= "00011";		-- Reset configura blocos padroes da mapper
			MapBank1_q   <= "00010";
			MapBank2_q   <= "00001";
			MapBank3_q   <= "00000";
		elsif rising_edge(mp_wr_s) then
			case cpu_a_i(1 downto 0) is
				when "00"   => MapBank0_q <= cpu_d_io(4 downto 0);
				when "01"   => MapBank1_q <= cpu_d_io(4 downto 0);
				when "10"   => MapBank2_q <= cpu_d_io(4 downto 0);
				when others => MapBank3_q <= cpu_d_io(4 downto 0);
			end case;

		end if;
	end process;

	-- Leitura dos registros da mapper pelas portas
	cpu_d_io(4 downto 0) <=
			(others => 'Z') when cpu_rd_n_i = '1' or ioFx_i = '0' else
	      MapBank0_q when cpu_a_i(1 downto 0) = "00" else
	      MapBank1_q when cpu_a_i(1 downto 0) = "01" else
	      MapBank2_q when cpu_a_i(1 downto 0) = "10" else
	      MapBank3_q;

	-- Gera endereco da SRAM de acordo com endereco do barramento e bancos configurados
	ram_ma_s	<= MapBank0_q when cpu_a_i(15 downto 14) = "00" else
					MapBank1_q when cpu_a_i(15 downto 14) = "01" else
					MapBank2_q when cpu_a_i(15 downto 14) = "10" else
					MapBank3_q;

	-- Pega parte baixa do endereco que vai direto nos pinos da SRAM
	sram_ma_o <= ram_ma_s & cpu_a_i(13);

	sram_cs_n_o <= sltsl_n_i;
	sram_we_n_o <= cpu_wr_n_i;
	busdir_n_o	<= not mp_rd_s;

end architecture;
