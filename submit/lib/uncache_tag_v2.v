`include "defines.vh"
`define T1 2'b00
`define T2 2'b01
`define T3 2'b11
`define T4 2'b10

module uncache_tag_v2(
    input wire clk,
    input wire rst,
 
    output reg stallreq,

    input wire cached,
    // cpu i/o
    input wire sram_en,
    input wire [3:0] sram_wen,
    input wire [31:0] sram_addr,
    // input wire [31:0] sram_wdata,
    // output reg [31:0] sram_rdata,

    // axi i/o
    input wire refresh,

    output reg axi_en, // en
    output reg [3:0] axi_wsel, // wen
    output reg [31:0] axi_addr, // addr
    // wdata from ex to axi
    // output reg [31:0] axi_wdata, // wdata
    // input wire [31:0] axi_rdata, // rdata
    
    output reg hit
);
    reg [1:0] stage;
    // reg end_stall;
    // assign stallreq = rst ? 1'b0 : ~cached & sram_en & end_stall;

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            axi_en <= `False_v;
            axi_wsel <= 4'b0;
            axi_addr <= 32'b0;
            // axi_wdata <= 32'b0;
            // end_stall <= 1'b1;
            hit <= 1'b0;
            stallreq <= 1'b0;

            stage <= `T1;
        end
        else begin
            case (stage)
                `T1:begin
                    if (sram_en&~cached) begin // write
                        axi_en <= `True_v;
                        axi_wsel <= sram_wen;
                        axi_addr <= sram_addr;
                        // axi_wdata <= sram_wdata;
                        stallreq <= 1'b1;
                        stage <= `T2;
                    end
                    hit <= 1'b0;
                    // end_stall <= 1'b1;
                end
                `T2:begin
                    if (refresh) begin
                        axi_en <= `False_v;
                        axi_wsel <= 4'b0;
                        axi_addr <= 32'b0;
                        // axi_wdata <= 32'b0;
                        stage <= `T3;
                        hit <= 1'b1;
                        stallreq <= 1'b0;
                    end
                end
                `T3:begin
                    stage <= `T1;
                    hit <= 1'b0;
                    stallreq <= 1'b0;
                end
                `T4:begin
                    
                end
                default:begin
                    stage <= `T1;
                    stallreq <= 1'b0;
                    // end_stall <= 1'b1;
                end
            endcase
        end
    end
endmodule 