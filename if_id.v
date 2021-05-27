`include "lib/defines.vh"
module if_id(
    input wire clk,
    input wire rst,

    input wire flush,
    input wire [`StallBus] stall,

    input wire [`InstAddrBus] if_pc,
    input wire [`InstBus] if_inst,

    output reg [`InstAddrBus] id_pc,
    output reg [`InstBus] id_inst

);

    always @ (posedge clk) begin
        if (rst) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        else if (flush) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        else if (stall[2] == `Stop && stall[3] == `NoStop) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end 
        else if (stall[2] == `NoStop) begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule