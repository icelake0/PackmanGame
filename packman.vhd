LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.numeric_std.all;

--Pong game. Uses Ps/2 keyboard and vga.
--Controls: Key0 resets. Left player uses keys W and S, right player uses O and L.


ENTITY packman IS

   PORT(pixel_row_in, pixel_col_in		: IN std_logic_vector(9 DOWNTO 0);
        Red,Green,Blue 				: OUT std_logic_vector(9 downto 0);
        Vert_sync, up, dn, lft, rth, resetn, clock_50	: IN std_logic);	
		
END packman;

architecture a of packman is

component char_rom
	PORT( 	character_address :IN STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			font_row, font_col : IN STD_LOGIC_VECTOR( 2 DOWNTO 0 );
			rom_mux_output : OUT STD_LOGIC;
			clock : in std_logic); 
end component;

signal char_addr : std_logic_vector(5 downto 0);
signal font_r : std_logic_vector(2 downto 0);
signal font_c : std_logic_vector(2 downto 0);
signal mux_out : std_logic;

constant draw_on : std_logic_vector(9 downto 0) := (others => '1');
constant draw_off : std_logic_vector(9 downto 0) := (others => '0');

constant topbar_y1 : integer := 50;
constant topbar_y2 : integer := 70;

constant botbar_y1 : integer := 410;
constant botbar_y2 : integer := 430;

constant lpad_x1 : integer := 15;
constant lpad_x2 : integer := 30;
signal lpad_y1 : integer range 0 to 480 := 100;
signal lpad_y2 : integer range 0 to 480 := 130;

constant rpad_x1 : integer := 610;
constant rpad_x2 : integer := 625;
signal rpad_y1 : integer range 0 to 480 := 100;
signal rpad_y2 : integer range 0 to 480 := 130;

signal point_x1 : integer range 0 to 640 := 320;
signal point_x2 : integer range 0 to 640 := 330;
signal point_y1 : integer range 0 to 480 := 240;
signal point_y2 : integer range 0 to 480 := 250;
---------------------------------------------
signal ghost_one_x1 : integer range 0 to 640 := 0;
signal ghost_one_x2 : integer range 0 to 640 := 10;
signal ghost_one_y1 : integer range 0 to 480 := 240;
signal ghost_one_y2 : integer range 0 to 480 := 250;

signal ghost_one_yvel : integer range -5 to 5 := 1;
signal ghost_one_xvel : integer range -5 to 5 := 1;
---------------------------------------------
---------------------------------------------
signal ghost_two_x1 : integer range 0 to 640 := 0;
signal ghost_two_x2 : integer range 0 to 640 := 10;
signal ghost_two_y1 : integer range 0 to 480 := 150;
signal ghost_two_y2 : integer range 0 to 480 := 160;

signal ghost_two_yvel : integer range -5 to 5 := 2;
signal ghost_two_xvel : integer range -5 to 5 := 2;
---------------------------------------------
---------------------------------------------
signal ghost_three_x1 : integer range 0 to 640 := 0;
signal ghost_three_x2 : integer range 0 to 640 := 10;
signal ghost_three_y1 : integer range 0 to 480 := 170;
signal ghost_three_y2 : integer range 0 to 480 := 180;

signal ghost_three_yvel : integer range -5 to 5 := 3;
signal ghost_three_xvel : integer range -5 to 5 := 3;
---------------------------------------------
---------------------------------------------
signal ghost_four_x1 : integer range 0 to 640 := 0;
signal ghost_four_x2 : integer range 0 to 640 := 10;
signal ghost_four_y1 : integer range 0 to 480 := 190;
signal ghost_four_y2 : integer range 0 to 480 := 200;

signal ghost_four_yvel : integer range -5 to 5 := 4;
signal ghost_four_xvel : integer range -5 to 5 := 4;
---------------------------------------------
---------------------------------------------
signal packman_x1 : integer range 0 to 640 := 585;
signal packman_x2 : integer range 0 to 640 := 615;
signal packman_y1 : integer range 0 to 480 := 225;
signal packman_y2 : integer range 0 to 480 := 255;

signal packman_yvel : integer range -5 to 5 := 2;
signal packman_xvel : integer range -5 to 5 := 2;
---------------------------------------------
signal disp_en : std_logic_vector(9 downto 0);

