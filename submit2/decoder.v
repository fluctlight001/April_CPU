`include "lib/defines.vh"
module decoder (
    input wire rst,
    output wire stallreq,
    input wire [`InstAddrBus] pc_i,
    input wire [`InstBus] inst_i,

    output wire [11:0] br_op,
    output wire [8:0] hilo_op,
    output wire [4:0] mem_op,

    output wire [2:0] sel_alu_src1, 
    output wire [3:0] sel_alu_src2,
    output wire [13:0] alu_op,
    // output wire sel_load_zero_extend,
    output wire data_ram_en, 
    output wire [3:0] data_ram_wen,
    output wire rf_we, // 写使能
    output wire [`RegAddrBus] rf_waddr, // 写地址
    output wire sel_rf_res, // 写数据sel
    
    output wire [31:0] excepttype_o
);
    wire [5:0] opcode;
    wire [`RegAddrBus] rs;
    wire [`RegAddrBus] rt;
    wire [`RegAddrBus] rd;
    wire [`RegAddrBus] sa;
    wire [5:0] func;
    wire [15:0] imm;
    wire [25:0] instr_index;
    wire [19:0] code;
    wire [4:0] base;
    wire [15:0] offset;
    wire [2:0] sel;

    wire [63:0] op_d, func_d;
    wire [31:0] rs_d, rt_d;
    // wire [31:0] sa_d;

    assign opcode = inst_i[31:26];
    assign rs = inst_i[25:21];
    assign rt = inst_i[20:16];
    assign rd = inst_i[15:11];
    assign sa = inst_i[10: 6];
    assign func = inst_i[5:0];
    assign imm = inst_i[15:0];
    assign instr_index = inst_i[25:0];
    assign code = inst_i[25:6];
    assign base = inst_i[25:21];
    assign offset = inst_i[15:0];
    assign sel = inst_i[2:0];

    wire [2:0] sel_rf_dst; // 写地址sel


    wire inst_add,  inst_addi,  inst_addu,  inst_addiu;
    wire inst_sub,  inst_subu,  inst_slt,   inst_slti;  
    wire inst_sltu, inst_sltiu, inst_div,   inst_divu;
    wire inst_mult, inst_multu, inst_and,   inst_andi;  
    wire inst_lui,  inst_nor,   inst_or,    inst_ori;
    wire inst_xor,  inst_xori,  inst_sll,   inst_sllv;
    wire inst_sra,  inst_srav,  inst_srl,   inst_srlv;
    wire inst_beq,  inst_bne,   inst_bgez,  inst_bgtz;
    wire inst_blez, inst_bltz,  inst_bltzal,inst_bgezal;
    wire inst_j,    inst_jal,   inst_jr,    inst_jalr;  
    wire inst_mfhi, inst_mflo,  inst_mthi,  inst_mtlo;
    wire inst_lb,   inst_lbu,   inst_lh,    inst_lhu;
    wire inst_lw,   inst_sb,    inst_sh,    inst_sw;
    wire inst_break,    inst_syscall;
    wire inst_eret, inst_mfc0,  inst_mtc0;
    wire inst_mul;


    wire op_add, op_sub, op_slt, op_sltu;
    wire op_and, op_nor, op_or, op_xor;
    wire op_sll, op_srl, op_sra, op_lui;
    wire op_hilo, op_excepttype;

    wire excepttype_is_syscall, excepttype_is_eret, excepttype_is_break, excepttype_is_instinvalid;
    assign excepttype_o = {18'b0,excepttype_is_break,excepttype_is_eret,2'b00,excepttype_is_instinvalid,excepttype_is_syscall,6'b0,inst_mfc0,inst_mtc0};
    
    assign excepttype_is_syscall = inst_syscall;
    assign excepttype_is_eret = inst_eret;
    assign excepttype_is_break = inst_break;
    assign excepttype_is_instinvalid = ~(inst_add | inst_addi | inst_addu | inst_addiu
                                        | inst_sub | inst_subu | inst_slt | inst_slti 
                                        | inst_sltu | inst_sltiu | inst_div | inst_divu
                                        | inst_mul | inst_mult | inst_multu | inst_and | inst_andi 
                                        | inst_lui | inst_nor | inst_or | inst_ori 
                                        | inst_xor | inst_xori | inst_sll | inst_sllv
                                        | inst_sra | inst_srav | inst_srl | inst_srlv
                                        | inst_beq | inst_bne | inst_bgez | inst_bgtz
                                        | inst_blez | inst_bltz | inst_bltzal | inst_bgezal
                                        | inst_j | inst_jal | inst_jr | inst_jalr 
                                        | inst_mfhi | inst_mflo | inst_mthi | inst_mtlo 
                                        | inst_lb | inst_lbu | inst_lh | inst_lhu 
                                        | inst_lw | inst_sb | inst_sh | inst_sw 
                                        | inst_break | inst_syscall | inst_eret 
                                        | inst_mfc0 | inst_mtc0);

    decoder_6_64 u0_decoder_6_64(
    	.in  (opcode),
        .out (op_d )
    );

    decoder_6_64 u1_decoder_6_64(
    	.in  (func),
        .out (func_d)
    );

    decoder_5_32 u0_decoder_5_32(
    	.in  (rs  ),
        .out (rs_d )
    );

    decoder_5_32 u1_decoder_5_32(
    	.in  (rt  ),
        .out (rt_d )
    );

    // decoder_5_32 u2_decoder_5_32(
    // 	.in  (sa  ),
    //     .out (sa_d )
    // );
    
    assign inst_add     = op_d[6'b00_0000] & func_d[6'b10_0000];
    assign inst_addi    = op_d[6'b00_1000];
    assign inst_addu    = op_d[6'b00_0000] & func_d[6'b10_0001];
    assign inst_addiu   = op_d[6'b00_1001];
    assign inst_sub     = op_d[6'b00_0000] & func_d[6'b10_0010];
    assign inst_subu    = op_d[6'b00_0000] & func_d[6'b10_0011];
    assign inst_slt     = op_d[6'b00_0000] & func_d[6'b10_1010];
    assign inst_slti    = op_d[6'b00_1010];
    assign inst_sltu    = op_d[6'b00_0000] & func_d[6'b10_1011];
    assign inst_sltiu   = op_d[6'b00_1011];

    assign inst_div     = op_d[6'b00_0000] & func_d[6'b01_1010];
    assign inst_divu    = op_d[6'b00_0000] & func_d[6'b01_1011];
    assign inst_mul     = op_d[6'b01_1100] & func_d[6'b00_0010];
    assign inst_mult    = op_d[6'b00_0000] & func_d[6'b01_1000];
    assign inst_multu   = op_d[6'b00_0000] & func_d[6'b01_1001];
    
    assign inst_and     = op_d[6'b00_0000] & func_d[6'b10_0100];
    assign inst_andi    = op_d[6'b00_1100];
    assign inst_lui     = op_d[6'b00_1111];
    assign inst_nor     = op_d[6'b00_0000] & func_d[6'b10_0111];
    assign inst_or      = op_d[6'b00_0000] & func_d[6'b10_0101];
    assign inst_ori     = op_d[6'b00_1101];
    assign inst_xor     = op_d[6'b00_0000] & func_d[6'b10_0110];
    assign inst_xori    = op_d[6'b00_1110];
    
    assign inst_sllv    = op_d[6'b00_0000] & func_d[6'b00_0100];
    assign inst_sll     = op_d[6'b00_0000] & func_d[6'b00_0000];
    assign inst_srav    = op_d[6'b00_0000] & func_d[6'b00_0111];
    assign inst_sra     = op_d[6'b00_0000] & func_d[6'b00_0011];
    assign inst_srlv    = op_d[6'b00_0000] & func_d[6'b00_0110];
    assign inst_srl     = op_d[6'b00_0000] & func_d[6'b00_0010];

    assign inst_beq     = op_d[6'b00_0100];
    assign inst_bne     = op_d[6'b00_0101];
    assign inst_bgez    = op_d[6'b00_0001] & rt_d[5'b0_0001];
    assign inst_bgtz    = op_d[6'b00_0111];
    assign inst_blez    = op_d[6'b00_0110];
    assign inst_bltz    = op_d[6'b00_0001] & rt_d[5'b0_0000];
    assign inst_bgezal  = op_d[6'b00_0001] & rt_d[5'b1_0001];
    assign inst_bltzal  = op_d[6'b00_0001] & rt_d[5'b1_0000];
    assign inst_j       = op_d[6'b00_0010];
    assign inst_jal     = op_d[6'b00_0011];
    assign inst_jr      = op_d[6'b00_0000] & func_d[6'b00_1000];
    assign inst_jalr    = op_d[6'b00_0000] & func_d[6'b00_1001];

    assign inst_mfhi    = op_d[6'b00_0000] & func_d[6'b01_0000];
    assign inst_mflo    = op_d[6'b00_0000] & func_d[6'b01_0010];
    assign inst_mthi    = op_d[6'b00_0000] & func_d[6'b01_0001];
    assign inst_mtlo    = op_d[6'b00_0000] & func_d[6'b01_0011];

    assign inst_break   = op_d[6'b00_0000] & func_d[6'b00_1101];
    assign inst_syscall = op_d[6'b00_0000] & func_d[6'b00_1100];

    assign inst_lb      = op_d[6'b10_0000];
    assign inst_lbu     = op_d[6'b10_0100];
    assign inst_lh      = op_d[6'b10_0001];
    assign inst_lhu     = op_d[6'b10_0101];
    assign inst_lw      = op_d[6'b10_0011];
    assign inst_sb      = op_d[6'b10_1000];
    assign inst_sh      = op_d[6'b10_1001];
    assign inst_sw      = op_d[6'b10_1011];

    assign inst_eret    = op_d[6'b01_0000] & func_d[6'b01_1000];
    assign inst_mfc0    = op_d[6'b01_0000] & rs_d[5'b0_0000];
    assign inst_mtc0    = op_d[6'b01_0000] & rs_d[5'b0_0100];


    // rs to reg1  
    assign sel_alu_src1[0] = inst_add | inst_addi | inst_addu | inst_addiu 
                           | inst_sub | inst_subu | inst_slt | inst_slti 
                           | inst_sltu | inst_sltiu | inst_div | inst_divu 
                           | inst_mul | inst_mult | inst_multu | inst_and | inst_andi 
                           | inst_nor | inst_or | inst_ori | inst_xor 
                           | inst_xori | inst_sllv | inst_srav | inst_srlv
                           | inst_mthi | inst_mtlo 
                           | inst_lb | inst_lbu | inst_lh | inst_lhu 
                           | inst_lw | inst_sb | inst_sh | inst_sw; 
    // pc to reg1
    assign sel_alu_src1[1] = inst_jal | inst_bltzal | inst_bgezal | inst_jalr;
    // sa_zero_extend to reg1
    assign sel_alu_src1[2] = inst_sll | inst_sra | inst_srl;
                           

    // rt to reg2
    assign sel_alu_src2[0] = inst_add | inst_addu | inst_sub | inst_subu 
                           | inst_slt | inst_sltu | inst_div | inst_divu 
                           | inst_mul | inst_mult | inst_multu | inst_and | inst_nor 
                           | inst_or | inst_xor | inst_sllv | inst_sll 
                           | inst_srav | inst_sra | inst_srlv | inst_srl;
    // imm_sign_extend to reg2
    assign sel_alu_src2[1] = inst_addi | inst_addiu | inst_lw | inst_lb | inst_lbu | inst_lh | inst_lhu | inst_sw | inst_sh | inst_sb | inst_lui
                           | inst_slti | inst_sltiu ;
    // 32'd8 to reg2
    assign sel_alu_src2[2] = inst_jal | inst_bltzal | inst_bgezal | inst_jalr;

    // imm_zero_extend to reg2
    assign sel_alu_src2[3] = inst_ori | inst_andi | inst_xori;

    


    assign op_add = inst_add | inst_addu | inst_addi | inst_addiu | inst_lw | | inst_lb | inst_lbu | inst_lh | inst_lhu | inst_sw | inst_sh | inst_sb | inst_jal | inst_bltzal | inst_bgezal | inst_jalr;
    assign op_sub = inst_sub | inst_subu;
    assign op_slt = inst_slt | inst_slti;
    assign op_sltu = inst_sltu | inst_sltiu;
    assign op_and = inst_and | inst_andi;
    assign op_nor = inst_nor;
    assign op_or = inst_or | inst_ori;
    assign op_xor = inst_xor | inst_xori;
    assign op_sll = inst_sllv | inst_sll;
    assign op_srl = inst_srlv | inst_srl;
    assign op_sra = inst_srav | inst_sra;
    assign op_lui = inst_lui;
    assign op_hilo = inst_mfhi | inst_mflo;
    assign op_excepttype = inst_add | inst_addi | inst_sub;

    assign alu_op = {op_excepttype, op_hilo,
                     op_add, op_sub, op_slt, op_sltu,
                     op_and, op_nor, op_or, op_xor,
                     op_sll, op_srl, op_sra, op_lui};

    assign mem_op = {
        inst_lb,
        inst_lbu,
        inst_lh,
        inst_lhu,
        inst_lw
    };
    // assign sel_load_zero_extend = inst_lbu | inst_lhu;
    assign data_ram_en = inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lw | inst_sb | inst_sh | inst_sw;
    // wire data_ram_wen_temp;
    // assign data_ram_wen_temp = inst_sw;
    assign data_ram_wen = {1'b0,inst_sb,inst_sh,inst_sw};
    

    // store enable
    assign rf_we = inst_add | inst_addu | inst_addi | inst_addiu | inst_sub | inst_subu | inst_lw | inst_lb | inst_lbu | inst_lh | inst_lhu
                 | inst_jal | inst_bltzal | inst_bgezal | inst_jalr | inst_slt | inst_slti | inst_sltu | inst_sltiu | inst_sllv | inst_sll 
                 | inst_srlv | inst_srl | inst_srav | inst_sra | inst_lui | inst_and | inst_andi
                 | inst_or | inst_ori | inst_xor | inst_xori | inst_nor | inst_mfhi | inst_mflo | inst_mfc0 | inst_mul;

    // store in [rd]
    assign sel_rf_dst[0] = inst_add | inst_addu | inst_sub | inst_subu | inst_slt | inst_sltu 
                         | inst_sllv | inst_sll | inst_srlv | inst_srl | inst_srav | inst_sra | inst_and 
                         | inst_or | inst_xor | inst_nor | inst_mfhi | inst_mflo | inst_mul;
    // store in [rt] 
    assign sel_rf_dst[1] = inst_addi | inst_addiu | inst_lw | inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lui | inst_ori | inst_andi | inst_xori | inst_slti | inst_sltiu | inst_mfc0;
    // store in [31]
    assign sel_rf_dst[2] = inst_jal | inst_bltzal | inst_bgezal | inst_jalr;

    assign rf_waddr = {5{sel_rf_dst[0]}} & rd 
                    | {5{sel_rf_dst[1]}} & rt
                    | {5{sel_rf_dst[2]}} & 32'd31;  

    assign sel_rf_res = inst_lw | inst_lb | inst_lbu | inst_lh | inst_lhu; // 0 from alu_res ; 1 from ld_res

    // assign sel_nextpc[0] = inst_addu | inst_addiu | inst_subu | inst_lw 
    //                      | inst_sw | inst_slt | inst_sltu | inst_sll 
    //                      | inst_srl | inst_sra | inst_lui | inst_and 
    //                      | inst_or | inst_xor | inst_nor;
    // assign sel_nextpc[1] = inst_beq | inst_bne;
    // assign sel_nextpc[2] = inst_jal;
    // assign sel_nextpc[3] = inst_jr;

    assign br_op = {
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
    };

// hilo part
    assign hilo_op = {
        inst_mfhi, inst_mflo, inst_mthi, inst_mtlo,
        inst_mult, inst_multu, inst_div, inst_divu,
        inst_mul
    };
    



    
    

endmodule