`include "lib/defines.vh"
module mycpu_core(
    input wire clk,
    input wire rst,
    input wire [5:0] ext_int,
    
    output wire[3:0]   arid,
    output wire[31:0]  araddr,
    output wire[3:0]   arlen,
    output wire[2:0]   arsize,
    output wire[1:0]   arburst,
    output wire[1:0]   arlock,
    output wire[3:0]   arcache,
    output wire[2:0]   arprot,
    output wire        arvalid,
    input  wire        arready,

    input  wire[3:0]   rid,
    input  wire[31:0]  rdata,
    input  wire[1:0]   rresp,
    input  wire        rlast,
    input  wire        rvalid,
    output wire        rready,

    output wire[3:0]   awid,
    output wire[31:0]  awaddr,
    output wire[3:0]   awlen,
    output wire[2:0]   awsize,
    output wire[1:0]   awburst,
    output wire[1:0]   awlock,
    output wire[3:0]   awcache,
    output wire[2:0]   awprot,
    output wire        awvalid,
    input  wire        awready,

    output wire[3:0]   wid,
    output wire[31:0]  wdata,
    output wire[3:0]   wstrb,
    output wire        wlast,
    output wire        wvalid,
    input  wire        wready,

    input  wire[3:0]   bid,
    input  wire[1:0]   bresp,
    input  wire        bvalid,
    output wire        bready,

    output wire [31:0] debug_wb_pc,
    output wire [3 :0] debug_wb_rf_wen,
    output wire [4 :0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata 
);

    wire inst_sram_en;
    wire [3:0] inst_sram_wen;
    wire [31:0] inst_sram_addr;
    wire [31:0] inst_sram_wdata;
    wire [31:0] inst_sram_rdata;

    wire data_sram_en;
    wire [3:0] data_sram_wen;
    wire [31:0] data_sram_addr;
    wire [31:0] data_sram_wdata;
    wire [31:0] data_sram_rdata;

    wire icache_refresh;
    wire icache_miss;
    wire [31:0] icache_addr;
    wire icache_hit;
    wire [`CACHELINE_WIDTH-1:0] icache_cacheline_new;
    wire icache_write_req;
    wire [31:0] icache_write_addr;
    wire [`CACHELINE_WIDTH-1:0] icache_cacheline_old;


    //ctrl 
    wire [`StallBus] stall;
    wire flush;
    wire [`InstAddrBus] new_pc;

    axi_control u_axi_control(
        .clk              (clk              ),
        .rst              (rst              ),
        .icache_miss      (icache_miss      ),
        .icache_addr      (icache_addr      ),
        .icache_refresh   (icache_refresh   ),
        .icache_cacheline (icache_cacheline_new ),
        .awid             (awid             ),
        .awaddr           (awaddr           ),
        .awlen            (awlen            ),
        .awsize           (awsize           ),
        .awburst          (awburst          ),
        .awlock           (awlock           ),
        .awcache          (awcache          ),
        .awprot           (awprot           ),
        .awvalid          (awvalid          ),
        .awready          (awready          ),
        .wid              (wid              ),
        .wdata            (wdata            ),
        .wstrb            (wstrb            ),
        .wlast            (wlast            ),
        .wvalid           (wvalid           ),
        .wready           (wready           ),
        .bid              (bid              ),
        .bresp            (bresp            ),
        .bvalid           (bvalid           ),
        .bready           (bready           ),
        .arid             (arid             ),
        .araddr           (araddr           ),
        .arlen            (arlen            ),
        .arsize           (arsize           ),
        .arburst          (arburst          ),
        .arlock           (arlock           ),
        .arcache          (arcache          ),
        .arprot           (arprot           ),
        .arvalid          (arvalid          ),
        .arready          (arready          ),
        .rid              (rid              ),
        .rdata            (rdata            ),
        .rresp            (rresp            ),
        .rlast            (rlast            ),
        .rvalid           (rvalid           ),
        .rready           (rready           )
    );

    wire stallreq_from_icache;

    cache_tag u_icache_tag(
    	.clk        (clk        ),
        .rst        (rst        ),
        .stallreq   (stallreq_from_icache),
        .sram_en    (inst_sram_en    ),
        .sram_wen   (inst_sram_wen   ),
        .sram_addr  (inst_sram_addr  ),
        .sram_wdata (inst_sram_wdata ),

        .refresh    (icache_refresh  ),
        .miss       (icache_miss     ),
        .axi_addr   (icache_addr     ),
        .hit        (icache_hit      )
    );

    cache_data u_icache_data(
    	.clk           (clk                ),
        .rst           (rst                ),
        .stall         (stall              ),
        .flush         (flush              ),
        .br_e          (br_bus[32]         ),
        .write_back    (~icache_hit        ),
        .hit           (icache_hit         ),
        .sram_en       (inst_sram_en       ),
        .sram_wen      (inst_sram_wen      ),
        .sram_addr     (inst_sram_addr     ),
        .sram_wdata    (inst_sram_wdata    ),
        .sram_rdata    (inst_sram_rdata    ),
        .refresh       (icache_refresh     ),
        .cacheline_new (icache_cacheline_new ),
        .write_req     (icache_write_req     ),
        .write_addr    (icache_write_addr    ),
        .cacheline_old (icache_cacheline_old )
    );
    


    





    wire [`PC_TO_IC_WD-1:0] pc_to_ic_bus;
    wire [`IC_TO_ID_WD-1:0] ic_to_id_bus;
    wire [`ID_TO_EX_WD-1:0] id_to_ex_bus;
    wire [`EX_TO_DC_WD-1:0] ex_to_dc_bus;
    wire [`DC_TO_MEM_WD-1:0] dc_to_mem_bus;
    wire [`MEM_TO_WB_WD-1:0] mem_to_wb_bus;
    wire [`BR_WD-1:0] br_bus; 


    


    // assign inst_sram_en     = rst ? 1'b0 : pc_ce;
    assign inst_sram_wen    = 4'b0;
    // assign inst_sram_addr   = rst ? 32'b0 : pc_pc;
    assign inst_sram_wdata  = 32'b0;
    assign {
        inst_sram_en,
        inst_sram_addr
    } = rst ? 33'b0 : pc_to_ic_bus[32:0];
    

    wire [`InstBus] ic_inst;
    assign ic_inst = rst ? 32'b0 
                   : ic_to_id_bus[32] ? inst_sram_rdata 
                   : 32'b0;

    pc u_pc(
    	.clk          (clk          ),
        .rst          (rst          ),
        .stall        (stall        ),
        .flush        (flush        ),
        .new_pc       (new_pc       ),
        .br_bus       (br_bus       ),
        .pc_to_ic_bus (pc_to_ic_bus )
    );
    
    
    ic u_ic(
    	.clk          (clk          ),
        .rst          (rst          ),
        .stall        (stall        ),
        .flush        (flush        ),
        .br_e         (br_bus[32]   ),
        .pc_to_ic_bus (pc_to_ic_bus ),
        .ic_to_id_bus (ic_to_id_bus )
    );

    wire [`RegAddrBus] rs_rf_raddr;
    wire [`RegAddrBus] rt_rf_raddr;
    wire rf_we;
    wire [`RegAddrBus] rf_waddr;
    wire [`RegBus] rf_wdata;
    
    id u_id(
    	.clk          (clk              ),
        .rst          (rst              ),
        .flush        (flush            ),
        .stall        (stall            ),
        .br_e         (br_bus[32]       ),
        .stallreq     (stallreq         ),
        .ic_to_id_bus (ic_to_id_bus     ),
        .ic_inst      (ic_inst          ),
        .wb_rf_we     (rf_we            ),
        .wb_rf_waddr  (rf_waddr         ),
        .wb_rf_wdata  (rf_wdata         ),
        .id_to_ex_bus (id_to_ex_bus     ),
        .rs_rf_raddr  (rs_rf_raddr      ),
        .rt_rf_raddr  (rt_rf_raddr      )
    );

    wire [31:0] rs_forward_data;
    wire [31:0] rt_forward_data;
    wire [31:0] hi, lo;
    wire stallreq_for_ex;
    wire [4:0] cp0_reg_raddr;
    wire [31:0] cp0_reg_rdata;
    ex u_ex(
        .clk             (clk             ),
        .rst             (rst             ),
        .flush           (flush           ),
        .stall           (stall           ),
        .stallreq_for_ex (stallreq_for_ex ),
        .id_to_ex_bus    (id_to_ex_bus    ),
        .ex_to_dc_bus    (ex_to_dc_bus    ),
        .sel_rs_forward  (sel_rs_forward  ),
        .rs_forward_data (rs_forward_data ),
        .sel_rt_forward  (sel_rt_forward  ),
        .rt_forward_data (rt_forward_data ),
        .br_bus          (br_bus          ),
        .hi_i            (hi              ),
        .lo_i            (lo              ),
        .cp0_reg_raddr   (cp0_reg_raddr   ),
        .cp0_reg_data_i  (cp0_reg_rdata   ),
        // .is_in_delayslot_i(br_bus[32]     ),
        .data_sram_en    (data_sram_en    ),
        .data_sram_wen   (data_sram_wen   ),
        .data_sram_addr  (data_sram_addr  ),
        .data_sram_wdata (data_sram_wdata )
    );
    

    dc u_dc(
    	.clk           (clk           ),
        .rst           (rst           ),
        .flush         (flush         ),
        .stall         (stall         ),
        .ex_to_dc_bus  (ex_to_dc_bus  ),
        .dc_to_mem_bus (dc_to_mem_bus )
    );

    wire [31:0] cp0_status, cp0_cause, cp0_epc;
    mem u_mem(
    	.clk             (clk             ),
        .rst             (rst             ),
        .flush           (flush           ),
        .stall           (stall           ),
        .dc_to_mem_bus   (dc_to_mem_bus   ),
        .mem_to_wb_bus   (mem_to_wb_bus   ),
        .data_sram_rdata (data_sram_rdata ),
        .cp0_status      (cp0_status      ),
        .cp0_cause       (cp0_cause       ),
        .cp0_epc         (cp0_epc         )
    );
    

    wire [65:0] hilo_bus;
    wire [38:0] cp0_bus;
    assign cp0_bus = mem_to_wb_bus[270:233];

    wb u_wb(
    	.clk               (clk               ),
        .rst               (rst               ),
        .flush             (flush             ),
        .stall             (stall             ),
        .mem_to_wb_bus     (mem_to_wb_bus     ),
        .rf_we             (rf_we             ),
        .rf_waddr          (rf_waddr          ),
        .rf_wdata          (rf_wdata          ),
        .hilo_bus          (hilo_bus          ),

        // .cp0_bus           (cp0_bus           ),
        // .cp0_epc_o         (cp0_epc           ),
        // .is_in_delayslot_o (is_in_delayslot   ),
        // .bad_vaddr_o       (bad_vaddr         ),
        // .excepttype_o      (excepttype_arr    ),
        
        .debug_wb_pc       (debug_wb_pc       ),
        .debug_wb_rf_wen   (debug_wb_rf_wen   ),
        .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),
        .debug_wb_rf_wdata (debug_wb_rf_wdata )
    );
    
    wire stallreq_for_load;
    bypass u_bypass(
        .clk               (clk                   ),
        .rst               (rst                   ),
        .flush             (flush                 ),
        .stall             (stall                 ),
        .stallreq_for_load (stallreq_for_load     ),

    	.rs_rf_raddr       (rs_rf_raddr           ),
        .rt_rf_raddr       (rt_rf_raddr           ),
        .ex_we             (ex_to_dc_bus[37]      ),
        .ex_waddr          (ex_to_dc_bus[36:32]   ),
        .ex_wdata          (ex_to_dc_bus[31:0]    ),
        .ex_ram_ctrl       (ex_to_dc_bus[43:39]   ),
        .dcache_we         (dc_to_mem_bus[37]     ),
        .dcache_waddr      (dc_to_mem_bus[36:32]  ),
        .dcache_wdata      (dc_to_mem_bus[31:0]   ),
        .dc_ram_ctrl       (dc_to_mem_bus[43:39]  ),
        .mem_we            (mem_to_wb_bus[37]     ),
        .mem_waddr         (mem_to_wb_bus[36:32]  ),
        .mem_wdata         (mem_to_wb_bus[31:0]   ),
        .sel_rs_forward_r  (sel_rs_forward        ),
        .rs_forward_data_r (rs_forward_data       ),
        .sel_rt_forward_r  (sel_rt_forward        ),
        .rt_forward_data_r (rt_forward_data       )
    );

    hilo_reg u_hilo_reg(
    	.clk       (clk       ),
        .rst       (rst       ),
        .stall     (stall     ),
        .ex_hi_we  (ex_to_dc_bus[141]  ),
        .ex_lo_we  (ex_to_dc_bus[140]  ),
        .ex_hi_i   (ex_to_dc_bus[139:108]   ),
        .ex_lo_i   (ex_to_dc_bus[107:76]   ),
        .dc_hi_we  (dc_to_mem_bus[141]  ),
        .dc_lo_we  (dc_to_mem_bus[140]  ),
        .dc_hi_i   (dc_to_mem_bus[139:108]   ),
        .dc_lo_i   (dc_to_mem_bus[107:76]   ),
        .mem_hi_we (mem_to_wb_bus[135] ),
        .mem_lo_we (mem_to_wb_bus[134] ),
        .mem_hi_i  (mem_to_wb_bus[133:102]  ),
        .mem_lo_i  (mem_to_wb_bus[101:70]  ),
        .wb_hi_we  (hilo_bus[65]  ),
        .wb_lo_we  (hilo_bus[64]  ),
        .wb_hi_i   (hilo_bus[63:32]   ),
        .wb_lo_i   (hilo_bus[31:0]   ),
        .hi_o      (hi      ),
        .lo_o      (lo      )
    );
    
    cp0_reg u_cp0_reg(
    	.clk               (clk               ),
        .rst               (rst               ),
        .stall             (stall             ),

        .we_i              (cp0_bus[37]       ),
        .waddr_i           (cp0_bus[36:32]    ),
        .raddr_i           (cp0_reg_raddr     ),
        .data_i            (cp0_bus[31:0]     ),
        .int_i             (ext_int           ),

        .data_o            (cp0_reg_rdata     ),
        .status_o          (cp0_status        ),
        .cause_o           (cp0_cause         ),
        .epc_o             (cp0_epc           ),

        .config_o          (config_o          ),
        .timer_int_o       (timer_int_o       ),

        .excepttype_i      (mem_to_wb_bus[167:136]    ),
        .pc_i              (mem_to_wb_bus[69:38]      ),
        .bad_vaddr_i       (mem_to_wb_bus[199:168]         ),
        .is_in_delayslot_i (mem_to_wb_bus[200]   ),

        .ex_cp0_bus        (ex_to_dc_bus[249:212]        ),
        .dc_cp0_bus        (dc_to_mem_bus[249:212]        ),
        .mem_cp0_bus       (mem_to_wb_bus[270:233]       )
        // .wb_cp0_bus        (cp0_bus        )
    );
 
    ctrl u_ctrl(
    	.rst              (rst              ),
        .stallreq_for_ex  (stallreq_for_ex ),
        .stallreq_for_load(stallreq_for_load),
        .stallreq_from_icache   (stallreq_from_icache),
        .stallreq_from_dcache   (),
        .excepttype_i     (mem_to_wb_bus[167:136]     ),
        .cp0_epc_i        (mem_to_wb_bus[232:201]        ),
        .flush            (flush            ),
        .new_pc           (new_pc           ),
        .stall            (stall            )
    );
    
    
    
    
    
endmodule 