library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity clock1Khz is
    port (
        clk : in std_logic;
        clk_1Khz : out std_logic
    );
end clock1Khz;
architecture C of clock1Khz is
    signal c1: std_logic_vector(9 downto 0) := "0000000000";
    signal c2: std_logic_vector(9 downto 0) := "0000000000";
begin
    process (clk) begin
        if (rising_edge(clk)) then
            c1 <= c1 + 1;
            if (c1 = "1111100111") then -- (c1 =1000)
                c1 <= "0000000000";
                c2 <= c2 + 1;
                if (c2 = "0000110010") then -- (c2 = 50)
                    c2 <= "0000000000";
                    if (clk_1Khz = 0) then
                        clk_1Khz <= 1;
                    elsif (clk_1hz = 1) then
                        clk_1Khz <= 0;
                    end if;  
                end if;
            end if;    
        end if;
    end process; 
end C ;

entity segmentdecoder is
    port (
        d : in std_logic_vector(3 downto 0);
        cd : out std_logic_vector(6 downto 0) 
    );
end segmentdecoder;
architecture decoder of segmentdecoder is 
begin
    process(d)
        begin
            case( d ) is
                when "0000" => cd <= "1111110" ;
                when "0001" => cd <= "1001111" ;
                when "0010" => cd <= "0010010" ;   
                when "0011" => cd <= "0000110" ;
                when "0100" => cd <= "1001100" ;
                when "0101" => cd <= "0100100" ;
                when "0110" => cd <= "0100000" ;
                when "0111" => cd <= "0001111" ;
                when "1000" => cd <= "0000000" ;
                when "1001" => cd <= "0000100" ;              
            end case ;
    end process;
end decoder;

entity sevensegment is
    port (
        clk_1Khz : in std_logic;
        clk_1hz : in std_logic;
        d1,d2,d3,d4 : in std_logic_vector(3 downto 0);
        p1, p2: in std_logic;
        an : out std_logic_vector(3 downto 0);
        d : out std_logic_vector(3 downto 0);
        dp : out std_logic_vector(1 downto 0) 
    );
end sevensegment;

architecture B of sevensegment is
    type state_type is (S1, S2, S3, S4);
    signal state: state_type := S1;
    signal dp_: std_logic_vector(1 downto 0);
    signal c1: std_logic_vector(9 downto 0) := "0000000000";
    signal c2: std_logic_vector(9 downto 0) := "0000000000";

begin
    process (clk_1hz)
        if (rising_edge(clk_1hz))
            if (p1=1 and p2=1)
                if (dp_ = "00") then
                    dp_ <= "11";
                    dp <= "11";
                else 
                    dp_ <= "00" ;
                    dp <= "00" ;
                end if ;
            elsif (p1 = 1) then
                if (dp_ = "10") then
                    dp_ <= "11";
                    dp <= "11";
                else 
                    dp_ <= "10" ;
                    dp <= "10" ;
                end if ;
            else
                if (dp_ = "01") then
                    dp_ <= "11";
                    dp <= "11";
                else 
                    dp_ <= "01" ;
                    dp <= "01" ;
                end if;
            end if;    
        end if;
    end process;
    
    process (clk_1Khz)
        if (rising_edge(clk_1Khz) )
            case( state ) is
                when S1 =>
                    state <= S2;
                    an <= "1000";
                    d <= d1;
                when S2 =>
                    state <= S3;
                    an <= "0100";
                    d <= d2;
                when S3 =>
                    state <= S4;
                    an <= "0010";
                    d <= d3;
                when S4 =>
                    state <= S1;
                    an <= "0001"
                    d <= d4;
            end case ;
        end if;
    end process;
end B ;

entity Bin2BCD is
    Port ( 
        bin : in  std_logic_vector (5 downto 0);
        bcd1 : out  std_logic_vector (3 downto 0);
        bcd2 : out  std_logic_vector (3 downto 0)
    );   
end Bin2BCD;

architecture D of Bin2BCD is
    signal temp : std_logic_vector(5 downto 0);
    signal bcd : unsigned(8 downto 0);
