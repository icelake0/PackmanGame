LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.numeric_std.all;

entity keyprocess is

	port(scan_code : in std_logic_vector(7 downto 0);
			scan_ready : in std_logic;
			resetn : in std_logic;
			up : out std_logic;
			dn : out std_logic;
			lft : out std_logic;
			rth : out std_logic;
			read_out : out std_logic
		);
end keyprocess;

architecture a of keyprocess is

signal break_int : std_logic := '1';


begin


process(scan_ready, resetn)
begin
				if scan_code = "01110101" then 
					up <= '1';
					dn <= '0';
				elsif scan_code= "01110010" then
					dn <= '1';
					up <= '0';
				end if;
				if scan_code = "01101011" then 
					lft <= '1';
					rth <= '0';
				elsif scan_code= "01110100" then
					rth <= '1';
					lft <= '0';
				end if;
end process;

end a;