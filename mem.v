`include "lib/defines.vh"
module mem(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,

    input wire [`DC_TO_MEM_WD-1:0] dc_to_mem_bus,

    output wire [`MEM_TO_WB_WD-1:0] mem_to_wb_bus,

    input wire [31:0] data_sram_rdata
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
    } = dc_to_mem_bus;

    reg [65:0] hilo_bus;
    reg [31:0] pc;
    reg sel_rf_res;
    reg rf_we;
    reg [4:0] rf_waddr;
    wire [31:0] rf_wdata;
    reg [4:0] mem_op;
    reg data_ram_en;
    reg [3:0] data_ram_wen;
    reg [31:0] alu_result;
    wire [31:0] mem_result;
    reg [31:0] data_sram_rdata_r;
    
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
            data_sram_rdata_r <= 32'b0;
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
            data_sram_rdata_r <= 32'b0;
        end
        else if (stall[5] == `Stop && stall[6] == `NoStop) begin
            hilo_bus <= 66'b0;
            pc <= 32'b0;
            sel_rf_res <= 1'b0;
            rf_we <= 1'b0;
            rf_waddr <= 5'b0;
            mem_op <= 5'b0;
            data_ram_en <= 1'b0;
            data_ram_wen <= 4'b0;
            alu_result <= 32'b0;
            data_sram_rdata_r <= 32'b0;
        end
        else if (stall[5] == `NoStop) begin
            hilo_bus <= hilo_bus_i;
            pc <= pc_i;
            sel_rf_res <= sel_rf_res_i;
            rf_we <= rf_we_i;
            rf_waddr <= rf_waddr_i;
            mem_op <= mem_op_i;
            data_ram_en <= data_ram_en_i;
            data_ram_wen <= data_ram_wen_i;
            alu_result <= alu_result_i;
            data_sram_rdata_r <= data_sram_rdata;
        end
    end

    wire inst_lb, inst_lbu, inst_lh, inst_lhu, inst_lw;
    assign {
        inst_lb,
        inst_lbu,
        inst_lh,
        inst_lhu,
        inst_lw
    } = mem_op;
    
    reg [31:0] mem_result_r;
    always @ (*) begin
        case(1'b1)
            inst_lb:begin
                case(alu_result[1:0])
                    2'b00:begin
                        mem_result_r = {{24{data_sram_rdata_r[7]}},data_sram_rdata_r[7:0]};
                    end
                    2'b01:begin
                        mem_result_r = {{24{data_sram_rdata_r[15]}},data_sram_rdata_r[15:8]};
                    end
                    2'b10:begin
                        mem_result_r = {{24{data_sram_rdata_r[23]}},data_sram_rdata_r[23:16]};
                    end
                    2'b11:begin
                        mem_result_r = {{24{data_sram_rdata_r[31]}},data_sram_rdata_r[31:24]};
                    end
                    default:begin
                        mem_result_r = 32'b0;
                    end
                endcase
            end
            inst_lbu:begin
                case(alu_result[1:0])
                    2'b00:begin
                        mem_result_r = {{24{1'b0}},data_sram_rdata_r[7:0]};
                    end
                    2'b01:begin
                        mem_result_r = {{24{1'b0}},data_sram_rdata_r[15:8]};
                    end
                    2'b10:begin
                        mem_result_r = {{24{1'b0}},data_sram_rdata_r[23:16]};
                    end
                    2'b11:begin
                        mem_result_r = {{24{1'b0}},data_sram_rdata_r[31:24]};
                    end
                    default:begin
                        mem_result_r = 32'b0;
                    end
                endcase
            end
            inst_lh:begin
                case(alu_result[1:0])
                    2'b00:begin
                        mem_result_r = {{16{data_sram_rdata_r[15]}},data_sram_rdata_r[15:0]};
                    end
                    
                    2'b10:begin
                        mem_result_r = {{16{data_sram_rdata_r[31]}},data_sram_rdata_r[31:16]};
                    end
                    default:begin
                        mem_result_r = 32'b0;
                    end
                endcase
            end
            inst_lhu:begin
                case(alu_result[1:0])
                    2'b00:begin
                        mem_result_r = {{16{1'b0}},data_sram_rdata_r[15:0]};
                    end
                    
                    2'b10:begin
                        mem_result_r = {{16{1'b0}},data_sram_rdata_r[31:16]};
                    end
                    default:begin
                        mem_result_r = 32'b0;
                    end
                endcase
            end
            inst_lw:begin
                mem_result_r = data_sram_rdata_r;
            end
            default:begin
                mem_result_r = 32'b0;
            end
        endcase
    end

    // assign mem_result = data_sram_rdata_r;
    assign rf_wdata = sel_rf_res ? mem_result_r : alu_result;
    assign mem_to_wb_bus = {
        hilo_bus,   // 135:70
        pc,         // 69:68
        rf_we,      // 37
        rf_waddr,   // 36:32
        rf_wdata    // 31:0
    };



endmodule 