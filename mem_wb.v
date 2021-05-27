`include "lib/defines.vh"
module mem_wb(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,

    input wire mem_rf_we,
    input wire [`RegAddrBus] mem_rf_waddr,
    input wire [`RegBus] mem_rf_wdata,

    output reg wb_rf_we,
    output reg [`RegAddrBus] wb_rf_waddr,
    output reg [`RegBus] wb_rf_wdata,

// HI LO
    input wire [`RegBus] mem_hi,
    input wire [`RegBus] mem_lo,
    input wire mem_whilo,

    output reg [`RegBus] wb_hi,
    output reg [`RegBus] wb_lo,
    output reg wb_whilo,

    input wire [`InstAddrBus] mem_pc,
    output reg [`InstAddrBus] wb_pc

);
    always @ (posedge clk) begin
        if (rst) begin
            wb_rf_we <= 1'b0;
            wb_rf_waddr <= `NOPRegAddr;
            wb_rf_wdata <= `ZeroWord;
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
            wb_whilo <= 1'b0;

            wb_pc <= `ZeroWord;
        end
        else if (flush) begin
            wb_rf_we <= 1'b0;
            wb_rf_waddr <= `NOPRegAddr;
            wb_rf_wdata <= `ZeroWord;
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
            wb_whilo <= 1'b0;

            wb_pc <= `ZeroWord;
        end
        else if (stall[6] == `Stop && stall[7] == `NoStop) begin
            wb_rf_we <= 1'b0;
            wb_rf_waddr <= `NOPRegAddr;
            wb_rf_wdata <= `ZeroWord;
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
            wb_whilo <= 1'b0;

            wb_pc <= `ZeroWord;
        end
        else if (stall[6] == `NoStop) begin
            wb_rf_we <= mem_rf_we;
            wb_rf_waddr <= mem_rf_waddr;
            wb_rf_wdata <= mem_rf_wdata;
            wb_hi <= mem_hi;
            wb_lo <= mem_lo;
            wb_whilo <= mem_whilo;

            wb_pc <= mem_pc;
        end
    end
endmodule 