begin
    process(bin)
        bcd <= "00000000";
        temp <= unsigned(bin);
        for i in 0 to 5 loop
            if bcd(7 downto 4) > 4 then 
                bcd(7 downto 4) := bcd(7 downto 4) + "0011";
            end if;
            if bcd(3 downto 0) >= 5 then 
                bcd(3 downto 0) <= bcd(3 downto 0) + "0011";
            end if; 
            bcd <= bcd(6 downto 0) & temp(5);
            temp <= temp(10 downto 0) & '0';
        end loop;
        bcd2 <= std_logic_vector(bcd(3 downto 0));
        bcd1 <= std_logic_vector(bcd(7 downto 4));
    end process ;            
  
end D;

entity main is
    port (
        clk : in std_logic;
        clk_1Khz: in std_logic;
        en, sw, up, dn : in std_logic;
        d1, d2, d3, d4: out std_logic_vector(3 downto 0);
        p1, p2, clk_1hz: out std_logic
    );
end main;
architecture A of main is
    signal h1,h2,m1,m2,s1,s2 : std_logic_vector(3 downto 0);
    type state_type is (S1, S2, S3, S4);
    signal state: state_type ;
    signal h: std_logic_vector(5 downto 0) := "000000";
    signal m: std_logic_vector(5 downto 0) := "000000";
    signal s: std_logic_vector(5 downto 0) := "000000";
    signal temp: std_logic  := 0;
    signal c1: std_logic_vector(9 downto 0) := "0000000000";
    signal c2: std_logic_vector(9 downto 0) := "0000000000";
    signal c3: std_logic_vector(9 downto 0) := "0000000000";
    signal count1,count2,count3,count4 : std_logic_vector(10 downto 0);
    component Bin2BCD port (bin : in  std_logic_vector (5 downto 0); 
                            bcd1 : out  std_logic_vector (3 downto 0);bcd2 : out  std_logic_vector (3 downto 0));
    end component;                        
