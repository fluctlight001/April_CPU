`include "lib/defines.vh"
module pc (
    input wire clk,
    input wire rst,
    input wire [`StallBus] stall,

    input wire flush,
    input wire [`InstAddrBus] new_pc,

    // input wire branch_e,
    // input wire [`InstAddrBus] branch_target_addr,
    input wire [`BR_WD-1:0] br_bus,
    // output reg [`InstAddrBus] pc,
    // output reg ce,
    // output wire [31:0] excepttype_o
    output wire [`PC_TO_IC_WD-1:0] pc_to_ic_bus

);
    reg [`InstAddrBus] pc;
    reg ce;
    wire [31:0] excepttype_o;

    assign excepttype_o = 32'b0;
    
    wire branch_e;
    wire [`InstAddrBus] branch_target_addr;
    
    assign pc_to_ic_bus = {
        excepttype_o,   // 64:33
        ce,             // 32
        pc              // 31:0
    };

    assign {
        branch_e,
        branch_target_addr
    } = br_bus;

    wire [`InstAddrBus] next_pc;

    assign next_pc = flush ? new_pc
                   : branch_e ? branch_target_addr 
                   : pc + 32'h4;


    always @ (posedge clk) begin
        if (rst) begin
            pc <= 32'hbfbf_fffc;
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