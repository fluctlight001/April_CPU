`include "lib/defines.vh"
module ctrl (
    input wire rst,
    input wire stallreq_for_ex,
    input wire stallreq_for_load,
    input wire stallreq_from_icache,
    input wire stallreq_from_dcache,
    input wire stallreq_from_axi,

    input wire [31:0] excepttype_i,
    input wire [`RegBus] cp0_epc_i,
    
    output reg flush,
    output reg [`RegBus] new_pc,
    output reg [`StallBus] stall
);
    always @ (*) begin
        if (rst) begin
           stall <=  9'b0;
           flush <= `False_v;
           new_pc <= `ZeroWord;
        end
        else if (excepttype_i != `ZeroWord) begin
            stall <= 9'b0;
            flush <= `True_v;
            new_pc <= `ZeroWord;
            case (excepttype_i)
                32'h00000001:begin
                    new_pc <= 32'hbfc00380;
                end
                32'h00000004:begin
                    new_pc <= 32'hbfc00380;
                end
                32'h00000005:begin
                    new_pc <= 32'hbfc00380;
                end
                32'h00000008:begin
                    new_pc <= 32'hbfc00380;
                end
                32'h00000009:begin
                    new_pc <= 32'hbfc00380;
                end
                32'h0000000a:begin
                    new_pc <= 32'hbfc00380;
                end
                32'h0000000d:begin
                    new_pc <= 32'hbfc00380;
                end
                32'h0000000c:begin
                    new_pc <= 32'hbfc00380;
                end
                32'h0000000e:begin
                    new_pc <= cp0_epc_i;
                end
                default:begin
                    new_pc <= 32'b0;
                end
            endcase
        end
        else if (stallreq_from_icache|stallreq_from_dcache|stallreq_from_axi) begin
            stall <= 9'b011111111;
            flush <= `False_v;
            new_pc <= `ZeroWord;
        end
        else if (stallreq_for_ex) begin
            stall <= 9'b000011111;
            flush <= `False_v;
            new_pc <= `ZeroWord;
        end
        else if(stallreq_for_load) begin
            stall <= 9'b000001111;
            flush <= `False_v;
            new_pc <= `ZeroWord;
        end
        else begin
            stall <= 9'b0;
            flush <= 1'b0;
            new_pc <= 32'b0;
        end
    end
    
endmodule