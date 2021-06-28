`include "lib/defines.vh"
module wb(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,

    input wire [`MEM_TO_WB_WD-1:0] mem_to_wb_bus,
    
    output reg rf_we,
    output reg [`RegAddrBus] rf_waddr,
    output reg [`RegBus] rf_wdata,

    output wire [31:0] debug_wb_pc,
    output wire [3:0] debug_wb_rf_wen,
    output wire [`RegAddrBus] debug_wb_rf_wnum,
    output wire [`RegBus] debug_wb_rf_wdata

// // HI LO
//     input wire [`RegBus] mem_hi,
//     input wire [`RegBus] mem_lo,
//     input wire mem_whilo,

//     output reg [`RegBus] wb_hi,
//     output reg [`RegBus] wb_lo,
//     output reg wb_whilo,

//     input wire [`InstAddrBus] mem_pc,
//     output reg [`InstAddrBus] wb_pc

);

    wire [31:0] pc_i;
    wire rf_we_i;
    wire [`RegAddrBus] rf_waddr_i;
    wire [`RegBus] rf_wdata_i;

    assign {
        pc_i,
        rf_we_i,
        rf_waddr_i,
        rf_wdata_i
    } = mem_to_wb_bus;

    reg [31:0] pc;
    // reg rf_we;
    // reg [`RegAddrBus] rf_waddr;
    // reg [`RegBus] rf_wdata;

    always @ (posedge clk) begin
        if (rst) begin
            pc <= `ZeroWord;
            rf_we <= 1'b0;
            rf_waddr <= `NOPRegAddr;
            rf_wdata <= `ZeroWord;
            // wb_hi <= `ZeroWord;
            // wb_lo <= `ZeroWord;
            // wb_whilo <= 1'b0;
        end
        else if (flush) begin
            pc <= `ZeroWord;
            rf_we <= 1'b0;
            rf_waddr <= `NOPRegAddr;
            rf_wdata <= `ZeroWord;
            // wb_hi <= `ZeroWord;
            // wb_lo <= `ZeroWord;
            // wb_whilo <= 1'b0;
        end
        else if (stall[6] == `Stop && stall[7] == `NoStop) begin
            pc <= `ZeroWord;
            rf_we <= 1'b0;
            rf_waddr <= `NOPRegAddr;
            rf_wdata <= `ZeroWord;
            // wb_hi <= `ZeroWord;
            // wb_lo <= `ZeroWord;
            // wb_whilo <= 1'b0;
        end
        else if (stall[6] == `NoStop) begin
            pc <= pc_i;
            rf_we <= rf_we_i;
            rf_waddr <= rf_waddr_i;
            rf_wdata <= rf_wdata_i;
            // wb_hi <= mem_hi;
            // wb_lo <= mem_lo;
            // wb_whilo <= mem_whilo;
        end
    end

    assign debug_wb_pc = pc;
    assign debug_wb_rf_wen = {4{rf_we}};
    assign debug_wb_rf_wnum = rf_waddr;
    assign debug_wb_rf_wdata = rf_wdata;
endmodule 