`timescale 1ns / 1ps

module RegfileModule (
    input wire clk_i,

    input wire  [4 : 0]     ra_i,
    input wire  [4 : 0]     rb_i,
    input wire  [4 : 0]     rc_i,

    input wire  werf_i,
    input wire  ra2sel_i,

    input wire  [31 : 0]    wd_i,

    output wire [31 : 0]    rd1_o,
    output wire [31 : 0]    rd2_o
);

    // Connects ra2 selection mux to ra2 port
    // on register file
    reg [4 : 0]    ra2_loc;

    // Register file module instantiation for
    // memory declaration
    RegisterFile reg_file_instance_0 (
        .clk_i(clk_i),
        
        .w_add_i(rc_i),        // Rc <25:21>
        .w_dat_i(wd_i),
        .write_en_i(werf_i),
        
        .a_add_sel(ra_i),
        .b_add_sel(ra2_loc),

        .r_port_a_o(rd1_o),
        .r_port_b_o(rd2_o)
    );

    // Logic for selection of register 2
    always @(ra2sel_i, rc_i, rb_i, clk_i) begin
        if (ra2sel_i == 1'b1) begin
            ra2_loc = rc_i;
        end else begin
            ra2_loc = rb_i;
        end
    end
endmodule
