`include "lib/defines.vh"
module ic(
    input wire clk,
    input wire rst,
    input wire [`StallBus] stall,
    input wire flush,
    input wire br_e,

    input wire [`PC_TO_IC_WD-1:0] pc_to_ic_bus,

    output wire [`IC_TO_ID_WD-1:0] ic_to_id_bus
);
    wire [`InstAddrBus] pc_pc;
    wire pc_ce;
    reg [`InstAddrBus] icache_pc;
    reg icache_ce;
    assign {
        pc_ce,
        pc_pc
    } = pc_to_ic_bus[33:0];
    
    assign ic_to_id_bus = {
        icache_ce,      // 32
        icache_pc       // 31:0
    };

    always @ (posedge clk) begin
        if (rst) begin
            icache_pc <= `ZeroWord;
            icache_ce <= 1'b0;
        end
        else if (flush || br_e) begin
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