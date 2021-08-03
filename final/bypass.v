`include "lib/defines.vh"
module bypass(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,
    output wire stallreq_for_load,

    input wire [`RegAddrBus] rs_rf_raddr,
    input wire [`RegAddrBus] rt_rf_raddr,

    input wire ex_we,
    input wire [`RegAddrBus] ex_waddr,
    input wire [`RegBus] ex_wdata,
    input wire [4:0] ex_ram_ctrl,

    input wire dt_we,
    input wire [`RegAddrBus] dt_waddr,
    input wire [`RegBus] dt_wdata,
    input wire [4:0] dt_ram_ctrl,

    input wire dcache_we,
    input wire [`RegAddrBus] dcache_waddr,
    input wire [`RegBus] dcache_wdata,
    input wire [4:0] dc_ram_ctrl,


    input wire mem_we,
    input wire [`RegAddrBus] mem_waddr,
    input wire [`RegBus] mem_wdata,

    output reg sel_rs_forward_r,
    output reg [`RegBus] rs_forward_data_r, 
    
    output reg sel_rt_forward_r,
    output reg [`RegBus] rt_forward_data_r
);
    // reg [`RegAddrBus] rs_rf_raddr, rt_rf_raddr;
    // reg ex_we, dcache_we, mem_we;
    // reg [`RegAddrBus] ex_waddr, dcache_waddr, mem_waddr;
    // reg [`RegBus] ex_wdata, dcache_wdata, mem_wdata;
    
    // always @ (posedge clk) begin
    //     if (rst) begin
    //         rs_rf_raddr <= 5'b0;
    //         rt_rf_raddr <= 5'b0;
    //         ex_we <= 1'b0;
    //         ex_waddr <= 5'b0;
    //         ex_wdata <= 32'b0;
    //         dcache_we <= 1'b0;
    //         dcache_waddr <= 5'b0;
    //         dcache_wdata <= 32'b0;
    //         mem_we <= 1'b0;
    //         mem_waddr <= 5'b0;
    //         mem_wdata <= 32'b0;
    //     end
    //     else begin
    //         rs_rf_raddr <= rs_rf_raddr_i;
    //         rt_rf_raddr <= rt_rf_raddr_i;
    //         ex_we <= ex_we_i;
    //         ex_waddr <= ex_waddr_i;
    //         ex_wdata <= ex_wdata_i;
    //         dcache_we <= dcache_we_i;
    //         dcache_waddr <= dcache_waddr_i;
    //         dcache_wdata <= dcache_wdata_i;
    //         mem_we <= mem_we_i;
    //         mem_waddr <= mem_waddr_i;
    //         mem_wdata <= mem_wdata_i;
    //     end
    // end

    wire rs_ex_ok, rs_dt_ok, rs_dcache_ok, rs_mem_ok;
    wire rt_ex_ok, rt_dt_ok, rt_dcache_ok, rt_mem_ok;
    wire sel_rs_forward, sel_rt_forward;
    wire [`RegBus] rs_forward_data, rt_forward_data;
    wire ex_is_load, dt_is_load, dc_is_load;
    wire stallreq_for_load_next;

    assign rs_ex_ok     = (rs_rf_raddr == ex_waddr) && ex_we ? 1'b1 : 1'b0;
    assign rs_dt_ok     = (rs_rf_raddr == dt_waddr) && dt_we ? 1'b1 : 1'b0;
    assign rs_dcache_ok = (rs_rf_raddr == dcache_waddr) && dcache_we ? 1'b1 : 1'b0;
    assign rs_mem_ok    = (rs_rf_raddr == mem_waddr) && mem_we ? 1'b1 : 1'b0;

    assign rt_ex_ok     = (rt_rf_raddr == ex_waddr) && ex_we ? 1'b1 : 1'b0;
    assign rt_dt_ok     = (rt_rf_raddr == dt_waddr) && dt_we ? 1'b1 : 1'b0;
    assign rt_dcache_ok = (rt_rf_raddr == dcache_waddr) && dcache_we ? 1'b1 : 1'b0;
    assign rt_mem_ok    = (rt_rf_raddr == mem_waddr) && mem_we ? 1'b1 : 1'b0;

    assign sel_rs_forward = rs_ex_ok | rs_dt_ok | rs_dcache_ok | rs_mem_ok;
    assign sel_rt_forward = rt_ex_ok | rt_dt_ok | rt_dcache_ok | rt_mem_ok;

    assign rs_forward_data = rs_ex_ok ? ex_wdata
                           : rs_dt_ok ? dt_wdata
                           : rs_dcache_ok ? dcache_wdata
                           : rs_mem_ok ? mem_wdata
                           : 32'b0;
    assign rt_forward_data = rt_ex_ok ? ex_wdata
                           : rt_dt_ok ? dt_wdata
                           : rt_dcache_ok ? dcache_wdata
                           : rt_mem_ok ? mem_wdata
                           : 32'b0;

    assign ex_is_load = ex_ram_ctrl[4] & ~(|ex_ram_ctrl[3:0]);
    assign dt_is_load = dt_ram_ctrl[4] & ~(|dt_ram_ctrl[3:0]);
    assign dc_is_load = dc_ram_ctrl[4] & ~(|dc_ram_ctrl[3:0]);

    assign stallreq_for_load_next = (ex_is_load & (rs_ex_ok|rt_ex_ok)) | (dt_is_load & (rs_dt_ok|rt_dt_ok)) | (dc_is_load & (rs_dcache_ok|rt_dcache_ok));
    assign stallreq_for_load = stallreq_for_load_next;
    always @ (posedge clk) begin
        if (rst) begin
            sel_rs_forward_r <= 1'b0;
            sel_rt_forward_r <= 1'b0;
            rs_forward_data_r <= 32'b0;
            rt_forward_data_r <= 32'b0;
            // stallreq_for_load <= 1'b0;
        end
        else if (stall[3] == `Stop && stall[4] == `NoStop) begin
            sel_rs_forward_r <= 1'b0;
            sel_rt_forward_r <= 1'b0;
            rs_forward_data_r <= 32'b0;
            rt_forward_data_r <= 32'b0;
            // stallreq_for_load <= 1'b0;
        end
        else if (stall[3] == `NoStop) begin
            sel_rs_forward_r <= sel_rs_forward;
            sel_rt_forward_r <= sel_rt_forward;
            rs_forward_data_r <= rs_forward_data;
            rt_forward_data_r <= rt_forward_data;
            // stallreq_for_load <= stallreq_for_load_next;
        end
    end
endmodule