`timescale 1ns/1ps

module main_memory #(
    parameter ADDRESS_WIDTH = 18, // Adresa de bloc (21 bi?i adres? - 3 bi?i offset)
    parameter BLOCK_SIZE = 256,   // 8 cuvinte * 32 bi?i
    parameter FILE = ""
)(
    input wire clock,
    input wire [BLOCK_SIZE - 1:0] din,
    input wire [ADDRESS_WIDTH - 1:0] address,
    input wire rden,
    input wire wren,
    output reg [BLOCK_SIZE - 1:0] dout
);

    localparam DEPTH = 1 << ADDRESS_WIDTH; // 262144 de blocuri
    
    // Memoria principal?
    reg [BLOCK_SIZE-1:0] mem [0:DEPTH-1];
    
    integer i;

    initial begin
	dout = {BLOCK_SIZE{1'b0}};
        if (FILE != "") begin
            $readmemb(FILE, mem);
        end else begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] = {BLOCK_SIZE{1'b0}};
            end
        end
    end

    always @(posedge clock) begin
        if (wren)
            mem[address] <= din;
    end

    always @(posedge clock) begin
        if (rden)
            dout <= mem[address];
    end

endmodule
