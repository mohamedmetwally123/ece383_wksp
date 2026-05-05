--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package graphicsParts is

	type sprite_status_t is record
	       row: unsigned(9 downto 0);
	       col: unsigned(9 downto 0);
	       --added stuff
	       sprite_type: std_logic_vector (5 downto 0);
	       active: std_logic;
	end record;

	type oneDarray is array(0 to 31) of sprite_status_t;
component graphics
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
  		   tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0));
end component;

component Flag_Register is
 Port ( clk: in std_logic;
        reset_n: in std_logic;
        set: in std_logic;
        clear: in std_logic;
        Q: out std_logic
        );
end component;
component graphics_fsm is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           fsmWrAddr: out std_logic_vector(4 downto 0);
           fsmSpriteStatus: out sprite_status_t;
           fsmWen : out std_logic;
           fsmAudio_type: out std_logic_vector (3 downto 0);
           fsmAudio_play_request: out std_logic;
           score: in unsigned(16 downto 0));
end component;

component graphics_datapath
    Port (
           clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);

           signal WrAddr: in std_logic_vector(4 downto 0);
           signal Wen: in std_logic;
           signal spriteStatus: in sprite_status_t;
           flagQ: out STD_LOGIC;
           flagClear: in STD_LOGIC;
           score: in unsigned(16 downto 0));
end component;


	component video is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           tmds : out  STD_LOGIC_VECTOR (3 downto 0);
           tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);
			  row: out unsigned(9 downto 0);
			  column: out unsigned(9 downto 0);
			  pixel_type : in  sprite_status_t;
			  ch1_enb: in std_logic;
			  ch2: in std_logic;
			  ch2_enb: in std_logic;
			  v_synch: out std_logic;
			  flagQ: out STD_LOGIC;
              flagClear: in STD_LOGIC;
              score: in unsigned(16 downto 0));
	end component;

  
  component NES_Controller is
  Port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        NES_data: in std_logic;
        NES_clk: out std_logic;
        NES_latch: out std_logic;
        NES_scan: out std_logic_vector(7 downto 0)
   );
   end component;
  component NES_Controller_datapath is
  Port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        NES_data: in std_logic;
        NES_clk: out std_logic;
        NES_latch: out std_logic;
        cw      : in std_logic_vector(7 downto 0);  -- control word
        sw      : out std_logic_vector(1 downto 0); -- status word   
        NES_scan: out std_logic_vector(7 downto 0)    
    );
    end component;
    
    component NES_Controller_cu is
    port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cw      : out std_logic_vector(7 downto 0);  -- control word
        sw      : in std_logic_vector(1 downto 0) -- status word
    );
    end component;
  component doodle_audio is
  Port (
           clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           Audio_type: in std_logic_vector (3 downto 0);
           Audio_play_request: in std_logic;
           ac_mclk : out STD_LOGIC;
           ac_adc_sdata : in STD_LOGIC;
           ac_dac_sdata : out STD_LOGIC;
           ac_bclk : out STD_LOGIC;
           ac_lrclk : out STD_LOGIC;
           scl : inout STD_LOGIC;
           sda : inout STD_LOGIC   
            );
  end component; 
  component doodle_audio_datapath is
    Port (
           clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           cw      : in std_logic_vector(1 downto 0);  -- control word
           sw      : out std_logic_vector(0 downto 0); -- status word
           Audio_type: in std_logic_vector (3 downto 0);
           data_out: out std_logic_vector(15 downto 0)
   );
   end component;
   
   component doodle_audio_cu is
    port (
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cw      : out std_logic_vector(1 downto 0);  -- control word
        sw      : in std_logic_vector(2 downto 0) -- status word
    );
    end component;

    component counter is
	generic (N: integer := 4);
	Port(	clk: in  STD_LOGIC;
			reset_n : in  STD_LOGIC;
			ctrl: in std_logic_vector(1 downto 0);
			D: in unsigned (N-1 downto 0);
			Q: out unsigned (N-1 downto 0));
    end component;
    
    component pixel_classifier is
    Port (row: in unsigned(9 downto 0);
          col: in unsigned(9 downto 0);
          sprite_status_array: in oneDarray;
          pixel_type: out sprite_status_t
          );
    end component;
    component read_from_bram is
    Port ( clk : in  STD_LOGIC;
         reset_n : in  STD_LOGIC;
         is_playing: in  STD_LOGIC;
         audio_type: in std_logic_vector (3 downto 0);
         sample_index: in unsigned(16 downto 0);
         data_out: out std_logic_vector(15 downto 0)
        );
      end component; 
constant doodle_BG      : std_logic_vector(2 downto 0) := "000";
constant doodle_outline : std_logic_vector(2 downto 0) := "001";
constant doodle_body    : std_logic_vector(2 downto 0) := "010";
constant doodle_light   : std_logic_vector(2 downto 0) := "011";
constant doodle_stripe  : std_logic_vector(2 downto 0) := "100";
type doodle_sprite_sym_t is array (0 to 39) of string(0 to 39);

