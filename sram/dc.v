`include "lib/defines.vh"
module dc(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,

    input wire [`EX_TO_DC_WD-1:0] ex_to_dc_bus,

    output reg [`DC_TO_MEM_WD-1:0] dc_to_mem_bus
);
    

    always @ (posedge clk) begin
        if (rst) begin
            dc_to_mem_bus <= `DC_TO_MEM_WD'b0;
        end
        else if (flush) begin
            dc_to_mem_bus <= `DC_TO_MEM_WD'b0;
        end
        else if (stall[4] == `Stop && stall[5] == `NoStop) begin
            dc_to_mem_bus <= `DC_TO_MEM_WD'b0;
        end
        else if (stall[4] == `NoStop) begin
            dc_to_mem_bus <= ex_to_dc_bus;
        end
    end

endmodule 