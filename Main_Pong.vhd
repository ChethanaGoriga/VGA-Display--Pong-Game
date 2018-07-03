----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:31:03 07/07/2016 
-- Design Name: 
-- Module Name:    top_pong - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
entity top_pong is
   port (
      clk,reset: in std_logic;
      btn_1: in std_logic_vector (1 downto 0);
		btn_2: in std_logic_vector (1 downto 0);
      hsync,vsync: out  std_logic;
      rgb: out std_logic_vector(2 downto 0)
   );
end top_pong;

architecture arch of top_pong is
 	signal pixel_x, pixel_y: std_logic_vector (9 downto 0);
   signal video_on, pixel_tick: std_logic;
   signal rgb_reg, rgb_next: std_logic_vector(2 downto 0);
	signal btn_1_temp, btn_2_temp: std_logic_vector(1 downto 0);
begin
   -- instantiate VGA sync
   vga_sync_unit: entity work.vga_sync
      port map(clk=>clk, reset=>reset,
               video_on=>video_on, p_tick=>pixel_tick,
               hsync=>hsync, vsync=>vsync,
               pixel_x=>pixel_x, pixel_y=>pixel_y);
 
  
   -- instantiate graphic generator
   pong_arc_unit: entity work.pong_arc
      port map (clk=>clk, reset=>reset,
                btn_1=>btn_1_temp, btn_2=>btn_2_temp, video_on=>video_on,
                pixel_x=>pixel_x, pixel_y=>pixel_y,
                graph_rgb=>rgb_next);
	
	-- right bar DOWN slide btn_1
	debouncer_btn_1_dwn:entity work.debouncer
	port map( clk=>clk, reset=>reset,
           deb_in => btn_1(0),
           deb_out=> btn_1_temp(0));
			  
	-- right bar UP slide btn_1	  
	debouncer_btn_1_up:entity work.debouncer
	port map( clk=>clk, reset=>reset,
           deb_in => btn_1(1),
           deb_out=> btn_1_temp(1));
			  
	-- Left bar DOWN slide btn_2
			  
	debouncer_btn_2_dwn:entity work.debouncer
	port map( clk=>clk, reset=>reset,
           deb_in => btn_2(0),
           deb_out=> btn_2_temp(0));
			  
	-- Left bar UP slide btn_2
			  		  
	debouncer_btn_2_up:entity work.debouncer
	port map( clk=>clk, reset=>reset,
           deb_in => btn_2(1),
           deb_out=> btn_2_temp(1));
			  		  
   -- rgb buffer
   process (clk)
   begin
      if (clk'event and clk='1') then
         if (pixel_tick='1') then
            rgb_reg <= rgb_next;
         end if;
      end if;
   end process;
   rgb <= rgb_reg;
end arch;

