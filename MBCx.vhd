----------------------------------------------------------------------------------
-- Company: Ladecadence.net
-- Engineer: David Pello
-- 
-- Create Date:    11:35:28 11/27/2010 
-- Design Name: 	 MBC5 GameBoy Mapper Clone
-- Module Name:    MBCx - Behavioral 
-- Project Name: 
-- Target Devices: xc9536
-- Tool versions:  ISE 14.2
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.9 - Working MBC5 model
-- Additional Comments: 
--
-- This code is licensed under the terms of the GNU General Public License (GPL)
-- version 2 or above; see http://www.fsf.org/licensing/licenses/gpl.html
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MBCx is
	port(	not_reset	:	in		std_logic;
			not_cs		:	in		std_logic;
			not_wr		:	in		std_logic;
			data			: 	in		std_logic_vector(7 downto 0);
			addr			: 	in		std_logic_vector(15 downto 12);
			rom_addr		: 	out	std_logic_vector(22 downto 14);
			ram_addr		: 	out	std_logic_vector(16 downto 13);
			not_ram_cs	:	out	std_logic;
			led_ctrl		:	out	std_logic );			
end MBCx;

architecture Behavioral of MBCx is
	signal ram_e_code:		std_logic;
	signal ram_e_regsel:		std_logic;
	signal romh_regsel:		std_logic;
	signal roml_regsel:		std_logic;
	signal ram_regsel:		std_logic;

	signal romlq:				std_logic_vector(7 downto 0) := "00000001";	-- 32K flat space after reset
	signal romhq:				std_logic := '0';
	
	signal ram_e_q:			std_logic := '1';
	
	signal lsb:					std_logic;
	
begin			

		--selection:process(addr, data, not_wr)
		--begin
		-- RAM enable	(0000h - 1FFFh)
		ram_e_regsel <= addr(13) or addr(14) or addr(15) or not_wr or (not not_cs);
					
		-- ROM low		(2000h-2FFFh)
		roml_regsel <=  not(addr(13) and not(addr(12) or addr(14) or addr(15) or not_wr)) or (not not_cs);
					
		-- ROM high		(3000h-3FFFh)
		romh_regsel <= not(addr(12) and addr(13) and not(addr(14) or addr(15) or not_wr)) or (not not_cs);
					
		-- RAM			(4000h-5FFFh)
		ram_regsel <= not(addr(14) and not(addr(13) or addr(15) or not_wr)) or (not not_cs);
			
		-- RAM enable code
		ram_e_code <= data(3) and (not data(2)) and data(1) and (not data(0));
		--end process selection;	
		
		-- REGISTERS
		-- ---------
		
		-- RAM enable register
		ram_enable:process(not_reset, not_cs, ram_e_code, ram_e_regsel, data)
		begin
			if not_reset = '0' then
				ram_e_q <= '1';
			elsif rising_edge(ram_e_regsel) then
				ram_e_q <= ram_e_code;
			end if;
		end process ram_enable;



		-- RAM register
		ramreg:process(not_reset, data, ram_regsel) is
		begin
			if not_reset = '0' then
				ram_addr <= "0000";
			elsif rising_edge(ram_regsel)  then
				ram_addr <= data(3 downto 0);
			end if;
		end process ramreg;



		-- ROM High  and LED register
		-- --------------------------
		
		-- ROM 22 and LED register
		romh22reg:process(not_reset, addr, data, romh_regsel) is
		begin
			if not_reset = '0' then
				romhq <= '0';
				led_ctrl <= '0';
			elsif rising_edge(romh_regsel) then
				romhq <= data(0);
				led_ctrl <= data(7);
			end if;
		end process romh22reg;
		
		
		-- ROM LOW register
		-- --------------------------
		
		romlreg:process(not_reset, addr, data, roml_regsel)
		begin		
			if not_reset = '0' then
				romlq <= "00000001";
			elsif rising_edge(roml_regsel) then
				romlq <= data;
			end if;
		end process romlreg;
		
		
		-- OUTPUT
		-- -------
		
		--lsb <= romlq(0) or not (romlq(1) or romlq(2) or romlq(3) or romlq(4) or romlq(5) or romlq(6) or romlq(7) or romhq);
		--rom_addr(14) <= lsb and addr(14);
		rom_addr(14) <= romlq(0) and addr(14);
		rom_addr(15) <= romlq(1) and addr(14);
		rom_addr(16) <= romlq(2) and addr(14);
		rom_addr(17) <= romlq(3) and addr(14);
		rom_addr(18) <= romlq(4) and addr(14);
		rom_addr(19) <= romlq(5) and addr(14);
		rom_addr(20) <= romlq(6) and addr(14);
		rom_addr(21) <= romlq(7) and addr(14);
		
		rom_addr(22) <= romhq and addr(14);
		
		not_ram_cs <= (not ram_e_q) or not_cs;

		
end architecture Behavioral;

