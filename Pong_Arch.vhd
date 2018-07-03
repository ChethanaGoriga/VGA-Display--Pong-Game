----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:15:21 07/07/2016 
-- Design Name: 
-- Module Name:    pong_arc - Behavioral 
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
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity pong_arc is
   port(
	     refr_tick_x: out std_logic;
        clk, reset: in std_logic;
        btn_1:in std_logic_vector(1 downto 0);
		  btn_2:in std_logic_vector(1 downto 0);
        video_on: in std_logic;
        pixel_x,pixel_y: in std_logic_vector(9 downto 0);
        graph_rgb: out std_logic_vector(2 downto 0)
   );
end pong_arc;

architecture arch of pong_arc is
   signal refr_tick: std_logic;
   -- x, y coordinates (0,0) to (639,479)
   signal pix_x, pix_y: unsigned(9 downto 0);
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;
	
	

	
   ----------------------------------------------
   -- left stick
   ----------------------------------------------
   -- bar left, right boundary
   constant stick_X_L: integer:=30;
   constant stick_X_R: integer:=40;
	-- bar top, bottom boundary
	signal stick_y_t, stick_y_b: unsigned(9 downto 0);
   constant stick_Y_SIZE: integer:=100;
   -- reg to track top boundary  (x position is fixed)
   signal stick_y_reg, stick_y_next: unsigned(9 downto 0);
   -- stick moving velocity when the button are pressed
   constant stick_V: integer:=4;
   ----------------------------------------------
   -- right stick bar
   ----------------------------------------------
   -- bar left, right boundary
   constant BAR_X_L: integer:=600;
   constant BAR_X_R: integer:=610;
   -- bar top, bottom boundary
   signal bar_y_t, bar_y_b: unsigned(9 downto 0);
   constant BAR_Y_SIZE: integer:=100;
   -- reg to track top boundary  (x position is fixed)
   signal bar_y_reg, bar_y_next: unsigned(9 downto 0);
   -- bar moving velocity when the button are pressed
   constant BAR_V: integer:=4;
  
	
   ----------------------------------------------
   -- square ball
   ----------------------------------------------
   constant BALL_SIZE: integer:=8; -- 8
   -- ball left, right boundary
   signal ball_x_l, ball_x_r: unsigned(9 downto 0);
   -- ball top, bottom boundary
   signal ball_y_t, ball_y_b: unsigned(9 downto 0);
   -- reg to track left, top boundary
   signal ball_x_reg, ball_x_next: unsigned(9 downto 0);
   signal ball_y_reg, ball_y_next: unsigned(9 downto 0);
   -- reg to track ball speed
   signal x_delta_reg, x_delta_next: unsigned(9 downto 0);
   signal y_delta_reg, y_delta_next: unsigned(9 downto 0);
   -- ball velocity can be pos or neg)
   constant BALL_V_P: unsigned(9 downto 0)
            :=to_unsigned(2,10);
   constant BALL_V_N: unsigned(9 downto 0)
            :=unsigned(to_signed(-2,10));			
	-- counter for color check
	signal count_R: std_logic_vector( 2 downto 0):="000"; 
   signal count_L: std_logic_vector( 2 downto 0):="000"; 
   ----------------------------------------------
   -- round ball image ROM
   ----------------------------------------------
   type rom_type is array (0 to 7)
        of std_logic_vector(0 to 7);
   -- ROM definition
   constant BALL_ROM: rom_type :=
   (
      "00011000", --    **
      "00011000", --    **
      "00011000", --    **
      "11111111", -- ********
      "11111111", -- ********
      "00011000", --    **
      "00011000", --    **
      "00011000"  --    **
   );
   signal rom_addr, rom_col: unsigned(2 downto 0);
   signal rom_data: std_logic_vector(7 downto 0);
   signal rom_bit: std_logic;
   ----------------------------------------------
   -- object output signals
   ----------------------------------------------
   signal stick_on, bar_on, sq_ball_on, str_ball_on : std_logic;
   signal stick_rgb, bar_rgb, ball_rgb: std_logic_vector(2 downto 0):="000";
  
