`include "lib/defines.vh"
module ctrl (
    input wire rst,
    input wire stallreq_from_ic,    
    input wire stallreq_from_id,
    input wire stallreq_from_ex,
    input wire stallreq_from_dc,
    input wire stallreq_for_load,

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
        else if(stallreq_for_load) begin
            stall <= 8'b00001111;
            flush <= `False_v;
            new_pc <= `ZeroWord;
        end
        else if (stallreq_from_dc) begin
            stall <= 9'b011111111;
            flush <= `False_v;
            new_pc <= `ZeroWord;
        end
        else if (stallreq_from_ex) begin
            stall <= 9'b000011111;
            flush <= `False_v;
            new_pc <= `ZeroWord;
        end
        else if (stallreq_from_id) begin
            stall <= 9'b000001111;
            flush <= `False_v;
            new_pc <= `ZeroWord;
        end
        else if (stallreq_from_ic) begin
            stall <= 9'b000000111;
            flush <= `False_v;
            new_pc <= `ZeroWord;
        end
        else begin
            stall <= 8'b0;
            flush <= 1'b0;
            new_pc <= 32'b0;
        end
    end
    
endmodule