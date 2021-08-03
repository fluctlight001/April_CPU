`include "lib/defines.vh"
module bpu (
    input wire clk,
    input wire rst,
    input wire [`StallBus] stall,
    input wire flush,

    input wire [31:0] if_pc,
    input wire [`BR_WD-1:0] br_bus,

    output wire [`BR_WD-1:0] bp_bus,
    output wire [`BR_WD-1:0] bp_to_ex_bus
);

    reg [7:0] valid;
    reg [31:0] branch_history_pc [7:0];
    reg [31:0] branch_target [7:0];
    reg [6:0] lru;
    reg [31:0] ic_pc, id_pc, ex_pc;
    reg ic_bp_e, id_bp_e, ex_bp_e;
    reg [31:0] ic_bp_target, id_bp_target, ex_bp_target;

    wire br_e;
    wire [31:0] br_target;

    wire [7:0] hit_way;
    wire bp_e;
    wire [31:0] bp_target;

    assign {
        br_e,
        br_target
    } = br_bus;

    assign bp_bus = {
        bp_e,
        bp_target
    };

    assign bp_to_ex_bus = {
        ex_bp_e,
        ex_bp_target
    };

    always @ (posedge clk) begin
        if (rst) begin
            lru <= 1'b0;
        end
        else if (hit_way[0] & ~hit_way[1]) begin
            lru <= 1'b1;
        end
        else if (~hit_way[0] & hit_way[1]) begin
            lru <= 1'b0;
        end
        else if (br_e) begin
            lru <= ~lru;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            valid <= 2'b0;
            branch_history_pc[0] <= 32'b0;
            branch_history_pc[1] <= 32'b0;
            branch_target[0] <= 32'b0;
            branch_target[1] <= 32'b0;
        end
        else if (br_e & ~lru) begin
            valid[0] <= 1'b1;
            branch_history_pc[0] <= ex_pc;
            branch_target[0] <= br_target;
        end
        else if (br_e & lru) begin
            valid[1] <= 1'b1;
            branch_history_pc[1] <= ex_pc;
            branch_target[1] <= br_target;
        end
    end
    
    assign hit_way[0] = valid[0] & (branch_history_pc[0] == ic_pc);
    assign hit_way[1] = valid[1] & (branch_history_pc[1] == ic_pc);
    assign bp_e = hit_way[0] | hit_way[1];
    assign bp_target = hit_way[0] ? branch_target[0]
                     : hit_way[1] ? branch_target[1] : 32'b0;



// time control
    // ic
    always @ (posedge clk) begin
        if (rst) begin
            ic_pc <= 32'b0;
        end
        else if (flush|br_e) begin
            ic_pc <= 32'b0;
        end
        else if (stall[1] == `Stop && stall[2] == `NoStop)begin
            ic_pc <= 32'b0;
        end
        else if (stall[1] == `NoStop) begin
            ic_pc <= if_pc;
        end
    end

    // id
    always @ (posedge clk) begin
        if (rst) begin
            id_pc <= 32'b0;
            id_bp_e <= 1'b0;
            id_bp_target <= 32'b0;
        end
        else if (flush|br_e) begin
            id_pc <= 32'b0;
            id_bp_e <= 1'b0;
            id_bp_target <= 32'b0;
        end
        else if (stall[2] == `Stop && stall[3] == `NoStop) begin
            id_pc <= 32'b0;
            id_bp_e <= 1'b0;
            id_bp_target <= 32'b0;
        end
        else if (stall[2] == `NoStop) begin
            id_pc <= ic_pc;
            id_bp_e <= bp_e;
            id_bp_target <= bp_target;
        end
    end

    // ex
    always @ (posedge clk) begin
        if (rst) begin
            ex_pc <= 32'b0;
            ex_bp_e <= 1'b0;
            ex_bp_target <= 32'b0;
        end
        else if (flush) begin
            ex_pc <= 32'b0;
            ex_bp_e <= 1'b0;
            ex_bp_target <= 32'b0;
        end
        else if (stall[3] == `Stop && stall[4] == `NoStop) begin
            ex_pc <= 32'b0;
            ex_bp_e <= 1'b0;
            ex_bp_target <= 32'b0;
        end
        else if (stall[3] == `NoStop) begin
            ex_pc <= id_pc;
            ex_bp_e <= id_bp_e;
            ex_bp_target <= id_bp_target;
        end
    end

endmodule