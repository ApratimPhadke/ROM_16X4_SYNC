`timescale 1ns/1ps
`default_nettype none
module rom_1r_sync #(
parameter integer DEPTH = 16,
parameter integer DATA_WIDTH =4,
parameter integer ADDR_WIDTH =4
)(
input wire clk,
input wire enable ,
input wire [ADDR_WIDTH-1:0] addr,
output reg [DATA_WIDTH-1:0] dout
);
reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
initial begin 
memory[ 0] = 4'hA;
        memory[ 1] = 4'h1;
        memory[ 2] = 4'hC;
        memory[ 3] = 4'hE;
        memory[ 4] = 4'h0;
        memory[ 5] = 4'h5;
        memory[ 6] = 4'h2;
        memory[ 7] = 4'hF;
        memory[ 8] = 4'h7;
        memory[ 9] = 4'h9;
        memory[10] = 4'h3;
        memory[11] = 4'hB;
        memory[12] = 4'h8;
        memory[13] = 4'h4;
        memory[14] = 4'hD;
        memory[15] = 4'h6;
    end
    always @(posedge clk) begin 
    if(enable) begin 
    dout<=memory[addr];
    end 
    end 
    initial begin 
    if(DEPTH != (1<<ADDR_WIDTH)) begin 
    $display("WARNING: DEPTH (%0d) != 2^ADDR_WIDTH (%0d).",
                     DEPTH, (1<<ADDR_WIDTH));
                     end 
                     end 
                     endmodule 
                     