`include "lib/defines.vh"
module bypass(
    input wire [`RegAddrBus] rs_rf_raddr,
    input wire [`RegAddrBus] rt_rf_raddr,

    input wire ex_we,
    input wire [`RegAddrBus] ex_waddr,
    input wire [`RegBus] ex_wdata,

    input wire dcache_we,
    input wire [`RegAddrBus] dcache_waddr,
    input wire [`RegBus] dcache_wdata,

    input wire mem_we,
    input wire [`RegAddrBus] mem_waddr,
    input wire [`RegBus] mem_wdata,

    output wire sel_rs_forward,
    output wire [`RegBus] rs_forward_data, 
    
    output wire sel_rt_forward,
    output wire [`RegBus] rt_forward_data
);

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