begin
    process (clk) begin
        if (rising_edge(clk)) then
            c1 <= c1 + 1;
            if (c1 = "1111100111") then -- (c1 =1000)
                c1 <= "0000000000";
                c2 <= c2 + 1;
                if (c2 = "1111100111") then -- (c2 = 1000)
                    c2 <= "0000000000";
                    c3 <= c3 + 1;
                    if (c3 = "0000110010") then -- (c3 = 50)
                        c3 <= "0000000000";
                        if (temp = 0) then
                            temp <= 1;
                            clk_1hz <= temp;
                        elsif (temp = 1) then
                            temp <= 0;
                            clk_1hz <= temp;
                        end if;
                    end if;    
                end if;
            end if;    
        end if;
    end process;   
    
    process(clk_1Khz) begin
        if (rising_edge(clk_1Khz) then
            if (en = 0) then
                count3 <= 0;
            else
                count3 <= count3 +1;
            end if ;
            if (sw = 0) then
                count4 <=0;
            else
                count4 <= count4 +1;
            end if ;
            if (count3 = "0111110100") then
                case (state) is
                    when S1 => state <=S3;
                    when S2 => state <=S3;
                    when S3 => state <=S1;
                    when S4 => state <=S1;
                end case;
            elsif (count4 = "0111110100") then
                case (state) is
                    when S1 => state <=S2;
                    when S2 => state <=S1;
                    when S3 => state <=S4;
                    when S4 => state <=S3;
                end case;
            end if ;
        end if ;
    end process ;

    process(clk_1Khz) begin
        if (rising_edge(clk_1Khz)) then
            if (up = 0) then
                count1 <= 0;
            end if ;
            if (down = 0) then
                count2 <= 0;
            end if ;
            case( state ) is
                when S3 =>
                    if (up = 1) then
                        count1 <= count1 + 1;
                        if (count1 = "00011111010") then
                            if (m = "111011") then
                                m <= 0;
                            else
                                m <= m + 1;
                            end if;
                        end if ;
                        if (count1 = "10011100010") then
                            count1 <= "01111101000";
                            if (m = "111011") then
                                m <= 0;
                            else
                                m <= m + 1;
                            end if;
                        end if;
                    elsif (dn = 1) then
                        count2 <= count2 + 1;
                        if (count2 = "00011111010") then
                            if (m = "000000") then
                                m <= "111011";
                            else
                                m <= m - 1;
                            end if;
                        end if ;
                        if (count2 = "10011100010") then
                            count2 <= "01111101000";
                            if (m = "000000") then
                                m <= "111011";
                            else
                                m <= m - 1;
                            end if;
                        end if ;
                    end if ;    
                when S4 =>
                if (up = 1) then
                    count1 <= count1 + 1;
                    if (count1 = "00111110100") then
                        if (h = "010111") then
                            h <= 0;
                        else
                            h <= h + 1;
                        end if;
                    end if ;
                    if (count1 = "10011100010") then
                        count1 <= "01111101000";
                        if (h = "010111") then
                            h <= 0;
                        else
                            h <= h + 1;
                        end if;
                    end if ;
                elsif (dn = 1) then
                    count2 <= count2 + 1;
                    if (count2 = "0111110100") then
                        if (h = "000000") then
                            h <= "010111";
                        else
                            h <= h - 1;
                        end if;
                    end if ;
                    if (count2 = "10011100010") then
                        count2 <= "01111101000";
                        if (h = "000000") then
                            h <= "010111";
                        else
                            h <= h - 1;
                        end if;
                    end if ;
                end if ;   
                when others =>           
            end case ;
        end if ;
    end process;

    process(temp) begin
        if (rising_edge(temp)) then
            if (s = "111011") then
                s <= "000000";
                if (m = "111011") then
                    m <= "000000";
                    if (h = "010111") then
                        h <= "000000";
                    else
                        h <= h+1;    
                    end if ;
                else
                    m <= m+1;
                end if ;
            else
                s <= s+1;
            end if ;    
        end if ;
    end process;
    
    hour: Bin2BCD port map(bin => h, bcd1 => h1, bcd2 =>h2);
    min: Bin2BCD port map(bin => m, bcd1 => m1, bcd2 =>m2); 
    sec: Bin2BCD port map(bin => s, bcd1 => s1, bcd2 =>s2);
    
    process(clk) begin    
        case( state ) is
            when S1 =>
                d1 <= h1; d2 <= h2; d3 <= m1; d4 <= m2; 
                p1 <= 1;p2 <= 1;
            when S2 =>
                d1 <= m1; d2 <= m2; d3 <= s1; d4 <= s2;
                p1 <= 1; p2 <= 1;
            when S3 =>
                d1 <= h1; d2 <= h2; d3 <= m1; d4 <= m2; 
                p1 <= 0; p2 <= 1;
            when S4 =>
                d1 <= h1; d2 <= h2; d3 <= m1; d4 <= m2; 
                p1 <= 1; p2 <= 0;
        end case ;
    end process;
end A;

entity final is
    port (
        clk: in std_logic ;
        en: in std_logic ;
        sw: in std_logic ;
        up: in std_logic ;
        dn: in std_logic ;
        an: out std_logic_vector(3 downto 0);
        cd: out std_logic_vector(6 downto 0);
        dp: out std_logic_vector(1 downto 0)
    );
end final;
architecture final of final is
    signal d1,d2,d3,d4,d : std_logic_vector(3 downto 0);
    signal p1, p2, clk_1Khz, clk_1hz: std_logic;
    
    component clock1Khz port (clk : in std_logic;clk_1Khz : out std_logic );
    end component;
    
    component main port (
        clk : in std_logic;
        clk_1Khz: in std_logic;
        en, sw, up, dn : in std_logic;
        d1, d2, d3, d4: out std_logic_vector(3 downto 0);
        p1, p2, clk_1hz: out std_logic
    );
    end component;
    
    component sevensegment port (
        clk_1Khz : in std_logic;
        clk_1hz : in std_logic;
        d1,d2,d3,d4 : in std_logic_vector(3 downto 0);
        p1, p2: in std_logic;
        an : out std_logic_vector(3 downto 0);
        d : out std_logic_vector(3 downto 0);
        dp : out std_logic_vector(1 downto 0) 
    );    
    end component;
    
    component segmentdecoder port (d : in std_logic_vector(3 downto 0); cd : out std_logic_vector(6 downto 0) );
    end component;

begin
    f1: clock1Khz port map (clk => clk, clk_1Khz => clk_1Khz);
    
    f2: main port map(clk => clk, clk_1Khz => clk_1Khz, en=> en, sw=>sw, up=>up, dn=>dn
                 d1=>d1, d2=>d2, d3=>d3, d4=>d4, p1=>p1, p2=>p2, clk_1hz=>clk_1hz );
                 
    f3: sevensegment port map(clk_1Khz => clk_1Khz, clk_1hz=>clk_1hz, d1=>d1, d2=>d2, d3=>d3, d4=>d4, p1=>p1, p2=>p2,
                         an => an, d=>d, dp=>dp);
    
    f4: segmentdecoder port map(d => d, cd =>cd);
end final ; 