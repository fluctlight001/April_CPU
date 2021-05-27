`include "lib/defines.vh"
module dc_mem (
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,

    input wire [`InstAddrBus] dc_pc,
    
    output reg [`InstAddrBus] mem_pc
);
    always @ (posedge clk) begin
        if (rst) begin
            mem_pc <= `ZeroWord;
        end
        else if (flush) begin
            mem_pc <= `ZeroWord;
        end
        else if (stall[5] == `Stop && stall[6] == `NoStop) begin
            mem_pc <= `ZeroWord;
        end
        else if (stall[5] == `Stop) begin
            mem_pc <= dc_pc;
        end
    end
    
endmodule