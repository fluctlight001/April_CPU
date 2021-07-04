`include "lib/defines.vh"
module id (
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,
    input wire br_e,
    output wire stallreq,

    input wire [`IC_TO_ID_WD-1:0] ic_to_id_bus,

    

    // input wire [31:0] pc_i,  
    input wire [31:0] ic_inst,

    input wire wb_rf_we,
    input wire [`RegAddrBus] wb_rf_waddr,
    input wire [`RegBus] wb_rf_wdata,

    output wire [`ID_TO_EX_WD-1:0] id_to_ex_bus,
    output wire [`RegAddrBus] rs_rf_raddr,
    output wire [`RegAddrBus] rt_rf_raddr
);
    wire [31:0] ic_pc;
    reg [31:0] id_pc;
    reg [31:0] id_inst;
    // wire [31:0] inst_i,
    assign ic_pc = ic_to_id_bus[31:0];

    wire [3:0] sel_nextpc;
    wire [2:0] sel_alu_src1;
    wire [3:0] sel_alu_src2;
    wire [11:0] br_op;
    wire [11:0] alu_op;
    wire data_ram_en;
    wire [3:0] data_ram_wen;
    
    wire rf_we;
    wire [`RegAddrBus] rf_waddr;
    wire sel_rf_res;

    wire [`RegBus] rf_rdata1, rf_rdata2;

    assign id_to_ex_bus = {
        br_op,          // 170:159
        id_pc,          // 158:127
        id_inst,        // 126:95
        alu_op,         // 94:83
        sel_alu_src1,   // 82:80
        sel_alu_src2,   // 79:76
        data_ram_en,    // 75
        data_ram_wen,   // 74:71
        rf_we,          // 70
        rf_waddr,       // 69:65
        sel_rf_res,     // 64
        rf_rdata1,      // 63:32
        rf_rdata2       // 31:0
    };
    reg flag;
    reg [`InstAddrBus] inst;
    always @ (posedge clk) begin
        if (rst) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
            flag <= 1'b0;
        end
        else if (flush || br_e) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
            flag <= 1'b0;
        end
        else if (stall[2] == `Stop && stall[3] == `NoStop) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
            flag <= 1'b0;
        end 
        else if (stall[2] == `NoStop&&flag) begin
            id_pc <= ic_pc;
            id_inst <= inst;
            flag <= 1'b0;
        end
        else if (stall[2]==`NoStop&&~flag) begin
            id_pc <= ic_pc;
            id_inst <= ic_inst;
            flag <= 1'b0;
        end
        else if (~flag) begin
            inst <= ic_inst;
            flag <= 1'b1;
        end
    end

    decoder u_decoder(
    	.rst          (rst          ),
        .stallreq     (stallreq     ),
        .pc_i         (id_pc        ),
        .inst_i       (id_inst      ),

        .br_op        (br_op        ),

        // .sel_nextpc   (sel_nextpc   ),
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
    assign raddr1 = id_inst[25:21];
    assign raddr2 = id_inst[20:16];
    assign rs_rf_raddr = raddr1;
    assign rt_rf_raddr = raddr2;
    
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
    assign rf_rdata2 = sel_r2_wdata ? wb_rf_wdata : rdata2;
    


    
endmodule