constant doodle_right : doodle_sprite_sym_t := (
    "........................................", -- visual row 04
    ".........########.......................", -- visual row 05
    "........##SSSSS####.....................", -- visual row 06
    ".......#SLBBBBBBSS##....................", -- visual row 07
    ".....##BLBBBBBBBBBS##...................", -- visual row 08
    "....#SLLBBBBBBLLLBBS##..................", -- visual row 09
    "....#LLBBBBBBBLLLBBBS##.................", -- visual row 10
    "...#LLBBBBBBBBBBBLBBBS#.................", -- visual row 11
    "..#SLLBBBBBBBBLLLLLBBBS#................", -- visual row 12
    "..#LLBBBBBBLLLLLLLLBBBS##...............", -- visual row 13
    ".#SLBBBBBBBLLLLLLLLLBBBS#...............", -- visual row 14
    ".#SBBBBBBBBBLLLBBBSLLSBS##..............", -- visual row 15
    ".#LBBBBBBBBBBLLLBS#BL#SBS#.........LSS..", -- visual row 16
    ".#LLBBBBBBBBBLLLBS#BL#SBS###......####..", -- visual row 17
    ".#LLBBLLBBBLLLLBBBBBBBLLLBS###########..", -- visual row 18
    ".#LBBBLLLBBLLLLLLLLBBLLLLBBBSSSSSS#SB#..", -- visual row 19
    ".#LBBBLLLLBBLLLLLLLLLBBBBBBBLLBBBB#SB##.", -- visual row 20
    ".#LBBBBLLLLBBBBBBBBBBBBBBBBBSSSBLL#SBS#.", -- visual row 21
    ".#LBBBLLLLBBBBBBBBBBBBBBBS#######S##LS#.", -- visual row 22
    ".#LLBBBBBBBBBBBBBBBBBBBBS##.....####S##.", -- visual row 23
    ".#LLLBLBBBBBBBBBBBBBBLLB###........###..", -- visual row 24
    ".#SLLBLLBBBBLLLLLBBBBLLS##..............", -- visual row 25
    ".##SSSSSSSSSSSSSSSSSSSS###..............", -- visual row 26
    ".#########################..............", -- visual row 27
    ".#SSSSSSSSSSSSSSSSSSSSSSS#..............", -- visual row 28
    ".#SSSSSSSSSSSSSSSSSSSSSSS#..............", -- visual row 29
    ".#SSSSSSSSSSSSSSSSSSSSSSS#..............", -- visual row 30
    ".#########################..............", -- visual row 31
    ".#SSSSSSSSSLLLLLLSSSSSSSS#..............", -- visual row 32
    ".#SLLLLLLLLLLLLLLLLLLSSSS#..............", -- visual row 33
    ".#SSSSSSSSSSSSSSSSSSSSSSS#..............", -- visual row 34
    ".#########################..............", -- visual row 35
    ".#SSLSSSSSSSSSSSSSSSSSSS##..............", -- visual row 36
    ".#########################..............", -- visual row 37
    "....##....##...##....##.................", -- visual row 38
    "....##....##...##....##.................", -- visual row 39
    "....##....##...##....##.................", -- visual row 40
    "....##....##...##....###................", -- visual row 41
    "....####..####.####..####...............", -- visual row 42
    "....####..####.####..####..............."  -- visual row 43
);

function doodle_sym_to_pix(c : character)
    return std_logic_vector;
	
function play_again_sym_to_pixel(ch : character) 
    return std_logic_vector;

type wide_tile_t is array (0 to 7, 0 to 47) of std_logic_vector(1 downto 0);

    constant greenPlatform_BG      : std_logic_vector(1 downto 0) := "00";
    constant greenPlatform_OUTLINE : std_logic_vector(1 downto 0) := "01";
    constant greenPlatform_GREEN  : std_logic_vector(1 downto 0) := "10";
    constant greenPlatform_LIGHT   : std_logic_vector(1 downto 0) := "11";
    
    constant bluePlatform_BG      : std_logic_vector(1 downto 0) := "00";
    constant bluePlatform_OUTLINE : std_logic_vector(1 downto 0) := "01";
    constant bluePlatform_BLUE    : std_logic_vector(1 downto 0) := "10";
    constant bluePlatform_LIGHT   : std_logic_vector(1 downto 0) := "11";
    
    constant doodle_width: integer:= 39;
    constant platform_width: integer := 47;
     constant platform_height: integer:= 7;
     constant doodle_height: integer:= 39;
     constant spring_width: integer:= 7; 
     constant spring_height: integer:= 5;    
    
