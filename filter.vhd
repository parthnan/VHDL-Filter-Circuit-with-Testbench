library ieee;  
use ieee.std_logic_1164.all;  
use ieee.std_logic_unsigned.all;  

entity filter is 
generic(N: integer := 32;
		K: integer := 4;
		W: integer := 3); 
  port(CLOCK_50, RESET_N: in std_logic;
	   q:out std_logic_vector(19 downto 0);
	   KEY: in std_logic_vector(3 downto 0);
	   SW: in std_logic_vector(9 downto 0);
	   LEDR: out std_logic_vector (9 downto 0);
       HEX0, HEX1, HEX2, HEX3, HEX4, HEX5: out std_logic_vector(6 downto 0));
end filter;  
  
architecture rtl of filter is
  type state_type is (s0, s1, s2, s3, s4, s5);
  signal din, sout: std_logic_vector(3 downto 0);
  signal dout,filterout: std_logic_vector(19 downto 0);
  signal press, start, we, clk, xrst: std_logic;
  signal state: state_type;
  signal wadr: std_logic_vector (2 downto 0);
  signal i: integer range 0 to 20;

  component ram_WxK
  generic(K: integer;
		  W: integer);
  port(clk: in std_logic;
	   din: in std_logic_vector (K-1 downto 0);
	   wadr: in std_logic_vector (W-1 downto 0);
	   we: in std_logic;
	   dout1: out std_logic_vector (K-1 downto 0);
	   dout2: out std_logic_vector (K-1 downto 0);
	   dout3: out std_logic_vector (K-1 downto 0);
	   dout4: out std_logic_vector (K-1 downto 0);
	   dout5: out std_logic_vector (K-1 downto 0));
  end component;

  component seven_seg_decoder is
  port(clk: in std_logic;
	   xrst: in std_logic;
	   din: in  std_logic_vector(3 downto 0);
	   dout: out std_logic_vector(6 downto 0));
  end component;

begin

	clk <= CLOCK_50;
	xrst <= RESET_N;
	din <= SW(3 downto 0);
	we <= not KEY(2);
	q<=filterout;

	ram1: ram_WxK generic map(K => K, W => W) port map(clk => clk, din => din, wadr => WADR, we => we, dout1 => dout(19 downto 16), dout2 => dout(15 downto 12), dout3 => dout(11 downto 8), dout4 => dout(7 downto 4), dout5 => dout(3 downto 0));
	ssd0: seven_seg_decoder port map(clk => CLOCK_50, xrst => RESET_N, din => filterout(3 downto 0), dout => HEX0);
	ssd1: seven_seg_decoder port map(clk => CLOCK_50, xrst => RESET_N, din => filterout(7 downto 4), dout => HEX1);
	ssd2: seven_seg_decoder port map(clk => CLOCK_50, xrst => RESET_N, din => filterout(11 downto 8), dout => HEX2);
	ssd3: seven_seg_decoder port map(clk => CLOCK_50, xrst => RESET_N, din => filterout(15 downto 12), dout => HEX3);
	ssd4: seven_seg_decoder port map(clk => CLOCK_50, xrst => RESET_N, din => filterout(19 downto 16), dout => HEX4);
	ssd5: seven_seg_decoder port map(clk => CLOCK_50, xrst => RESET_N, din => din, dout => HEX5);

process(state,clk,xrst)
begin
if(xrst='0') then 
	state <=s0;
	WADR<="000";
	press <='0';
	start <='0';
	i <=0;
	sout<="0000";
	filterout<="00000000000000000000";

elsif(clk' event and clk = '1')then
 case state is

	when s0 =>
	i <=0;
	sout<="0000";
	if(SW(9)='0' and SW(8)='1') then
		if(KEY(3)='0' and press='0') then
			press<='1';
			if(WADR="100") then
				WADR<="000";
			else 
				WADR<=WADR+"001";
			end if;
		elsif(KEY(3)='1' and press='1') then
			press<='0';
		end if;
	elsif(SW(9)='1' and SW(8)='1' and KEY(0)='0' and start='0') then
			filterout<=dout;
			start<='1';
    elsif(SW(9)='1' and SW(8)='1' and KEY(0)='1' and start='1') then
			state<=s1;
			filterout<="00000000000000000000";
			start<='0';
    end if;
		
	when s1 =>
	sout<="0001";
	if(dout(19-i)='0') then
		filterout(19-i)<='0';
		state<=s1;
	elsif(dout(19-i)='1') then
		filterout(19-i)<='0';
		state<=s2;
	end if;
	if(i=19) then
		state<=s5;
	end if;
	i<=i+1;
	
		
	when s2 =>
	sout<="0010";
	if(dout(19-i)='0') then
		filterout(19-i)<='0';
		state<=s1;
	elsif(dout(19-i)='1') then
		filterout(19-i)<='1';
		state<=s3;
	end if;
	if(i=19) then
		state<=s5;
	end if;
	i<=i+1;
		  
   	when s3 =>
   	sout<="0011";
	if(dout(19-i)='0') then
		filterout(19-i)<='0';
		state<=s2;
	elsif(dout(19-i)='1') then
		filterout(19-i)<='1';
		state<=s4;
	end if;
	if(i=19) then
		state<=s5;
	end if;
	i<=i+1;
		  
	when s4 =>
	sout<="0100";
	if(dout(19-i)='0') then
		filterout(19-i)<='1';
		state<=s3;
	elsif(dout(19-i)='1') then
		filterout(19-i)<='1';
		state<=s4;
	end if;
	if(i=19) then
		state<=s5;
	end if;
	i<=i+1;

	when s5 =>
	WADR<="000";
	state<=s0;

	when others =>
		state<=state;
	end case;
end if;
end process;
end rtl;
  
