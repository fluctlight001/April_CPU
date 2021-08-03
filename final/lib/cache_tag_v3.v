`include "defines.vh"

module cache_tag_v3(
    input wire clk,
    input wire rst,
    
    output wire stallreq,

    input wire cached,   //  根据是不是uncache，来控制cacheline是否可复用

    // sram_port
    input wire sram_en,
    input wire [3:0] sram_wen,
    input wire [31:0] sram_addr,
    // input wire [31:0] sram_wdata,
    // output wire [31:0] sram_rdata,
    // axi
    input wire refresh, // 刷新,控制新pc写入

    output wire miss,
    output wire [31:0] axi_raddr,
    output wire write_back,
    output wire [31:0] axi_waddr,

    // cache_data
    output wire [`HIT_WIDTH-1:0] hit,
    output wire [`LRU_WIDTH-1:0] lru
);
    reg [`TAG_WIDTH-1:0] tag_way0 [`INDEX_WIDTH-1:0]; // v + tag 
    reg [`TAG_WIDTH-1:0] tag_way1 [`INDEX_WIDTH-1:0];
    reg [`TAG_WIDTH-1:0] tag_way2 [`INDEX_WIDTH-1:0];
    reg [`TAG_WIDTH-1:0] tag_way3 [`INDEX_WIDTH-1:0];
    reg [`INDEX_WIDTH-1:0] lru_r [`LRU_WIDTH-1:0];
    wire [`TAG_WIDTH-2:0] tag;
    wire [6:0] index;
    wire [4:0] offset;
    wire cached_v;
    // wire [`TAG_WIDTH-1:0] tag_ram_out;

    wire hit_way0;
    wire hit_way1;
    wire hit_way2;
    wire hit_way3;
    wire [31:0] axi_waddr_way0;
    wire [31:0] axi_waddr_way1;
    wire [31:0] axi_waddr_way2;
    wire [31:0] axi_waddr_way3;
    wire write_back_way0;
    wire write_back_way1;
    wire write_back_way2;
    wire write_back_way3;
    
    assign cached_v = cached;
    
    assign {
        tag,
        index,
        offset
    } = sram_addr;

    // tag_dist_ram u_tag_ram(
    //     .clk(clk),
    //     .we(refresh),
    //     .a(index),
    //     .d({cached_v,tag}),
    //     .spo(tag_ram_out)
    // );

    // lru lru_r指向的即为最闲的那个
    always @ (posedge clk) begin
        if (rst) begin
            lru_r[0] <= `INDEX_WIDTH'b0;
        end
        else if (hit_way0 & ~hit_way1) begin
            lru_r[0][index] <= 1'b1;
        end
        else if (~hit_way0 & hit_way1) begin
            lru_r[0][index] <= 1'b0;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            lru_r[1] <= `INDEX_WIDTH'b0;
        end 
        else if (hit_way2 & ~hit_way3) begin
            lru_r[1][index] <= 1'b1;
        end   
        else if (~hit_way2 & hit_way3) begin
            lru_r[1][index] <= 1'b0;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            lru_r[2] <= `INDEX_WIDTH'b0;
        end
        else if (hit_way0|hit_way1) begin
            lru_r[2][index] <= 1'b1;
        end
        else if (hit_way2|hit_way3) begin
            lru_r[2][index] <= 1'b0;
        end
    end


    // way0
    always @ (posedge clk) begin
        if (rst) begin
            tag_way0[  0] <= 21'b0;
            tag_way0[  1] <= 21'b0;
            tag_way0[  2] <= 21'b0;
            tag_way0[  3] <= 21'b0;
            tag_way0[  4] <= 21'b0;
            tag_way0[  5] <= 21'b0;
            tag_way0[  6] <= 21'b0;
            tag_way0[  7] <= 21'b0;
            tag_way0[  8] <= 21'b0;
            tag_way0[  9] <= 21'b0;
            tag_way0[ 10] <= 21'b0;
            tag_way0[ 11] <= 21'b0;
            tag_way0[ 12] <= 21'b0;
            tag_way0[ 13] <= 21'b0;
            tag_way0[ 14] <= 21'b0;
            tag_way0[ 15] <= 21'b0;
            tag_way0[ 16] <= 21'b0;
            tag_way0[ 17] <= 21'b0;
            tag_way0[ 18] <= 21'b0;
            tag_way0[ 19] <= 21'b0;
            tag_way0[ 20] <= 21'b0;
            tag_way0[ 21] <= 21'b0;
            tag_way0[ 22] <= 21'b0;
            tag_way0[ 23] <= 21'b0;
            tag_way0[ 24] <= 21'b0;
            tag_way0[ 25] <= 21'b0;
            tag_way0[ 26] <= 21'b0;
            tag_way0[ 27] <= 21'b0;
            tag_way0[ 28] <= 21'b0;
            tag_way0[ 29] <= 21'b0;
            tag_way0[ 30] <= 21'b0;
            tag_way0[ 31] <= 21'b0;
            tag_way0[ 32] <= 21'b0;
            tag_way0[ 33] <= 21'b0;
            tag_way0[ 34] <= 21'b0;
            tag_way0[ 35] <= 21'b0;
            tag_way0[ 36] <= 21'b0;
            tag_way0[ 37] <= 21'b0;
            tag_way0[ 38] <= 21'b0;
            tag_way0[ 39] <= 21'b0;
            tag_way0[ 40] <= 21'b0;
            tag_way0[ 41] <= 21'b0;
            tag_way0[ 42] <= 21'b0;
            tag_way0[ 43] <= 21'b0;
            tag_way0[ 44] <= 21'b0;
            tag_way0[ 45] <= 21'b0;
            tag_way0[ 46] <= 21'b0;
            tag_way0[ 47] <= 21'b0;
            tag_way0[ 48] <= 21'b0;
            tag_way0[ 49] <= 21'b0;
            tag_way0[ 50] <= 21'b0;
            tag_way0[ 51] <= 21'b0;
            tag_way0[ 52] <= 21'b0;
            tag_way0[ 53] <= 21'b0;
            tag_way0[ 54] <= 21'b0;
            tag_way0[ 55] <= 21'b0;
            tag_way0[ 56] <= 21'b0;
            tag_way0[ 57] <= 21'b0;
            tag_way0[ 58] <= 21'b0;
            tag_way0[ 59] <= 21'b0;
            tag_way0[ 60] <= 21'b0;
            tag_way0[ 61] <= 21'b0;
            tag_way0[ 62] <= 21'b0;
            tag_way0[ 63] <= 21'b0;
            tag_way0[ 64] <= 21'b0;
            tag_way0[ 65] <= 21'b0;
            tag_way0[ 66] <= 21'b0;
            tag_way0[ 67] <= 21'b0;
            tag_way0[ 68] <= 21'b0;
            tag_way0[ 69] <= 21'b0;
            tag_way0[ 70] <= 21'b0;
            tag_way0[ 71] <= 21'b0;
            tag_way0[ 72] <= 21'b0;
            tag_way0[ 73] <= 21'b0;
            tag_way0[ 74] <= 21'b0;
            tag_way0[ 75] <= 21'b0;
            tag_way0[ 76] <= 21'b0;
            tag_way0[ 77] <= 21'b0;
            tag_way0[ 78] <= 21'b0;
            tag_way0[ 79] <= 21'b0;
            tag_way0[ 80] <= 21'b0;
            tag_way0[ 81] <= 21'b0;
            tag_way0[ 82] <= 21'b0;
            tag_way0[ 83] <= 21'b0;
            tag_way0[ 84] <= 21'b0;
            tag_way0[ 85] <= 21'b0;
            tag_way0[ 86] <= 21'b0;
            tag_way0[ 87] <= 21'b0;
            tag_way0[ 88] <= 21'b0;
            tag_way0[ 89] <= 21'b0;
            tag_way0[ 90] <= 21'b0;
            tag_way0[ 91] <= 21'b0;
            tag_way0[ 92] <= 21'b0;
            tag_way0[ 93] <= 21'b0;
            tag_way0[ 94] <= 21'b0;
            tag_way0[ 95] <= 21'b0;
            tag_way0[ 96] <= 21'b0;
            tag_way0[ 97] <= 21'b0;
            tag_way0[ 98] <= 21'b0;
            tag_way0[ 99] <= 21'b0;
            tag_way0[100] <= 21'b0;
            tag_way0[101] <= 21'b0;
            tag_way0[102] <= 21'b0;
            tag_way0[103] <= 21'b0;
            tag_way0[104] <= 21'b0;
            tag_way0[105] <= 21'b0;
            tag_way0[106] <= 21'b0;
            tag_way0[107] <= 21'b0;
            tag_way0[108] <= 21'b0;
            tag_way0[109] <= 21'b0;
            tag_way0[110] <= 21'b0;
            tag_way0[111] <= 21'b0;
            tag_way0[112] <= 21'b0;
            tag_way0[113] <= 21'b0;
            tag_way0[114] <= 21'b0;
            tag_way0[115] <= 21'b0;
            tag_way0[116] <= 21'b0;
            tag_way0[117] <= 21'b0;
            tag_way0[118] <= 21'b0;
            tag_way0[119] <= 21'b0;
            tag_way0[120] <= 21'b0;
            tag_way0[121] <= 21'b0;
            tag_way0[122] <= 21'b0;
            tag_way0[123] <= 21'b0;
            tag_way0[124] <= 21'b0;
            tag_way0[125] <= 21'b0;
            tag_way0[126] <= 21'b0;
            tag_way0[127] <= 21'b0;
        end
        else if (refresh&(~lru_r[2][index])&(~lru_r[0][index])) begin
            tag_way0[index] <= {cached_v,tag};
        end
    end

    // way1
    always @ (posedge clk) begin
        if (rst) begin
            tag_way1[  0] <= 21'b0;
            tag_way1[  1] <= 21'b0;
            tag_way1[  2] <= 21'b0;
            tag_way1[  3] <= 21'b0;
            tag_way1[  4] <= 21'b0;
            tag_way1[  5] <= 21'b0;
            tag_way1[  6] <= 21'b0;
            tag_way1[  7] <= 21'b0;
            tag_way1[  8] <= 21'b0;
            tag_way1[  9] <= 21'b0;
            tag_way1[ 10] <= 21'b0;
            tag_way1[ 11] <= 21'b0;
            tag_way1[ 12] <= 21'b0;
            tag_way1[ 13] <= 21'b0;
            tag_way1[ 14] <= 21'b0;
            tag_way1[ 15] <= 21'b0;
            tag_way1[ 16] <= 21'b0;
            tag_way1[ 17] <= 21'b0;
            tag_way1[ 18] <= 21'b0;
            tag_way1[ 19] <= 21'b0;
            tag_way1[ 20] <= 21'b0;
            tag_way1[ 21] <= 21'b0;
            tag_way1[ 22] <= 21'b0;
            tag_way1[ 23] <= 21'b0;
            tag_way1[ 24] <= 21'b0;
            tag_way1[ 25] <= 21'b0;
            tag_way1[ 26] <= 21'b0;
            tag_way1[ 27] <= 21'b0;
            tag_way1[ 28] <= 21'b0;
            tag_way1[ 29] <= 21'b0;
            tag_way1[ 30] <= 21'b0;
            tag_way1[ 31] <= 21'b0;
            tag_way1[ 32] <= 21'b0;
            tag_way1[ 33] <= 21'b0;
            tag_way1[ 34] <= 21'b0;
            tag_way1[ 35] <= 21'b0;
            tag_way1[ 36] <= 21'b0;
            tag_way1[ 37] <= 21'b0;
            tag_way1[ 38] <= 21'b0;
            tag_way1[ 39] <= 21'b0;
            tag_way1[ 40] <= 21'b0;
            tag_way1[ 41] <= 21'b0;
            tag_way1[ 42] <= 21'b0;
            tag_way1[ 43] <= 21'b0;
            tag_way1[ 44] <= 21'b0;
            tag_way1[ 45] <= 21'b0;
            tag_way1[ 46] <= 21'b0;
            tag_way1[ 47] <= 21'b0;
            tag_way1[ 48] <= 21'b0;
            tag_way1[ 49] <= 21'b0;
            tag_way1[ 50] <= 21'b0;
            tag_way1[ 51] <= 21'b0;
            tag_way1[ 52] <= 21'b0;
            tag_way1[ 53] <= 21'b0;
            tag_way1[ 54] <= 21'b0;
            tag_way1[ 55] <= 21'b0;
            tag_way1[ 56] <= 21'b0;
            tag_way1[ 57] <= 21'b0;
            tag_way1[ 58] <= 21'b0;
            tag_way1[ 59] <= 21'b0;
            tag_way1[ 60] <= 21'b0;
            tag_way1[ 61] <= 21'b0;
            tag_way1[ 62] <= 21'b0;
            tag_way1[ 63] <= 21'b0;
            tag_way1[ 64] <= 21'b0;
            tag_way1[ 65] <= 21'b0;
            tag_way1[ 66] <= 21'b0;
            tag_way1[ 67] <= 21'b0;
            tag_way1[ 68] <= 21'b0;
            tag_way1[ 69] <= 21'b0;
            tag_way1[ 70] <= 21'b0;
            tag_way1[ 71] <= 21'b0;
            tag_way1[ 72] <= 21'b0;
            tag_way1[ 73] <= 21'b0;
            tag_way1[ 74] <= 21'b0;
            tag_way1[ 75] <= 21'b0;
            tag_way1[ 76] <= 21'b0;
            tag_way1[ 77] <= 21'b0;
            tag_way1[ 78] <= 21'b0;
            tag_way1[ 79] <= 21'b0;
            tag_way1[ 80] <= 21'b0;
            tag_way1[ 81] <= 21'b0;
            tag_way1[ 82] <= 21'b0;
            tag_way1[ 83] <= 21'b0;
            tag_way1[ 84] <= 21'b0;
            tag_way1[ 85] <= 21'b0;
            tag_way1[ 86] <= 21'b0;
            tag_way1[ 87] <= 21'b0;
            tag_way1[ 88] <= 21'b0;
            tag_way1[ 89] <= 21'b0;
            tag_way1[ 90] <= 21'b0;
            tag_way1[ 91] <= 21'b0;
            tag_way1[ 92] <= 21'b0;
            tag_way1[ 93] <= 21'b0;
            tag_way1[ 94] <= 21'b0;
            tag_way1[ 95] <= 21'b0;
            tag_way1[ 96] <= 21'b0;
            tag_way1[ 97] <= 21'b0;
            tag_way1[ 98] <= 21'b0;
            tag_way1[ 99] <= 21'b0;
            tag_way1[100] <= 21'b0;
            tag_way1[101] <= 21'b0;
            tag_way1[102] <= 21'b0;
            tag_way1[103] <= 21'b0;
            tag_way1[104] <= 21'b0;
            tag_way1[105] <= 21'b0;
            tag_way1[106] <= 21'b0;
            tag_way1[107] <= 21'b0;
            tag_way1[108] <= 21'b0;
            tag_way1[109] <= 21'b0;
            tag_way1[110] <= 21'b0;
            tag_way1[111] <= 21'b0;
            tag_way1[112] <= 21'b0;
            tag_way1[113] <= 21'b0;
            tag_way1[114] <= 21'b0;
            tag_way1[115] <= 21'b0;
            tag_way1[116] <= 21'b0;
            tag_way1[117] <= 21'b0;
            tag_way1[118] <= 21'b0;
            tag_way1[119] <= 21'b0;
            tag_way1[120] <= 21'b0;
            tag_way1[121] <= 21'b0;
            tag_way1[122] <= 21'b0;
            tag_way1[123] <= 21'b0;
            tag_way1[124] <= 21'b0;
            tag_way1[125] <= 21'b0;
            tag_way1[126] <= 21'b0;
            tag_way1[127] <= 21'b0;

        end
        else if (refresh&(~lru_r[2][index])&(lru_r[0][index])) begin
            tag_way1[index] <= {cached_v,tag};
        end
    end

    // way2
    always @ (posedge clk) begin
        if (rst) begin
            tag_way2[  0] <= 21'b0;
            tag_way2[  1] <= 21'b0;
            tag_way2[  2] <= 21'b0;
            tag_way2[  3] <= 21'b0;
            tag_way2[  4] <= 21'b0;
            tag_way2[  5] <= 21'b0;
            tag_way2[  6] <= 21'b0;
            tag_way2[  7] <= 21'b0;
            tag_way2[  8] <= 21'b0;
            tag_way2[  9] <= 21'b0;
            tag_way2[ 10] <= 21'b0;
            tag_way2[ 11] <= 21'b0;
            tag_way2[ 12] <= 21'b0;
            tag_way2[ 13] <= 21'b0;
            tag_way2[ 14] <= 21'b0;
            tag_way2[ 15] <= 21'b0;
            tag_way2[ 16] <= 21'b0;
            tag_way2[ 17] <= 21'b0;
            tag_way2[ 18] <= 21'b0;
            tag_way2[ 19] <= 21'b0;
            tag_way2[ 20] <= 21'b0;
            tag_way2[ 21] <= 21'b0;
            tag_way2[ 22] <= 21'b0;
            tag_way2[ 23] <= 21'b0;
            tag_way2[ 24] <= 21'b0;
            tag_way2[ 25] <= 21'b0;
            tag_way2[ 26] <= 21'b0;
            tag_way2[ 27] <= 21'b0;
            tag_way2[ 28] <= 21'b0;
            tag_way2[ 29] <= 21'b0;
            tag_way2[ 30] <= 21'b0;
            tag_way2[ 31] <= 21'b0;
            tag_way2[ 32] <= 21'b0;
            tag_way2[ 33] <= 21'b0;
            tag_way2[ 34] <= 21'b0;
            tag_way2[ 35] <= 21'b0;
            tag_way2[ 36] <= 21'b0;
            tag_way2[ 37] <= 21'b0;
            tag_way2[ 38] <= 21'b0;
            tag_way2[ 39] <= 21'b0;
            tag_way2[ 40] <= 21'b0;
            tag_way2[ 41] <= 21'b0;
            tag_way2[ 42] <= 21'b0;
            tag_way2[ 43] <= 21'b0;
            tag_way2[ 44] <= 21'b0;
            tag_way2[ 45] <= 21'b0;
            tag_way2[ 46] <= 21'b0;
            tag_way2[ 47] <= 21'b0;
            tag_way2[ 48] <= 21'b0;
            tag_way2[ 49] <= 21'b0;
            tag_way2[ 50] <= 21'b0;
            tag_way2[ 51] <= 21'b0;
            tag_way2[ 52] <= 21'b0;
            tag_way2[ 53] <= 21'b0;
            tag_way2[ 54] <= 21'b0;
            tag_way2[ 55] <= 21'b0;
            tag_way2[ 56] <= 21'b0;
            tag_way2[ 57] <= 21'b0;
            tag_way2[ 58] <= 21'b0;
            tag_way2[ 59] <= 21'b0;
            tag_way2[ 60] <= 21'b0;
            tag_way2[ 61] <= 21'b0;
            tag_way2[ 62] <= 21'b0;
            tag_way2[ 63] <= 21'b0;
            tag_way2[ 64] <= 21'b0;
            tag_way2[ 65] <= 21'b0;
            tag_way2[ 66] <= 21'b0;
            tag_way2[ 67] <= 21'b0;
            tag_way2[ 68] <= 21'b0;
            tag_way2[ 69] <= 21'b0;
            tag_way2[ 70] <= 21'b0;
            tag_way2[ 71] <= 21'b0;
            tag_way2[ 72] <= 21'b0;
            tag_way2[ 73] <= 21'b0;
            tag_way2[ 74] <= 21'b0;
            tag_way2[ 75] <= 21'b0;
            tag_way2[ 76] <= 21'b0;
            tag_way2[ 77] <= 21'b0;
            tag_way2[ 78] <= 21'b0;
            tag_way2[ 79] <= 21'b0;
            tag_way2[ 80] <= 21'b0;
            tag_way2[ 81] <= 21'b0;
            tag_way2[ 82] <= 21'b0;
            tag_way2[ 83] <= 21'b0;
            tag_way2[ 84] <= 21'b0;
            tag_way2[ 85] <= 21'b0;
            tag_way2[ 86] <= 21'b0;
            tag_way2[ 87] <= 21'b0;
            tag_way2[ 88] <= 21'b0;
            tag_way2[ 89] <= 21'b0;
            tag_way2[ 90] <= 21'b0;
            tag_way2[ 91] <= 21'b0;
            tag_way2[ 92] <= 21'b0;
            tag_way2[ 93] <= 21'b0;
            tag_way2[ 94] <= 21'b0;
            tag_way2[ 95] <= 21'b0;
            tag_way2[ 96] <= 21'b0;
            tag_way2[ 97] <= 21'b0;
            tag_way2[ 98] <= 21'b0;
            tag_way2[ 99] <= 21'b0;
            tag_way2[100] <= 21'b0;
            tag_way2[101] <= 21'b0;
            tag_way2[102] <= 21'b0;
            tag_way2[103] <= 21'b0;
            tag_way2[104] <= 21'b0;
            tag_way2[105] <= 21'b0;
            tag_way2[106] <= 21'b0;
            tag_way2[107] <= 21'b0;
            tag_way2[108] <= 21'b0;
            tag_way2[109] <= 21'b0;
            tag_way2[110] <= 21'b0;
            tag_way2[111] <= 21'b0;
            tag_way2[112] <= 21'b0;
            tag_way2[113] <= 21'b0;
            tag_way2[114] <= 21'b0;
            tag_way2[115] <= 21'b0;
            tag_way2[116] <= 21'b0;
            tag_way2[117] <= 21'b0;
            tag_way2[118] <= 21'b0;
            tag_way2[119] <= 21'b0;
            tag_way2[120] <= 21'b0;
            tag_way2[121] <= 21'b0;
            tag_way2[122] <= 21'b0;
            tag_way2[123] <= 21'b0;
            tag_way2[124] <= 21'b0;
            tag_way2[125] <= 21'b0;
            tag_way2[126] <= 21'b0;
            tag_way2[127] <= 21'b0;
        end
        else if (refresh&(lru_r[2][index])&(~lru_r[1][index])) begin
            tag_way2[index] <= {cached_v,tag};
        end
    end

    // way1
    always @ (posedge clk) begin
        if (rst) begin
            tag_way3[  0] <= 21'b0;
            tag_way3[  1] <= 21'b0;
            tag_way3[  2] <= 21'b0;
            tag_way3[  3] <= 21'b0;
            tag_way3[  4] <= 21'b0;
            tag_way3[  5] <= 21'b0;
            tag_way3[  6] <= 21'b0;
            tag_way3[  7] <= 21'b0;
            tag_way3[  8] <= 21'b0;
            tag_way3[  9] <= 21'b0;
            tag_way3[ 10] <= 21'b0;
            tag_way3[ 11] <= 21'b0;
            tag_way3[ 12] <= 21'b0;
            tag_way3[ 13] <= 21'b0;
            tag_way3[ 14] <= 21'b0;
            tag_way3[ 15] <= 21'b0;
            tag_way3[ 16] <= 21'b0;
            tag_way3[ 17] <= 21'b0;
            tag_way3[ 18] <= 21'b0;
            tag_way3[ 19] <= 21'b0;
            tag_way3[ 20] <= 21'b0;
            tag_way3[ 21] <= 21'b0;
            tag_way3[ 22] <= 21'b0;
            tag_way3[ 23] <= 21'b0;
            tag_way3[ 24] <= 21'b0;
            tag_way3[ 25] <= 21'b0;
            tag_way3[ 26] <= 21'b0;
            tag_way3[ 27] <= 21'b0;
            tag_way3[ 28] <= 21'b0;
            tag_way3[ 29] <= 21'b0;
            tag_way3[ 30] <= 21'b0;
            tag_way3[ 31] <= 21'b0;
            tag_way3[ 32] <= 21'b0;
            tag_way3[ 33] <= 21'b0;
            tag_way3[ 34] <= 21'b0;
            tag_way3[ 35] <= 21'b0;
            tag_way3[ 36] <= 21'b0;
            tag_way3[ 37] <= 21'b0;
            tag_way3[ 38] <= 21'b0;
            tag_way3[ 39] <= 21'b0;
            tag_way3[ 40] <= 21'b0;
            tag_way3[ 41] <= 21'b0;
            tag_way3[ 42] <= 21'b0;
            tag_way3[ 43] <= 21'b0;
            tag_way3[ 44] <= 21'b0;
            tag_way3[ 45] <= 21'b0;
            tag_way3[ 46] <= 21'b0;
            tag_way3[ 47] <= 21'b0;
            tag_way3[ 48] <= 21'b0;
            tag_way3[ 49] <= 21'b0;
            tag_way3[ 50] <= 21'b0;
            tag_way3[ 51] <= 21'b0;
            tag_way3[ 52] <= 21'b0;
            tag_way3[ 53] <= 21'b0;
            tag_way3[ 54] <= 21'b0;
            tag_way3[ 55] <= 21'b0;
            tag_way3[ 56] <= 21'b0;
            tag_way3[ 57] <= 21'b0;
            tag_way3[ 58] <= 21'b0;
            tag_way3[ 59] <= 21'b0;
            tag_way3[ 60] <= 21'b0;
            tag_way3[ 61] <= 21'b0;
            tag_way3[ 62] <= 21'b0;
            tag_way3[ 63] <= 21'b0;
            tag_way3[ 64] <= 21'b0;
            tag_way3[ 65] <= 21'b0;
            tag_way3[ 66] <= 21'b0;
            tag_way3[ 67] <= 21'b0;
            tag_way3[ 68] <= 21'b0;
            tag_way3[ 69] <= 21'b0;
            tag_way3[ 70] <= 21'b0;
            tag_way3[ 71] <= 21'b0;
            tag_way3[ 72] <= 21'b0;
            tag_way3[ 73] <= 21'b0;
            tag_way3[ 74] <= 21'b0;
            tag_way3[ 75] <= 21'b0;
            tag_way3[ 76] <= 21'b0;
            tag_way3[ 77] <= 21'b0;
            tag_way3[ 78] <= 21'b0;
            tag_way3[ 79] <= 21'b0;
            tag_way3[ 80] <= 21'b0;
            tag_way3[ 81] <= 21'b0;
            tag_way3[ 82] <= 21'b0;
            tag_way3[ 83] <= 21'b0;
            tag_way3[ 84] <= 21'b0;
            tag_way3[ 85] <= 21'b0;
            tag_way3[ 86] <= 21'b0;
            tag_way3[ 87] <= 21'b0;
            tag_way3[ 88] <= 21'b0;
            tag_way3[ 89] <= 21'b0;
            tag_way3[ 90] <= 21'b0;
            tag_way3[ 91] <= 21'b0;
            tag_way3[ 92] <= 21'b0;
            tag_way3[ 93] <= 21'b0;
            tag_way3[ 94] <= 21'b0;
            tag_way3[ 95] <= 21'b0;
            tag_way3[ 96] <= 21'b0;
            tag_way3[ 97] <= 21'b0;
            tag_way3[ 98] <= 21'b0;
            tag_way3[ 99] <= 21'b0;
            tag_way3[100] <= 21'b0;
            tag_way3[101] <= 21'b0;
            tag_way3[102] <= 21'b0;
            tag_way3[103] <= 21'b0;
            tag_way3[104] <= 21'b0;
            tag_way3[105] <= 21'b0;
            tag_way3[106] <= 21'b0;
            tag_way3[107] <= 21'b0;
            tag_way3[108] <= 21'b0;
            tag_way3[109] <= 21'b0;
            tag_way3[110] <= 21'b0;
            tag_way3[111] <= 21'b0;
            tag_way3[112] <= 21'b0;
            tag_way3[113] <= 21'b0;
            tag_way3[114] <= 21'b0;
            tag_way3[115] <= 21'b0;
            tag_way3[116] <= 21'b0;
            tag_way3[117] <= 21'b0;
            tag_way3[118] <= 21'b0;
            tag_way3[119] <= 21'b0;
            tag_way3[120] <= 21'b0;
            tag_way3[121] <= 21'b0;
            tag_way3[122] <= 21'b0;
            tag_way3[123] <= 21'b0;
            tag_way3[124] <= 21'b0;
            tag_way3[125] <= 21'b0;
            tag_way3[126] <= 21'b0;
            tag_way3[127] <= 21'b0;
        end
        else if (refresh&(lru_r[2][index])&(lru_r[1][index])) begin
            tag_way3[index] <= {cached_v,tag};
        end
    end

    // assign hit = cached_v & sram_en & ({1'b1,tag} == tag_ram_out);
    assign lru = {
        lru_r[2][index],
        lru_r[1][index],
        lru_r[0][index]
    };
    assign hit = {
        hit_way3,
        hit_way2,
        hit_way1,
        hit_way0
    };
    assign hit_way0 = cached_v & sram_en & ({1'b1,tag} == tag_way0[index]);
    assign hit_way1 = cached_v & sram_en & ({1'b1,tag} == tag_way1[index]);
    assign hit_way2 = cached_v & sram_en & ({1'b1,tag} == tag_way2[index]);
    assign hit_way3 = cached_v & sram_en & ({1'b1,tag} == tag_way3[index]);

    assign miss = cached_v & sram_en & ~(hit_way0|hit_way1|hit_way2|hit_way3);
    assign stallreq = miss;

    assign axi_raddr = cached_v ? {sram_addr[31:5],5'b0} : sram_addr;

    assign write_back = lru[2] ? (lru[1] ? write_back_way3 : write_back_way2) : (lru[0] ? write_back_way1 : write_back_way0);
    assign write_back_way0 = cached_v & sram_en & miss & tag_way0[index][`TAG_WIDTH-1];
    assign write_back_way1 = cached_v & sram_en & miss & tag_way1[index][`TAG_WIDTH-1];
    assign write_back_way2 = cached_v & sram_en & miss & tag_way2[index][`TAG_WIDTH-1];
    assign write_back_way3 = cached_v & sram_en & miss & tag_way3[index][`TAG_WIDTH-1];

    assign axi_waddr = lru[2] ? (lru[1] ? axi_waddr_way3 : axi_waddr_way2) : (lru[0] ? axi_waddr_way1 : axi_waddr_way0);
    assign axi_waddr_way0 = {
        tag_way0[index][`TAG_WIDTH-2:0],
        index,
        5'b0
    };
    assign axi_waddr_way1 = {
        tag_way1[index][`TAG_WIDTH-2:0],
        index,
        5'b0
    };
    assign axi_waddr_way2 = {
        tag_way2[index][`TAG_WIDTH-2:0],
        index,
        5'b0
    };
    assign axi_waddr_way3 = {
        tag_way3[index][`TAG_WIDTH-2:0],
        index,
        5'b0
    };
endmodule