constant platform_full_tile : wide_tile_t := (
    0 => (
        0  => greenPlatform_BG,      1  => greenPlatform_BG,      2  => greenPlatform_OUTLINE, 3  => greenPlatform_OUTLINE,
        4  => greenPlatform_OUTLINE, 5  => greenPlatform_OUTLINE, 6  => greenPlatform_OUTLINE, 7  => greenPlatform_OUTLINE,

        8  => greenPlatform_OUTLINE, 9  => greenPlatform_OUTLINE, 10 => greenPlatform_OUTLINE, 11 => greenPlatform_OUTLINE,
        12 => greenPlatform_OUTLINE, 13 => greenPlatform_OUTLINE, 14 => greenPlatform_OUTLINE, 15 => greenPlatform_OUTLINE,

        16 => greenPlatform_OUTLINE, 17 => greenPlatform_OUTLINE, 18 => greenPlatform_OUTLINE, 19 => greenPlatform_OUTLINE,
        20 => greenPlatform_OUTLINE, 21 => greenPlatform_OUTLINE, 22 => greenPlatform_OUTLINE, 23 => greenPlatform_OUTLINE,

        24 => greenPlatform_OUTLINE, 25 => greenPlatform_OUTLINE, 26 => greenPlatform_OUTLINE, 27 => greenPlatform_OUTLINE,
        28 => greenPlatform_OUTLINE, 29 => greenPlatform_OUTLINE, 30 => greenPlatform_OUTLINE, 31 => greenPlatform_OUTLINE,

        32 => greenPlatform_OUTLINE, 33 => greenPlatform_OUTLINE, 34 => greenPlatform_OUTLINE, 35 => greenPlatform_OUTLINE,
        36 => greenPlatform_OUTLINE, 37 => greenPlatform_OUTLINE, 38 => greenPlatform_OUTLINE, 39 => greenPlatform_OUTLINE,

        40 => greenPlatform_OUTLINE, 41 => greenPlatform_OUTLINE, 42 => greenPlatform_OUTLINE, 43 => greenPlatform_OUTLINE,
        44 => greenPlatform_OUTLINE, 45 => greenPlatform_OUTLINE, 46 => greenPlatform_BG,      47 => greenPlatform_BG
    ),

    1 => (
        0  => greenPlatform_BG,      1  => greenPlatform_OUTLINE, 2  => greenPlatform_LIGHT,   3  => greenPlatform_LIGHT,
        4  => greenPlatform_LIGHT,   5  => greenPlatform_LIGHT,   6  => greenPlatform_LIGHT,   7  => greenPlatform_LIGHT,

        8  => greenPlatform_LIGHT,   9  => greenPlatform_LIGHT,   10 => greenPlatform_LIGHT,   11 => greenPlatform_LIGHT,
        12 => greenPlatform_LIGHT,   13 => greenPlatform_LIGHT,   14 => greenPlatform_LIGHT,   15 => greenPlatform_LIGHT,

        16 => greenPlatform_LIGHT,   17 => greenPlatform_LIGHT,   18 => greenPlatform_LIGHT,   19 => greenPlatform_LIGHT,
        20 => greenPlatform_LIGHT,   21 => greenPlatform_LIGHT,   22 => greenPlatform_LIGHT,   23 => greenPlatform_LIGHT,

        24 => greenPlatform_LIGHT,   25 => greenPlatform_LIGHT,   26 => greenPlatform_LIGHT,   27 => greenPlatform_LIGHT,
        28 => greenPlatform_LIGHT,   29 => greenPlatform_LIGHT,   30 => greenPlatform_LIGHT,   31 => greenPlatform_LIGHT,

        32 => greenPlatform_LIGHT,   33 => greenPlatform_LIGHT,   34 => greenPlatform_LIGHT,   35 => greenPlatform_LIGHT,
        36 => greenPlatform_LIGHT,   37 => greenPlatform_LIGHT,   38 => greenPlatform_LIGHT,   39 => greenPlatform_LIGHT,

        40 => greenPlatform_LIGHT,   41 => greenPlatform_LIGHT,   42 => greenPlatform_LIGHT,   43 => greenPlatform_LIGHT,
        44 => greenPlatform_LIGHT,   45 => greenPlatform_LIGHT,   46 => greenPlatform_OUTLINE, 47 => greenPlatform_BG
    ),

    2 => (
        0  => greenPlatform_OUTLINE, 1  => greenPlatform_LIGHT,   2  => greenPlatform_GREEN,   3  => greenPlatform_GREEN,
        4  => greenPlatform_GREEN,   5  => greenPlatform_GREEN,   6  => greenPlatform_GREEN,   7  => greenPlatform_GREEN,

        8  => greenPlatform_GREEN,   9  => greenPlatform_GREEN,   10 => greenPlatform_GREEN,   11 => greenPlatform_GREEN,
        12 => greenPlatform_GREEN,   13 => greenPlatform_GREEN,   14 => greenPlatform_GREEN,   15 => greenPlatform_GREEN,

        16 => greenPlatform_GREEN,   17 => greenPlatform_GREEN,   18 => greenPlatform_GREEN,   19 => greenPlatform_GREEN,
        20 => greenPlatform_GREEN,   21 => greenPlatform_GREEN,   22 => greenPlatform_GREEN,   23 => greenPlatform_GREEN,

        24 => greenPlatform_GREEN,   25 => greenPlatform_GREEN,   26 => greenPlatform_GREEN,   27 => greenPlatform_GREEN,
        28 => greenPlatform_GREEN,   29 => greenPlatform_GREEN,   30 => greenPlatform_GREEN,   31 => greenPlatform_GREEN,

        32 => greenPlatform_GREEN,   33 => greenPlatform_GREEN,   34 => greenPlatform_GREEN,   35 => greenPlatform_GREEN,
        36 => greenPlatform_GREEN,   37 => greenPlatform_GREEN,   38 => greenPlatform_GREEN,   39 => greenPlatform_GREEN,

        40 => greenPlatform_GREEN,   41 => greenPlatform_GREEN,   42 => greenPlatform_GREEN,   43 => greenPlatform_GREEN,
        44 => greenPlatform_GREEN,   45 => greenPlatform_GREEN,   46 => greenPlatform_LIGHT,   47 => greenPlatform_OUTLINE
    ),

    3 => (
        0  => greenPlatform_OUTLINE, 1  => greenPlatform_GREEN,   2  => greenPlatform_GREEN,   3  => greenPlatform_GREEN,
        4  => greenPlatform_GREEN,   5  => greenPlatform_GREEN,   6  => greenPlatform_GREEN,   7  => greenPlatform_GREEN,

        8  => greenPlatform_GREEN,   9  => greenPlatform_GREEN,   10 => greenPlatform_GREEN,   11 => greenPlatform_GREEN,
        12 => greenPlatform_GREEN,   13 => greenPlatform_GREEN,   14 => greenPlatform_GREEN,   15 => greenPlatform_GREEN,

        16 => greenPlatform_GREEN,   17 => greenPlatform_GREEN,   18 => greenPlatform_GREEN,   19 => greenPlatform_GREEN,
        20 => greenPlatform_GREEN,   21 => greenPlatform_GREEN,   22 => greenPlatform_GREEN,   23 => greenPlatform_GREEN,

        24 => greenPlatform_GREEN,   25 => greenPlatform_GREEN,   26 => greenPlatform_GREEN,   27 => greenPlatform_GREEN,
        28 => greenPlatform_GREEN,   29 => greenPlatform_GREEN,   30 => greenPlatform_GREEN,   31 => greenPlatform_GREEN,

        32 => greenPlatform_GREEN,   33 => greenPlatform_GREEN,   34 => greenPlatform_GREEN,   35 => greenPlatform_GREEN,
        36 => greenPlatform_GREEN,   37 => greenPlatform_GREEN,   38 => greenPlatform_GREEN,   39 => greenPlatform_GREEN,

        40 => greenPlatform_GREEN,   41 => greenPlatform_GREEN,   42 => greenPlatform_GREEN,   43 => greenPlatform_GREEN,
        44 => greenPlatform_GREEN,   45 => greenPlatform_GREEN,   46 => greenPlatform_GREEN,   47 => greenPlatform_OUTLINE
    ),

    4 => (
        0  => greenPlatform_OUTLINE, 1  => greenPlatform_GREEN,   2  => greenPlatform_GREEN,   3  => greenPlatform_GREEN,
        4  => greenPlatform_GREEN,   5  => greenPlatform_GREEN,   6  => greenPlatform_GREEN,   7  => greenPlatform_GREEN,

        8  => greenPlatform_GREEN,   9  => greenPlatform_GREEN,   10 => greenPlatform_GREEN,   11 => greenPlatform_GREEN,
        12 => greenPlatform_GREEN,   13 => greenPlatform_GREEN,   14 => greenPlatform_GREEN,   15 => greenPlatform_GREEN,

        16 => greenPlatform_GREEN,   17 => greenPlatform_GREEN,   18 => greenPlatform_GREEN,   19 => greenPlatform_GREEN,
        20 => greenPlatform_GREEN,   21 => greenPlatform_GREEN,   22 => greenPlatform_GREEN,   23 => greenPlatform_GREEN,

        24 => greenPlatform_GREEN,   25 => greenPlatform_GREEN,   26 => greenPlatform_GREEN,   27 => greenPlatform_GREEN,
        28 => greenPlatform_GREEN,   29 => greenPlatform_GREEN,   30 => greenPlatform_GREEN,   31 => greenPlatform_GREEN,

        32 => greenPlatform_GREEN,   33 => greenPlatform_GREEN,   34 => greenPlatform_GREEN,   35 => greenPlatform_GREEN,
        36 => greenPlatform_GREEN,   37 => greenPlatform_GREEN,   38 => greenPlatform_GREEN,   39 => greenPlatform_GREEN,

        40 => greenPlatform_GREEN,   41 => greenPlatform_GREEN,   42 => greenPlatform_GREEN,   43 => greenPlatform_GREEN,
        44 => greenPlatform_GREEN,   45 => greenPlatform_GREEN,   46 => greenPlatform_GREEN,   47 => greenPlatform_OUTLINE
    ),

    5 => (
        0  => greenPlatform_OUTLINE, 1  => greenPlatform_LIGHT,   2  => greenPlatform_GREEN,   3  => greenPlatform_GREEN,
        4  => greenPlatform_GREEN,   5  => greenPlatform_GREEN,   6  => greenPlatform_GREEN,   7  => greenPlatform_GREEN,

        8  => greenPlatform_GREEN,   9  => greenPlatform_GREEN,   10 => greenPlatform_GREEN,   11 => greenPlatform_GREEN,
        12 => greenPlatform_GREEN,   13 => greenPlatform_GREEN,   14 => greenPlatform_GREEN,   15 => greenPlatform_GREEN,

        16 => greenPlatform_GREEN,   17 => greenPlatform_GREEN,   18 => greenPlatform_GREEN,   19 => greenPlatform_GREEN,
        20 => greenPlatform_GREEN,   21 => greenPlatform_GREEN,   22 => greenPlatform_GREEN,   23 => greenPlatform_GREEN,

        24 => greenPlatform_GREEN,   25 => greenPlatform_GREEN,   26 => greenPlatform_GREEN,   27 => greenPlatform_GREEN,
        28 => greenPlatform_GREEN,   29 => greenPlatform_GREEN,   30 => greenPlatform_GREEN,   31 => greenPlatform_GREEN,

        32 => greenPlatform_GREEN,   33 => greenPlatform_GREEN,   34 => greenPlatform_GREEN,   35 => greenPlatform_GREEN,
        36 => greenPlatform_GREEN,   37 => greenPlatform_GREEN,   38 => greenPlatform_GREEN,   39 => greenPlatform_GREEN,

        40 => greenPlatform_GREEN,   41 => greenPlatform_GREEN,   42 => greenPlatform_GREEN,   43 => greenPlatform_GREEN,
        44 => greenPlatform_GREEN,   45 => greenPlatform_GREEN,   46 => greenPlatform_LIGHT,   47 => greenPlatform_OUTLINE
    ),

    6 => (
        0  => greenPlatform_BG,      1  => greenPlatform_OUTLINE, 2  => greenPlatform_GREEN,   3  => greenPlatform_GREEN,
        4  => greenPlatform_GREEN,   5  => greenPlatform_GREEN,   6  => greenPlatform_GREEN,   7  => greenPlatform_GREEN,

        8  => greenPlatform_GREEN,   9  => greenPlatform_GREEN,   10 => greenPlatform_GREEN,   11 => greenPlatform_GREEN,
        12 => greenPlatform_GREEN,   13 => greenPlatform_GREEN,   14 => greenPlatform_GREEN,   15 => greenPlatform_GREEN,

        16 => greenPlatform_GREEN,   17 => greenPlatform_GREEN,   18 => greenPlatform_GREEN,   19 => greenPlatform_GREEN,
        20 => greenPlatform_GREEN,   21 => greenPlatform_GREEN,   22 => greenPlatform_GREEN,   23 => greenPlatform_GREEN,

        24 => greenPlatform_GREEN,   25 => greenPlatform_GREEN,   26 => greenPlatform_GREEN,   27 => greenPlatform_GREEN,
        28 => greenPlatform_GREEN,   29 => greenPlatform_GREEN,   30 => greenPlatform_GREEN,   31 => greenPlatform_GREEN,

        32 => greenPlatform_GREEN,   33 => greenPlatform_GREEN,   34 => greenPlatform_GREEN,   35 => greenPlatform_GREEN,
        36 => greenPlatform_GREEN,   37 => greenPlatform_GREEN,   38 => greenPlatform_GREEN,   39 => greenPlatform_GREEN,

        40 => greenPlatform_GREEN,   41 => greenPlatform_GREEN,   42 => greenPlatform_GREEN,   43 => greenPlatform_GREEN,
        44 => greenPlatform_GREEN,   45 => greenPlatform_GREEN,   46 => greenPlatform_OUTLINE, 47 => greenPlatform_BG
    ),

    7 => (
        0  => greenPlatform_BG,      1  => greenPlatform_BG,      2  => greenPlatform_OUTLINE, 3  => greenPlatform_OUTLINE,
        4  => greenPlatform_OUTLINE, 5  => greenPlatform_OUTLINE, 6  => greenPlatform_OUTLINE, 7  => greenPlatform_OUTLINE,

        8  => greenPlatform_OUTLINE, 9  => greenPlatform_OUTLINE, 10 => greenPlatform_OUTLINE, 11 => greenPlatform_OUTLINE,
        12 => greenPlatform_OUTLINE, 13 => greenPlatform_OUTLINE, 14 => greenPlatform_OUTLINE, 15 => greenPlatform_OUTLINE,

        16 => greenPlatform_OUTLINE, 17 => greenPlatform_OUTLINE, 18 => greenPlatform_OUTLINE, 19 => greenPlatform_OUTLINE,
        20 => greenPlatform_OUTLINE, 21 => greenPlatform_OUTLINE, 22 => greenPlatform_OUTLINE, 23 => greenPlatform_OUTLINE,

        24 => greenPlatform_OUTLINE, 25 => greenPlatform_OUTLINE, 26 => greenPlatform_OUTLINE, 27 => greenPlatform_OUTLINE,
        28 => greenPlatform_OUTLINE, 29 => greenPlatform_OUTLINE, 30 => greenPlatform_OUTLINE, 31 => greenPlatform_OUTLINE,

        32 => greenPlatform_OUTLINE, 33 => greenPlatform_OUTLINE, 34 => greenPlatform_OUTLINE, 35 => greenPlatform_OUTLINE,
        36 => greenPlatform_OUTLINE, 37 => greenPlatform_OUTLINE, 38 => greenPlatform_OUTLINE, 39 => greenPlatform_OUTLINE,

        40 => greenPlatform_OUTLINE, 41 => greenPlatform_OUTLINE, 42 => greenPlatform_OUTLINE, 43 => greenPlatform_OUTLINE,
        44 => greenPlatform_OUTLINE, 45 => greenPlatform_OUTLINE, 46 => greenPlatform_BG,      47 => greenPlatform_BG
    )
);

    --Added stuff
    constant JETPACK_AND_DOODLE_WIDTH  : integer := 54;
    constant JETPACK_AND_DOODLE_HEIGHT : integer := 42;
    function jetpack_and_doodle_sym_to_pix(c : character)
    return std_logic_vector;
    constant doodle_outline_jd : std_logic_vector(3 downto 0) := "0000";
    constant doodle_body_jd    : std_logic_vector(3 downto 0) := "0001";
    constant doodle_light_jd   : std_logic_vector(3 downto 0) := "0010";
    constant doodle_stripe_jd  : std_logic_vector(3 downto 0) := "0011";
    constant jetpack_body_jd      : std_logic_vector(3 downto 0) := "0100";
    constant jetpack_yellow_jd    : std_logic_vector(3 downto 0) := "0101";
    constant jetpack_stripe_jd    : std_logic_vector(3 downto 0) := "0110";
    constant jetpack_darkblue_jd  : std_logic_vector(3 downto 0) := "0111";
    constant jetpack_brown_jd     : std_logic_vector(3 downto 0) := "1000";
    constant flame_core_jd          : std_logic_vector(3 downto 0) := "1001"; 
    constant flame_outer_jd          : std_logic_vector(3 downto 0) := "1010";
    constant doodle_BG_jd             : std_logic_vector(3 downto 0) := "1011";
    
    

      
    type jetpack_and_doodle_sprite_sym_t is array (0 to 42) of string(0 to 54);
    constant jetpackAndDoodle : jetpack_and_doodle_sprite_sym_t:= (
".......................................................", -- visual row 04
".......................########........................", -- visual row 05
"......................##SSSSS####......................", -- visual row 06
".....................#SLBBBBBBSS##.....................", -- visual row 07
"...................##BLBBBBBBBBBS##....................", -- visual row 08
"..................#SLLBBBBBBLLLBBS##...................", 
"......####........#LLBBBBBBBLLLBBBS##..................", 
".....######......#LLBBBBBBBBBBBLBBBS#..................", 
".....#YYYY#.....#SLLBBBBBBBBLLLLLBBBS#.................",
"....##YYYY##....#LLBBBBBBLLLLLLLLBBBS##................", 
"....#YYYYYY#....#SLBBBBBBBLLLLLLLLLBBBS#...............",  
"....#TTTTTT#....#SBBBBBBBBBLLLBBBSLLSBS##..............",
"....#TTTTTT#....#LBBBBBBBBBBLLLBS#BL#SBS#.........LSS..",
"....#JJJJJJ######LLBBBBBBBBBLLLBS#BL#SBS###......####..",
"....#JJJJJJ#DDDD#LLBBLLBBBLLLLBBBBBBBLLLBS###########..",
"....#JJJJJJ#DDDD#LBBBLLLBBLLLLLLLLBBLLLLBBBSSSSSS#SB#..",
"....#JJJJJJ######LBBBLLLLBBLLLLLLLLLBBBBBBBLLBBBB#SB##.",
"....#JJJJJJ#....#LBBBBLLLLBBBBBBBBBBBBBBBBBSSSBLL#SBS#.", 
"....#JJJJJJ#....#LBBBLLLLBBBBBBBBBBBBBBBS#######S##LS#.",
"....#JJJJJJ#....#LLBBBBBBBBBBBBBBBBBBBBS##.....####S##.", 
"....#JJJJJJ#....#LLLBLBBBBBBBBBBBBBBLLB###........###..", 
"....#JJJJJJ#....#SLLBLLBBBBLLLLLBBBBLLS##..............",
"....#JJJJJJ#....##SSSSSSSSSSSSSSSSSSSS###..............", 
"....#JJJJJJ#....#########################..............",
"....#JJJJJJ#....#SSSSSSSSSSSSSSSSSSSSSSS#..............", 
"....#JJJJJJ#....#SSSSSSSSSSSSSSSSSSSSSSS#..............",
"....#JJJJJJ#....#SSSSSSSSSSSSSSSSSSSSSSS#..............",
"....#JJTTJJ#....#########################..............",
"....#J####J######SSSSSSSSSLLLLLLSSSSSSSS#..............", 
"....#JJJJJJ#DDDD#SLLLLLLLLLLLLLLLLLLSSSS#..............",
"....#JJTTJJ#DDDD#SSSSSSSSSSSSSSSSSSSSSSS#..............", 
"....#J####J##############################..............", 
"....#JJJJJJ#....#SSLSSSSSSSSSSSSSSSSSSS##..............",
"....#JJJJJJ#....#########################..............", 
"....##RRRR##.......##....##...##....##.................",
".....######........##....##...##....##.................",
"......####.........##....##...##....##.................", 
".....OOOOOO........##....##...##....###................",
"....OOOOOOOO.......####..####.####..####...............",
"...OOCCCCCCOO......####..####.####..####...............",
"..OOCCCCCCCCOO.........................................",
".OOCCCCCCCCCCOO........................................",
"OOCCCCCCCCCCCCOO......................................."
    );
    
    
    
    constant JETPACK_WIDTH  : integer := 21;
    constant JETPACK_HEIGHT : integer := 31;
    function jetpack_sym_to_pix(c : character)
        return std_logic_vector;
    constant jetpack_BG        : std_logic_vector(2 downto 0) := "000";
    constant jetpack_outline   : std_logic_vector(2 downto 0) := "001";
    constant jetpack_body      : std_logic_vector(2 downto 0) := "010";
    constant jetpack_yellow    : std_logic_vector(2 downto 0) := "011";
    constant jetpack_stripe    : std_logic_vector(2 downto 0) := "100";
    constant jetpack_darkblue  : std_logic_vector(2 downto 0) := "101";
    constant jetpack_brown     : std_logic_vector(2 downto 0) := "110";
    
    type jetpack_sprite_sym_t is array (0 to 31) of string(0 to 21);
    constant jetpack : jetpack_sprite_sym_t :=
    (
    "......................", -- visual row 00
    "..####........####....", -- visual row 01
    ".######......######...", -- visual row 02
    ".#YYYY#......#YYYY#...", -- visual row 03
    "##YYYY##....##YYYY##..", -- visual row 04
    "#YYYYYY#....#YYYYYY#..", -- visual row 05
    "#TTTTTT#....#TTTTTT#..", -- visual row 06
    "#TTTTTT##..##TTTTTT#..", -- visual row 07
    "#BBBBBB######BBBBBB#..", -- visual row 08
    "#BBBBBB#DDDD#BBBBBB#..", -- visual row 09
    "#BBBBBB#DDDD#BBBBBB#..", -- visual row 10
    "#BBBBBB######BBBBBB#..", -- visual row 11
    "#BBBBBB#....#BBBBBB#..", -- visual row 12
    "#BBBBBB#....#BBBBBB#..", -- visual row 13
    "#BBBBBB#....#BBBBBB#..", -- visual row 14
    "#BBBBBB#....#BBBBBB#..", -- visual row 15
    "#BBBBBB#....#BBBBBB#..", -- visual row 16
    "#BBBBBB#....#BBBBBB#..", -- visual row 17
    "#BBBBBB#....#BBBBBB#..", -- visual row 18
    "#BBBBBB#....#BBBBBB#..", -- visual row 19
    "#BBBBBB#....#BBBBBB#..", -- visual row 20
    "#BBBBBB#....#BBBBBB#..", -- visual row 21
    "#BBTTBB#....#BBTTBB#..", -- visual row 22
    "#B####B######B####B#..", -- visual row 23
    "#BBBBBB#DDDD#BBBBBB#..", -- visual row 24
    "#BBTTBB#DDDD#BBTTBB#..", -- visual row 25
    "#B####B######B####B#..", -- visual row 26
    "#BBBBBB#....#BBBBBB#..", -- visual row 27
    "#BBBBBB#....#BBBBBB#..", -- visual row 28
    "##RRRR##....##RRRR##..", -- visual row 29
    ".######......######...", -- visual row 30
    "..####........####...."  -- visual row 31
    );
     


    constant TEXT_OUTLINE        : std_logic_vector(1 downto 0) := "00";
    constant TEXT_SHADOW   : std_logic_vector(1 downto 0) := "01";
    constant TEXT_BG      : std_logic_vector(1 downto 0) := "10";
    constant PLAYAGAIN_WIDTH  : integer := 79;
    constant PLAYAGAIN_HEIGHT : integer := 33; 
