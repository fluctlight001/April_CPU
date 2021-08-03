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
    input wire [`BR_WD-1:0] bp_bus,
    // output reg [`InstAddrBus] pc,
    // output reg ce,
    // output wire [31:0] excepttype_o
    output wire [`PC_TO_IC_WD-1:0] pc_to_ic_bus

);
    reg [`InstAddrBus] pc;
    reg ce;
    wire [31:0] excepttype_o;
    wire excepttype_is_ft_adel;
    
    assign excepttype_is_ft_adel = pc[0]|pc[1];
    assign excepttype_o = {15'b0,excepttype_is_ft_adel,16'b0};
    
    wire branch_e;
    wire [`InstAddrBus] branch_target_addr;
    wire bp_e;
    wire [`InstAddrBus] bp_target;
    
    assign pc_to_ic_bus = {
        excepttype_o,   // 64:33
        ce,             // 32
        pc              // 31:0
    };

    assign {
        branch_e,
        branch_target_addr
    } = br_bus;

    assign {
        bp_e,
        bp_target
    } = bp_bus;
    
    wire [`InstAddrBus] next_pc;

    assign next_pc = flush ? new_pc
                   : branch_e ? branch_target_addr 
                   : bp_e ? bp_target
                   : pc + 32'h4;


    always @ (posedge clk) begin
        if (rst) begin
            pc <= 32'hbfbf_fffc;
            // pc <= 32'hbfc00820-4'h4;
        end
        else if (stall[0]==`NoStop) begin
            pc <= next_pc;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            ce <= 1'b0;
        end
        else if (stall[0]==`NoStop) begin
            ce <= 1'b1;
        end
    end

    
endmodule