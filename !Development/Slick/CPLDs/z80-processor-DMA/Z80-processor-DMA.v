/*
 * Generated by Digital. Don't modify this file!
 * Any changes will be lost if this file is regenerated.
 */

// 8-bit identity comparator
module \74688  (
  input P_0,
  input Q_0,
  input P_1,
  input Q_1,
  input P_2,
  input Q_2,
  input P_3,
  input Q_3,
  input P_4,
  input Q_4,
  input P_5,
  input Q_5,
  input P_6,
  input Q_6,
  input P_7,
  input Q_7,
  input \~OE ,
  input VCC,
  input GND,
  output \~EQ 
);
  assign \~EQ  = ~ (~ \~OE  & ~ ((P_0 ^ Q_0) | (P_1 ^ Q_1) | (P_2 ^ Q_2)) & ~ ((P_3 ^ Q_3) | (P_4 ^ Q_4) | (P_5 ^ Q_5)) & ~ ((P_6 ^ Q_6) | (P_7 ^ Q_7)));
endmodule

module Demux2
#(
    parameter Default = 0 
)
(
    output out_0,
    output out_1,
    output out_2,
    output out_3,
    input [1:0] sel,
    input in
);
    assign out_0 = (sel == 2'h0)? in : Default;
    assign out_1 = (sel == 2'h1)? in : Default;
    assign out_2 = (sel == 2'h2)? in : Default;
    assign out_3 = (sel == 2'h3)? in : Default;
endmodule


// dual 2-line to 4-line decoder/demultiplexer
module \74139  (
  input \1A ,
  input \1B ,
  input \~1G ,
  input \2A ,
  input \2B ,
  input \~2G ,
  input VCC,
  input GND,
  output \~1Y0 ,
  output \~1Y1 ,
  output \~1Y2 ,
  output \~1Y3 ,
  output \~2Y0 ,
  output \~2Y1 ,
  output \~2Y2 ,
  output \~2Y3 
);
  wire [1:0] s0;
  wire [1:0] s1;
  assign s0[0] = \1A ;
  assign s0[1] = \1B ;
  assign s1[0] = \2A ;
  assign s1[1] = \2B ;
  Demux2 #(
    .Default(1)
  )
  Demux2_i0 (
    .sel( s0 ),
    .in( \~1G  ),
    .out_0( \~1Y0  ),
    .out_1( \~1Y1  ),
    .out_2( \~1Y2  ),
    .out_3( \~1Y3  )
  );
  Demux2 #(
    .Default(1)
  )
  Demux2_i1 (
    .sel( s1 ),
    .in( \~2G  ),
    .out_0( \~2Y0  ),
    .out_1( \~2Y1  ),
    .out_2( \~2Y2  ),
    .out_3( \~2Y3  )
  );
endmodule

module Mux_2x1_NBits #(
    parameter Bits = 2
)
(
    input [0:0] sel,
    input [(Bits - 1):0] in_0,
    input [(Bits - 1):0] in_1,
    output reg [(Bits - 1):0] out
);
    always @ (*) begin
        case (sel)
            1'h0: out = in_0;
            1'h1: out = in_1;
            default:
                out = 'h0;
        endcase
    end
endmodule


// quad 2-line to 1-line data selectors/multiplexers
module \74157  (
  input S, // select
  input A1,
  input A2,
  input A3,
  input A4,
  input B1,
  input B2,
  input B3,
  input B4,
  input G, // strobe
  input VCC,
  input GND,
  output Y1,
  output Y2,
  output Y3,
  output Y4
);
  wire [3:0] s0;
  wire [3:0] s1;
  wire [3:0] s2;
  wire [3:0] s3;
  assign s1[0] = B1;
  assign s1[1] = B2;
  assign s1[2] = B3;
  assign s1[3] = B4;
  assign s0[0] = A1;
  assign s0[1] = A2;
  assign s0[2] = A3;
  assign s0[3] = A4;
  Mux_2x1_NBits #(
    .Bits(4)
  )
  Mux_2x1_NBits_i0 (
    .sel( S ),
    .in_0( s0 ),
    .in_1( s1 ),
    .out( s2 )
  );
  Mux_2x1_NBits #(
    .Bits(4)
  )
  Mux_2x1_NBits_i1 (
    .sel( G ),
    .in_0( s2 ),
    .in_1( 4'b0 ),
    .out( s3 )
  );
  assign Y1 = s3[0];
  assign Y2 = s3[1];
  assign Y3 = s3[2];
  assign Y4 = s3[3];
endmodule

module DIG_D_FF_AS_Nbit
#(
    parameter Bits = 2,
    parameter Default = 0
)
(
   input Set,
   input [(Bits-1):0] D,
   input C,
   input Clr,
   output [(Bits-1):0] Q,
   output [(Bits-1):0] \~Q
);
    reg [(Bits-1):0] state;

    assign Q = state;
    assign \~Q  = ~state;

    always @ (posedge C or posedge Clr or posedge Set)
    begin
        if (Set)
            state <= {Bits{1'b1}};
        else if (Clr)
            state <= 'h0;
        else
            state <= D;
    end

    initial begin
        state = Default;
    end
endmodule

// quad D-flip-flop
module \74175  (
  input CLK,
  input \~CL ,
  input D1,
  input D2,
  input D3,
  input D4,
  input VCC,
  input GND,
  output Q1,
  output Q2,
  output Q3,
  output Q4,
  output \~Q1 ,
  output \~Q2 ,
  output \~Q3 ,
  output \~Q4 
);
  wire [3:0] s0;
  wire s1;
  wire [3:0] s2;
  wire [3:0] s3;
  assign s1 = ~ \~CL ;
  assign s0[0] = D1;
  assign s0[1] = D2;
  assign s0[2] = D3;
  assign s0[3] = D4;
  DIG_D_FF_AS_Nbit #(
    .Bits(4),
    .Default(0)
  )
  DIG_D_FF_AS_Nbit_i0 (
    .Set( 1'b0 ),
    .D( s0 ),
    .C( CLK ),
    .Clr( s1 ),
    .Q( s2 ),
    .\~Q ( s3 )
  );
  assign Q1 = s2[0];
  assign Q2 = s2[1];
  assign Q3 = s2[2];
  assign Q4 = s2[3];
  assign \~Q1  = s3[0];
  assign \~Q2  = s3[1];
  assign \~Q3  = s3[2];
  assign \~Q4  = s3[3];
endmodule

module \Z80-processor-DMA  (
  input \~DREQ0 ,
  input \~DREQ1 ,
  input \~CPUxWR ,
  input \~CPUxRESET ,
  input \CPU-D0 ,
  input \CPU-D1 ,
  input \CPU-D2 ,
  input \CPU-D3 ,
  input \~CPUxIORQ ,
  input \~CPUxM1 ,
  input CPUxA2,
  input Q2,
  input Q3,
  input CPUxA4,
  input CPUxA5,
  input CPUxA6,
  input CPUxA7,
  input Q4,
  input Q5,
  input Q6,
  input Q7,
  input R4,
  input R5,
  input R6,
  input R7,
  input CPUxA0,
  input CPUxA1,
  input \~CPUxWAIT ,
  input \~CPUxBUSACK ,
  input \~DMAxINTxPULSE1 ,
  input \~DMAxINTxPULSE2 ,
  input CPUxA3,
  input \~DMAxBAO2 ,
  output DMAxRDY1,
  output DMAxRDY2,
  output \~DMAxRESET1 ,
  output \~DMAxRESET2 ,
  output \~FPxLATCH ,
  output \~DMAxCS1 ,
  output \~DMAxCS2 ,
  output \~BUSxEN ,
  output DATAxXFER,
  output IOxSEL,
  output \~CSxMAP ,
  output \~CSxUART 
);
  wire s0;
  wire s1;
  wire s2;
  wire s3;
  wire s4;
  wire s5;
  wire s6;
  wire s7;
  wire s8;
  wire s9;
  wire s10;
  wire \~BUSxEN_temp ;
  \74688  \74688_i0 (
    .P_0( \~CPUxM1  ),
    .Q_0( 1'b1 ),
    .P_1( 1'b1 ),
    .Q_1( 1'b1 ),
    .P_2( CPUxA2 ),
    .Q_2( Q2 ),
    .P_3( CPUxA3 ),
    .Q_3( Q3 ),
    .P_4( CPUxA4 ),
    .Q_4( Q4 ),
    .P_5( CPUxA5 ),
    .Q_5( Q5 ),
    .P_6( CPUxA6 ),
    .Q_6( Q6 ),
    .P_7( CPUxA7 ),
    .Q_7( Q7 ),
    .\~OE ( \~CPUxIORQ  ),
    .VCC( 1'b1 ),
    .GND( 1'b0 ),
    .\~EQ ( s6 )
  );
  \74688  \74688_i1 (
    .P_0( \~CPUxM1  ),
    .Q_0( 1'b1 ),
    .P_1( 1'b1 ),
    .Q_1( 1'b1 ),
    .P_2( 1'b1 ),
    .Q_2( 1'b1 ),
    .P_3( 1'b1 ),
    .Q_3( 1'b1 ),
    .P_4( CPUxA4 ),
    .Q_4( R4 ),
    .P_5( CPUxA5 ),
    .Q_5( R5 ),
    .P_6( CPUxA6 ),
    .Q_6( R6 ),
    .P_7( CPUxA7 ),
    .Q_7( R7 ),
    .\~OE ( \~CPUxIORQ  ),
    .VCC( 1'b1 ),
    .GND( 1'b0 ),
    .\~EQ ( s7 )
  );
  assign \~BUSxEN_temp  = ~ \~DMAxBAO2 ;
  \74139  \74139_i2 (
    .\1A ( 1'b1 ),
    .\1B ( 1'b1 ),
    .\~1G ( 1'b1 ),
    .\2A ( CPUxA0 ),
    .\2B ( CPUxA1 ),
    .\~2G ( s6 ),
    .VCC( 1'b1 ),
    .GND( 1'b0 ),
    .\~2Y0 ( s9 ),
    .\~2Y1 ( s10 ),
    .\~2Y2 ( \~FPxLATCH  ),
    .\~2Y3 ( s2 )
  );
  assign IOxSEL = ~ (s6 & s7);
  assign \~CSxMAP  = (s7 | CPUxA3);
  assign \~CSxUART  = (s7 | ~ CPUxA3);
  assign s8 = (\~BUSxEN_temp  | \~CPUxBUSACK );
  assign s3 = (\~CPUxWR  | s2);
  \74157  \74157_i3 (
    .S( s8 ),
    .A1( \~CPUxWAIT  ),
    .A2( \~CPUxWAIT  ),
    .A3( 1'b0 ),
    .A4( 1'b0 ),
    .B1( s9 ),
    .B2( s10 ),
    .B3( 1'b0 ),
    .B4( 1'b0 ),
    .G( 1'b0 ),
    .VCC( 1'b1 ),
    .GND( 1'b0 ),
    .Y1( \~DMAxCS1  ),
    .Y2( \~DMAxCS2  )
  );
  assign DATAxXFER = (s8 | (\~DMAxINTxPULSE1  & \~DMAxINTxPULSE2 ));
  \74175  \74175_i4 (
    .CLK( s3 ),
    .\~CL ( \~CPUxRESET  ),
    .D1( \CPU-D0  ),
    .D2( \CPU-D1  ),
    .D3( \CPU-D2  ),
    .D4( \CPU-D3  ),
    .VCC( 1'b1 ),
    .GND( 1'b0 ),
    .Q1( s0 ),
    .Q2( s1 ),
    .\~Q3 ( s4 ),
    .\~Q4 ( s5 )
  );
  assign DMAxRDY1 = (~ \~DREQ0  | s0);
  assign DMAxRDY2 = (~ \~DREQ1  | s1);
  assign \~DMAxRESET1  = (s4 & \~CPUxRESET );
  assign \~DMAxRESET2  = (\~CPUxRESET  & s5);
  assign \~BUSxEN  = \~BUSxEN_temp ;
endmodule