type play_again_sprite_array is array (0 to 33) of string(0 to 79);

constant play_again_sprite : play_again_sprite_array := (

("....########################################################################...."),
("...##########################################################################..."),
("..############################################################################.."),
(".####======================================================================####."),
("####========================================================================####"),
("###==========================================================================###"),
("###==========================================================================###"),
("###==========================================================================###"),
("###==========================================================================###"),
("###==========================================================================###"),
("###=========#####=#======###==#===#=====###===####==###==#####=#===#=========###"),
("###=========#####=#======###==#===#=====###===####==###==#####=#===#=========###"),
("###=========#===#=#=====#===#=#===#====#===#=#=====#===#===#===##==#=========###"),
("###=========#===#=#=====#===#=#===#====#===#=#=====#===#===#===##==#=========###"),
("###=========#===#=#=====#===#==###=====#===#=#=====#===#===#===#=#=#=========###"),
("###=========#===#=#=====#===#==###=====#===#=#=====#===#===#===#=#=#=========###"),
("###=========#####=#=====#####===#======#####=#=###=#####===#===#==##=========###"),
("###=========#####=#=====#####===#======#####=#=###=#####===#===#==##=========###"),
("###=========#=====#=====#===#===#======#===#=#===#=#===#===#===#===#=========###"),
("###=========#=====#=====#===#===#======#===#=#===#=#===#===#===#===#=========###"),
("###=========#=====#=====#===#===#======#===#=#===#=#===#===#===#===#=========###"),
("###=========#=====#=====#===#===#======#===#=#===#=#===#===#===#===#=========###"),
("###=========#=====#####=#===#===#======#===#==###==#===#=#####=#===#=========###"),
("###=========#=====#####=#===#===#======#===#==###==#===#=#####=#===#=========###"),
("###==========================================================================###"),
("###==========================================================================###"),
("###==========================================================================###"),
("###==========================================================================###"),
("###==========================================================================###"),
("###==========================================================================###"),
("####========================================================================####"),
(".####======================================================================####."),
("..############################################################################.."),
("...##########################################################################...")

);



    constant PLAY_WIDTH  : integer := 79;
    constant PLAY_HEIGHT : integer := 23; 

