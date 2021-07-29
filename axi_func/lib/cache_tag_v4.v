`include "defines.vh"

module cache_tag_v4(
    input wire clk,
    input wire rst,
    input wire flush,
    
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
    output wire lru
);
    // reg [`TAG_WIDTH-1:0] tag_way0 [`INDEX_WIDTH-1:0]; // v + tag 
    // reg [`TAG_WIDTH-1:0] tag_way1 [`INDEX_WIDTH-1:0];
    reg [`INDEX_WIDTH-1:0] lru_r;
    wire [`TAG_WIDTH-2:0] tag;
    wire [6:0] index;
    wire [4:0] offset;
    reg cached_v;
    reg [`TAG_WIDTH-2:0] tag_r;
    reg [6:0] index_r;
    reg sram_en_r;
    // wire [`TAG_WIDTH-1:0] tag_ram_out;

    wire hit_way0;
    wire hit_way1;
    wire [31:0] axi_waddr_way0;
    wire [31:0] axi_waddr_way1;
    wire write_back_way0;
    wire write_back_way1;
    wire [`TAG_WIDTH-1:0] tag_way0_o;
    wire [`TAG_WIDTH-1:0] tag_way1_o;
    
    // assign cached_v = cached;
    always @ (posedge clk) begin
        if (rst) begin
            cached_v <= 1'b0;
            tag_r <= 20'b0;
            index_r <= 7'b0;
            sram_en_r <= 1'b0;
        end
        else begin
            cached_v <= cached;
            tag_r <= tag;
            index_r <= index;
            sram_en_r <= sram_en;
        end
    end 

    assign {
        tag,
        index,
        offset
    } = sram_addr;

    tag_bram_bank u_tag_way0(
        .clka(clk),
        .ena(sram_en),     // 1
        .wea(refresh&(~lru_r[index])),     // 1
        .addra(index),   // 7
        .dina({cached,tag}),    // 21
        .douta(tag_way0_o)    // 21
    );

    tag_bram_bank u_tag_way1(
        .clka(clk),
        .ena(sram_en),     // 1
        .wea(refresh&lru_r[index]),     // 1
        .addra(index),   // 7
        .dina({cached,tag}),    // 21
        .douta(tag_way1_o)    // 21
    );

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
            lru_r  <= {`INDEX_WIDTH'b0};
        end
        else if (hit_way0 & ~hit_way1) begin
            lru_r[index] <= 1'b1;
        end
        else if (~hit_way0 & hit_way1) begin
            lru_r[index] <= 1'b0;
        end
        else if (refresh) begin
            lru_r[index] <= ~lru_r[index];
        end
    end

    // assign hit = cached_v & sram_en & ({1'b1,tag} == tag_ram_out);
    assign lru = lru_r[index_r];
    assign hit = {
        hit_way1,
        hit_way0
    };
    assign hit_way0 = ~flush & cached_v & sram_en_r & ({1'b1,tag_r} == tag_way0_o);
    assign hit_way1 = ~flush & cached_v & sram_en_r & ({1'b1,tag_r} == tag_way1_o);
    assign miss = cached_v & sram_en_r & ~(hit_way0|hit_way1) & ~flush;
    assign stallreq = miss;
    assign axi_raddr = cached_v ? {sram_addr[31:5],5'b0} : sram_addr;
    assign write_back = flush ? 1'b0 : lru ? write_back_way1 : write_back_way0;
    assign write_back_way0 = cached_v & sram_en_r & miss & tag_way0_o[`TAG_WIDTH-1];
    assign write_back_way1 = cached_v & sram_en_r & miss & tag_way1_o[`TAG_WIDTH-1];
    assign axi_waddr = lru_r[index_r] ? axi_waddr_way1 : axi_waddr_way0;
    assign axi_waddr_way0 = {
        tag_way0_o[`TAG_WIDTH-2:0],
        index_r,
        5'b0
    };
    assign axi_waddr_way1 = {
        tag_way1_o[`TAG_WIDTH-2:0],
        index_r,
        5'b0
    };
endmodule