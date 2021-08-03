`include "defines.vh"
module uncache_data(
    input wire clk,
    input wire rst,
    
    input wire hit,
    input wire cached,
    // axi in
    input wire refresh,
    input wire [31:0] axi_rdata,
    // sram out
    output wire [31:0] sram_rdata
);  
    reg [31:0] sram_rdata_r;
    reg hit_r;
    reg cached_r;
    always @ (posedge clk) begin
        if (rst) begin
            sram_rdata_r <= 32'b0;
        end
        else if (refresh) begin
            sram_rdata_r <= axi_rdata;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            hit_r <= 1'b0;
            cached_r <= 1'b1;
        end
        else begin
            hit_r <= hit;
            cached_r <= cached;
        end
    end

    assign sram_rdata = hit_r & ~cached_r ? sram_rdata_r : 32'b0;
endmodule