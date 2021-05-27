module mux4_32b(
    input wire [31:0] in0, in1, in2, in3,
    input wire [3:0] sel,
    output wire [31:0] out
);
    assign out = ({32{sel[0]}} & in0) 
               | ({32{sel[1]}} & in1)
               | ({32{sel[2]}} & in2)
               | ({32{sel[3]}} & in3);
endmodule