`include "defines.vh"

module cache_tag(
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
    output wire hit
);
    reg [`TAG_WIDTH-1:0] tag_way0 [`INDEX_WIDTH-1:0]; // v + tag 
    wire [`TAG_WIDTH-2:0] tag;
    wire [6:0] index;
    wire [4:0] offset;
    wire cached_v;
    // wire [`TAG_WIDTH-1:0] tag_ram_out;
    
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
        else if (refresh) begin
            tag_way0[index] <= {cached_v,tag};
        end
    end

    // assign hit = cached_v & sram_en & ({1'b1,tag} == tag_ram_out);
    assign hit = cached_v & sram_en & ({1'b1,tag} == tag_way0[index]);
    assign miss = cached_v & sram_en & ~hit;
    assign stallreq = miss;
    assign axi_raddr = cached_v ? {sram_addr[31:5],5'b0} : sram_addr;
    assign write_back = cached_v & sram_en & miss & tag_way0[index][`TAG_WIDTH-1];
    assign axi_waddr = {
        tag_way0[index][`TAG_WIDTH-2:0],
        index,
        5'b0
    };
endmodule