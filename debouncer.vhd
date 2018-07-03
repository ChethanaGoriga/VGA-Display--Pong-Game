----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:34:55 07/07/2016 
-- Design Name: 
-- Module Name:    debouncer - Behavioral 
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debouncer is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           deb_in : in  STD_LOGIC;
           deb_out : out  STD_LOGIC);
end debouncer;

architecture Behavioral of debouncer is

TYPE state_type is (btn_1,btn_1_counting,btn_2,btn_2_counting);
signal pr_state: state_type;
signal nx_state: state_type;
signal pr_count,nx_count: integer range 0 to 200 := 0;

signal deb_temp : std_logic;
begin
---- sequential
process(reset,clk)
begin
 if (reset = '1') then
    pr_state <= btn_1; ---assume everything starts with btn_1	 
	 pr_count <= 0;
 elsif (rising_edge (clk)) then 
      pr_state <= nx_state;	
      pr_count <= nx_count;		
 end if;
end process;

--- combinational 
process(deb_in,pr_state,pr_count)
begin
  case(pr_state) is
  when btn_1 =>
     if (deb_in = '1') then 
	     nx_state <= btn_1_counting;
		  nx_count <= 0;
	  else
	     nx_state <= btn_1;
        nx_count <= 0;
	  end if;
	  
	  deb_temp <= '0';

  when btn_1_counting =>
     if (deb_in = '0') then 
	     nx_state <= btn_1;
		  nx_count <= 0; 
		  deb_temp <= '0';
	  else  
		   if (pr_count = 20) then  
			    deb_temp <= '1'; 
				 nx_state <= btn_2;
				 nx_count <= 0;
		   else
			    deb_temp <= '0'; 
				 nx_state <= btn_1_counting;
				 nx_count <= pr_count + 1;
			end if;
	  end if;
	  
  when btn_2 =>
     if (deb_in = '0') then 
	     nx_state <= btn_2_counting;
		  nx_count <= 0;
	  else
	     nx_state <= btn_2;
        nx_count <= 0;
	  end if;
	  deb_temp <= '1';
  when btn_2_counting =>
     if (deb_in = '1') then 
	     nx_state <= btn_2;
		  nx_count <= 0; 
		  deb_temp <= '1';
	  else
		   if (pr_count = 20) then
			    deb_temp <= '0'; 
				 nx_state <= btn_1;
				 nx_count <= 0;
		   else
			    deb_temp <= '1'; 
				 nx_state <= btn_2_counting;
				 nx_count <= pr_count + 1;
			end if;
	  end if;	  
	end case;
end process;

deb_out <= deb_temp;

end Behavioral;

