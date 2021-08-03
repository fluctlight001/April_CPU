`include "lib/defines.vh"
module dc(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,

    input wire [`DT_TO_DC_WD-1:0] dt_to_dc_bus,

    output reg [`DC_TO_MEM_WD-1:0] dc_to_mem_bus
);
    

    always @ (posedge clk) begin
        if (rst) begin
            dc_to_mem_bus <= `DC_TO_MEM_WD'b0;
        end
        else if (flush) begin
            dc_to_mem_bus <= `DC_TO_MEM_WD'b0;
        end
        else if (stall[5] == `Stop && stall[6] == `NoStop) begin
            dc_to_mem_bus <= `DC_TO_MEM_WD'b0;
        end
        else if (stall[5] == `NoStop) begin
            dc_to_mem_bus <= dt_to_dc_bus;
        end
    end

endmodule 