type play_sprite_array is array (0 to 23) of string(0 to 79);
constant play_sprite : play_sprite_array := (
("....########################################################################...."),
("..############################################################################.."),
(".####======================================================================####."),
("###==========================================================================###"),
("###==========================================================================###"),
("###=========================#####=#======###==#===#==========================###"),
("###=========================#####=#======###==#===#==========================###"),
("###=========================#===#=#=====#===#=#===#==========================###"),
("###=========================#===#=#=====#===#=#===#==========================###"),
("###=========================#===#=#=====#===#==###===========================###"),
("###=========================#===#=#=====#===#==###===========================###"),
("###=========================#####=#=====#####===#============================###"),
("###=========================#####=#=====#####===#============================###"),
("###=========================#=====#=====#===#===#============================###"),
("###=========================#=====#=====#===#===#============================###"),
("###=========================#=====#=====#===#===#============================###"),
("###=========================#=====#=====#===#===#============================###"),
("###=========================#=====#####=#===#===#============================###"),
("###=========================#=====#####=#===#===#============================###"),
("###==========================================================================###"),
("###==========================================================================###"),
(".####======================================================================####."),
("..############################################################################.."),
("....########################################################################....")
);

    constant GAME_OVER_LETTERS        : std_logic_vector(1 downto 0) := "00";
    constant GAME_OVER_BK   : std_logic_vector(1 downto 0) := "01";
    constant GAME_OVER_WIDTH  : integer := 79;
    constant GAME_OVER_HEIGHT : integer := 13; 
    function game_over_sym_to_pix(c: character)
        return std_logic_vector;
