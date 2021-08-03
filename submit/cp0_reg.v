`include "lib/defines.vh"

module cp0_reg(
    input wire clk,
    input wire rst,
    input wire [`StallBus] stall,

    input wire we_i,
    input wire [4:0] waddr_i,
    input wire [4:0] raddr_i,
    input wire [31:0] data_i,

    input wire [5:0] int_i,

    output wire [31:0] data_o,
    output reg [31:0] status_o,
    output reg [31:0] cause_o,
    output reg [31:0] epc_o,
    output reg [31:0] config_o,

    output reg [31:0] timer_int_o,

    input wire [31:0] excepttype_i,
    input wire [31:0] pc_i,
    input wire [31:0] bad_vaddr_i,
    input wire is_in_delayslot_i,

    input wire [37:0] ex_cp0_bus,
    input wire [37:0] dt_cp0_bus,
    input wire [37:0] dc_cp0_bus,
    input wire [37:0] mem_cp0_bus
    // input wire [37:0] wb_cp0_bus
);
    reg [31:0] bad_vaddr;
    reg [31:0] count;
    reg [31:0] compare;
    reg [31:0] data_r;

    reg tick;
    always @ (posedge clk) begin
        if (rst) begin
            tick <= 1'b0;
        end
        else begin
            tick <= ~tick;
        end
    end

    // write 
    always @ (posedge clk) begin
        if (rst) begin
            bad_vaddr <= 32'b0;
            count <= 33'b0;
            compare <= 32'b0;
            status_o <= {4'b0001,28'd0};
            cause_o <= 32'b0;
            epc_o <= 32'b0;
            config_o <= 32'b0;
            timer_int_o <= 32'b0;
            
        end
        else begin
            if (tick) begin
                count <= count + 1'b1;
            end
            cause_o[15:10] <= int_i;
            if (compare != 32'b0 && count == compare) begin
                timer_int_o <= `InterruptAssert;
            end 
            if (we_i) begin
                case (waddr_i)
                    `CP0_REG_COUNT:begin
                        count <= data_i;
                    end 
                    `CP0_REG_COMPARE:begin
                        compare <= data_i;
                    end
                    `CP0_REG_STATUS:begin
                        status_o <= data_i;
                    end
                    `CP0_REG_EPC:begin
                        epc_o <= data_i;
                    end
                    `CP0_REG_CAUSE:begin
                        cause_o[9:8] <= data_i[9:8];
                        cause_o[23] <= data_i[23];
                        cause_o[22] <= data_i[22];
                    end
                    default:begin
                        
                    end
                endcase
            end
            case (excepttype_i)
                32'h00000001:begin // interrupt
                    if (is_in_delayslot_i == `InDelaySlot) begin
                        epc_o <= pc_i - 4;
                        cause_o[31] <= 1'b1;
                    end
                    else begin
                        epc_o <= pc_i;
                        cause_o[31] <= 1'b0;
                    end
                        status_o[1] <= 1'b1;
                        cause_o[6:2] <= 5'b00000;
                    end
                32'h00000004:begin // loadassert
                    if (status_o[1] == 1'b0) begin
                        if (is_in_delayslot_i == `InDelaySlot) begin
                            epc_o <= pc_i - 4;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= pc_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b00100;
                    bad_vaddr <= bad_vaddr_i;
                end
                32'h00000005:begin // storeassert
                    if (status_o[1] == 1'b0) begin
                        if (is_in_delayslot_i == `InDelaySlot) begin
                            epc_o <= pc_i - 4;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= pc_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b00101;
                    bad_vaddr <= bad_vaddr_i;
                end
                32'h00000008:begin // syscall
                    if (status_o[1] == 1'b0) begin
                        if (is_in_delayslot_i == `InDelaySlot) begin
                            epc_o <= pc_i - 4;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= pc_i;
                            cause_o[31] <= 1'b0;
                        end            
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01000;
                end
                32'h00000009:begin // break
                    if (status_o[1] == 1'b0) begin
                        if (is_in_delayslot_i == `InDelaySlot) begin
                            epc_o <= pc_i - 4;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= pc_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01001;
                end
                32'h0000000a:begin // inst_invalid
                    if (status_o[1] == 1'b0) begin
                        if (is_in_delayslot_i == `InDelaySlot) begin
                            epc_o <= pc_i - 4;
                            cause_o[31] <= 1'b1; 
                        end
                        else begin
                            epc_o <= pc_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01010;
                end
                32'h0000000d:begin // trap
                    if (status_o[1] == 1'b0) begin
                        if (is_in_delayslot_i == `InDelaySlot) begin
                            epc_o <= pc_i - 4;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= pc_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01101;
                end
                32'h0000000c:begin // ov
                    if (status_o[1] == 1'b0) begin
                        if (is_in_delayslot_i == `InDelaySlot) begin
                            epc_o <= pc_i - 4;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= pc_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01100; 
                end
                32'h0000000e:begin // 
                    status_o[1] <= 1'b0;
                end
                default:begin
                
                end
            endcase
        end
    end

    always @ (*) begin
        if (rst == `RstEnable) begin
            data_r <= `ZeroWord;
        end
        else begin
            case (raddr_i)
                `CP0_REG_COUNT:begin
                    data_r <= count;
                end
                `CP0_REG_COMPARE:begin
                    data_r <= compare;
                end
                `CP0_REG_STATUS:begin
                    data_r <= status_o;
                end
                `CP0_REG_CAUSE:begin
                    data_r <= cause_o;
                end
                `CP0_REG_EPC:begin
                    data_r <= epc_o;
                end
                `CP0_REG_CONFIG:begin
                    data_r <= config_o;
                end
                `CP0_REG_BADADDR:begin
                    data_r <= bad_vaddr;
                end
                default:begin
                    data_r <= `ZeroWord;
                end
            endcase 
        end
    end

// bypass
    wire [31:0] cp0_data_temp;
    wire ex_ok, dt_ok, dc_ok, mem_ok, wb_ok;
    reg [37:0] ex_buffer, dt_buffer, dc_buffer, mem_buffer;

    always @ (posedge clk ) begin
        if (rst) begin
            {ex_buffer,dt_buffer,dc_buffer,mem_buffer} <= {38'b0,38'b0,38'b0,38'b0};
        end
        else if(stall[3] == `Stop && stall[4] == `NoStop) begin
            {ex_buffer,dt_buffer,dc_buffer,mem_buffer} <= {38'b0,38'b0,38'b0,38'b0};
        end
        else if (stall[3] == `NoStop) begin
            {ex_buffer,dt_buffer,dc_buffer,mem_buffer} <= {ex_cp0_bus,dt_cp0_bus,dc_cp0_bus,mem_cp0_bus};
        end
    end

    assign ex_ok = ex_buffer[37] & (raddr_i==ex_buffer[36:32]);
    assign dt_ok = dt_buffer[37] & (raddr_i==dt_buffer[36:32]);
    assign dc_ok = dc_buffer[37] & (raddr_i==dc_buffer[36:32]);
    assign mem_ok = mem_buffer[37] & (raddr_i==mem_buffer[36:32]);
    // assign wb_ok = wb_cp0_bus[37] & (raddr_i==wb_cp0_bus[36:32]);

    assign cp0_data_temp = ex_ok ? ex_buffer[31:0]
                         : dt_ok ? dt_buffer[31:0]
                         : dc_ok ? dc_buffer[31:0]
                         : mem_ok ? mem_buffer[31:0]
                        //  : wb_ok ? wb_cp0_bus[31:0]
                         : data_r;
    assign data_o = cp0_data_temp;
    // assign ex_ok = ex_cp0_bus[37] & (raddr_i==ex_cp0_bus[36:32]);
    // assign dc_ok = dc_cp0_bus[37] & (raddr_i==dc_cp0_bus[36:32]);
    // assign mem_ok = mem_cp0_bus[37] & (raddr_i==mem_cp0_bus[36:32]);
    // // assign wb_ok = wb_cp0_bus[37] & (raddr_i==wb_cp0_bus[36:32]);

    // assign cp0_data_temp = ex_ok ? ex_cp0_bus[31:0]
    //                      : dc_ok ? dc_cp0_bus[31:0]
    //                      : mem_ok ? mem_cp0_bus[31:0]
    //                     //  : wb_ok ? wb_cp0_bus[31:0]
    //                      : data_r;

    // always @ (posedge clk) begin
    //     if(rst) begin
    //         data_o <= 32'b0;
    //     end
    //     else if(stall[3] == `Stop && stall[4] == `NoStop) begin
    //         data_o <= 32'b0;
    //     end
    //     else if (stall[3] == `NoStop) begin
    //         data_o <= cp0_data_temp;
    //     end
    // end

endmodule