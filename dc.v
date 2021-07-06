`include "lib/defines.vh"
module dc(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,

    input wire [`EX_TO_DC_WD-1:0] ex_to_dc_bus,

    output wire [`DC_TO_MEM_WD-1:0] dc_to_mem_bus
);
    wire [65:0] hilo_bus_i;
    wire [31:0] pc_i;
    wire sel_rf_res_i;
    wire rf_we_i;
    wire [4:0] rf_waddr_i;
    wire [4:0] mem_op_i;
    wire data_ram_en_i;
    wire [3:0] data_ram_wen_i;
    wire [31:0] alu_result_i;

    assign {
        mem_op_i,       // 146:142
        hilo_bus_i,     // 141:76
        pc_i,           // 75:44        
        data_ram_en_i,  // 43
        data_ram_wen_i, // 42:39
        sel_rf_res_i,   // 38
        rf_we_i,        // 37
        rf_waddr_i,     // 36:32
        alu_result_i    // 31:0
    } = ex_to_dc_bus;

    reg [65:0] hilo_bus;
    reg [31:0] pc;
    reg sel_rf_res;
    reg rf_we;
    reg [4:0] rf_waddr;
    reg [4:0] mem_op;
    reg data_ram_en;
    reg [3:0] data_ram_wen;
    reg [31:0] alu_result;

    always @ (posedge clk) begin
        if (rst) begin
            hilo_bus <= 66'b0;
            pc <= 32'b0;
            sel_rf_res <= 1'b0;
            rf_we <= 1'b0;
            rf_waddr <= 5'b0;
            mem_op <= 5'b0;
            data_ram_en <= 1'b0;
            data_ram_wen <= 4'b0;
            alu_result <= 32'b0;
        end
        else if (flush) begin
            hilo_bus <= 66'b0;
            pc <= 32'b0;
            sel_rf_res <= 1'b0;
            rf_we <= 1'b0;
            rf_waddr <= 5'b0;
            mem_op <= 5'b0;
            data_ram_en <= 1'b0;
            data_ram_wen <= 4'b0;
            alu_result <= 32'b0;
        end
        else if (stall[4] == `Stop && stall[5] == `NoStop) begin
            hilo_bus <= 66'b0;
            pc <= 32'b0;
            sel_rf_res <= 1'b0;
            rf_we <= 1'b0;
            rf_waddr <= 5'b0;
            mem_op <= 5'b0;
            data_ram_en <= 1'b0;
            data_ram_wen <= 4'b0;
            alu_result <= 32'b0;
        end
        else if (stall[4] == `NoStop) begin
            hilo_bus <= hilo_bus_i;
            pc <= pc_i;
            sel_rf_res <= sel_rf_res_i;
            rf_we <= rf_we_i;
            rf_waddr <= rf_waddr_i;
            mem_op <= mem_op_i;
            data_ram_en <= data_ram_en_i;
            data_ram_wen <= data_ram_wen_i;
            alu_result <= alu_result_i;
        end
    end

    assign dc_to_mem_bus = {
        mem_op,         // 146:142
        hilo_bus,       // 141:76
        pc,             // 75:44
        data_ram_en,    // 43
        data_ram_wen,   // 42:39
        sel_rf_res,     // 38
        rf_we,          // 37
        rf_waddr,       // 36:32
        alu_result      // 31:0
    };

endmodule 