type game_over_sprite_array is array (0 to 13) of string(0 to 79);
constant game_over_sprite : game_over_sprite_array := (
("...########..###...##...##..########......#####..##...##..########..########...."),
("...########..###...##...##..########......#####..##...##..########..########...."),
("...##.......#...#..###.###..##............#...#..##...##..##........#......#...."),
("...##.......#...#..###.###..##............#...#..##...##..##........#......#...."),
("...##.......#...#..##.#.##..##............#...#..##...##..##........#......#...."),
("...##.......#...#..##.#.##..##............#...#..##...##..##........#......#...."),
("...##..####.#####..##...##..########......#...#..##...##..########..########...."),
("...##..####.#####..##...##..########......#...#..##...##..########..########...."),
("...##....##.##.##..##...##..##............#...#..##...##..##........###........."),
("...##....##.##.##..##...##..##............#...#..##...##..##........#.##........"),
("...##....##.##.##..##...##..##............#...#...##.##...##........#..##......."),
("...##....##.##.##..##...##..##............#...#...##.##...##........#...##......"),
("...########.##.##..##...##..########......#####....###....########..#....##....."),
("...########.##.##..##...##..########......#####....###....########..#.....##....")
);


constant brown_beam_outline: std_logic_vector(1 downto 0) := "00";
constant brown_beam_body : std_logic_vector(1 downto 0) := "01";
constant brown_beam_light : std_logic_vector(1 downto 0) := "10";
constant brown_beam_bg: std_logic_vector(1 downto 0) := "11";
constant BROWN_BEAM_WIDTH  : integer := 47;
constant BROWN_BEAM_HEIGHT : integer := 7; 
type brown_beam_sprite_array is array (0 to 7) of string(0 to 47);
    function beam_sym_to_pix(c : character)
    return std_logic_vector;
