library verilog;
use verilog.vl_types.all;
entity First_vlg_check_tst is
    port(
        CP              : in     vl_logic;
        Div_10          : in     vl_logic;
        Div_100         : in     vl_logic;
        Div_1000        : in     vl_logic;
        Out_0           : in     vl_logic;
        Out_1           : in     vl_logic;
        Out_2           : in     vl_logic;
        Out_3           : in     vl_logic;
        Out_4           : in     vl_logic;
        Out_5           : in     vl_logic;
        Out_6           : in     vl_logic;
        Out_7           : in     vl_logic;
        Seg_a           : in     vl_logic;
        Seg_b           : in     vl_logic;
        Seg_c           : in     vl_logic;
        Seg_d           : in     vl_logic;
        Seg_e           : in     vl_logic;
        Seg_f           : in     vl_logic;
        Seg_g           : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end First_vlg_check_tst;
