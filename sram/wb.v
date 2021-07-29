`include "lib/defines.vh"
module wb(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,

    input wire [`MEM_TO_WB_WD-1:0] mem_to_wb_bus,
    
    output wire rf_we,
    output wire [`RegAddrBus] rf_waddr,
    output wire [`RegBus] rf_wdata,

    output wire [65:0] hilo_bus,

    output wire [37:0] cp0_bus,
    output wire [31:0] cp0_epc_o,
    output wire is_in_delayslot_o,
    output wire [31:0] bad_vaddr_o,
    output wire [31:0] excepttype_o,

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

    reg [`MEM_TO_WB_WD-1:0] mem_to_wb_bus_r;
    // reg rf_we;
    // reg [`RegAddrBus] rf_waddr;
    // reg [`RegBus] rf_wdata;

    always @ (posedge clk) begin
        if (rst) begin
            mem_to_wb_bus_r <= `MEM_TO_WB_WD'b0;
        end
        else if (flush) begin
            mem_to_wb_bus_r <= `MEM_TO_WB_WD'b0;
        end
        else if (stall[7] == `Stop && stall[8] == `NoStop) begin
            mem_to_wb_bus_r <= `MEM_TO_WB_WD'b0;
        end
        else if (stall[7] == `NoStop) begin
            mem_to_wb_bus_r <= mem_to_wb_bus;
        end
    end

    wire [31:0] pc;

    assign {
        cp0_bus,
        cp0_epc_o,
        is_in_delayslot_o,
        bad_vaddr_o,
        excepttype_o,
        hilo_bus,
        pc,
        rf_we,
        rf_waddr,
        rf_wdata
    } = mem_to_wb_bus_r;

    assign debug_wb_pc = pc;
    assign debug_wb_rf_wen = {4{rf_we}};
    assign debug_wb_rf_wnum = rf_waddr;
    assign debug_wb_rf_wdata = rf_wdata;
endmodule 