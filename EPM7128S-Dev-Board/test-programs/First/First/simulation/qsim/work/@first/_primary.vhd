library verilog;
use verilog.vl_types.all;
entity First is
    port(
        CP              : out    vl_logic;
        Div_100         : out    vl_logic;
        Clock           : in     vl_logic;
        Out_0           : out    vl_logic;
        pin_name1       : in     vl_logic;
        Out_1           : out    vl_logic;
        pin_name2       : in     vl_logic;
        Out_2           : out    vl_logic;
        pin_name3       : in     vl_logic;
        Out_3           : out    vl_logic;
        pin_name4       : in     vl_logic;
        Out_4           : out    vl_logic;
        pin_name5       : in     vl_logic;
        Out_5           : out    vl_logic;
        pin_name6       : in     vl_logic;
        Out_6           : out    vl_logic;
        pin_name7       : in     vl_logic;
        Out_7           : out    vl_logic;
        pin_name8       : in     vl_logic;
        Seg_a           : out    vl_logic;
        Seg_b           : out    vl_logic;
        Seg_c           : out    vl_logic;
        Seg_d           : out    vl_logic;
        Seg_e           : out    vl_logic;
        Seg_f           : out    vl_logic;
        Seg_g           : out    vl_logic;
        Div_1000        : out    vl_logic;
        Div_10          : out    vl_logic
    );
end First;