signal pixel_row : integer range 0 to 480;
signal pixel_col : integer range 0 to 640;

signal lives : integer range 0 to 15 := 9;
------------------------------------------------
signal score0 : integer range 0 to 9 := 0;
signal score1 : integer range 0 to 9 := 0;
signal score2 : integer range 0 to 9 := 0;
signal score3 : integer range 0 to 9 := 0;
signal score4 : integer range 0 to 9 := 0;
signal score5 : integer range 0 to 9 := 0;
signal score6 : integer range 0 to 9 := 0;
signal score7 : integer range 0 to 9 := 0;
------------------------------------------------

signal l_win : std_logic := '0';
signal r_win : std_logic := '0';
signal game_play : std_logic := '1';

signal game_clock : std_logic;

begin  

c1 : char_rom port map(	character_address => char_addr,
					font_row => font_r,
					font_col => font_c,
					rom_mux_output => mux_out,
					clock => clock_50);

game_clock <= (game_play or not(resetn)) and vert_sync;

--red <= disp_en;
--green <= disp_en;
--blue <= disp_en;

pixel_row <= to_integer(unsigned(pixel_row_in));
pixel_col <= to_integer(unsigned(pixel_col_in));

----------------display logic-------------------
font_r <= pixel_row_in(4 downto 2);
font_c <= pixel_col_in(4 downto 2);

process(pixel_row_in, pixel_col_in)
begin

if pixel_row < 32 then	
		if lives = 0  then
			case pixel_col is 
				when 0 to 31 => char_addr <= std_logic_vector(to_unsigned(lives + 48, 6));--live
				when 32 to 63 => char_addr <= "100000";--space
				when 64 to 95 => char_addr <= "000111";--g
				when 96 to 127 => char_addr <= "000001";--a
				when 128 to 159 => char_addr <= "001101";--m
				when 160 to 191 => char_addr <= "000101";--e
				when 192 to 223 => char_addr <= "100000";--space
				when 224 to 255 => char_addr <= "001111";--o
				when 256 to 287 => char_addr <= "010110";--v
				when 288 to 319 => char_addr <= "000101";--e
				when 320 to 351 => char_addr <= "010010";--r
				when 352 to 383 => char_addr <= "100000";--space
				when 384 to 415 => char_addr <= std_logic_vector(to_unsigned(score7 + 48, 6));
				when 416 to 447 => char_addr <= std_logic_vector(to_unsigned(score6 + 48, 6));
				when 448 to 479 => char_addr <= std_logic_vector(to_unsigned(score5 + 48, 6));
				when 480 to 511 => char_addr <= std_logic_vector(to_unsigned(score4 + 48, 6));
				when 512 to 543 => char_addr <= std_logic_vector(to_unsigned(score3 + 48, 6));
				when 544 to 575 => char_addr <= std_logic_vector(to_unsigned(score2 + 48, 6));
				when 576 to 607 => char_addr <= std_logic_vector(to_unsigned(score1 + 48, 6));
				when 608 to 640 => char_addr <= std_logic_vector(to_unsigned(score0 + 48, 6));
				when others => char_addr <= "100000";
			end case;
		else
			case pixel_col is 
				when 0 to 31 => char_addr <= std_logic_vector(to_unsigned(lives + 48, 6));--live
				when 384 to 415 => char_addr <= std_logic_vector(to_unsigned(score7 + 48, 6));
				when 416 to 447 => char_addr <= std_logic_vector(to_unsigned(score6 + 48, 6));
				when 448 to 479 => char_addr <= std_logic_vector(to_unsigned(score5 + 48, 6));
				when 480 to 511 => char_addr <= std_logic_vector(to_unsigned(score4 + 48, 6));
				when 512 to 543 => char_addr <= std_logic_vector(to_unsigned(score3 + 48, 6));
				when 544 to 575 => char_addr <= std_logic_vector(to_unsigned(score2 + 48, 6));
				when 576 to 607 => char_addr <= std_logic_vector(to_unsigned(score1 + 48, 6));
				when 608 to 640 => char_addr <= std_logic_vector(to_unsigned(score0 + 48, 6));
				when others => char_addr <= "100000";
			end case;
		end if;	
	if mux_out = '1' then
		disp_en <= draw_on;
		red <= disp_en;
		green <= disp_en;
		blue <= disp_en;
	else
		disp_en <= draw_off;
		red <= disp_en;
		green <= disp_en;
		blue <= disp_en;
	end if;
	
