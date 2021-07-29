`include "defines.vh"

module cache_data_v3(
    input wire clk,
    input wire rst,

    input wire write_back,
    input wire [`HIT_WIDTH-1:0] hit,
    input wire [`LRU_WIDTH-1:0] lru,
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
    wire [31:0] rdata_way1 [7:0];
    wire [31:0] rdata_way2 [7:0];
    wire [31:0] rdata_way3 [7:0];

    wire [`TAG_WIDTH-2:0] tag;
    wire [6:0] index;
    wire [4:0] offset;
    reg [`HIT_WIDTH-1:0] hit_r;
    reg [`LRU_WIDTH-1:0] lru_r;
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
            hit_r <= `HIT_WIDTH'b0;
            lru_r <= `LRU_WIDTH'b0;
            cached_r <= 1'b1;
            bank_sel_r <= 8'b0;
        end
        else begin
            hit_r <= hit;
            lru_r <= lru;
            cached_r <= cached;
            bank_sel_r <= bank_sel;
        end
    end
    
// data_bram_way0 begin
    data_bram_bank bank0_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[0]&hit[0]|write_back),     // 1
        .wea(refresh?(~lru[2]&~lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[31:0]:sram_wdata),    // 32
        .douta(rdata_way0[0])    //32
    );
    data_bram_bank bank1_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[1]&hit[0]|write_back),     // 1
        .wea(refresh?(~lru[2]&~lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[63:32]:sram_wdata),    // 32
        .douta(rdata_way0[1])    //32
    );
    data_bram_bank bank2_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[2]&hit[0]|write_back),     // 1
        .wea(refresh?(~lru[2]&~lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[95:64]:sram_wdata),    // 32
        .douta(rdata_way0[2])    //32
    );
    data_bram_bank bank3_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[3]&hit[0]|write_back),     // 1
        .wea(refresh?(~lru[2]&~lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[127:96]:sram_wdata),    // 32
        .douta(rdata_way0[3])    //32
    );
    data_bram_bank bank4_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[4]&hit[0]|write_back),     // 1
        .wea(refresh?(~lru[2]&~lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[159:128]:sram_wdata),    // 32
        .douta(rdata_way0[4])    //32
    );
    data_bram_bank bank5_way0(
        .clka(clk),
        .ena((cached&refresh|sram_en&bank_sel[5]&hit[0]|write_back)),     // 1
        .wea(refresh?(~lru[2]&~lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[191:160]:sram_wdata),    // 32
        .douta(rdata_way0[5])    //32
    );
    data_bram_bank bank6_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[6]&hit[0]|write_back),     // 1
        .wea(refresh?(~lru[2]&~lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[223:192]:sram_wdata),    // 32
        .douta(rdata_way0[6])    //32
    );
    data_bram_bank bank7_way0(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[7]&hit[0]|write_back),     // 1
        .wea(refresh?(~lru[2]&~lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[255:224]:sram_wdata),    // 32
        .douta(rdata_way0[7])    //32
    );
// data_bram_way0 end

// data_bram_way1 begin
    data_bram_bank bank0_way1(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[0]&hit[1]|write_back),     // 1
        .wea(refresh?(~lru[2]&lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[31:0]:sram_wdata),    // 32
        .douta(rdata_way1[0])    //32
    );
    data_bram_bank bank1_way1(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[1]&hit[1]|write_back),     // 1
        .wea(refresh?(~lru[2]&lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[63:32]:sram_wdata),    // 32
        .douta(rdata_way1[1])    //32
    );
    data_bram_bank bank2_way1(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[2]&hit[1]|write_back),     // 1
        .wea(refresh?(~lru[2]&lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[95:64]:sram_wdata),    // 32
        .douta(rdata_way1[2])    //32
    );
    data_bram_bank bank3_way1(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[3]&hit[1]|write_back),     // 1
        .wea(refresh?(~lru[2]&lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[127:96]:sram_wdata),    // 32
        .douta(rdata_way1[3])    //32
    );
    data_bram_bank bank4_way1(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[4]&hit[1]|write_back),     // 1
        .wea(refresh?(~lru[2]&lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[159:128]:sram_wdata),    // 32
        .douta(rdata_way1[4])    //32
    );
    data_bram_bank bank5_way1(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[5]&hit[1]|write_back),     // 1
        .wea(refresh?(~lru[2]&lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[191:160]:sram_wdata),    // 32
        .douta(rdata_way1[5])    //32
    );
    data_bram_bank bank6_way1(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[6]&hit[1]|write_back),     // 1
        .wea(refresh?(~lru[2]&lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[223:192]:sram_wdata),    // 32
        .douta(rdata_way1[6])    //32
    );
    data_bram_bank bank7_way1(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[7]&hit[1]|write_back),     // 1
        .wea(refresh?(~lru[2]&lru[0])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[255:224]:sram_wdata),    // 32
        .douta(rdata_way1[7])    //32
    );
