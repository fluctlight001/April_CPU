`include "lib/defines.vh"
`define STAGE_WIDTH 20
module axi_control(
    input wire clk,
    input wire rst,

    // icache
    input wire icache_miss,
    input wire [31:0] icache_addr,

    output wire icache_refresh,
    output wire icache_cache,
    output wire [`CACHELINE_WIDTH-1:0] icache_cacheline,

    //写地址通道信号
    output  reg [3:0]	    awid,//写地址ID，用来标志一组写信号
    output  reg [31:0]	    awaddr,//写地址，给出一次写突发传输的写地址
    output  reg [3:0]	    awlen,//突发长度，给出突发传输的次数
    output  reg [2:0]	    awsize,//突发大小，给出每次突发传输的字节数
    output  reg [1:0]	    awburst,//突发类型
    output  reg [1:0]	    awlock,//总线锁信号，可提供操作的原子性
    output  reg [3:0]	    awcache,//内存类型，表明一次传输是怎样通过系统的
    output  reg [2:0]	    awprot,//保护类型，表明一次传输的特权级及安全等级
    output  reg 		    awvalid,//有效信号，表明此通道的地址控制信号有效
    input	wire		    awready,//表明"从"可以接收地址和对应的控制信号

    //写数据通道信号
    output  reg [3:0]	    wid,//一次写传输的ID tag
    output  reg [31:0]	    wdata,//写数据
    output  reg [3:0]	    wstrb,//写数据有效的字节线，用来表明哪8bits数据是有效的
    output  reg 		    wlast,//表明此次传输是最后一个突发传输
    output  reg		        wvalid,//写有效，表明此次写有效
    input	wire		    wready,//表明从机可以接收写数据
    //写响应通道信号
    input	wire [3:0]	    bid,//写响应ID tag
    input	wire [1:0]	    bresp,//写响应，表明写传输的状态 00为正常，当然可以不理会
    input	wire		    bvalid,//写响应有效
    output  reg		        bready,//表明主机能够接收写响应

    //总线侧接口
    //读地址通道信号
    output  reg [3:0]	    arid,//读地址ID，用来标志一组写信号
    output  reg [31:0]	    araddr,//读地址，给出一次写突发传输的读地址
    output  reg [3:0]	    arlen,//突发长度，给出突发传输的次数
    output  reg [2:0]	    arsize,//突发大小，给出每次突发传输的字节数
    output  reg [1:0]	    arburst,//突发类型
    output  reg [1:0]	    arlock,//总线锁信号，可提供操作的原子性
    output  reg [3:0]	    arcache,//内存类型，表明一次传输是怎样通过系统的
    output  reg [2:0]	    arprot,//保护类型，表明一次传输的特权级及安全等级
    output  reg 		    arvalid,//有效信号，表明此通道的地址控制信号有效
    input	wire		    arready,//表明"从"可以接收地址和对应的控制信号
    //读数据通道信号
    input	wire [3:0]	    rid,//读ID tag
    input	wire [31:0]	    rdata,//读数据
    input	wire [1:0]	    rresp,//读响应，表明读传输的状态
    input	wire		    rlast,//表明读突发的最后一次传输
    input	wire		    rvalid,//表明此通道信号有效
    output  reg		        rready//表明主机能够接收读数据和响应信息
);

    reg icache_refresh_r;
    reg [`CACHELINE_WIDTH-1:0] icache_cacheline_r;
    reg [2:0] icache_offset;
    reg [2:0] dcache_offset;

    reg [`STAGE_WIDTH-1:0] stage;

    assign icache_refresh = icache_refresh_r;
    assign icache_cacheline = icache_cacheline_r;

    always @ (posedge clk) begin
        if (rst) begin
            arid <= 4'b0000;
            araddr <= `ZeroWord;
            arlen <= 4'b0000;
            arsize <= 3'b010;
            arburst <= 2'b01;
            arlock <= 2'b00;
            arcache <= 4'b0000;
            arprot <= 3'b000;
            arvalid <= 1'b0;

            rready <= 1'b0;

            awid <= 4'b0001;
            awaddr <= `ZeroWord;
            awlen <= 4'b0000;
            awsize <= 3'b010;
            awburst <= 2'b01;
            awlock <= 2'b00;
            awcache <= 4'b0000;
            awprot <= 3'b000;
            awvalid <= 1'b0;

            wid <= 4'b0001;
            wdata <= `ZeroWord;
            wstrb <= 4'b0000;
            wlast <= 1'b1;
            wvalid <= 1'b0;

            bready <= 1'b0;

            stage <= `STAGE_WIDTH'b1;

            icache_refresh_r <= 1'b0;
            icache_cacheline_r <= `CACHELINE_WIDTH'b0;
            icache_offset <= 3'b0;
        end
        else begin
            case(1'b1)
                stage[0]:begin
                    icache_refresh_r <= 1'b0;
                    icache_cacheline_r <= `CACHELINE_WIDTH'b0;
                    icache_offset <= 1'b0;

                    if (icache_miss) begin
                        stage <= stage << 1;
                    end
                end
                stage[1]:begin
                    arid <= 4'b0;
                    araddr <= icache_addr;
                    arlen <= 4'h7;
                    arsize <= 3'b010;
                    arvalid <= 1'b1;

                    stage <= stage << 1;
                end
                stage[2]:begin
                    if (arready) begin
                    arvalid <= 1'b0;
                    araddr <= 32'b0;
                    rready <= 1'b1;
                    icache_offset <= 3'd0;
                        stage <= stage << 1;
                    end
                end
                stage[3]:begin
                    if (!rlast) begin
                    if (rvalid) begin
                        icache_cacheline_r[icache_offset*32+:32] <= rdata;
                        icache_offset <= icache_offset + 1'b1;
                    end   
                    end
                    else begin
                        icache_cacheline_r[icache_offset*32+:32] <= rdata;
                        icache_refresh_r <= 1'b1;
                        stage <= stage << 1;
                    end
                end
                stage[4]:begin
                    stage <= 1'b1;
                end
                default:begin
                    stage <= `STAGE_WIDTH'b1;
                end
            endcase
        end
    end

endmodule