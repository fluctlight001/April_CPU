`include "lib/defines.vh"
module ex (
    input wire rst,
    input wire [31:0] pc, inst,
    input wire [11:0] alu_op,
    input wire [2:0] sel_alu_src1, sel_alu_src2,
    input wire [31:0] rf_rdata1, rf_rdata2, imm_sign_extend, sa_zero_extend,
    
    //bypass
    input wire sel_rs_forward,
    input wire [`RegBus] rs_forward_data,
    input wire sel_rt_forward,
    input wire [`RegBus] rt_forward_data

);

    wire [31:0] alu_src1, alu_src2;
    wire [31:0] alu_result;

    wire [31:0] rf_rdata1_bp; // with forward
    wire [31:0] rf_rdata2_bp; // with forward

    assign rf_rdata1_bp = sel_rs_forward ? rs_forward_data : rf_rdata1; 
    assign rf_rdata2_bp = sel_rt_forward ? rt_forward_data : rf_rdata2;
    
    mux3_32b u_ALUSrc1(
    	.in0 (rf_rdata1_bp ),
        .in1 (pc ),
        .in2 (sa_zero_extend ),
        .sel (sel_alu_src1 ),
        .out (alu_src1)
    );

    mux3_32b u_ALUSrc2(
    	.in0 (rf_rdata2_bp ),
        .in1 (imm_sign_extend),
        .in2 (32'd8 ),
        .sel (sel_alu_src2 ),
        .out (alu_src2)
    );
    
    alu u_alu(
    	.alu_control (alu_op ),
        .alu_src1    (alu_src1    ),
        .alu_src2    (alu_src2    ),
        .alu_result  (alu_result  )
    );
    

    
endmodule