else --display the rest of the game

	if ((pixel_row >= topbar_y1) and (pixel_row <= topbar_y2)) then --draw top boundary
		disp_en <= draw_on;
		red <= disp_en;
		green <= disp_en;
		blue <= disp_en;
	elsif ((pixel_row >= botbar_y1) and (pixel_row <= botbar_y2)) then --draw bottom boundary
		disp_en <= draw_on;
		red <= disp_en;
		green <= disp_en;
		blue <= disp_en;
	elsif ((pixel_row >= point_y1) and (pixel_row <= point_y2) and (pixel_col >= point_x1) and (pixel_col <= point_x2)) then --draw point
		disp_en <= draw_on;
		red <= disp_en;
		green <= disp_en;
		blue <= disp_en;
	elsif ((pixel_row >= ghost_one_y1) and (pixel_row <= ghost_one_y2) and (pixel_col >= ghost_one_x1) and (pixel_col <= ghost_one_x2)) then --draw ghost_one
		disp_en <= draw_on;
		red <= "1111111111";
		green <= "0000000000";
		blue <= "0000000000";
	elsif ((pixel_row >= ghost_two_y1) and (pixel_row <= ghost_two_y2) and (pixel_col >= ghost_two_x1) and (pixel_col <= ghost_two_x2)) then --draw ghost_two
		disp_en <= draw_on;
		red <= "1111111111";
		green <= "1111111111";
		blue <= "0000000000";
	elsif ((pixel_row >= ghost_three_y1) and (pixel_row <= ghost_three_y2) and (pixel_col >= ghost_three_x1) and (pixel_col <= ghost_three_x2)) then --draw ghost_three
		disp_en <= draw_on;
		red <= "0000000000";
		green <= "0000000000";
		blue <= "1111111111";
	elsif ((pixel_row >= ghost_four_y1) and (pixel_row <= ghost_four_y2) and (pixel_col >= ghost_four_x1) and (pixel_col <= ghost_four_x2)) then --draw four_one
		disp_en <= draw_on;
		red <= "1111111111";
		green <= "0000000000";
		blue <= "1111111111";
	elsif ((pixel_row >= packman_y1) and (pixel_row <= packman_y2) and (pixel_col >= packman_x1) and (pixel_col <= packman_x2)) then --draw packman
		disp_en <= draw_on;
		red <= "1111111111";
		green <= "1111111111";
		blue <= "0000000000";
	else
		disp_en <= draw_off;--draw nothing
		red <= disp_en;
		green <= disp_en;
		blue <= disp_en;
	end if;
