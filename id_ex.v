`include "lib/defines.vh"
module id_ex(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,

    input wire [`InstAddrBus] id_pc,
    input wire [`InstBus] id_inst,
    // ex
    input wire [3:0] sel_nextpc,
    input wire [2:0] id_sel_alu_src1, id_sel_alu_src2,
    input wire [11:0] id_alu_op,
    // mem
    input wire id_data_ram_en,
    input wire id_data_ram_wen,
    //wb
    input wire id_rf_we,
    input wire [2:0] id_sel_rf_dst,
    input wire sel_rf_res,

    input wire [`RegBus] id_rf_rdata1,
    input wire [`RegBus] id_rf_rdata2,
    input wire [`RegBus] id_imm_sign_extend,
    input wire [`RegBus] id_sa_zero_extend,

    output reg [31:0] ex_pc,
    output reg [31:0] ex_inst,
    output reg [2:0] ex_sel_alu_src1, ex_sel_alu_src2,
    output reg [31:0] ex_rf_rdata1, ex_rf_rdata2, ex_imm_sign_extend, ex_sa_zero_extend

);

    always @ (posedge clk) begin
        if (rst) begin
            ex_pc <= 32'b0;
            ex_inst <= 32'b0;
            ex_sel_alu_src1 <= 3'b0;
            ex_sel_alu_src2 <= 3'b0;
            ex_rf_rdata1 <= 32'b0;
            ex_rf_rdata2 <= 32'b0;
            ex_imm_sign_extend <= 32'b0;
            ex_sa_zero_extend <= 32'b0;
        end
        else if (flush) begin
            ex_pc <= 32'b0;
            ex_inst <= 32'b0;
            ex_sel_alu_src1 <= 3'b0;
            ex_sel_alu_src2 <= 3'b0;
            ex_rf_rdata1 <= 32'b0;
            ex_rf_rdata2 <= 32'b0;
            ex_imm_sign_extend <= 32'b0;
            ex_sa_zero_extend <= 32'b0;
        end
        else if (stall[3] == `Stop && stall[4] == `NoStop) begin
            ex_pc <= 32'b0;
            ex_inst <= 32'b0;
            ex_sel_alu_src1 <= 3'b0;
            ex_sel_alu_src2 <= 3'b0;
            ex_rf_rdata1 <= 32'b0;
            ex_rf_rdata2 <= 32'b0;
            ex_imm_sign_extend <= 32'b0;
            ex_sa_zero_extend <= 32'b0;
        end
        else if (stall[3] == `NoStop) begin
            ex_pc <= id_pc;
            ex_inst <= id_inst;
            ex_sel_alu_src1 <= id_sel_alu_src1;
            ex_sel_alu_src2 <= id_sel_alu_src2;
            ex_rf_rdata1 <= id_rf_rdata1;
            ex_rf_rdata2 <= id_rf_rdata2;
            ex_imm_sign_extend <= id_imm_sign_extend;
            ex_sa_zero_extend <= id_sa_zero_extend;
        end
    end

endmodule