`include "lib/defines.vh"
module id (
    input wire clk,
    input wire rst,
    output wire stallreq,
    input wire [31:0] pc_i,
    input wire [31:0] inst_i,

    input wire wb_rf_we,
    input wire [`RegAddrBus] wb_rf_waddr,
    input wire [`RegBus] wb_rf_wdata,

    output wire [3:0] sel_nextpc,
    output wire [2:0] sel_alu_src1,sel_alu_src2,
    output wire [11:0] alu_op,
    output wire data_ram_en,
    output wire data_ram_wen,
    
    output wire rf_we,
    output wire rf_waddr,
    output wire sel_rf_res,

    output wire [`RegBus] rf_rdata1, rf_rdata2

);
    decoder u_decoder(
    	.rst          (rst          ),
        .stallreq     (stallreq     ),
        .pc_i         (pc_i         ),
        .inst_i       (inst_i       ),
        .sel_nextpc   (sel_nextpc   ),
        .sel_alu_src1 (sel_alu_src1 ),
        .sel_alu_src2 (sel_alu_src2 ),
        .alu_op       (alu_op       ),
        .data_ram_en  (data_ram_en  ),
        .data_ram_wen (data_ram_wen ),
        .rf_we        (rf_we        ),
        .rf_waddr     (rf_waddr     ),
        .sel_rf_res   (sel_rf_res   )
    );

    wire [`RegAddrBus] raddr1;
    wire [`RegAddrBus] raddr2;
    wire [`RegBus] rdata1;
    wire [`RegBus] rdata2;
    assign raddr1 = inst_i[25:21];
    assign raddr2 = inst_i[20:16];
    
    regfile u_regfile(
    	.clk    (clk    ),
        .raddr1 (raddr1 ),
        .rdata1 (rdata1 ),
        .raddr2 (raddr2 ),
        .rdata2 (rdata2 ),
        .we     (wb_rf_we     ),
        .waddr  (wb_rf_waddr  ),
        .wdata  (wb_rf_wdata  )
    );

    // write first & bypass
    wire sel_r1_wdata;
    wire sel_r2_wdata;
    assign sel_r1_wdata = wb_rf_we & (wb_rf_waddr == raddr1);
    assign sel_r2_wdata = wb_rf_we & (wb_rf_waddr == raddr2);

    assign rf_rdata1 = sel_r1_wdata ? wb_rf_wdata : rdata1;
    assign rf_rdata1 = sel_r2_wdata ? wb_rf_wdata : rdata2;
    


    
endmodule