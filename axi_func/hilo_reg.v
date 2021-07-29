`include "lib/defines.vh"
module hilo_reg(
    input wire clk,
    input wire rst,
    input wire [`StallBus] stall,

    input wire ex_hi_we, ex_lo_we,
    input wire [`RegBus] ex_hi_i,
    input wire [`RegBus] ex_lo_i,

    input wire dt_hi_we, dt_lo_we,
    input wire [`RegBus] dt_hi_i,
    input wire [`RegBus] dt_lo_i,

    input wire dc_hi_we, dc_lo_we,
    input wire [`RegBus] dc_hi_i,
    input wire [`RegBus] dc_lo_i,

    input wire mem_hi_we, mem_lo_we,
    input wire [`RegBus] mem_hi_i,
    input wire [`RegBus] mem_lo_i,

    input wire wb_hi_we, wb_lo_we, 
    input wire [`RegBus] wb_hi_i,
    input wire [`RegBus] wb_lo_i,

    output reg [`RegBus] hi_o,
    output reg [`RegBus] lo_o
);

    reg [31:0] hi_r, lo_r;
    always @ (posedge clk) begin
        if (rst) begin
            hi_r <= 32'b0;
        end
        else if (wb_hi_we) begin
            hi_r <= wb_hi_i;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            lo_r <= 32'b0;
        end
        else if (wb_lo_we) begin
            lo_r <= wb_lo_i;
        end
    end

    wire [31:0] hi_temp, lo_temp;
    // assign {hi_temp, lo_temp} = ex_we ? {ex_hi_i, ex_lo_i}
    //                           : dc_we ? {dc_hi_i, dc_lo_i}
    //                           : mem_we ? {mem_hi_i, mem_lo_i}
    //                           : {hi_r, lo_r};
    
    assign hi_temp = ex_hi_we ? ex_hi_i
                   : dt_hi_we ? dt_hi_i
                   : dc_hi_we ? dc_hi_i
                   : mem_hi_we ? mem_hi_i
                   : wb_hi_we ? wb_hi_i
                   : hi_r;
    
    assign lo_temp = ex_lo_we ? ex_lo_i
                   : dt_lo_we ? dt_lo_i
                   : dc_lo_we ? dc_lo_i
                   : mem_lo_we ? mem_lo_i
                   : wb_lo_we ? wb_lo_i
                   : lo_r;

    always @ (posedge clk) begin
        if (rst) begin
            {hi_o, lo_o} <= {32'b0, 32'b0};
        end
        else if(stall[3] == `Stop && stall[4] == `NoStop) begin
            {hi_o, lo_o} <= {32'b0, 32'b0};
        end
        else if (stall[3] == `NoStop) begin
            {hi_o, lo_o} <= {hi_temp, lo_temp};
        end
    end
endmodule