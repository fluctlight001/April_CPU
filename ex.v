`include "lib/defines.vh"
module ex (
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,
    output wire stallreq_for_ex,

    input wire [`ID_TO_EX_WD-1:0] id_to_ex_bus,
    
    output wire [`EX_TO_DC_WD-1:0] ex_to_dc_bus,


    // input wire [31:0] pc, inst,
    // input wire [11:0] alu_op,
    // input wire [2:0] sel_alu_src1, sel_alu_src2,
    // input wire [31:0] rf_rdata1, rf_rdata2, imm_sign_extend, sa_zero_extend,
    
    // bypass
    input wire sel_rs_forward,
    input wire [`RegBus] rs_forward_data,
    input wire sel_rt_forward,
    input wire [`RegBus] rt_forward_data,

    // br
    output wire [`BR_WD-1:0] br_bus,

    // hilo
    input wire [31:0] hi_i, lo_i,
    // output wire [65:0] hilo_bus,

    // data sram interface
    output wire        data_sram_en   ,
    output wire [ 3:0] data_sram_wen  ,
    output wire [31:0] data_sram_addr ,
    output wire [31:0] data_sram_wdata

);
    wire [31:0] pc_i,inst_i;
    wire [11:0] br_op_i;
    wire [7:0] hilo_op_i;
    wire [12:0] alu_op_i;
    wire [2:0] sel_alu_src1_i;
    wire [3:0] sel_alu_src2_i;
    wire data_ram_en_i;
    wire [3:0] data_ram_wen_i;
    wire rf_we_i;
    wire [`RegAddrBus] rf_waddr_i;
    wire sel_rf_res_i;
    wire [31:0] rf_rdata1_i, rf_rdata2_i;

    assign {
        hilo_op_i,      // 179:172
        br_op_i,        // 171:160
        pc_i,           // 159:128
        inst_i,         // 127:96
        alu_op_i,       // 95:83
        sel_alu_src1_i, // 82:80
        sel_alu_src2_i, // 79:76
        data_ram_en_i,  // 75
        data_ram_wen_i, // 74:71
        rf_we_i,        // 70 
        rf_waddr_i,     // 69:65
        sel_rf_res_i,   // 64
        rf_rdata1_i,    // 63:32
        rf_rdata2_i     // 31:0
    } = id_to_ex_bus;

    reg [31:0] pc,inst;
    reg [11:0] br_op;
    reg [7:0] hilo_op;
    reg [12:0] alu_op;
    reg [2:0] sel_alu_src1;
    reg [3:0] sel_alu_src2;
    reg data_ram_en;
    reg [3:0] data_ram_wen;
    reg rf_we;
    reg [`RegAddrBus] rf_waddr;
    reg sel_rf_res;
    reg [31:0] rf_rdata1, rf_rdata2;
    wire [31:0] imm_sign_extend, imm_zero_extend, sa_zero_extend;

    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'b0;
            inst <= 32'b0;
            br_op <= 12'b0;
            hilo_op <= 8'b0;
            alu_op <= 13'b0;
            sel_alu_src1 <= 3'b0;
            sel_alu_src2 <= 4'b0;
            data_ram_en <= 1'b0;
            data_ram_wen <= 4'b0;
            rf_we <= 1'b0;
            rf_waddr <= 5'b0;
            sel_rf_res <= 1'b0;
            rf_rdata1 <= 32'b0;
            rf_rdata2 <= 32'b0;
        end
        else if (flush) begin
            pc <= 32'b0;
            inst <= 32'b0;
            br_op <= 12'b0;
            hilo_op <= 8'b0;
            alu_op <= 13'b0;
            sel_alu_src1 <= 3'b0;
            sel_alu_src2 <= 4'b0;
            data_ram_en <= 1'b0;
            data_ram_wen <= 4'b0;
            rf_we <= 1'b0;
            rf_waddr <= 5'b0;
            sel_rf_res <= 1'b0;
            rf_rdata1 <= 32'b0;
            rf_rdata2 <= 32'b0;
        end
        else if(stall[3] == `Stop && stall[4] == `NoStop) begin
            pc <= 32'b0;
            inst <= 32'b0;
            br_op <= 12'b0;
            hilo_op <= 8'b0;
            alu_op <= 13'b0;
            sel_alu_src1 <= 3'b0;
            sel_alu_src2 <= 4'b0;
            data_ram_en <= 1'b0;
            data_ram_wen <= 4'b0;
            rf_we <= 1'b0;
            rf_waddr <= 5'b0;
            sel_rf_res <= 1'b0;
            rf_rdata1 <= 32'b0;
            rf_rdata2 <= 32'b0;
        end
        else if (stall[3] == `NoStop) begin
            pc <= pc_i;
            inst <= inst_i;
            br_op <= br_op_i;
            hilo_op <= hilo_op_i;
            alu_op <= alu_op_i;
            sel_alu_src1 <= sel_alu_src1_i;
            sel_alu_src2 <= sel_alu_src2_i;
            data_ram_en <= data_ram_en_i;
            data_ram_wen <= data_ram_wen_i;
            rf_we <= rf_we_i;
            rf_waddr <= rf_waddr_i;
            sel_rf_res <= sel_rf_res_i;
            rf_rdata1 <= rf_rdata1_i;
            rf_rdata2 <= rf_rdata2_i;
        end
    end

    assign imm_sign_extend = {{16{inst[15]}}, inst[15:0]};
    assign imm_zero_extend = {16'b0, inst[15:0]};
    assign sa_zero_extend = {27'b0,inst[10:6]};

    wire [31:0] alu_src1, alu_src2;
    wire [31:0] alu_result;
    wire [31:0] ex_result;
    wire [31:0] hilo_result;
    wire [65:0] hilo_bus;

    wire [31:0] rf_rdata1_bp; // with forward
    wire [31:0] rf_rdata2_bp; // with forward

    assign rf_rdata1_bp = sel_rs_forward ? rs_forward_data : rf_rdata1; 
    assign rf_rdata2_bp = sel_rt_forward ? rt_forward_data : rf_rdata2;
    
    // mux3_32b u_ALUSrc1(
    // 	.in0 (rf_rdata1_bp      ),
    //     .in1 (pc                ),
    //     .in2 (sa_zero_extend    ),
    //     .sel (sel_alu_src1      ),
    //     .out (alu_src1          )
    // );


    // mux4_32b u_ALUSrc2(
    // 	.in0 (rf_rdata2_bp      ),
    //     .in1 (imm_sign_extend   ),
    //     .in2 (32'd8             ),
    //     .in3 (imm_zero_extend   ),
    //     .sel (sel_alu_src2      ),
    //     .out (alu_src2          )
    // );
    assign alu_src1 = sel_alu_src1[1] ? pc :
                      sel_alu_src1[2] ? sa_zero_extend :
                      sel_rs_forward ? rs_forward_data : rf_rdata1;

    assign alu_src2 = sel_alu_src2[1] ? imm_sign_extend :
                      sel_alu_src2[2] ? 32'd8 :
                      sel_alu_src2[3] ? imm_zero_extend :
                      sel_rt_forward ? rt_forward_data : rf_rdata2;
    alu u_alu(
    	.alu_control (alu_op[11:0]  ),
        .alu_src1    (alu_src1      ),
        .alu_src2    (alu_src2      ),
        .alu_result  (alu_result    )
    );

    assign ex_result = alu_op[12] ? hilo_result : alu_result;
    
    assign ex_to_dc_bus = {
        hilo_bus,       // 141:76
        pc,             // 75:44
        data_ram_en,    // 43
        data_ram_wen,   // 42:39
        sel_rf_res,     // 38
        rf_we,          // 37
        rf_waddr,       // 36:32
        ex_result       // 31:0
    };

    // jump module **************************
    wire inst_beq,  inst_bne,   inst_bgez,  inst_bgtz;
    wire inst_blez, inst_bltz,  inst_bltzal,inst_bgezal;
    wire inst_j,    inst_jal,   inst_jr,    inst_jalr; 

    assign {
        inst_beq,
        inst_bne,
        inst_bgez,
        inst_bgtz,
        inst_blez,
        inst_bltz,
        inst_bgezal,
        inst_bltzal,
        inst_j,
        inst_jal,
        inst_jr,
        inst_jalr
    } = br_op;

    wire branch_e;
    wire [`RegBus] br_target;
    wire rs_eq_rt;
    wire rs_ge_z;
    wire rs_gt_z;
    wire rs_le_z;
    wire rs_lt_z;
    wire [31:0] pc_plus_4;
    assign pc_plus_4 = pc_i; //pc + 32'h4;

    assign rs_eq_rt = (rf_rdata1_bp == rf_rdata2_bp);
    assign rs_ge_z = ~rf_rdata1_bp[31];
    assign rs_gt_z = ($signed(rf_rdata1_bp) > 0);
    assign rs_le_z = (rf_rdata1_bp[31]==1'b1 || rf_rdata1_bp == 32'b0);
    assign rs_lt_z = (rf_rdata1_bp[31]);

    assign branch_e = inst_beq & rs_eq_rt
                    | inst_bne & ~rs_eq_rt
                    | inst_bgez & rs_ge_z
                    | inst_bgezal & rs_ge_z
                    | inst_bgtz & rs_gt_z
                    | inst_blez & rs_le_z
                    | inst_bltz & rs_lt_z
                    | inst_bltzal & rs_lt_z
                    | inst_j
                    | inst_jal
                    | inst_jr
                    | inst_jalr;

    assign br_target = (inst_beq)   ? (pc_plus_4 + {{14{inst[15]}},inst[15:0],2'b0}) :
                       (inst_bne)   ? (pc_plus_4 + {{14{inst[15]}},inst[15:0],2'b0}) :
                       (inst_bgez)  ? (pc_plus_4 + {{14{inst[15]}},inst[15:0],2'b0}) :
                       (inst_bgezal)? (pc_plus_4 + {{14{inst[15]}},inst[15:0],2'b0}) :
                       (inst_bgtz)  ? (pc_plus_4 + {{14{inst[15]}},inst[15:0],2'b0}) :
                       (inst_blez)  ? (pc_plus_4 + {{14{inst[15]}},inst[15:0],2'b0}) :
                       (inst_bltz)  ? (pc_plus_4 + {{14{inst[15]}},inst[15:0],2'b0}) :
                       (inst_bltzal)? (pc_plus_4 + {{14{inst[15]}},inst[15:0],2'b0}) :
                       (inst_j)     ? {pc_plus_4[31:28],inst[25:0],2'b0} :
                       (inst_jal)   ? {pc_plus_4[31:28],inst[25:0],2'b0} : 
                       (inst_jr)    ? rf_rdata1_bp :
                       (inst_jalr)  ? rf_rdata1_bp : 32'b0;

    assign br_bus = {
        branch_e,   // 32
        br_target   // 31:0
    };
    
    assign data_sram_en = data_ram_en;
    assign data_sram_wen = data_ram_wen;
    assign data_sram_addr = alu_result; 
    assign data_sram_wdata = rf_rdata2_bp;



    // hilo part
    wire inst_mfhi, inst_mflo,  inst_mthi,  inst_mtlo;
    wire inst_mult, inst_multu, inst_div,   inst_divu;

    assign {
        inst_mfhi, inst_mflo, inst_mthi, inst_mtlo,
        inst_mult, inst_multu, inst_div, inst_divu
    } = hilo_op;

    wire hi_we, lo_we;
    wire [31:0] hi_o, lo_o;
    wire [63:0] div_result;
    wire [63:0] mod_result;
    wire [63:0] mul_result;
    wire op_mul = inst_mult | inst_multu;
    wire op_div = inst_div | inst_divu;

    assign hi_we = inst_mthi | inst_div | inst_divu | inst_mult | inst_multu;
    assign lo_we = inst_mtlo | inst_div | inst_divu | inst_mult | inst_multu;
    assign hi_o = inst_mthi ? rf_rdata1_bp :
                  op_mul ? mul_result[63:32] :
                  op_div ? div_result[63:32] : 32'b0;
    assign lo_o = inst_mtlo ? rf_rdata1_bp : 
                  op_mul ? mul_result[31:0] :
                  op_div ? div_result[31:0] : 32'b0;

    assign hilo_result = inst_mfhi ? hi_i :
                         inst_mflo ? lo_i : 32'b0;

    assign hilo_bus = {
        hi_we,
        lo_we,
        hi_o,
        lo_o
    };

    wire div_ready_i;
    reg stallreq_for_div;
    assign stallreq_for_ex = stallreq_for_div;

    reg [`RegBus] div_opdata1_o;
    reg [`RegBus] div_opdata2_o;
    reg div_start_o;
    reg signed_div_o;

// MUL 
    mul u_mul(
    	.clk        (clk        ),
        .resetn     (~rst     ),
        .mul_signed (inst_mult ),
        .ina        (rf_rdata1_bp        ),
        .inb        (rf_rdata2_bp        ),
        .result     (mul_result     )
    );
    

// DIV
    div u_div(
    	.rst          (rst          ),
        .clk          (clk          ),
        .signed_div_i (signed_div_o ),
        .opdata1_i    (div_opdata1_o    ),
        .opdata2_i    (div_opdata2_o    ),
        .start_i      (div_start_o      ),
        .annul_i      (1'b0      ),
        .result_o     (div_result     ),
        .ready_o      (div_ready_i      )
    );

    
    always @ (*) begin
        if (rst == `RstEnable) begin
            stallreq_for_div <= `NoStop;
            div_opdata1_o <= `ZeroWord;
            div_opdata2_o <= `ZeroWord;
            div_start_o <= `DivStop;
            signed_div_o <= 1'b0;
        end
        else begin
            stallreq_for_div <= `NoStop;
            div_opdata1_o <= `ZeroWord;
            div_opdata2_o <= `ZeroWord;
            div_start_o <= `DivStop;
            signed_div_o <= 1'b0;
            case ({inst_div,inst_divu})
                2'b10:begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o <= rf_rdata1_bp;
                        div_opdata2_o <= rf_rdata2_bp;
                        div_start_o <= `DivStart;
                        signed_div_o <= 1'b1;
                        stallreq_for_div <= `Stop;
                    end
                    else if (div_ready_i == `DivResultReady) begin
                        div_opdata1_o <= rf_rdata1_bp;
                        div_opdata2_o <= rf_rdata2_bp;
                        div_start_o <= `DivStop;
                        signed_div_o <= 1'b1;
                        stallreq_for_div <= `NoStop;
                    end
                    else begin
                        div_opdata1_o <= `ZeroWord;
                        div_opdata2_o <= `ZeroWord;
                        div_start_o <= `DivStop;
                        signed_div_o <= 1'b0;
                        stallreq_for_div <= `NoStop;
                    end
                end
                2'b01:begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o <= rf_rdata1_bp;
                        div_opdata2_o <= rf_rdata2_bp;
                        div_start_o <= `DivStart;
                        signed_div_o <= 1'b0;
                        stallreq_for_div <= `Stop;
                    end
                    else if (div_ready_i == `DivResultReady) begin
                        div_opdata1_o <= rf_rdata1_bp;
                        div_opdata2_o <= rf_rdata2_bp;
                        div_start_o <= `DivStop;
                        signed_div_o <= 1'b0;
                        stallreq_for_div <= `NoStop;
                    end
                    else begin
                        div_opdata1_o <= `ZeroWord;
                        div_opdata2_o <= `ZeroWord;
                        div_start_o <= `DivStop;
                        signed_div_o <= 1'b0;
                        stallreq_for_div <= `NoStop;
                    end
                end
                default:begin
                end
            endcase
        end
    end
    





    
endmodule