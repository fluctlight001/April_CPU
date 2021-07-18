`include "defines.vh"

module cache_data(
    input wire clk,
    input wire rst,
    input wire [`StallBus] stall,
    input wire flush,
    input wire br_e,

    input wire write_back,
    input wire hit,

    // sram_port
    input wire sram_en,
    input wire [3:0] sram_wen,
    input wire [31:0] sram_addr,
    input wire [31:0] sram_wdata,
    output wire [31:0] sram_rdata,

    // axi
    input wire refresh,
    input wire [`CACHELINE_WIDTH-1:0] cacheline_new,
    output wire write_req,
    output wire [31:0] write_addr,
    output wire [`CACHELINE_WIDTH-1:0] cacheline_old

);
    wire [31:0] rdata_way0 [7:0];
    wire [`TAG_WIDTH-2:0] tag;
    wire [6:0] index;
    wire [4:0] offset;
    reg hit_r;
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
            bank_sel_r <= 8'b0;
        end
        else if (flush || br_e) begin
            hit_r <= hit;
            bank_sel_r <= bank_sel;
        end
        else if (stall[1] == `Stop && stall[2] == `NoStop)begin
            hit_r <= hit;
            bank_sel_r <= bank_sel;
        end
        else if (stall[1] == `NoStop) begin
            hit_r <= hit;
            bank_sel_r <= bank_sel;
        end
    end
    

    data_bram_bank bank0_way0(
        .clka(clk),
        .ena(refresh|sram_en&bank_sel[0]),     // 1
        .wea({4{refresh}}|sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[31:0]:sram_wdata),    // 32
        .douta(rdata_way0[0])    //32
    );
    data_bram_bank bank1_way0(
        .clka(clk),
        .ena(refresh|sram_en&bank_sel[1]),     // 1
        .wea({4{refresh}}|sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[63:32]:sram_wdata),    // 32
        .douta(rdata_way0[1])    //32
    );
    data_bram_bank bank2_way0(
        .clka(clk),
        .ena(refresh|sram_en&bank_sel[2]),     // 1
        .wea({4{refresh}}|sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[95:64]:sram_wdata),    // 32
        .douta(rdata_way0[2])    //32
    );
    data_bram_bank bank3_way0(
        .clka(clk),
        .ena(refresh|sram_en&bank_sel[3]),     // 1
        .wea({4{refresh}}|sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[127:96]:sram_wdata),    // 32
        .douta(rdata_way0[3])    //32
    );
    data_bram_bank bank4_way0(
        .clka(clk),
        .ena(refresh|sram_en&bank_sel[4]),     // 1
        .wea({4{refresh}}|sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[159:128]:sram_wdata),    // 32
        .douta(rdata_way0[4])    //32
    );
    data_bram_bank bank5_way0(
        .clka(clk),
        .ena(refresh|sram_en&bank_sel[5]),     // 1
        .wea({4{refresh}}|sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[191:160]:sram_wdata),    // 32
        .douta(rdata_way0[5])    //32
    );
    data_bram_bank bank6_way0(
        .clka(clk),
        .ena(refresh|sram_en&bank_sel[6]),     // 1
        .wea({4{refresh}}|sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[223:192]:sram_wdata),    // 32
        .douta(rdata_way0[6])    //32
    );
    data_bram_bank bank7_way0(
        .clka(clk),
        .ena(refresh|sram_en&bank_sel[7]),     // 1
        .wea({4{refresh}}|sram_wen),     // 4
        .addra(index),   // 7
        .dina(refresh?cacheline_new[255:224]:sram_wdata),    // 32
        .douta(rdata_way0[7])    //32
    );

    assign sram_rdata = ~hit_r ? 32'b0 :
                        bank_sel_r[0] ? rdata_way0[0] :
                        bank_sel_r[1] ? rdata_way0[1] :
                        bank_sel_r[2] ? rdata_way0[2] :
                        bank_sel_r[3] ? rdata_way0[3] :
                        bank_sel_r[4] ? rdata_way0[4] :
                        bank_sel_r[5] ? rdata_way0[5] :
                        bank_sel_r[6] ? rdata_way0[6] :
                        bank_sel_r[7] ? rdata_way0[7] : 32'b0;


    // always @ (posedge clk) begin
    //     if(rst) begin
    //     end
    //     else if (sram_en&~(|sram_wen)) begin
    //         // case (offset[4:2])
    //         //     3'b000:begin
    //         //         sram_rdata <= data_way0[index][31:0];
    //         //     end
    //         //     3'b001:begin
    //         //         sram_rdata <= data_way0[index][63:32];
    //         //     end
    //         //     3'b010:begin
    //         //         sram_rdata <= data_way0[index][95:64];
    //         //     end
    //         //     3'b011:begin
    //         //         sram_rdata <= data_way0[index][127:96];
    //         //     end
    //         //     3'b100:begin
    //         //         sram_rdata <= data_way0[index][159:128];
    //         //     end
    //         //     3'b101:begin
    //         //         sram_rdata <= data_way0[index][191:160];
    //         //     end
    //         //     3'b110:begin
    //         //         sram_rdata <= data_way0[index][223:192];
    //         //     end
    //         //     3'b111:begin
    //         //         sram_rdata <= data_way0[index][255:224];
    //         //     end
    //         //     default:begin
    //         //         sram_rdata <= 32'b0;
    //         //     end
    //         // endcase 
    //     end
    //     else if (sram_en&(|sram_wen)) begin
            
    //     end
    // end
endmodule