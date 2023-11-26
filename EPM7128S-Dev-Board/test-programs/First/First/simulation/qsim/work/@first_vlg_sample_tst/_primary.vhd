library verilog;
use verilog.vl_types.all;
entity First_vlg_sample_tst is
    port(
        Clock           : in     vl_logic;
        pin_name1       : in     vl_logic;
        pin_name2       : in     vl_logic;
        pin_name3       : in     vl_logic;
        pin_name4       : in     vl_logic;
        pin_name5       : in     vl_logic;
        pin_name6       : in     vl_logic;
        pin_name7       : in     vl_logic;
        pin_name8       : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end First_vlg_sample_tst;
