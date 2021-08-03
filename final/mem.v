`include "lib/defines.vh"
module mem(
    input wire clk,
    input wire rst,
    input wire flush,
    input wire [`StallBus] stall,

    input wire [`DC_TO_MEM_WD-1:0] dc_to_mem_bus,

    output wire [`MEM_TO_WB_WD-1:0] mem_to_wb_bus,

    input wire [31:0] data_sram_rdata,

    input wire [`RegBus] cp0_status,
    input wire [`RegBus] cp0_cause,
    input wire [`RegBus] cp0_epc,

    output wire [31:0] epc_to_ctrl
);

    reg [`DC_TO_MEM_WD-1:0] dc_to_mem_bus_r;
    reg [31:0] data_sram_rdata_r;
    reg flag;
    reg [31:0] data_sram_rdata_buffer;

    always @ (posedge clk) begin
        if (rst) begin
            dc_to_mem_bus_r <= `DC_TO_MEM_WD'b0;
            data_sram_rdata_r <= 32'b0;
            flag <= 1'b0;
        end
        else if (flush) begin
            dc_to_mem_bus_r <= `DC_TO_MEM_WD'b0;
            data_sram_rdata_r <= 32'b0;
            flag <= 1'b0;
        end
        else if (stall[6] == `Stop && stall[7] == `NoStop) begin
            dc_to_mem_bus_r <= `DC_TO_MEM_WD'b0;
            data_sram_rdata_r <= 32'b0;
            flag <= 1'b0;
        end
        else if (stall[6] == `NoStop&&flag) begin
            dc_to_mem_bus_r <= dc_to_mem_bus;
            data_sram_rdata_r <= data_sram_rdata_buffer;
            flag <= 1'b0;
        end
        else if (stall[6] == `NoStop&&~flag) begin
            dc_to_mem_bus_r <= dc_to_mem_bus;
            data_sram_rdata_r <= data_sram_rdata;
            flag <= 1'b0;
        end
        else if(~flag) begin
            data_sram_rdata_buffer <= data_sram_rdata;
            flag <= 1'b1;
        end
    end

    wire [65:0] hilo_bus;
    wire [31:0] pc;
    wire sel_rf_res;
    wire rf_we;
    wire [4:0] rf_waddr;
    wire [31:0] rf_wdata;
    wire [4:0] mem_op;
    wire data_ram_en;
    wire [3:0] data_ram_wen;
    wire [31:0] alu_result;
    wire [31:0] mem_result;
    wire [31:0] excepttype_arr;
    wire [31:0] bad_vaddr;
    wire is_in_delayslot;
    wire [37:0] cp0_bus;
    
    assign {
        cp0_bus,        // 249:212
        is_in_delayslot,// 211
        bad_vaddr,      // 210:179
        excepttype_arr, // 178:147
        mem_op,         // 146:142
        hilo_bus,       // 141:76
        pc,             // 75:44        
        data_ram_en,    // 43
        data_ram_wen,   // 42:39
        sel_rf_res,     // 38
        rf_we,          // 37
        rf_waddr,       // 36:32
        alu_result      // 31:0
    } = dc_to_mem_bus_r;

    wire inst_lb, inst_lbu, inst_lh, inst_lhu, inst_lw;
    assign {
        inst_lb,
        inst_lbu,
        inst_lh,
        inst_lhu,
        inst_lw
    } = mem_op;

        
    reg [31:0] excepttype_o;
    wire [31:0] cp0_epc_o;
    wire is_in_delayslot_o;
    wire [31:0] bad_vaddr_o;
    assign is_in_delayslot_o = is_in_delayslot;
    wire [37:0] cp0_bus_o;
    assign cp0_bus_o = cp0_bus;
    assign bad_vaddr_o = bad_vaddr;

    assign mem_to_wb_bus = {
        cp0_bus_o,      // 270:233
        cp0_epc_o,      // 232:201
        is_in_delayslot_o,// 200
        bad_vaddr_o,    // 199:168
        excepttype_o,   // 167:136
        hilo_bus,       // 135:70
        pc,             // 69:38
        rf_we,          // 37
        rf_waddr,       // 36:32
        rf_wdata        // 31:0
    };

// load part
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

// excepttype part
    // wire [31:0] cp0_status;
    // wire [31:0] cp0_cause;
    // wire [31:0] cp0_epc;
    assign cp0_epc_o = cp0_epc;

    always @ (*) begin
        if (rst == `RstEnable) begin
            excepttype_o <= `ZeroWord;
        end
        else begin
            excepttype_o <= `ZeroWord;
            if (pc != `ZeroWord) begin
                if (((cp0_cause[15:8] & cp0_status[15:8]) != 8'b0) && (cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1)) begin
                    excepttype_o <= 32'h00000001;         //interrupt
                end
                else if (excepttype_arr[16] == 1'b1) begin // ft_adel
                    excepttype_o <= 32'h00000004;
                end
                else if (excepttype_arr[9] == 1'b1) begin // inst_invalid
                    excepttype_o <= 32'h0000000a;
                end
                else if (excepttype_arr[8] == 1'b1) begin // syscall
                    excepttype_o <= 32'h00000008;
                end
                else if (excepttype_arr[13] == 1'b1) begin // break
                    excepttype_o <= 32'h00000009;
                end
                else if (excepttype_arr[10] == 1'b1) begin // trap
                    excepttype_o <= 32'h0000000d;
                end
                else if (excepttype_arr[11] == 1'b1) begin // ov
                    excepttype_o <= 32'h0000000c;
                end
                else if (excepttype_arr[12] == 1'b1) begin // eret
                    excepttype_o <= 32'h0000000e;
                end
                else if (excepttype_arr[14] == 1'b1) begin // storeassert
                    excepttype_o <= 32'h00000005;
                end
                else if (excepttype_arr[15] == 1'b1) begin // loadassert
                    excepttype_o <= 32'h00000004;
                end
            end
        end
  end


endmodule 