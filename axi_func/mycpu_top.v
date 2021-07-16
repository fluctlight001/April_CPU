module mycpu_top(
    input wire [5:0] ext_int,
    input wire aclk,
    input wire aresetn,
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
    wire [31:0] inst_sram_addr_o;
    wire [31:0] inst_sram_wdata;
    wire [31:0] inst_sram_rdata;

    wire data_sram_en;
    wire [3:0] data_sram_wen;
    wire [31:0] data_sram_addr;
    wire [31:0] data_sram_addr_o;
    wire [31:0] data_sram_wdata;
    wire [31:0] data_sram_rdata;

    wire stall_from_axi;

    mycpu_core u_mycpu_core(
        .clk               (aclk               ),
        .rst               (~aresetn           ),
        .int               (ext_int           ),
        .inst_sram_en      (inst_sram_en      ),
        .inst_sram_wen     (inst_sram_wen     ),
        .inst_sram_addr    (inst_sram_addr    ),
        .inst_sram_wdata   (inst_sram_wdata   ),
        .inst_sram_rdata   (inst_sram_rdata   ),

        .data_sram_en      (data_sram_en      ),
        .data_sram_wen     (data_sram_wen     ),
        .data_sram_addr    (data_sram_addr    ),
        .data_sram_wdata   (data_sram_wdata   ),
        .data_sram_rdata   (data_sram_rdata   ),

        .debug_wb_pc       (debug_wb_pc       ),
        .debug_wb_rf_wen   (debug_wb_rf_wen   ),
        .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),
        .debug_wb_rf_wdata (debug_wb_rf_wdata ),

        .stallreq_from_outside(stall_from_axi) 
    );
    
    mmu u_mmu_inst(
    	.addr_i (inst_sram_addr ),
        .addr_o (inst_sram_addr_o )
    );

    mmu u_mmu_data(
    	.addr_i (data_sram_addr ),
        .addr_o (data_sram_addr_o )
    );

    axi_bus axi0(
        .clk(aclk),
        .rst(~aresetn),
        
        .stall(stall_from_axi),

        .pc_i(inst_sram_addr_o),
        .isMiss_from_icache(inst_sram_en),
        .inst_icache_o(inst_sram_rdata),

        .mem_addr_i(data_sram_addr_o),
        .mem_we_i(data_sram_wen),
        .mem_data_i(data_sram_wdata),
        .isMiss_from_dcache(data_sram_en), 
        .mem_data_o(data_sram_rdata),

        .arid         (arid         ),
        .araddr       (araddr       ),
        .arlen        (arlen        ),
        .arsize       (arsize       ),
        .arburst      (arburst      ),
        .arlock       (arlock       ),
        .arcache      (arcache      ),
        .arprot       (arprot       ),
        .arvalid      (arvalid      ),
        .arready      (arready      ),
        .rid          (rid          ),
        .rdata        (rdata        ),
        .rresp        (rresp        ),
        .rlast        (rlast        ),
        .rvalid       (rvalid       ),
        .rready       (rready       ),
        .awid         (awid         ),
        .awaddr       (awaddr       ),
        .awlen        (awlen        ),
        .awsize       (awsize       ),
        .awburst      (awburst      ),
        .awlock       (awlock       ),
        .awcache      (awcache      ),
        .awprot       (awprot       ),
        .awvalid      (awvalid      ),
        .awready      (awready      ),
        .wid          (wid          ),
        .wdata        (wdata        ),
        .wstrb        (wstrb        ),
        .wlast        (wlast        ),
        .wvalid       (wvalid       ),
        .wready       (wready       ),
        .bid          (bid          ),
        .bresp        (bresp        ),
        .bvalid       (bvalid       ),
        .bready       (bready       )
    ); 

endmodule 