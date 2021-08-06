`include "lib/defines.vh"
module ex (
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,
    output wire stallreq_for_ex,

    input wire [`ID_TO_EX_WD-1:0] id_to_ex_bus,
    
    output wire [`EX_TO_DT_WD-1:0] ex_to_dt_bus,


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

    // cp0
    output wire [4:0] cp0_reg_raddr,
    input wire [31:0] cp0_reg_data_i,

    // excepttype
    // input wire is_in_delayslot_i,

    // data sram interface
    
    output wire [`DATA_SRAM_WD-1:0] ex_dt_sram_bus,

    // bpu
    input wire [`BR_WD-1:0] bp_to_ex_bus
);
    wire [31:0] pc_i,inst_i;
    wire [11:0] br_op_i;
    wire [8:0] hilo_op_i;
    wire [4:0] mem_op_i;
    wire [13:0] alu_op_i;
    wire [2:0] sel_alu_src1_i;
    wire [3:0] sel_alu_src2_i;
    wire sel_load_zero_extend_i;
    wire data_ram_en_i;
    wire [3:0] data_ram_wen_i;
    wire rf_we_i;
    wire [`RegAddrBus] rf_waddr_i;
    wire sel_rf_res_i;
    wire [31:0] rf_rdata1_i, rf_rdata2_i;
    wire [31:0] excepttype_i;

    assign {
        excepttype_i,   // 218:187
        mem_op_i,       // 186:182
        hilo_op_i,      // 181:173
        br_op_i,        // 172:161
        pc_i,           // 160:129
        inst_i,         // 128:97
        alu_op_i,       // 96:83
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
    reg [8:0] hilo_op;
    reg [4:0] mem_op;
    reg [13:0] alu_op;
    reg [2:0] sel_alu_src1;
    reg [3:0] sel_alu_src2;
    reg sel_load_zero_extend;
    reg data_ram_en;
    reg [3:0] data_ram_wen;
    reg rf_we;
    reg [`RegAddrBus] rf_waddr;
    reg sel_rf_res;
    reg [31:0] rf_rdata1, rf_rdata2;
    wire [31:0] imm_sign_extend, imm_zero_extend, sa_zero_extend;
    reg [31:0] excepttype_arr;
    wire [31:0] excepttype_o;
    reg is_in_delayslot;

    wire op_br;
    

    always @(posedge clk) begin
        if (rst) begin
            excepttype_arr <= 32'b0;
            pc <= 32'b0;
            inst <= 32'b0;
            br_op <= 12'b0;
            hilo_op <= 9'b0;
            mem_op <= 5'b0;
            alu_op <= 14'b0;
            sel_alu_src1 <= 3'b0;
            sel_alu_src2 <= 4'b0;
            // sel_load_zero_extend <= 1'b0;
            data_ram_en <= 1'b0;
            data_ram_wen <= 4'b0;
            rf_we <= 1'b0;
            rf_waddr <= 5'b0;
            sel_rf_res <= 1'b0;
            rf_rdata1 <= 32'b0;
            rf_rdata2 <= 32'b0;
            is_in_delayslot <= 1'b0;
        end
        else if (flush) begin
            excepttype_arr <= 32'b0;
            pc <= 32'b0;
            inst <= 32'b0;
            br_op <= 12'b0;
            hilo_op <= 9'b0;
            mem_op <= 5'b0;
            alu_op <= 14'b0;
            sel_alu_src1 <= 3'b0;
            sel_alu_src2 <= 4'b0;
            // sel_load_zero_extend <= 1'b0;
            data_ram_en <= 1'b0;
            data_ram_wen <= 4'b0;
            rf_we <= 1'b0;
            rf_waddr <= 5'b0;
            sel_rf_res <= 1'b0;
            rf_rdata1 <= 32'b0;
            rf_rdata2 <= 32'b0;
            is_in_delayslot <= 1'b0;
        end
        else if(stall[3] == `Stop && stall[4] == `NoStop) begin
            excepttype_arr <= 32'b0;
            pc <= 32'b0;
            inst <= 32'b0;
            br_op <= 12'b0;
            hilo_op <= 9'b0;
            mem_op <= 5'b0;
            alu_op <= 14'b0;
            sel_alu_src1 <= 3'b0;
            sel_alu_src2 <= 4'b0;
            // sel_load_zero_extend <= 1'b0;
            data_ram_en <= 1'b0;
            data_ram_wen <= 4'b0;
            rf_we <= 1'b0;
            rf_waddr <= 5'b0;
            sel_rf_res <= 1'b0;
            rf_rdata1 <= 32'b0;
            rf_rdata2 <= 32'b0;
            is_in_delayslot <= 1'b0;
        end
        else if (stall[3] == `NoStop) begin
            excepttype_arr <= excepttype_i;
            pc <= pc_i;
            inst <= inst_i;
            br_op <= br_op_i;
            hilo_op <= hilo_op_i;
            mem_op <= mem_op_i;
            alu_op <= alu_op_i;
            sel_alu_src1 <= sel_alu_src1_i;
            sel_alu_src2 <= sel_alu_src2_i;
            // sel_load_zero_extend <= sel_load_zero_extend_i;
            data_ram_en <= data_ram_en_i;
            data_ram_wen <= data_ram_wen_i;
            rf_we <= rf_we_i;
            rf_waddr <= rf_waddr_i;
            sel_rf_res <= sel_rf_res_i;
            rf_rdata1 <= rf_rdata1_i;
            rf_rdata2 <= rf_rdata2_i;
            is_in_delayslot <= op_br;
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

// output
    wire ovassert, loadassert, storeassert;
    wire [31:0] bad_vaddr;
    wire cp0_op;
    wire [37:0] cp0_bus;
    reg stop_store;
    wire [63:0] mul_result;
    wire inst_mul;
    
    assign ex_result = alu_op[12] ? hilo_result :
                       cp0_op ? cp0_reg_data_i :
                       inst_mul ? mul_result[31:0] : alu_result;
    assign excepttype_o = {excepttype_arr[31:16],loadassert,storeassert,excepttype_arr[13:12],ovassert,1'b0,excepttype_arr[9:8],8'b0};
    
    always @ (posedge clk) begin
        if (rst) begin
            stop_store <= 1'b0;
        end
        else if (flush) begin
            stop_store <= 1'b0;
        end
        else if (|excepttype_o) begin
            stop_store <= 1'b1;
        end
    end
    assign ex_to_dt_bus = {
        cp0_bus,        // 249:212
        is_in_delayslot,// 211
        bad_vaddr,      // 210:179
        excepttype_o,   // 178:147
        mem_op,         // 146:142 
        hilo_bus,       // 141:76
        pc,             // 75:44
        data_ram_en,    // 43
        data_ram_wen,   // 42:39
        sel_rf_res,     // 38
        rf_we,          // 37
        rf_waddr,       // 36:32
        ex_result       // 31:0
    };

// jump part **************************
    wire inst_beq,  inst_bne,   inst_bgez,  inst_bgtz;
    wire inst_blez, inst_bltz,  inst_bltzal,inst_bgezal;
    wire inst_j,    inst_jal,   inst_jr,    inst_jalr; 

    assign op_br = inst_beq | inst_bne | inst_bgez | inst_bgtz
                 | inst_blez | inst_bltz | inst_bltzal | inst_bgezal 
                 | inst_j | inst_jal | inst_jr | inst_jalr;
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
    wire bp_e;
    wire [31:0] bp_target;
    wire real_br_e;
    wire [31:0] real_br_target;
    wire rs_eq_rt;
    wire rs_ge_z;
    wire rs_gt_z;
    wire rs_le_z;
    wire rs_lt_z;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_plus_8;
    assign pc_plus_4 = pc + 32'h4;
    assign pc_plus_8 = pc + 32'h8;

    assign rs_eq_rt = (rf_rdata1_bp == rf_rdata2_bp);
    assign rs_ge_z = ~rf_rdata1_bp[31];
    assign rs_gt_z = ($signed(rf_rdata1_bp) > 0);
    assign rs_le_z = (rf_rdata1_bp[31]==1'b1 || rf_rdata1_bp == 32'b0);
    assign rs_lt_z = (rf_rdata1_bp[31]);

    assign real_br_e = inst_beq & rs_eq_rt
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

    assign real_br_target = (inst_beq)   ? (pc_plus_4 + {{14{inst[15]}},inst[15:0],2'b0}) :
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

    assign {
        bp_e,
        bp_target
    } = bp_to_ex_bus;

    wire jump_err, nojump_err, target_err;
    assign target_err = (real_br_target != bp_target);
    assign jump_err = (~bp_e & real_br_e) | (bp_e & real_br_e & target_err);
    assign nojump_err = bp_e & ~real_br_e;
    assign branch_e = jump_err | nojump_err;
    assign br_target = jump_err ? real_br_target 
                     : nojump_err ? pc_plus_8 : 32'b0;

    assign br_bus = {
        branch_e,   // 32
        br_target   // 31:0
    };

// store part

    wire inst_sb, inst_sh, inst_sw;
    assign {
        inst_sb,
        inst_sh,
        inst_sw
    } = data_ram_wen[2:0];

    // wire sb_sel1, sb_sel2, sb_sel3, sb_sel4;
    // wire sh_sel1, sh_sel2;
    // wire sw_sel;

    // assign sb_sel1 = inst_sb & ~alu_result[1] & ~alu_result[0];
    // assign sb_sel2 = inst_sb & ~alu_result[1] & alu_result[0];
    // assign sb_sel3 = inst_sb & alu_result[1] & ~alu_result[0];
    // assign sb_sel4 = inst_sb & alu_result[1] & alu_result[0];

    // assign sh_sel1 = inst_sh & ~alu_result[1] & ~alu_result[0];
    // assign sh_sel2 = inst_sh & alu_result[1] & ~alu_result[0];

    reg [3:0] data_sram_wen_r;
    reg [31:0] data_sram_wdata_r;
    
    always @ (*) begin
        case(1'b1)
            inst_sb:begin
                data_sram_wdata_r = {4{rf_rdata2_bp[7:0]}};
                case(alu_result[1:0])
                    2'b00:begin
                        data_sram_wen_r = 4'b0001;
                    end
                    2'b01:begin
                        data_sram_wen_r = 4'b0010;
                    end
                    2'b10:begin
                        data_sram_wen_r = 4'b0100;
                    end
                    2'b11:begin
                        data_sram_wen_r = 4'b1000;
                    end
                    default:begin
                        data_sram_wen_r = 4'b0;
                    end
                endcase
            end
            inst_sh:begin
                data_sram_wdata_r = {2{rf_rdata2_bp[15:0]}};
                case(alu_result[1:0])
                    2'b00:begin
                        data_sram_wen_r = 4'b0011;
                    end
                    2'b10:begin
                        data_sram_wen_r = 4'b1100;
                    end
                    default:begin
                        data_sram_wen_r = 4'b0000;
                    end
                endcase
            end
            inst_sw:begin
                data_sram_wdata_r = rf_rdata2_bp;
                data_sram_wen_r = 4'b1111;
            end
            default:begin
                data_sram_wdata_r = 32'b0;
                data_sram_wen_r = 4'b0000;
            end
        endcase
    end
    wire        data_sram_en   ;
    wire [ 3:0] data_sram_wen  ;
    wire [31:0] data_sram_addr ;
    wire [31:0] data_sram_wdata;
    assign data_sram_en = (|excepttype_o)|stop_store ? 1'b0 : data_ram_en;
    assign data_sram_wen = data_sram_wen_r;
    assign data_sram_addr = alu_result; 
    assign data_sram_wdata = data_sram_wdata_r;

    assign ex_dt_sram_bus = {
        data_sram_en,   // 68
        data_sram_wen,   // 67:64
        data_sram_addr, // 63:32
        data_sram_wdata // 31:0
    };


// hilo part
    wire inst_mfhi, inst_mflo,  inst_mthi,  inst_mtlo;
    wire inst_mult, inst_multu, inst_div,   inst_divu;
    // wire inst_mul;

    assign {
        inst_mfhi, inst_mflo, inst_mthi, inst_mtlo,
        inst_mult, inst_multu, inst_div, inst_divu,
        inst_mul
    } = hilo_op;

    wire hi_we, lo_we;
    wire [31:0] hi_o, lo_o;
    wire [63:0] div_result;
    wire [63:0] mod_result;
    // wire [63:0] mul_result;
    wire op_mul = inst_mul | inst_mult | inst_multu;
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
    reg stallreq_for_mul;
    assign stallreq_for_ex = stallreq_for_div | stallreq_for_mul;

    reg [`RegBus] div_opdata1_o;
    reg [`RegBus] div_opdata2_o;
    reg div_start_o;
    reg signed_div_o;

// MUL part
    mul u_mul(
    	.clk        (clk        ),
        .resetn     (~rst     ),
        .mul_signed (inst_mult ),
        .ina        (rf_rdata1_bp        ),
        .inb        (rf_rdata2_bp        ),
        .result     (mul_result     )
    );
    
    reg cnt;
    reg next_cnt;
    
    always @ (posedge clk) begin
        if (rst) begin
           cnt <= 1'b0; 
        end
        else begin
           cnt <= next_cnt; 
        end
    end

    always @ (*) begin
        if (rst) begin
            stallreq_for_mul <= 1'b0;
            next_cnt <= 1'b0;
        end
        else if((inst_mult|inst_multu)&~cnt) begin
            stallreq_for_mul <= 1'b1;
            next_cnt <= 1'b1;
        end
        else if((inst_mult|inst_multu)&cnt) begin
            stallreq_for_mul <= 1'b0;
            next_cnt <= 1'b0;
        end
        else begin
           stallreq_for_mul <= 1'b0;
           next_cnt <= 1'b0; 
        end
    end

// DIV part
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
            stallreq_for_div = `NoStop;
            div_opdata1_o = `ZeroWord;
            div_opdata2_o = `ZeroWord;
            div_start_o = `DivStop;
            signed_div_o = 1'b0;
        end
        else begin
            stallreq_for_div = `NoStop;
            div_opdata1_o = `ZeroWord;
            div_opdata2_o = `ZeroWord;
            div_start_o = `DivStop;
            signed_div_o = 1'b0;
            case ({inst_div,inst_divu})
                2'b10:begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o = rf_rdata1_bp;
                        div_opdata2_o = rf_rdata2_bp;
                        div_start_o = `DivStart;
                        signed_div_o = 1'b1;
                        stallreq_for_div = `Stop;
                    end
                    else if (div_ready_i == `DivResultReady) begin
                        div_opdata1_o = rf_rdata1_bp;
                        div_opdata2_o = rf_rdata2_bp;
                        div_start_o = `DivStop;
                        signed_div_o = 1'b1;
                        stallreq_for_div = `NoStop;
                    end
                    else begin
                        div_opdata1_o = `ZeroWord;
                        div_opdata2_o = `ZeroWord;
                        div_start_o = `DivStop;
                        signed_div_o = 1'b0;
                        stallreq_for_div = `NoStop;
                    end
                end
                2'b01:begin
                    if (div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o = rf_rdata1_bp;
                        div_opdata2_o = rf_rdata2_bp;
                        div_start_o = `DivStart;
                        signed_div_o = 1'b0;
                        stallreq_for_div = `Stop;
                    end
                    else if (div_ready_i == `DivResultReady) begin
                        div_opdata1_o = rf_rdata1_bp;
                        div_opdata2_o = rf_rdata2_bp;
                        div_start_o = `DivStop;
                        signed_div_o = 1'b0;
                        stallreq_for_div = `NoStop;
                    end
                    else begin
                        div_opdata1_o = `ZeroWord;
                        div_opdata2_o = `ZeroWord;
                        div_start_o = `DivStop;
                        signed_div_o = 1'b0;
                        stallreq_for_div = `NoStop;
                    end
                end
                default:begin
                end
            endcase
        end
    end
    

// excepttype 
    // wire trapassert;

    wire ov_sum;
    wire [31:0] src2_mux;
    
    
    // ovassert
    assign src2_mux = alu_op[10] ? (~alu_src2)+1 : alu_src2;
    assign ov_sum = ((~alu_src1[31] && ~src2_mux[31] && alu_result[31]) || (alu_src1[31] && src2_mux[31]) && (~alu_result[31]));
    assign ovassert = alu_op[13] & ov_sum;

    // loadassert
    wire inst_lb, inst_lbu, inst_lh, inst_lhu, inst_lw;
    assign {
        inst_lb,
        inst_lbu,
        inst_lh,
        inst_lhu,
        inst_lw
    } = mem_op;
    assign loadassert = (inst_lh|inst_lhu) & alu_result[0]
                      | (inst_lw) & (alu_result[1]|alu_result[0]);
    assign storeassert = (inst_sh) & alu_result[0] 
                      | (inst_sw) & (alu_result[1]|alu_result[0]);
    assign bad_vaddr = excepttype_arr[16] ? pc : alu_result;

// cp0 part
    wire inst_mfc0,inst_mtc0;
    assign {
        inst_mfc0,
        inst_mtc0
    } = excepttype_arr[1:0];
    assign cp0_op = inst_mfc0;

    wire cp0_reg_we = inst_mtc0;
    wire [4:0] cp0_reg_waddr = inst[15:11];
    wire [31:0] cp0_reg_wdata = alu_src2;

    assign cp0_reg_raddr = inst[15:11];

    assign cp0_bus = {
        cp0_reg_we,
        cp0_reg_waddr,
        cp0_reg_wdata
    };
    


    
endmodule