
module Z80CPU
(
    input CLK,
    input [2:0] CPU_ADDR,
    input CPU_A15,
    input CPU_A14,
    input CPU_D0,
    input MA15,
    input MA14,
    input [7:0] EIRQ,
    input nCPUxRESET,
    input nCPUxRD,
    input nCPUxWR,
    input IOxSEL,
    input nCPUxM1,
    input nCPUxIORQ,
    input nCPUxMREQ,
    input nCPUxRFSH,
    input nDMAxIEI1,
    input nDMAxIEO2,
    input nINTxI2C,
    input nFPxLATCH,
    input WSxMEMRD,
    input WSxIORD,
    input WSxMEMWR,
    input WSxIOWR,
    input nCSxMAP,
    output reg [2:0] IM2xS,
    output DATAxDIR,
    output nIM2xIEO,
    output nIM2xEN,
    output nFPxLATCHxRD,
    output FPxLATCHxWR,
    output reg nPAGExEN,
    output READY,
    output RESET,
    output WS1,
    output WS2,
    output WS3,
    output WS4,
    output WS5,
    output WS6,
    output WS7,
    output WS8,
    output SEL_A15,
    output SEL_A14
);

reg nIM2xINT;
reg RDY;
reg [7:0] wait_state;
wire nINTA;
wire nMR;
wire nPAGExWR;
wire TMP;
wire nPGENxWR;
wire nCSxI2C;
wire INTxI2C;
wire nCSxI2CxWR;

/* Priority encoder for EIRQ[7:0] */
always @(*)
begin
    if (EIRQ[7])      begin IM2xS = 3'b111; nIM2xINT = 0; end
    else if (EIRQ[6]) begin IM2xS = 3'b110; nIM2xINT = 0; end
    else if (EIRQ[5]) begin IM2xS = 3'b101; nIM2xINT = 0; end
    else if (EIRQ[4]) begin IM2xS = 3'b100; nIM2xINT = 0; end
    else if (EIRQ[3]) begin IM2xS = 3'b011; nIM2xINT = 0; end
    else if (EIRQ[2]) begin IM2xS = 3'b010; nIM2xINT = 0; end
    else if (EIRQ[1]) begin IM2xS = 3'b001; nIM2xINT = 0; end
    else if (EIRQ[0]) begin IM2xS = 3'b000; nIM2xINT = 0; end
    else begin IM2xS = 3'b000; nIM2xINT = 1; end
end

/* Wait state mux to generate RDY. */
always @(*)
begin
    case ({nCPUxMREQ, nCPUxRD})
        2'b00: RDY = WSxMEMRD;
        2'b01: RDY = WSxMEMWR;
        2'b10: RDY = WSxIORD;
        2'b11: RDY = WSxIOWR;
    endcase
end

/* Wait state shift register. */
always @(posedge CLK)
begin
    if (nMR == 0) wait_state = 8'b0;
    else wait_state = { wait_state[6:0], 1'b1 };
end

/* Paging enable register bit. */
always @(posedge CLK)
begin
    if (nCPUxRESET == 0) nPAGExEN = 1;
    else if (nPAGExWR == 0) nPAGExEN = ~CPU_D0;
end

assign { WS1, WS2, WS3, WS4, WS5, WS6, WS7, WS8 } = wait_state;

assign nINTA = nCPUxM1 | nCPUxIORQ;

assign DATAxDIR = (nCPUxRD | IOxSEL) & (nINTA | ~nDMAxIEI1);

assign nIM2xIEO = nIM2xINT | ~nDMAxIEO2;

assign nIM2xEN = nINTA | nIM2xIEO;

assign nFPxLATCHxRD = nCPUxRD | nFPxLATCH;

assign FPxLATCHxWR = ~(nFPxLATCH | nCPUxWR);

assign nMR = ~(nCPUxMREQ & nCPUxIORQ);

assign READY = ~(nMR & nCPUxRFSH) | RDY;

assign nPAGExWR = ~CPU_ADDR[2] & nCSxMAP & nCPUxWR; /* FIXME: not right. */

assign TMP = (CPU_ADDR[2] & nCSxMAP);

assign nPGENxWR = TMP | CPU_ADDR[1];

assign nCSxI2C = TMP | ~CPU_ADDR[1];

assign INTxI2C = ~nINTxI2C;

assign nCSxI2CxWR = nCSxI2C | nCPUxWR;

assign RESET = ~nCPUxRESET;

assign SEL_A14 = nCPUxIORQ == 0 ? CPU_A14 : MA14;
assign SEL_A15 = nCPUxIORQ == 0 ? CPU_A15 : MA15;

endmodule