constant brown_beam_sprite : brown_beam_sprite_array :=
(
"..####################..#####################...",
".#BBBBBBBBBBBBBBBBBBB#..#BBBBBBBBBBBBBBBBBBBB#..",
"#BLLLLLBBBBBBBBBBBBBB#..#BBBBBBBBBBBBBBLLLLLLB#.",
"#BBBBBBBBBBBBBBBBBBB#..##BBBBBBBBBBBBBBBBBBBBB#.",
"#BBBBBBBBBBBBBBBBBBB#..#BBBBBBBBBBBBBBBBBBBBBB#.",
"#BBBBBBBBBBBBBBBBBBBB#..#BBBBBBBBBBBBBBBBBBBBB#.",
".#BBBBBBBBBBBBBBBBBBB#..#BBBBBBBBBBBBBBBBBBBB#..",
"..####################..######################.."
);


constant BROKEN_BROWN_BEAM_WIDTH  : integer := 7;
constant BROKEN_BROWN_BEAM_HEIGHT : integer := 24;
type broken_brown_beam_sprite_array is array (0 to 24) of string(0 to 7);
constant broken_brown_beam_sprite: broken_brown_beam_sprite_array:=
(
"........",
"..####..",
".#BBBB##",
"#BLBBBB#",
"#BLBBBB#",
"#BLBBBB#",
"#BLBBBB#",
"#BLBBBB#",
"#BLBBBB#",
"#BBBBBB#",
"#BBBBBB#",
"#BBBBBB#",
"#BBBBBB#",
"#BBBBBB#",
"#BBBBBB#",
"#BBBBBB#",
"#BBBBBB#",
"#BBBBBB#",
"#BBBBBB#",
"#BBBBBB#",
"#BBBBBB#",
"#BBBBBB#",
"#BBBBBB#",
"####B###",
"...##..."
);

