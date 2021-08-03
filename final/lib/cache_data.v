`include "defines.vh"

module cache_data(
    input wire clk,
    input wire rst,

    input wire write_back,
    input wire hit,
    input wire cached,

    // sram_port
    input wire sram_en,
    input wire [3:0] sram_wen,
    input wire [31:0] sram_addr,
    input wire [31:0] sram_wdata,
    output wire [31:0] sram_rdata,

    // axi
    input wire refresh,
    input wire [`CACHELINE_WIDTH-1:0] cacheline_new,
    output wire [`CACHELINE_WIDTH-1:0] cacheline_old
);
    wire [31:0] rdata_way0 [7:0];
    wire [`TAG_WIDTH-2:0] tag;
    wire [6:0] index;
    wire [4:0] offset;
    reg hit_r;
    reg cached_r;
    assign {
        tag,
        index,
        offset
    } = sram_addr;

    wire [7:0] bank_sel;
    reg [7:0] bank_sel_r;
    decoder_3_8 u_decoder_3_8(
    	.in  (offset[4:2]  ),
        .out (bank_sel )
    );

    always @ (posedge clk) begin
        if (rst) begin
            hit_r <= 1'b0;
            cached_r <= 1'b1;
            bank_sel_r <= 8'b0;
        end
        else begin
            hit_r <= hit;
            cached_r <= cached;
            bank_sel_r <= bank_sel;
        end
    end
    
// data_bram begin
    data_bram_bank bank0_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[0]|write_back),     // 1
        .wea(refresh?4'b1111:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[31:0]:sram_wdata),    // 32
        .douta(rdata_way0[0])    //32
    );
    data_bram_bank bank1_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[1]|write_back),     // 1
        .wea(refresh?4'b1111:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[63:32]:sram_wdata),    // 32
        .douta(rdata_way0[1])    //32
    );
    data_bram_bank bank2_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[2]|write_back),     // 1
        .wea(refresh?4'b1111:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[95:64]:sram_wdata),    // 32
        .douta(rdata_way0[2])    //32
    );
    data_bram_bank bank3_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[3]|write_back),     // 1
        .wea(refresh?4'b1111:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[127:96]:sram_wdata),    // 32
        .douta(rdata_way0[3])    //32
    );
    data_bram_bank bank4_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[4]|write_back),     // 1
        .wea(refresh?4'b1111:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[159:128]:sram_wdata),    // 32
        .douta(rdata_way0[4])    //32
    );
    data_bram_bank bank5_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[5]|write_back),     // 1
        .wea(refresh?4'b1111:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[191:160]:sram_wdata),    // 32
        .douta(rdata_way0[5])    //32
    );
    data_bram_bank bank6_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[6]|write_back),     // 1
        .wea(refresh?4'b1111:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[223:192]:sram_wdata),    // 32
        .douta(rdata_way0[6])    //32
    );
    data_bram_bank bank7_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[7]|write_back),     // 1
        .wea(refresh?4'b1111:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[255:224]:sram_wdata),    // 32
        .douta(rdata_way0[7])    //32
    );
// data_bram end

    assign sram_rdata = ~hit_r ? 32'b0 :
                        ~cached_r ? 32'b0:
                        bank_sel_r[0] ? rdata_way0[0] :
                        bank_sel_r[1] ? rdata_way0[1] :
                        bank_sel_r[2] ? rdata_way0[2] :
                        bank_sel_r[3] ? rdata_way0[3] :
                        bank_sel_r[4] ? rdata_way0[4] :
                        bank_sel_r[5] ? rdata_way0[5] :
                        bank_sel_r[6] ? rdata_way0[6] :
                        bank_sel_r[7] ? rdata_way0[7] : 32'b0;
    assign cacheline_old = {
        rdata_way0[7],
        rdata_way0[6],
        rdata_way0[5],
        rdata_way0[4],
        rdata_way0[3],
        rdata_way0[2],
        rdata_way0[1],
        rdata_way0[0]
    };
endmodule