// data_bram_way1 end

// data_bram_way2 begin
    data_bram_bank bank0_way2(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[0]&hit[2]|write_back),     // 1
        .wea(refresh?(lru[2]&~lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[31:0]:sram_wdata),    // 32
        .douta(rdata_way2[0])    //32
    );
    data_bram_bank bank1_way2(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[1]&hit[2]|write_back),     // 1
        .wea(refresh?(lru[2]&~lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[63:32]:sram_wdata),    // 32
        .douta(rdata_way2[1])    //32
    );
    data_bram_bank bank2_way2(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[2]&hit[2]|write_back),     // 1
        .wea(refresh?(lru[2]&~lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[95:64]:sram_wdata),    // 32
        .douta(rdata_way2[2])    //32
    );
    data_bram_bank bank3_way2(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[3]&hit[2]|write_back),     // 1
        .wea(refresh?(lru[2]&~lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[127:96]:sram_wdata),    // 32
        .douta(rdata_way2[3])    //32
    );
    data_bram_bank bank4_way2(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[4]&hit[2]|write_back),     // 1
        .wea(refresh?(lru[2]&~lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[159:128]:sram_wdata),    // 32
        .douta(rdata_way2[4])    //32
    );
    data_bram_bank bank5_way2(
        .clka(clk),
        .ena((cached&refresh|sram_en&bank_sel[5]&hit[2]|write_back)),     // 1
        .wea(refresh?(lru[2]&~lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[191:160]:sram_wdata),    // 32
        .douta(rdata_way2[5])    //32
    );
    data_bram_bank bank6_way2(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[6]&hit[2]|write_back),     // 1
        .wea(refresh?(lru[2]&~lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[223:192]:sram_wdata),    // 32
        .douta(rdata_way2[6])    //32
    );
    data_bram_bank bank7_way2(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[7]&hit[2]|write_back),     // 1
        .wea(refresh?(lru[2]&~lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[255:224]:sram_wdata),    // 32
        .douta(rdata_way2[7])    //32
    );
// data_bram_way2 end

// data_bram_way3 begin
    data_bram_bank bank0_way3(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[0]&hit[3]|write_back),     // 1
        .wea(refresh?(lru[2]&lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[31:0]:sram_wdata),    // 32
        .douta(rdata_way3[0])    //32
    );
    data_bram_bank bank1_way3(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[1]&hit[3]|write_back),     // 1
        .wea(refresh?(lru[2]&lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[63:32]:sram_wdata),    // 32
        .douta(rdata_way3[1])    //32
    );
    data_bram_bank bank2_way3(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[2]&hit[3]|write_back),     // 1
        .wea(refresh?(lru[2]&lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[95:64]:sram_wdata),    // 32
        .douta(rdata_way3[2])    //32
    );
    data_bram_bank bank3_way3(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[3]&hit[3]|write_back),     // 1
        .wea(refresh?(lru[2]&lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[127:96]:sram_wdata),    // 32
        .douta(rdata_way3[3])    //32
    );
    data_bram_bank bank4_way3(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[4]&hit[3]|write_back),     // 1
        .wea(refresh?(lru[2]&lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[159:128]:sram_wdata),    // 32
        .douta(rdata_way3[4])    //32
    );
    data_bram_bank bank5_way3(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[5]&hit[3]|write_back),     // 1
        .wea(refresh?(lru[2]&lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[191:160]:sram_wdata),    // 32
        .douta(rdata_way3[5])    //32
    );
    data_bram_bank bank6_way3(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[6]&hit[3]|write_back),     // 1
        .wea(refresh?(lru[2]&lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[223:192]:sram_wdata),    // 32
        .douta(rdata_way3[6])    //32
    );
    data_bram_bank bank7_way3(
        .clka(clk),
        .ena(cached&refresh|sram_en&bank_sel[7]&hit[3]|write_back),     // 1
        .wea(refresh?(lru[2]&lru[1])?4'b1111:4'b0000:write_back?4'b0000:sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[255:224]:sram_wdata),    // 32
        .douta(rdata_way3[7])    //32
    );
// data_bram_way3 end

    wire [31:0] sram_rdata_way0,sram_rdata_way1,sram_rdata_way2,sram_rdata_way3;

    assign sram_rdata_way0 = ~cached_r ? 32'b0 :
                            bank_sel_r[0] ? rdata_way0[0] :
                            bank_sel_r[1] ? rdata_way0[1] :
                            bank_sel_r[2] ? rdata_way0[2] :
                            bank_sel_r[3] ? rdata_way0[3] :
                            bank_sel_r[4] ? rdata_way0[4] :
                            bank_sel_r[5] ? rdata_way0[5] :
                            bank_sel_r[6] ? rdata_way0[6] :
                            bank_sel_r[7] ? rdata_way0[7] : 32'b0;
    assign sram_rdata_way1 = ~cached_r ? 32'b0 :
                            bank_sel_r[0] ? rdata_way1[0] :
                            bank_sel_r[1] ? rdata_way1[1] :
                            bank_sel_r[2] ? rdata_way1[2] :
                            bank_sel_r[3] ? rdata_way1[3] :
                            bank_sel_r[4] ? rdata_way1[4] :
                            bank_sel_r[5] ? rdata_way1[5] :
                            bank_sel_r[6] ? rdata_way1[6] :
                            bank_sel_r[7] ? rdata_way1[7] : 32'b0;
    assign sram_rdata_way2 = ~cached_r ? 32'b0 :
                            bank_sel_r[0] ? rdata_way2[0] :
                            bank_sel_r[1] ? rdata_way2[1] :
                            bank_sel_r[2] ? rdata_way2[2] :
                            bank_sel_r[3] ? rdata_way2[3] :
                            bank_sel_r[4] ? rdata_way2[4] :
                            bank_sel_r[5] ? rdata_way2[5] :
                            bank_sel_r[6] ? rdata_way2[6] :
                            bank_sel_r[7] ? rdata_way2[7] : 32'b0;
    assign sram_rdata_way3 = ~cached_r ? 32'b0 :
                            bank_sel_r[0] ? rdata_way3[0] :
                            bank_sel_r[1] ? rdata_way3[1] :
                            bank_sel_r[2] ? rdata_way3[2] :
                            bank_sel_r[3] ? rdata_way3[3] :
                            bank_sel_r[4] ? rdata_way3[4] :
                            bank_sel_r[5] ? rdata_way3[5] :
                            bank_sel_r[6] ? rdata_way3[6] :
                            bank_sel_r[7] ? rdata_way3[7] : 32'b0;

    assign sram_rdata = hit_r[0] ? sram_rdata_way0 :
                        hit_r[1] ? sram_rdata_way1 :
                        hit_r[2] ? sram_rdata_way2 :
                        hit_r[3] ? sram_rdata_way3 : 32'b0;

    wire [`CACHELINE_WIDTH-1:0] cacheline_old_way0, cacheline_old_way1, cacheline_old_way2, cacheline_old_way3;
    assign cacheline_old_way0 = {
        rdata_way0[7],
        rdata_way0[6],
        rdata_way0[5],
        rdata_way0[4],
        rdata_way0[3],
        rdata_way0[2],
        rdata_way0[1],
        rdata_way0[0]
    };
    assign cacheline_old_way1 = {
        rdata_way1[7],
        rdata_way1[6],
        rdata_way1[5],
        rdata_way1[4],
        rdata_way1[3],
        rdata_way1[2],
        rdata_way1[1],
        rdata_way1[0]
    };
    assign cacheline_old_way2 = {
        rdata_way2[7],
        rdata_way2[6],
        rdata_way2[5],
        rdata_way2[4],
        rdata_way2[3],
        rdata_way2[2],
        rdata_way2[1],
        rdata_way2[0]
    };
    assign cacheline_old_way3 = {
        rdata_way3[7],
        rdata_way3[6],
        rdata_way3[5],
        rdata_way3[4],
        rdata_way3[3],
        rdata_way3[2],
        rdata_way3[1],
        rdata_way3[0]
    };
    assign cacheline_old = lru_r[2] ? (lru_r[1] ? cacheline_old_way3 : cacheline_old_way2) : (lru_r[0] ? cacheline_old_way1 : cacheline_old_way0);
endmodule