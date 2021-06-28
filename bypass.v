`include "lib/defines.vh"
module bypass(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,

    input wire [`RegAddrBus] rs_rf_raddr_i,
    input wire [`RegAddrBus] rt_rf_raddr_i,

    input wire ex_we_i,
    input wire [`RegAddrBus] ex_waddr_i,
    input wire [`RegBus] ex_wdata_i,

    input wire dcache_we_i,
    input wire [`RegAddrBus] dcache_waddr_i,
    input wire [`RegBus] dcache_wdata_i,

    input wire mem_we_i,
    input wire [`RegAddrBus] mem_waddr_i,
    input wire [`RegBus] mem_wdata_i,

    output wire sel_rs_forward,
    output wire [`RegBus] rs_forward_data, 
    
    output wire sel_rt_forward,
    output wire [`RegBus] rt_forward_data
);
    reg [`RegAddrBus] rs_rf_raddr, rt_rf_raddr;
    reg ex_we, dcache_we, mem_we;
    reg [`RegAddrBus] ex_waddr, dcache_waddr, mem_waddr;
    reg [`RegBus] ex_wdata, dcache_wdata, mem_wdata;
    
    always @ (posedge clk) begin
        if (rst) begin
            rs_rf_raddr <= 5'b0;
            rt_rf_raddr <= 5'b0;
            ex_we <= 1'b0;
            ex_waddr <= 5'b0;
            ex_wdata <= 32'b0;
            dcache_we <= 1'b0;
            dcache_waddr <= 5'b0;
            dcache_wdata <= 32'b0;
            mem_we <= 1'b0;
            mem_waddr <= 5'b0;
            mem_wdata <= 32'b0;
        end
        else begin
            rs_rf_raddr <= rs_rf_raddr_i;
            rt_rf_raddr <= rt_rf_raddr_i;
            ex_we <= ex_we_i;
            ex_waddr <= ex_waddr_i;
            ex_wdata <= ex_wdata_i;
            dcache_we <= dcache_we_i;
            dcache_waddr <= dcache_waddr_i;
            dcache_wdata <= dcache_wdata_i;
            mem_we <= mem_we_i;
            mem_waddr <= mem_waddr_i;
            mem_wdata <= mem_wdata_i;
        end
    end

    wire rs_ex_ok,rs_dcache_ok,rs_mem_ok;
    wire rt_ex_ok,rt_dcache_ok,rt_mem_ok;

    assign rs_ex_ok     = (rs_rf_raddr == ex_waddr) && ex_we ? 1'b1 : 1'b0;
    assign rs_dcache_ok = (rs_rf_raddr == dcache_waddr) && dcache_we ? 1'b1 : 1'b0;
    assign rs_mem_ok    = (rs_rf_raddr == mem_waddr) && mem_we ? 1'b1 : 1'b0;

    assign rt_ex_ok     = (rt_rf_raddr == ex_waddr) && ex_we ? 1'b1 : 1'b0;
    assign rt_dcache_ok = (rt_rf_raddr == dcache_waddr) && dcache_we ? 1'b1 : 1'b0;
    assign rt_mem_ok    = (rt_rf_raddr == mem_waddr) && mem_we ? 1'b1 : 1'b0;

    assign sel_rs_forward = rs_ex_ok | rs_dcache_ok | rs_mem_ok;
    assign sel_rt_forward = rt_ex_ok | rt_dcache_ok | rt_mem_ok;

    assign rs_forward_data = rs_ex_ok ? ex_wdata
                           : rs_dcache_ok ? dcache_wdata
                           : rs_mem_ok ? mem_wdata
                           : 32'b0;
    assign rt_forward_data = rt_ex_ok ? ex_wdata
                           : rt_dcache_ok ? dcache_wdata
                           : rt_mem_ok ? mem_wdata
                           : 32'b0;
endmodule