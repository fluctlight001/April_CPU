`include "lib/defines.vh"
module pc (
    input wire clk,
    input wire rst,
    input wire [`StallBus] stall,

    input wire flush,
    input wire [`InstAddrBus] new_pc,

    input wire branch_e,
    input wire [`InstAddrBus] branch_target_addr,

    output reg [`InstAddrBus] pc,
    output reg ce,

    output wire [31:0] excepttype_o
);
    wire [`InstAddrBus] next_pc;

    assign next_pc = flush ? new_pc
                   : branch_e ? branch_target_addr 
                   : pc[31:2] + 1'b1;

    always @ (posedge clk) begin
        if (rst) begin
            pc <= 32'hbfc0_0000;
        end
        else begin
            pc <= next_pc;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            ce <= 1'b0;
        end
        else begin
            ce <= 1'b1;
        end
    end

    
endmodule