--------------------------------------------------------------------------------
--
-- LAB #3
-- Chetan Grewal
--
--------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity bitstorage is
	port(bitin: in std_logic;
		 enout: in std_logic;
		 writein: in std_logic;
		 bitout: out std_logic);
end entity bitstorage;

architecture memlike of bitstorage is
	signal q: std_logic := '0';
begin
	process(writein) is
	begin
		if (rising_edge(writein)) then
			q <= bitin;
		end if;
	end process;
	
	-- Note that data is output only when enout = 0	
	bitout <= q when enout = '0' else 'Z';
end architecture memlike;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity fulladder is
    port (a : in std_logic;
          b : in std_logic;
          cin : in std_logic;
          sum : out std_logic;
          carry : out std_logic
         );
end fulladder;

architecture addlike of fulladder is
begin
  sum   <= a xor b xor cin; 
  carry <= (a and b) or (a and cin) or (b and cin); 
end architecture addlike;


--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register8 is
	port(datain: in std_logic_vector(7 downto 0);
	     enout:  in std_logic;
	     writein: in std_logic;
	     dataout: out std_logic_vector(7 downto 0));
end entity register8;

architecture memmy of register8 is
	component bitstorage
		port(bitin: in std_logic;
		 	 enout: in std_logic;
		 	 writein: in std_logic;
		 	 bitout: out std_logic);
	end component;
begin
	-- insert code here

	R0: bitstorage port map(datain(0), enout, writein, dataout(0));
	R1: bitstorage port map(datain(1), enout, writein, dataout(1));
	R2: bitstorage port map(datain(2), enout, writein, dataout(2));
	R3: bitstorage port map(datain(3), enout, writein, dataout(3));
	R4: bitstorage port map(datain(4), enout, writein, dataout(4));
	R5: bitstorage port map(datain(5), enout, writein, dataout(5));
	R6: bitstorage port map(datain(6), enout, writein, dataout(6));
	R7: bitstorage port map(datain(7), enout, writein, dataout(7));

end architecture memmy;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register32 is
	port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
end entity register32;

architecture biggermem of register32 is

	-- hint: you'll want to put register8 as a component here 
	-- so you can use it below
	component register8
		port(	datain: in std_logic_vector(7 downto 0);
				enout: in std_logic;
				writein: in std_logic;
				dataout: out std_logic_vector(7 downto 0));
	end component;

	signal enable8, enable16, write8, write16: std_logic;

begin
	-- insert code here.

	write8 <= writein32 OR writein16 OR writein8;
	write16 <= writein32 OR writein16;

	enable8 <= enout32 AND enout16 AND enout8;
	enable16 <= enout32 AND enout16;

	r0: register8 port map (datain(7 downto 0), enable8, write8, dataout(7 downto 0));
	r1: register8 port map (datain(15 downto 8), enable16, write16, dataout(15 downto 8));
	r2: register8 port map (datain(23 downto 16), enout32, writein32, dataout(23 downto 16));
	r3: register8 port map (datain(31 downto 24), enout32, writein32, dataout(31 downto 24)); 

end architecture biggermem;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity adder_subtracter is
	port(	datain_a: in std_logic_vector(31 downto 0);
		datain_b: in std_logic_vector(31 downto 0);
		add_sub: in std_logic;
		dataout: out std_logic_vector(31 downto 0);
		co: out std_logic);
end entity adder_subtracter;

architecture calc of adder_subtracter is

	component fulladder
		port(	a: in std_logic;
		  		b: in std_logic;
		  		cin: in std_logic;
		  		sum: out std_logic;
		  		carry: out std_logic);
	end component;

	signal c: std_logic_vector (32 downto 0); -- carry
	signal b: std_logic_vector (31 downto 0);

begin
	-- insert code here.

	WITH add_sub SELECT 
	b <= 	NOT (datain_b) WHEN '1',
		   	datain_b WHEN OTHERS;
	c(0)<= 	add_sub;
	co <= 	c(32);

	FULLADD: FOR i in 0 to 31 GENERATE
		FA: fulladder PORT MAP (datain_a(i), b(i), c(i), dataout(i), c(i+1));
	end GENERATE;

end architecture calc;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity shift_register is
	port(	datain: in std_logic_vector(31 downto 0);
	   	dir: in std_logic;
		shamt:	in std_logic_vector(4 downto 0);
		dataout: out std_logic_vector(31 downto 0));
end entity shift_register;

architecture shifter of shift_register is
	
begin

	-- insert code here.
	with dir & shamt select
	dataout <= 		
				--Shift Left
				datain(30 downto 0) & '0'  	when "000010",
				datain(29 downto 0) & "00"	when "000100",
				datain(28 downto 0) & "000" when "000110",
				--Shift Right
				'0' & datain(31 downto 1)  		when "000011", --shift right by 1	
				"00" & datain(31 downto 2) 		when "000101", --shift right by 2
				"000" & datain(31 downto 3)		when "000111", --shift right by 3
				--other
				datain(31 downto 0) 			when others;

end architecture shifter;



