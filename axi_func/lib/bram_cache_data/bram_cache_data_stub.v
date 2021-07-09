// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Fri Jul  9 10:42:15 2021
// Host        : LAPTOP-7RBBD5ET running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/Fluctlight/Desktop/April_cpu/axi_func/lib/bram_cache_data/bram_cache_data_stub.v
// Design      : bram_cache_data
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module bram_cache_data(clka, ena, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[31:0],addra[6:0],dina[255:0],douta[255:0]" */;
  input clka;
  input ena;
  input [31:0]wea;
  input [6:0]addra;
  input [255:0]dina;
  output [255:0]douta;
endmodule
