`include "lib/defines.vh"
module hilo_reg(
    input wire clk,
    input wire rst,

    input wire we,
    input wire [`RegBus] hi_i,
    input wire [`RegBus] lo_i,

    output reg [`RegBus] hi_o,
    output reg [`RegBus] lo_o
);
    always @ (posedge clk) begin
        if (rst) begin
            hi_o <= 32'b0;
            lo_o <= 32'b0;
        end
        else if (we) begin
            hi_o <= hi_i;
            lo_o <= lo_i;
        end
    end
endmodule