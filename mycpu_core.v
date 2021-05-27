`include "lib/defines.vh"
module mycpu_core(
    input wire clk,
    input wire rst,
    input wire [5:0] int,

    output wire inst_sram_en,
    output wire [3:0] inst_sram_wen,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    input wire [31:0] inst_sram_rdata,

    output wire data_sram_en,
    output wire [3:0] data_sram_wen,
    output wire [31:0] data_sram_addr,
    output wire [31:0] data_sram_wdata,
    input wire [31:0] data_sram_rdata,

    output wire [31:0] debug_wb_pc,
    output wire [3:0] debug_wb_rf_wen,
    output wire [4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata 
);

    //ctrl 
    wire [`StallBus] stall;
    wire flush;
    wire [`InstAddrBus] new_pc;


    // pc --> icache
    wire [`InstAddrBus] pc_pc;
    wire pc_ce;
    assign inst_sram_en     = rst ? 1'b0 : pc_ce;
    assign inst_sram_wen    = 4'b0;
    assign inst_sram_addr   = rst ? 32'b0 : pc_pc;
    assign inst_sram_wdata  = 32'b0;

    // icache --> if_id
    wire [`InstAddrBus] if_pc;
    wire if_ce;
    wire [`InstBus] if_inst;
    assign if_inst = rst ? 32'b0 : inst_sram_rdata;

    // if_id --> id
    wire [`InstAddrBus] id_pc;
    wire [`InstBus] id_inst;
    

    pc u_pc(
    	.clk                (clk                ),
        .rst                (rst                ),
        .stall              (stall              ),
        .flush              (flush              ),
        .new_pc             (new_pc             ),
        .branch_e           (branch_e           ),
        .branch_target_addr (branch_target_addr ),
        .pc                 (pc_pc              ),
        .ce                 (pc_ce              ),
        .excepttype_o       (excepttype_o       )
    );

    icache u_icache(
    	.clk       (clk       ),
        .rst       (rst       ),
        .stall     (stall     ),
        .flush     (flush     ),
        .pc_pc     (pc_pc     ),
        .pc_ce     (pc_ce     ),
        .icache_pc (if_pc     ),
        .icache_ce (if_ce     )
    );

    if_id u_if_id(
    	.clk     (clk     ),
        .rst     (rst     ),
        .flush   (flush   ),
        .stall   (stall   ),
        .if_pc   (if_pc   ),
        .if_inst (if_inst ),
        .id_pc   (id_pc   ),
        .id_inst (id_inst )
    );
    
    id u_id(
    	.clk          (clk          ),
        .rst          (rst          ),
        .stallreq     (stallreq     ),
        .pc_i         (id_pc        ),
        .inst_i       (id_inst      ),
        .wb_rf_we     (wb_rf_we     ),
        .wb_rf_waddr  (wb_rf_waddr  ),
        .wb_rf_wdata  (wb_rf_wdata  ),
        .sel_nextpc   (sel_nextpc   ),
        .sel_alu_src1 (sel_alu_src1 ),
        .sel_alu_src2 (sel_alu_src2 ),
        .alu_op       (alu_op       ),
        .data_ram_en  (data_ram_en  ),
        .data_ram_wen (data_ram_wen ),
        .rf_we        (rf_we        ),
        .rf_waddr     (rf_waddr     ),
        .sel_rf_res   (sel_rf_res   ),
        .rf_rdata1    (rf_rdata1    ),
        .rf_rdata2    (rf_rdata2    )
    );

    id_ex u_id_ex(
    	.clk                (clk                ),
        .rst                (rst                ),
        .flush              (flush              ),
        .stall              (stall              ),
        .id_pc              (id_pc              ),
        .id_inst            (id_inst            ),
        .sel_nextpc         (sel_nextpc         ),
        .id_sel_alu_src1    (id_sel_alu_src1    ),
        .id_sel_alu_src2    (id_sel_alu_src2    ),
        .id_alu_op          (id_alu_op          ),
        .id_data_ram_en     (id_data_ram_en     ),
        .id_data_ram_wen    (id_data_ram_wen    ),
        .id_rf_we           (id_rf_we           ),
        .id_sel_rf_dst      (id_sel_rf_dst      ),
        .sel_rf_res         (sel_rf_res         ),
        .id_rf_rdata1       (id_rf_rdata1       ),
        .id_rf_rdata2       (id_rf_rdata2       ),
        .id_imm_sign_extend (id_imm_sign_extend ),
        .id_sa_zero_extend  (id_sa_zero_extend  ),
        .ex_pc              (ex_pc              ),
        .ex_inst            (ex_inst            ),
        .ex_sel_alu_src1    (ex_sel_alu_src1    ),
        .ex_sel_alu_src2    (ex_sel_alu_src2    ),
        .ex_rf_rdata1       (ex_rf_rdata1       ),
        .ex_rf_rdata2       (ex_rf_rdata2       ),
        .ex_imm_sign_extend (ex_imm_sign_extend ),
        .ex_sa_zero_extend  (ex_sa_zero_extend  )
    );
    

    ex u_ex(
    	.rst             (rst             ),
        .pc              (pc              ),
        .inst            (inst            ),
        .alu_op          (alu_op          ),
        .sel_alu_src1    (sel_alu_src1    ),
        .sel_alu_src2    (sel_alu_src2    ),
        .rf_rdata1       (rf_rdata1       ),
        .rf_rdata2       (rf_rdata2       ),
        .imm_sign_extend (imm_sign_extend ),
        .sa_zero_extend  (sa_zero_extend  ),
        .sel_rs_forward  (sel_rs_forward  ),
        .rs_forward_data (rs_forward_data ),
        .sel_rt_forward  (sel_rt_forward  ),
        .rt_forward_data (rt_forward_data )
    );

    bypass u_bypass(
    	.rs_rf_raddr     (rs_rf_raddr     ),
        .rt_rf_raddr     (rt_rf_raddr     ),
        .ex_we           (ex_we           ),
        .ex_waddr        (ex_waddr        ),
        .ex_wdata        (ex_wdata        ),
        .dcache_we       (dcache_we       ),
        .dcache_waddr    (dcache_waddr    ),
        .dcache_wdata    (dcache_wdata    ),
        .mem_we          (mem_we          ),
        .mem_waddr       (mem_waddr       ),
        .mem_wdata       (mem_wdata       ),
        .sel_rs_forward  (sel_rs_forward  ),
        .rs_forward_data (rs_forward_data ),
        .sel_rt_forward  (sel_rt_forward  ),
        .rt_forward_data (rt_forward_data )
    );


    ctrl u_ctrl(
    	.rst              (rst              ),
        .stallreq_from_ic (stallreq_from_ic ),
        .stallreq_from_id (stallreq_from_id ),
        .stallreq_from_ex (stallreq_from_ex ),
        .stallreq_from_dc (stallreq_from_dc ),
        .excepttype_i     (excepttype_i     ),
        .cp0_epc_i        (cp0_epc_i        ),
        .flush            (flush            ),
        .new_pc           (new_pc           ),
        .stall            (stall            )
    );
    
    
    
    
    
endmodule 