begin
   -- registers
   process (clk,reset)
   begin
      if reset='1' then
		   stick_y_reg <= (others=>'0');
         bar_y_reg <= (others=>'0');
         ball_x_reg <= (others=>'0');
         ball_y_reg <= (others=>'0');
         x_delta_reg <= ("0000000100");
         y_delta_reg <= ("0000000100");
      elsif (clk'event and clk='1') then
         stick_y_reg <= stick_y_next;
			bar_y_reg <= bar_y_next;
         ball_x_reg <= ball_x_next;
         ball_y_reg <= ball_y_next;
         x_delta_reg <= x_delta_next;
         y_delta_reg <= y_delta_next;
      end if;
   end process;
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
   -- refr_tick: 1-clock tick asserted at start of v-sync
   --       i.e., when the screen is refreshed (60 Hz)
   refr_tick <= '1' when (pix_y=481) and (pix_x=0) else
                '0';
   ----------------------------------------------
   --left stick
   ----------------------------------------------
   stick_y_t <= stick_y_reg;
   stick_y_b <= stick_y_t + stick_Y_SIZE - 1;
   -- pixel within bar
   stick_on <=
      '1' when (stick_X_L<=pix_x) and (pix_x<=stick_X_R) and
               (stick_y_t<=pix_y) and (pix_y<=stick_y_b) else
      '0';
   -- new bar y-position
   process(stick_y_reg,stick_y_b,stick_y_t,refr_tick,btn_1)
   begin
      stick_y_next <= stick_y_reg; -- no move
      if refr_tick='1' then
         if btn_1(1)='1' and stick_y_b<(MAX_Y-1-BAR_V) then
            stick_y_next <= stick_y_reg + stick_V; -- move down
         elsif btn_1(0)='1' and stick_y_t > stick_V then
            stick_y_next <= stick_y_reg - stick_V; -- move up
         end if;
      end if;
		
   end process;
	
	refr_tick_x<=refr_tick;

   ----------------------------------------------
   -- right vertical bar
   ----------------------------------------------
   -- boundary
   bar_y_t <= bar_y_reg;
   bar_y_b <= bar_y_t + BAR_Y_SIZE - 1;
   -- pixel within bar
   bar_on <=
      '1' when (BAR_X_L<=pix_x) and (pix_x<=BAR_X_R) and
               (bar_y_t<=pix_y) and (pix_y<=bar_y_b) else
      '0';
   process(bar_y_reg,bar_y_b,bar_y_t,refr_tick,btn_2)
   begin
      bar_y_next <= bar_y_reg; -- no move
      if refr_tick='1' then
         if btn_2(1)='1' and bar_y_b<(MAX_Y-1-BAR_V) then
            bar_y_next <= bar_y_reg + BAR_V; -- move down
         elsif btn_2(0)='1' and bar_y_t > BAR_V then
            bar_y_next <= bar_y_reg - BAR_V; -- move up
         end if;
      end if;
   end process;

   ----------------------------------------------
   -- square ball
   ----------------------------------------------
   -- boundary
   ball_x_l <= ball_x_reg;
   ball_y_t <= ball_y_reg;
   ball_x_r <= ball_x_l + BALL_SIZE - 1;
   ball_y_b <= ball_y_t + BALL_SIZE - 1;
   -- pixel within ball
   sq_ball_on <=
      '1' when (ball_x_l<=pix_x) and (pix_x<=ball_x_r) and
               (ball_y_t<=pix_y) and (pix_y<=ball_y_b) else
      '0';
   -- map current pixel location to ROM addr/col
   rom_addr <= pix_y(2 downto 0) - ball_y_t(2 downto 0);
   rom_col <= pix_x(2 downto 0) - ball_x_l(2 downto 0);
   rom_data <= BALL_ROM(to_integer(rom_addr));
   rom_bit <= rom_data(to_integer(rom_col));
   -- pixel within ball
   str_ball_on <=
      '1' when (sq_ball_on='1') and (rom_bit='1') else
      '0';
		
   -- new ball position
   ball_x_next <= ball_x_reg + x_delta_reg
                     when refr_tick='1' else
                  ball_x_reg ;
   ball_y_next <= ball_y_reg + y_delta_reg
                     when refr_tick='1' else
                  ball_y_reg ;
   -- new ball velocity
   process(clk,x_delta_reg,y_delta_reg,ball_y_t,ball_x_l,ball_x_r,
           ball_y_t,ball_y_b,bar_y_t,bar_y_b, stick_y_t,stick_y_b)
   begin
      x_delta_next <= x_delta_reg;
      y_delta_next <= y_delta_reg;
      if ball_y_t < 1 then -- reach top
         y_delta_next <= BALL_V_P;
      elsif ball_y_b > (MAX_Y-1) then   -- reach bottom
         y_delta_next <= BALL_V_N;
					
--------------------------------------------------------------------------------------
--trap the ball
--------------------------------------------------------------------------------------

		elsif ball_x_r>(MAX_X-1) then
		    x_delta_next <= BALL_V_N;
		elsif ball_x_l<1 then
		    x_delta_next <= BALL_V_P;

      elsif ball_x_l <= stick_X_R  then -- reach stick
			
			if (stick_y_t<=ball_y_b) and (ball_y_t<=stick_y_b) then
            x_delta_next <= BALL_V_P; --hit, bounce back
				stick_rgb <=count_L;
				ball_rgb<=count_L;
				count_L<=std_logic_vector(unsigned(count_L))+1;
				if (count_L="100") then
   			count_L<="000";
            end if;
				end if;

      elsif (BAR_X_L<=ball_x_r) and (ball_x_r<=BAR_X_R) then
         -- reach x of right bar
         if (bar_y_t<=ball_y_b) and (ball_y_t<=bar_y_b) then
            x_delta_next <= BALL_V_N; --hit, bounce back
				bar_rgb <=count_R;
				ball_rgb<= count_R;
				
				count_R<=std_logic_vector(unsigned(count_R))-1;
				if (count_R="100") then
   			count_R<="000";
            end if;
         end if;			
      end if;		
   end process;
	

	
	
	
   ----------------------------------------------
   -- rgb multiplexing circuit
   ----------------------------------------------
   process(video_on,stick_on,bar_on,str_ball_on,
           stick_rgb, bar_rgb, ball_rgb)
   begin
      if video_on='0' then
          graph_rgb <= "000"; --blank
      else
         if stick_on='1' then
            graph_rgb <= stick_rgb;
         elsif bar_on='1' then
            graph_rgb <= bar_rgb;
         elsif str_ball_on='1' then
            graph_rgb <= ball_rgb;
         else
            graph_rgb <= "000"; -- black background
         end if;
      end if;
   end process;
end arch;

