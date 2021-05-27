`include "lib/defines.vh"
module ic(
    input wire clk,
    input wire rst,
    input wire [`StallBus] stall,
    input wire flush,

    input wire [`InstAddrBus] pc_pc,
    input wire pc_ce,

    output reg [`InstAddrBus] icache_pc,
    output reg icache_ce
);
    always @ (posedge clk) begin
        if (rst) begin
            icache_pc <= `ZeroWord;
            icache_ce <= 1'b0;
        end
        else if (flush) begin
            icache_pc <= `ZeroWord;
            icache_ce <= 1'b0;
        end
        else if (stall[1] == `Stop && stall[2] == `NoStop)begin
            icache_pc <= `ZeroWord;
            icache_ce <= 1'b0;
        end
        else if (stall[1] == `NoStop) begin
            icache_pc <= pc_pc;
            icache_ce <= pc_ce;
        end
    end

endmodule 