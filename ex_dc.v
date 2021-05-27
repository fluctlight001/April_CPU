`include "lib/defines.vh"
module ex_dc(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,

    input wire [`InstAddrBus] ex_pc,
    input wire [`InstBus] ex_inst,

    output reg [`InstAddrBus] dc_pc,
    output reg [`InstBus] dc_inst
);
    always @ (posedge clk) begin
        if (rst) begin
            dc_pc <= `ZeroWord;
            dc_inst <= `ZeroWord;
        end
        else if (flush) begin
            dc_pc <= `ZeroWord;
            dc_inst <= `ZeroWord;
        end
        else if (stall[4] == `Stop && stall[5] == `NoStop) begin
            dc_pc <= `ZeroWord;
            dc_inst <= `ZeroWord;
        end
        else if (stall[4] == `NoStop) begin
            dc_pc <= ex_pc;
            dc_inst <= ex_inst;
        end
    end

endmodule 