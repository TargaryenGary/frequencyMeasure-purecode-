`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/01 20:33:16
// Design Name: 
// Module Name: fre_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fre_tb(

    );
    
    wire[3:0]dig;
    wire[6:0]seg;
    reg sys_rst_n;
    reg clk_test;
    reg clk_stand;
    
  always #5 clk_stand = ~clk_stand;  
  always #1000 clk_test = ~clk_test;  
    
  initial  
  begin
    clk_test= 0;
    clk_stand= 0;
    sys_rst_n= 0;
    
    #100
    sys_rst_n = 1;
    
    
  end
    
  frequency_calculate  frequency_calculate(
   .rst_n(sys_rst_n)     ,   //系统时钟,频率50MHz
   .clk_test(clk_test)     ,   //系统时钟,频率50MHz
   .clk_stand(clk_stand)     ,   //系统时钟,频率50MHz
   .dig(dig),        //系统时钟,频率50MHz
   .seg(seg)       //系统时钟,频率50MHz

);
    
    
endmodule