end graphicsParts;

package body graphicsParts is

    function game_over_sym_to_pix(c: character)
        return std_logic_vector is 
    begin   
        case c is 
            when '.' => return game_over_bk;
            when '#' => return game_over_letters;
            when others => return game_over_bk;
        end case;
    end function;
    function doodle_sym_to_pix(c : character)
        return std_logic_vector is
    begin
        case c is
            when '.' => return doodle_BG;
            when '#' => return doodle_outline;
            when 'B' => return doodle_body;
            when 'L' => return doodle_light;
            when 'S' => return doodle_stripe;
            when others => return doodle_BG;
        end case;
    end function;
    
    --Added stuff
    function jetpack_sym_to_pix(c : character)
    return std_logic_vector is
    begin
    case c is
        when '.' => return jetpack_BG;
        when '#' => return jetpack_outline;
        when 'B' => return jetpack_body;
        when 'Y' => return jetpack_yellow;
        when 'T' => return jetpack_stripe;
        when 'D' => return jetpack_darkblue;
        when 'R' => return jetpack_brown;
        when others => return jetpack_BG;
    end case;
end function;

    function jetpack_and_doodle_sym_to_pix(c : character)
        return std_logic_vector is
    begin
        case c is
            when '.' => return doodle_BG_jd;
            when '#' => return doodle_outline_jd;
            when 'B' => return doodle_body_jd;
            when 'L' => return doodle_light_jd;
            when 'S' => return doodle_stripe_jd;
            when 'J' => return jetpack_body_jd;
            when 'Y' => return jetpack_yellow_jd;
            when 'T' => return jetpack_stripe_jd;
            when 'D' => return jetpack_darkblue_jd;
            when 'R' => return jetpack_brown_jd;
            when 'O' => return flame_outer_jd;
            when 'C' => return flame_core_jd;
            when others => return doodle_BG_jd;
        end case;
    end function; 

    function play_again_sym_to_pixel(ch : character) return std_logic_vector is
    begin
    case ch is
        when '#' => return TEXT_OUTLINE; -- outline + text
        when '=' => return TEXT_SHADOW;
        when others => return TEXT_BG;
    end case;
    end function;
    
    function beam_sym_to_pix(c : character)
    return std_logic_vector is
begin
    case c is
        when '.' => return brown_beam_BG;
        when '#' => return brown_beam_outline;
        when 'B' => return brown_beam_body;
        when 'L' => return brown_beam_light;
        when others => return brown_beam_BG;
    end case;
end function;

end package body graphicsParts;