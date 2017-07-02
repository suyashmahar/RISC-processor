`timescale 1ns / 1ps

module ProgramCounter #(
    parameter ARCHITECTURE = 32 
)(
    input wire rst_i,   // Resets PC to 0x0
    input wire clk_i,   // Global clk
    output reg [ARCHITECTURE-1:0] pc_o     // Program counter output
);

    wire [ARCHITECTURE-1:0] pc_local_wire;

    // Increment PC by four
    PCAdder #(32, 32'h00000004) pc_adder_instance_0 (
        .pc_in_i(pc_o),
        .inc_pc_o(pc_local_wire)
    );

    // To update PC on positive edge of clock
    always @(posedge clk_i) begin
        if (rst_i) begin
            pc_o = 0;
        end else begin
            pc_o = pc_local_wire;
        end
    end


endmodule
