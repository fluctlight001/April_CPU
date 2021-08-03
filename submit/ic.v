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
    wire [31:0] excepttype_i;
    reg [`InstAddrBus] icache_pc;
    reg icache_ce;
    reg [31:0] excepttype_o;
    assign {
        excepttype_i,
        pc_ce,
        pc_pc
    } = pc_to_ic_bus;
    
    assign ic_to_id_bus = {
        excepttype_o,   // 64:33
        icache_ce,      // 32
        icache_pc       // 31:0
    };

    always @ (posedge clk) begin
        if (rst) begin
            excepttype_o <= 32'b0;
            icache_pc <= `ZeroWord;
            icache_ce <= 1'b0;
        end
        else if (flush || br_e) begin
            excepttype_o <= 32'b0;
            icache_pc <= `ZeroWord;
            icache_ce <= 1'b0;
        end
        else if (stall[1] == `Stop && stall[2] == `NoStop)begin
            excepttype_o <= 32'b0;
            icache_pc <= `ZeroWord;
            icache_ce <= 1'b0;
        end
        else if (stall[1] == `NoStop) begin
            excepttype_o <= excepttype_i;
            icache_pc <= pc_pc;
            icache_ce <= pc_ce;
        end
    end

endmodule 