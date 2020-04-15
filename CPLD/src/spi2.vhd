-------------------------------------------------------------------------------
--
-- MSX SD Mapper
--
-- Copyright (c) 2016, Fabio Belavenuto (belavenuto@gmail.com)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-------------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi2 is
	port (
		clock_i			: in    std_logic;
		reset_n_i		: in    std_logic;
		-- CPU interface
		cs_i				: in    std_logic;
		data_bus_io		: inout std_logic_vector(7 downto 0);
		wr_n_i			: in    std_logic;
		rd_n_i			: in    std_logic;
		wait_n_o			: out   std_logic;
		-- SD card interface
		spi_sclk_o		: out   std_logic;
		spi_mosi_o		: out   std_logic;
		spi_miso_i		: in    std_logic
	);
end entity;

architecture rtl of spi2 is

	signal sck_delayed_s	: std_logic;
	signal counter_s		: unsigned(3 downto 0);
	-- Shift register has an extra bit because we write on the
	-- falling edge and read on the rising edge
	signal shift_r			: std_logic_vector( 8 downto 0);
	signal port_r			: std_logic_vector( 7 downto 0);
	signal port_en_s		: std_logic;
	signal edge_det_s		: std_logic_vector( 1 downto 0)		:= "00";
	signal last_wr_n_q	: std_logic_vector( 1 downto 0)	:= (others => '0');
	signal last_data_q	: std_logic_vector( 7 downto 0);
	signal wait_n_s		: std_logic;
	signal wait_cnt_q		: unsigned( 3 downto 0)	:= (others => '0');

begin

	port_en_s	<= '1'	when cs_i = '1' and (wr_n_i = '0' or rd_n_i = '0')	else '0';

	-- Port reading
	data_bus_io <=	port_r	when port_en_s = '1' and rd_n_i = '0'	else
						(others => 'Z');

	--------------------------------------------------
	-- Essa parte lida com a porta SPI por hardware --
	--      Implementa um SPI Master Mode 0         --
	--------------------------------------------------

	-- SD card outputs from clock divider and shift register
	spi_sclk_o  <= sck_delayed_s;
	spi_mosi_o  <= shift_r(8);

	-- Atrasa SCK para dar tempo do bit mais significativo mudar de estado e acertar MOSI antes do SCK
	process (clock_i, reset_n_i)
	begin
		if reset_n_i = '0' then
			sck_delayed_s <= '0';
		elsif rising_edge(clock_i) then
			sck_delayed_s <= not counter_s(0);
		end if;
	end process;

	-- SPI write
	process(clock_i, reset_n_i)
	begin		
		if reset_n_i = '0' then

			shift_r		<= (others => '1');
			port_r		<= (others => '1');
			counter_s	<= "1111"; -- Idle
			wait_n_s		<= '1';
			wait_cnt_q	<= (others => '0');

		elsif rising_edge(clock_i) then

			-- Shift-register, detects rising edge
			edge_det_s		<= edge_det_s(0) & port_en_s;

			if counter_s = "1111" then
				port_r		<= shift_r(7 downto 0);		-- Store previous shift register value in input register
				shift_r(8)	<= '1';							-- MOSI repousa em '1'
				if wait_cnt_q /= 0 then
					wait_cnt_q	<= wait_cnt_q - 1;
				else
					wait_n_s		<= '1';
				end if;

				-- Idle - check for a bus access
				if edge_det_s = "10"  then
					-- Write loads shift register with data
					-- Read loads it with all 1s
					if last_wr_n_q(1) = '0' then
						shift_r <= last_data_q & '1';		-- Write
					else
						shift_r <= (others => '1');		-- Read dispares 0xFF transmition
					end if;
					counter_s <= "0000";						-- Initiates transfer
				end if;
			else
				counter_s <= counter_s + 1;				-- Transfer in progress

				if sck_delayed_s = '0' then
					shift_r(0)	<= spi_miso_i;				-- Input next bit on rising edge
				else
					shift_r		<= shift_r(7 downto 0) & '1';		-- Output next bit on falling edge
				end if;
				if edge_det_s = "01" then
					wait_n_s	<= '0';
				end if;
				wait_cnt_q	<= (others => '1');
			end if;

			-- Delay signals
			last_wr_n_q	<= last_wr_n_q(0) & wr_n_i;
			last_data_q	<= data_bus_io;

		end if;
	end process;

	wait_n_o	<= wait_n_s;

end architecture;
