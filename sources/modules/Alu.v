`timescale 1ns / 1ps

module Alu(
    input wire [5:0] alufn,
    input wire [31:0] a,
    input wire [31:0] b,

    output wire [31:0] s,
    output reg [31:0] z,
    output wire [31:0] v,
    output wire [31:0] n
);


endmodule

module AddSub(
    input wire [5:0] alufn,
    input wire [31:0] a,
    input wire [31:0] b,

    output wire [31:0] s,
    output wire z,
    output wire v,
    output wire n
);

    wire [31:0]     xb;

    integer 	i = 0;
   
    assign xb = b ^ {32{alufn[0]}};
    assign s = a + xb + alufn[0];
    assign z = (s == 32'h00000000);
    assign v = (a[31] & xb[31] & (~s[31])) + ((~a[31]) & (~xb[31]) & s[31]);
    assign n = s[31]; 

endmodule

module CmpModule(
    input wire [5:0] alufn,
    input wire [31:0] a,
    input wire [31:0] b,

    output wire [31:0] cmp
);

wire [31:0] s;
wire z;
wire v;
wire n;

AddSub add_sub_inst_0( 
    .alufn({{2'b0},{alufn[2:1]},{1{1'b1}}}), .a(a), .b(b), .s(s), .z(z), .v(v), .n(n)
);

reg lsb;

// Calculate LSB using combination of z, v, n and alufn[2:1]
always @(alufn, z, v, n) begin
    if (alufn[2:1] == 2'b01) begin
        lsb = z;
    end else if (alufn[2:1] == 2'b10) begin
        lsb = n ^ v;
    end else if (alufn[2:1] == 2'b11) begin
        lsb = z + (n ^ v);
    end
end

// Set 0th bit of output as lsb and rest 0
assign cmp = {{31{1'b0}}, {lsb}};

endmodule

module LogicModule(
    input wire [5:0] alufn,
    input wire [31:0] a,
    input wire [31:0] b,

    output reg [31:0] res
);

integer i = 0;

always @(alufn[3:0], a, b) begin
    for (i = 0; i < 32; i = i + 1) begin
        res[i] = alufn[{{b[i]}, {a[i]}}];
    end 
end

endmodule
