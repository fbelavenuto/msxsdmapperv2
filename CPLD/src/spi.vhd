
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi is
	port(
		clock_i			: in    std_logic;
		reset_n_i		: in    std_logic;
		-- CPU interface
		cs_i				: in    std_logic;
		data_bus_io		: inout std_logic_vector(7 downto 0);
		wr_n_i			: in    std_logic;
		rd_n_i			: in    std_logic;
		wait_n_o			: out   std_logic;
		-- SPI interface
		spi_sclk_o		: out   std_logic;
		spi_mosi_o		: out   std_logic;
		spi_miso_i		: in    std_logic
	);

end entity;

architecture Behavioral of spi is

	signal spi_cs_s			: std_logic;
	signal spi_data_q			: std_logic_vector(7 downto 0);
	-- State type of the SPI transfer state machine
	type   state_type_t is (s_idle, s_cleaning, s_running, s_done);
	signal state_s				: state_type_t;
	signal shift_reg_s		: std_logic_vector(8 downto 0);	-- Shift register
	signal spi_data_buf_s	: std_logic_vector(7 downto 0);	-- Buffer to hold data to be sent
	signal start_s				: std_logic;							-- Start transmission flag
	signal count_q				: unsigned(3 downto 0);				-- Number of bits transfered
	signal spi_clk_buf_s		: std_logic;							-- Buffered SPI clock
	signal spi_clk_out_s		: std_logic;							-- Buffered SPI clock output
	signal prev_spi_clk_s	: std_logic;							-- Previous SPI clock state
	signal ff_q, ff_clr_s	: std_logic;
	signal wait_n_s			: std_logic;

begin

	spi_cs_s <= '1' when cs_i = '1' and (rd_n_i = '0' or wr_n_i = '0')	else '0';

	-- flip-flop
	process(ff_clr_s, clock_i)
	begin
		if ff_clr_s = '1' then
			ff_q	<= '0';
		elsif rising_edge(clock_i) then
			ff_q	<= start_s;
		end if;
	end process;

	-- Data read
	data_bus_io <= spi_data_q	when cs_i = '1' and rd_n_i = '0'	else
						(others => 'Z');

	-- R/W port
	process (reset_n_i, ff_clr_s, spi_cs_s)
	begin
		if reset_n_i = '0' or ff_clr_s = '1' then
			spi_data_buf_s	<= (others => '1');
			start_s			<= '0';
		elsif rising_edge(spi_cs_s) then						-- only works if rising_edge
			if rd_n_i = '0' then
				spi_data_buf_s <= (others => '1');
			else
				spi_data_buf_s <= data_bus_io;
			end if;
			start_s <= '1';
		end if;
	end process;

	--------------------------------------------------
	-- Essa parte lida com a porta SPI por hardware --
	--      Implementa um SPI Master Mode 0         --
	--------------------------------------------------

	-- SPI write
	process(clock_i, reset_n_i)
	begin		
		if reset_n_i = '0' then
			ff_clr_s <= '0';
		elsif rising_edge(clock_i) then

			prev_spi_clk_s <= spi_clk_buf_s;
			case state_s is

				when s_idle =>
					if ff_q = '1' then
						count_q     <= (others => '0');
						shift_reg_s <= spi_data_buf_s & '1';
						state_s     <= s_cleaning;
						ff_clr_s    <= '1';
					end if;
					wait_n_s	<= '1';

				when s_cleaning =>
					ff_clr_s	<= '0';
					state_s	<= s_running;

				when s_running =>
					if start_s = '1' then
						wait_n_s	<= '0';
					end if;
					if prev_spi_clk_s = '1' and spi_clk_buf_s = '0' then
						spi_clk_out_s <= '0';
						count_q       <= count_q + 1;
						shift_reg_s   <= shift_reg_s(7 downto 0) & spi_miso_i;
						if count_q = "0111" then
							state_s		<= s_done;
						end if;
					elsif prev_spi_clk_s = '0' and spi_clk_buf_s = '1' then
						spi_clk_out_s <= '1';
					end if;

				when s_done =>
					spi_data_q	<= shift_reg_s(7 downto 0);
					state_s		<= s_idle;

				when others =>
					null;
			end case;
		end if;
	end process;

	-- Generate SPI clock
	spi_clock_gen : process(clock_i, reset_n_i)
	begin
		if reset_n_i = '0' then
			spi_clk_buf_s   <= '0';
		elsif rising_edge(clock_i) then
			if state_s = s_running then
				spi_clk_buf_s <= not spi_clk_buf_s;
			else
				spi_clk_buf_s <= '0';
			end if;
		end if;
	end process;

	spi_mosi_o <= shift_reg_s(8);
	spi_sclk_o <= spi_clk_out_s;
	wait_n_o	<= wait_n_s;

end architecture;
