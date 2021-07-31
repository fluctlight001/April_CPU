`include "defines.vh"
module decoder_4_16 (
    input wire [3:0] in,
    output reg [15:0] out
);
    always @ (*) begin
        case(in)
            4'd0 :begin out=16'b00000000_00000001; end
            4'd1 :begin out=16'b00000000_00000010; end
            4'd2 :begin out=16'b00000000_00000100; end
            4'd3 :begin out=16'b00000000_00001000; end
            4'd4 :begin out=16'b00000000_00010000; end
            4'd5 :begin out=16'b00000000_00100000; end
            4'd6 :begin out=16'b00000000_01000000; end
            4'd7 :begin out=16'b00000000_10000000; end
            4'd8 :begin out=16'b00000001_00000000; end
            4'd9 :begin out=16'b00000010_00000000; end
            4'd10:begin out=16'b00000100_00000000; end
            4'd11:begin out=16'b00001000_00000000; end
            4'd12:begin out=16'b00010000_00000000; end
            4'd13:begin out=16'b00100000_00000000; end
            4'd14:begin out=16'b01000000_00000000; end
            4'd15:begin out=16'b10000000_00000000; end
            default:begin
                out=16'b0;
            end
        endcase
    end
endmodule