end if;
end process;
----------------game logic-----------------
process
begin
	wait until game_clock ='1';
	if resetn = '0' then
		lives <= 9;
		--reset game
		---------------------------------------------
		ghost_one_x1 <= 0;
		ghost_one_x2 <= 10;
		ghost_one_y1 <= 240;
		ghost_one_y2 <= 250;
		ghost_one_yvel <= 1;
		ghost_one_xvel <= 1;
		---------------------------------------------
		---------------------------------------------
		ghost_two_x1 <= 0;
		ghost_two_x2 <= 10;
		ghost_two_y1 <= 150;
		ghost_two_y2 <= 160;
		ghost_two_yvel <= 2;
		ghost_two_xvel <= 2;
		---------------------------------------------
		---------------------------------------------
		ghost_three_x1 <= 0;
		ghost_three_x2 <= 10;
		ghost_three_y1 <= 170;
		ghost_three_y2 <= 180;
		ghost_three_yvel <= 3;
		ghost_three_xvel <= 3;
		---------------------------------------------
		---------------------------------------------
		ghost_four_x1 <= 0;
		ghost_four_x2 <= 10;
		ghost_four_y1 <= 190;
		ghost_four_y2 <= 200;
		ghost_four_yvel <= 4;
		ghost_four_xvel <= 4;
		---------------------------------------------
		---------------------------------------------
		packman_x1 <= 585;
		packman_x2 <= 615;
		packman_y1 <= 225;
		packman_y2 <= 255;
		packman_yvel <= 2;
		packman_xvel <= 2;
		---------------------------------------------
		---------------------------------------------
		point_x1 <= 320;
		point_x2 <= 330;
		point_y1 <= 240;
		point_y2 <= 250;
		---------------------------------------------
		---------------------------------------------
		score0<=0;
		score1<=0;
		score2<=0;
		score3<=0;
		score4<=0;
		score5<=0;
		score6<=0;
		score7<=0;
		---------------------------------------------
		
	elsif lives  >0 then
		--------------ghosts one movement--------------
			ghost_one_x1 <= ghost_one_x1 + ghost_one_xvel; --move the ghost_one
			ghost_one_y1 <= ghost_one_y1 + ghost_one_yvel;
			ghost_one_x2 <= ghost_one_x2 + ghost_one_xvel;
			ghost_one_y2 <= ghost_one_y2 + ghost_one_yvel;
			---------------top and bottom bar collision----------------
			if ghost_one_y1 < topbar_y2 then --check top and bottom collisions and bounce
				ghost_one_yvel <= -ghost_one_yvel;
				ghost_one_y1 <= ghost_one_y1 + (topbar_y2 - ghost_one_y1 + 5) + ghost_one_yvel;
				ghost_one_y2 <= ghost_one_y2 + (topbar_y2 - ghost_one_y1 + 5) + ghost_one_yvel;
			elsif ghost_one_y2 > botbar_y1 then
				ghost_one_yvel <= -ghost_one_yvel;
				ghost_one_y1 <= ghost_one_y1 - (ghost_one_y2 - botbar_y1 + 5) - ghost_one_yvel;
				ghost_one_y2 <= ghost_one_y2 - (ghost_one_y2 - botbar_y1 + 5) - ghost_one_yvel;
			end if;
			if ghost_one_x1 <= 0 then --check lefth and right collisions and bounce
				ghost_one_xvel <= -ghost_one_xvel;
				ghost_one_x1 <= ghost_one_x1 + ghost_one_yvel;
				ghost_one_x2 <= ghost_one_x2 + ghost_one_yvel;
			elsif ghost_one_x2 >= 640 then
				ghost_one_xvel <= -ghost_one_xvel;
				ghost_one_x1 <= ghost_one_x1 - ghost_one_xvel;
				ghost_one_x2 <= ghost_one_x2 - ghost_one_xvel;
			end if;
			--------------ghosts two movement--------------
			ghost_two_x1 <= ghost_two_x1 + ghost_two_xvel; --move the ghost_two
			ghost_two_y1 <= ghost_two_y1 + ghost_two_yvel;
			ghost_two_x2 <= ghost_two_x2 + ghost_two_xvel;
			ghost_two_y2 <= ghost_two_y2 + ghost_two_yvel;
			---------------top and bottom bar collision----------------
			if ghost_two_y1 < topbar_y2 then --check top and bottom collisions and bounce
				ghost_two_yvel <= -ghost_two_yvel;
				ghost_two_y1 <= ghost_two_y1 + (topbar_y2 - ghost_two_y1 + 5) + ghost_two_yvel;
				ghost_two_y2 <= ghost_two_y2 + (topbar_y2 - ghost_two_y1 + 5) + ghost_two_yvel;
			elsif ghost_two_y2 > botbar_y1 then
				ghost_two_yvel <= -ghost_two_yvel;
				ghost_two_y1 <= ghost_two_y1 - (ghost_two_y2 - botbar_y1 + 5) - ghost_two_yvel;
				ghost_two_y2 <= ghost_two_y2 - (ghost_two_y2 - botbar_y1 + 5) - ghost_two_yvel;
			end if;
			if ghost_two_x1 <= 0 then --check lefth and right collisions and bounce
				ghost_two_xvel <= -ghost_two_xvel;
				ghost_two_x1 <= ghost_two_x1 + ghost_two_yvel;
				ghost_two_x2 <= ghost_two_x2 + ghost_two_yvel;
			elsif ghost_two_x2 >= 640 then
				ghost_two_xvel <= -ghost_two_xvel;
				ghost_two_x1 <= ghost_two_x1 - ghost_two_xvel;
				ghost_two_x2 <= ghost_two_x2 - ghost_two_xvel;
			end if;
			--------------ghosts three movement--------------
			ghost_three_x1 <= ghost_three_x1 + ghost_three_xvel; --move the ghost_three
			ghost_three_y1 <= ghost_three_y1 + ghost_three_yvel;
			ghost_three_x2 <= ghost_three_x2 + ghost_three_xvel;
			ghost_three_y2 <= ghost_three_y2 + ghost_three_yvel;
			---------------top and bottom bar collision----------------
			if ghost_three_y1 < topbar_y2 then --check top and bottom collisions and bounce
				ghost_three_yvel <= -ghost_three_yvel;
				ghost_three_y1 <= ghost_three_y1 + (topbar_y2 - ghost_three_y1 + 5) + ghost_three_yvel;
				ghost_three_y2 <= ghost_three_y2 + (topbar_y2 - ghost_three_y1 + 5) + ghost_three_yvel;
			elsif ghost_three_y2 > botbar_y1 then
				ghost_three_yvel <= -ghost_three_yvel;
				ghost_three_y1 <= ghost_three_y1 - (ghost_three_y2 - botbar_y1 + 5) - ghost_three_yvel;
				ghost_three_y2 <= ghost_three_y2 - (ghost_three_y2 - botbar_y1 + 5) - ghost_three_yvel;
			end if;
			if ghost_three_x1 <= 0 then --check lefth and right collisions and bounce
				ghost_three_xvel <= -ghost_three_xvel;
				ghost_three_x1 <= ghost_three_x1 + ghost_three_yvel;
				ghost_three_x2 <= ghost_three_x2 + ghost_three_yvel;
			elsif ghost_three_x2 >= 640 then
				ghost_three_xvel <= -ghost_three_xvel;
				ghost_three_x1 <= ghost_three_x1 - ghost_three_xvel;
				ghost_three_x2 <= ghost_three_x2 - ghost_three_xvel;
			end if;
			--------------ghosts four movement--------------
			ghost_four_x1 <= ghost_four_x1 + ghost_four_xvel; --move the ghost_four
			ghost_four_y1 <= ghost_four_y1 + ghost_four_yvel;
			ghost_four_x2 <= ghost_four_x2 + ghost_four_xvel;
			ghost_four_y2 <= ghost_four_y2 + ghost_four_yvel;
			---------------top and bottom bar collision----------------
			if ghost_four_y1 < topbar_y2-2 then --check top and bottom collisions and bounce
				ghost_four_yvel <= -ghost_four_yvel;
				ghost_four_y1 <= ghost_four_y1 + (topbar_y2 - ghost_four_y1 + 5) + ghost_four_yvel;
				ghost_four_y2 <= ghost_four_y2 + (topbar_y2 - ghost_four_y1 + 5) + ghost_four_yvel;
			elsif ghost_four_y2 > botbar_y1+2 then
				ghost_four_yvel <= -ghost_four_yvel;
				ghost_four_y1 <= ghost_four_y1 - (ghost_four_y2 - botbar_y1 + 5) - ghost_four_yvel;
				ghost_four_y2 <= ghost_four_y2 - (ghost_four_y2 - botbar_y1 + 5) - ghost_four_yvel;
			end if;
			if ghost_four_x1 <= 0 then --check lefth and right collisions and bounce
				ghost_four_xvel <= -ghost_four_xvel;
				ghost_four_x1 <= ghost_four_x1 + ghost_four_yvel;
				ghost_four_x2 <= ghost_four_x2 + ghost_four_yvel;
			elsif ghost_four_x2 >= 640 then
				ghost_four_xvel <= -ghost_four_xvel;
				ghost_four_x1 <= ghost_four_x1 - ghost_four_xvel;
				ghost_four_x2 <= ghost_four_x2 - ghost_four_xvel;
			end if;
		--------------packman movement--------------
			
			if up = '1' and dn = '0' and packman_y1 > topbar_y2 then --move left packman up
				
				--if lpad_y1 > topbar_y2 then --check if not colliding
					packman_y1 <= packman_y1 - packman_yvel;
					packman_y2 <= packman_y2 - packman_yvel;
				--end if;
				
			elsif up = '0' and dn = '1' and packman_y2 < botbar_y1 then --move left packman down
			
				--if lpad_y2 < botbar_y1 then --check if not colliding
					packman_y1 <= packman_y1 + packman_yvel;
					packman_y2 <= packman_y2 + packman_yvel;
				--end if;
				
			end if;
			if lft = '1' and rth = '0' and packman_x1 > 1 then --and packman_y1 > topbar_y2 then --move left packman left
				
				--if lpad_y1 > topbar_y2 then --check if not colliding
					packman_x1 <= packman_x1 - packman_xvel;
					packman_x2 <= packman_x2 - packman_xvel;
				--end if;
				
			elsif lft = '0' and rth = '1' and packman_x2<640 then --and packman_y2 < botbar_y1 then --move left packman right
			
				--if lpad_y2 < botbar_y1 then --check if not colliding
					packman_x1 <= packman_x1 + packman_xvel;
					packman_x2 <= packman_x2 + packman_xvel;
				--end if;
				
			end if;
			--------------------check if packman takes point----------------------
			if (packman_x1<=point_x1 and point_x2 <= packman_x2 and packman_y1<=point_y1 and point_y2 <= packman_y2) then
				point_x1 <= ghost_four_x1;
				point_x2 <= ghost_four_x2;
				point_y1 <= ghost_four_y1;
				point_y2 <= ghost_four_y2;
				score0<=score0+1;
				if score0=9 then
					score0<=0;
					score1<=score1+1;
					if score1=9 then
						score1<=0;
						score2<=score2+1;
						if score2=9 then
							score2<=0;
							score3<=score3+1;
							if score3=9 then
								score3<=0;
								score4<=score4+1;
								if score4=9 then
									score4<=0;
									score5<=score5+1;
									if score5=9 then
										score5<=0;
										score6<=score6+1;
										if score6=9 then
											score6<=0;
											score7<=score7+1;
										end if; 
									end if; 
								end if; 
							end if; 
						end if; 
					end if; 
				end if; 
				
			end if;
			--------------check packman collision with the ghost--------------
			--if (packman_x1<ghost_one_x2 and packman_y1<ghost_one_y2 and packman_y2 > ghost_one_y2)then
			if (packman_x1<ghost_one_x1 and ghost_one_x2 < packman_x2 and packman_y1<ghost_one_y1 and ghost_one_y2 < packman_y2)
			or (packman_x1<ghost_two_x1 and ghost_two_x2 < packman_x2 and packman_y1<ghost_two_y1 and ghost_two_y2 < packman_y2)
			or (packman_x1<ghost_three_x1 and ghost_three_x2 < packman_x2 and packman_y1<ghost_three_y1 and ghost_three_y2 < packman_y2)
			or (packman_x1<ghost_four_x1 and ghost_four_x2 < packman_x2 and packman_y1<ghost_four_y1 and ghost_four_y2 < packman_y2)
			then
			--reset game
			---------------------------------------------
			ghost_one_x1 <= 0;
			ghost_one_x2 <= 10;
			ghost_one_y1 <= 240;
			ghost_one_y2 <= 250;
			ghost_one_yvel <= 1;
			ghost_one_xvel <= 1;
			---------------------------------------------
			---------------------------------------------
			ghost_two_x1 <= 0;
			ghost_two_x2 <= 10;
			ghost_two_y1 <= 150;
			ghost_two_y2 <= 160;
			ghost_two_yvel <= 2;
			ghost_two_xvel <= 2;
			---------------------------------------------
			---------------------------------------------
			ghost_three_x1 <= 0;
			ghost_three_x2 <= 10;
			ghost_three_y1 <= 170;
			ghost_three_y2 <= 180;
			ghost_three_yvel <= 3;
			ghost_three_xvel <= 3;
			---------------------------------------------
			---------------------------------------------
			ghost_four_x1 <= 0;
			ghost_four_x2 <= 10;
			ghost_four_y1 <= 190;
			ghost_four_y2 <= 200;
			ghost_four_yvel <= 4;
			ghost_four_xvel <= 4;
			---------------------------------------------
			---------------------------------------------
			packman_x1 <= 585;
			packman_x2 <= 615;
			packman_y1 <= 225;
			packman_y2 <= 255;
			packman_yvel <= 2;
			packman_xvel <= 2;
			---------------------------------------------
			--decrease live
			lives<=lives-1;
			end if;
	end if;
end process;

END a;