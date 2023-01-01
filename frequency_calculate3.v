`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/01 16:22:52
// Design Name: 
// Module Name: frequency_calculate
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


module frequency_calculate(
    input wire rst_n,//复位信号，低电平有效
 //   input wire clk_test,//待检测时钟
    input wire clk_stand,//待检测时钟
    output reg[3:0] dig,
    output reg [6:0] seg
    );
parameter CNT_GATE_S_MAX =28'd37499999;
parameter CNT_RISE_MAX=28'd6250000;
parameter CLK_STAND_FREQ=28'd100000000;
//wire clk_stand; //标准时钟,频率100MHz
wire gate_a_fall_s;//实际闸门下降沿（标准时钟下）
wire gate_a_fall_t;//实际闸门下降沿（待检测时钟下）

reg     [27:0]  cnt_gate_s          ;   //软件闸门计数器
reg             gate_s              ;   //软件闸门
reg             gate_a              ;   //实际闸门
reg             gate_a_test         ;
reg             gate_a_stand        ;   //实际闸门打一拍(标准时钟下)
reg             gate_a_stand_reg    ;
reg             gate_a_test_reg     ;   //实际闸门打一拍(待检测时钟下)
reg     [47:0]  cnt_clk_stand       ;   //标准时钟周期计数器
reg     [47:0]  cnt_clk_stand_reg   ;   //实际闸门下标志时钟周期数
reg     [47:0]  cnt_clk_test        ;   //待检测时钟周期计数器
reg     [47:0]  cnt_clk_test_reg    ;   //实际闸门下待检测时钟周期数
reg             calc_flag           ;   //待检测时钟时钟频率计算标志信号
wire     [3:0]   dig_T               ;
wire     [3:0]   dig_H               ;
wire     [3:0]   dig_M               ;
wire     [3:0]   dig_L               ;
 reg [6:0] seg_H;
 reg [6:0] seg_M;
 reg [6:0] seg_L;
 reg [6:0] seg_T;
 reg [1:0]state;
 reg[33:0] freq;
 reg sys_clk;//系统时钟，频率50Hz;
 reg  clk_test;//系统时钟，频率50Hz;
 reg  [4:0]cnt;//系统时钟，频率50Hz;
 
  always@(posedge clk_stand or negedge rst_n)
    if(rst_n == 1'b0) 
        cnt <=0;
    else if(cnt==19)
        cnt<= 0;
    else
        cnt <= cnt + 1;
 
 always@(posedge clk_stand or negedge rst_n)
    if(rst_n == 1'b0) 
        clk_test <=0;
    else if(cnt==9)
        clk_test <= ~clk_test;
    else if(cnt==19)
        clk_test <= ~clk_test;
 
always@(posedge clk_stand or negedge rst_n)
    if(rst_n == 1'b0) 
        sys_clk <=0;
    else 
        sys_clk <= ~sys_clk;
 
always@(posedge sys_clk or negedge rst_n)
    if(rst_n == 1'b0)
        cnt_gate_s  <=  28'd0;
    else    if(cnt_gate_s == CNT_GATE_S_MAX)
        cnt_gate_s  <=  28'd0;
    else
        cnt_gate_s  <=  cnt_gate_s + 1'b1;
//gate_s:软件闸门
always@(posedge sys_clk or negedge rst_n)
    if(rst_n == 1'b0)
        gate_s  <=  1'b0;
    else    if((cnt_gate_s>= CNT_RISE_MAX)
                && (cnt_gate_s <= (CNT_GATE_S_MAX - CNT_RISE_MAX)))
        gate_s  <=  1'b1;
    else
        gate_s  <=  1'b0;
//gate_a:实际闸门
always@(posedge clk_test or negedge rst_n)
    if(rst_n == 1'b0)
        gate_a  <=  1'b0;
    else
        gate_a  <=  gate_s;
always@(posedge clk_test or negedge rst_n)
    if(rst_n == 1'b0)
        gate_a_test  <=  1'b0;
    else
        gate_a_test  <=  gate_a;
//gate_a_stand:实际闸门打一拍(标准时钟下)
always@(posedge clk_stand or negedge rst_n)
    if(rst_n == 1'b0)
        gate_a_stand    <=  1'b0;
    else
        gate_a_stand    <=  gate_a_test; 
//cnt_clk_stand:标准时钟周期计数器,计数实际闸门下标准时钟周期数
always@(posedge clk_stand or negedge rst_n)
    if(rst_n == 1'b0)
        cnt_clk_stand   <=  48'd0;
    else    if(gate_a_stand == 1'b0)
        cnt_clk_stand   <=  48'd0;
    else    if(gate_a_stand == 1'b1)
        cnt_clk_stand   <=  cnt_clk_stand + 1'b1;
//cnt_clk_test:待检测时钟周期计数器,计数实际闸门下待检测时钟周期数
always@(posedge clk_test or negedge rst_n)
    if(rst_n == 1'b0)
        cnt_clk_test    <=  48'd0;
    else    if(gate_a_test == 1'b0)
        cnt_clk_test    <=  48'd0;
    else    if(gate_a_test == 1'b1)
        cnt_clk_test    <=  cnt_clk_test + 1'b1;

always@(posedge clk_stand or negedge rst_n)
    if(rst_n == 1'b0)
        gate_a_stand_reg    <=  1'b0;
    else
        gate_a_stand_reg    <=  gate_a_stand;
//gate_a_fall_s:实际闸门下降沿(标准时钟下)
assign  gate_a_fall_s = ((gate_a_stand_reg == 1'b1) && (gate_a_stand == 1'b0))
                        ? 1'b1 : 1'b0;
//cnt_clk_stand_reg:实际闸门下标志时钟周期数
always@(posedge clk_stand or negedge rst_n)
    if(rst_n == 1'b0)
        cnt_clk_stand_reg   <=  32'd0;
    else    if(gate_a_fall_s == 1'b1)
        cnt_clk_stand_reg   <=  cnt_clk_stand;
//gate_a_test:实际闸门打一拍(待检测时钟下)
always@(posedge clk_test or negedge rst_n)
    if(rst_n == 1'b0)
        gate_a_test_reg <=  1'b0;
    else
        gate_a_test_reg <=  gate_a_test;
//gate_a_fall_t:实际闸门下降沿(待检测时钟下)
assign  gate_a_fall_t = ((gate_a_test_reg == 1'b1) && (gate_a_test == 1'b0))
                        ? 1'b1 : 1'b0;
//cnt_clk_test_reg:实际闸门下待检测时钟周期数
always@(posedge clk_test or negedge rst_n)
    if(rst_n == 1'b0)
        cnt_clk_test_reg   <=  32'd0;
    else    if(gate_a_fall_t == 1'b1)
        cnt_clk_test_reg   <=  cnt_clk_test;
//calc_flag:待检测时钟时钟频率计算标志信号
always@(posedge sys_clk or negedge rst_n)
    if(rst_n == 1'b0)
        calc_flag   <=  1'b0;
    else    if(cnt_gate_s == (CNT_GATE_S_MAX - 1'b1))
        calc_flag   <=  1'b1;
    else
        calc_flag   <=  1'b0;
//freq:待检测时钟信号时钟频率
 


always@(posedge sys_clk or negedge rst_n)
    if(rst_n == 1'b0)
        freq    <=  34'd0;
    else    if(calc_flag == 1'b1)
        freq    <=  ((CLK_STAND_FREQ / cnt_clk_stand_reg * cnt_clk_test_reg));
//        always@(posedge sys_clk or negedge rst_n)//计数器 1s
//        begin
            
//            dig_T<=(a)?0:freq[7:4];
//            dig_H<=(b&&a)?1:((b&&!a)?0:(!b&&a)?freq[11:8]+1:freq[11:8]);
//            dig_M<=(c&&b)?1:((c&&!b)?0:(!c&&b)?freq[15:12]+1:freq[15:12]);
//            dig_L<=(d&&c)?1:((d&&!c)?0:(!d&&c)?freq[19:16]+1:freq[19:16]);
//        end
  wire [33:0] temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, temp9, temp10, temp11;

  assign dig_T[3] = (freq >= 8000000)    ? 1            : 0;
  assign temp1          = (freq >= 8000000)    ? freq - 8000000     : freq;
  assign dig_T[2] = (temp1 >= 4000000) ? 1            : 0;
  assign temp2          = (temp1 >= 4000000) ? temp1 - 4000000  : temp1;
  assign dig_T[1] = (temp2 >= 2000000) ? 1            : 0;
  assign temp3          = (temp2 >= 2000000) ? temp2 - 2000000  : temp2;
  assign dig_T[0] = (temp3 >= 1000000) ? 1            : 0;
  assign temp4          = (temp3 >= 1000000) ? temp3 - 1000000  : temp3;

  assign dig_H[3] = (temp4 >= 800000) ? 1            : 0;
  assign temp5      = (temp4 >= 800000) ? temp4 - 800000   : temp4;
  assign dig_H[2] = (temp5 >= 400000) ? 1            : 0;
  assign temp6         = (temp5 >= 400000) ? temp5 - 400000   : temp5;
  assign dig_H[1] = (temp6 >= 200000) ? 1            : 0;
  assign temp7         = (temp6 >= 200000) ? temp6 - 200000   : temp6;
  assign dig_H[0] = (temp7 >= 100000) ? 1            : 0;
  assign temp8         = (temp7 >= 100000) ? temp7 - 100000   : temp7;
  
  assign dig_M[3] = (temp8  >= 80000)  ? 1            : 0;
  assign temp9     = (temp8  >= 80000)  ? temp8 - 80000   : temp8;
  assign dig_M[2] = (temp9  >= 40000)  ? 1            : 0;
  assign temp10    = (temp9  >= 40000)  ? temp9 - 40000   : temp9;
  assign dig_M[1] = (temp10 >= 20000) ? 1            : 0;
  assign temp11    = (temp10 >= 20000) ? temp10 - 20000   : temp10;
  assign dig_M[0] = (temp11 >= 10000) ? 1            : 0;
  assign dig_L    = (temp11 >= 10000) ? temp11 - 10000   : temp11;

        //数码管显示，低电平有效 
        always @ (dig_H)
         case(dig_H)
         4'b0000: seg_H <= 7'b100_0000;
         4'b0001: seg_H  <= 7'b111_1001;
         4'b0010: seg_H <= 7'b010_0100; 
         4'b0011: seg_H <= 7'b011_0000;
         4'b0100: seg_H <= 7'b001_1001;
         4'b0101: seg_H <= 7'b001_0010;
         4'b0110: seg_H <= 7'b000_0010; 
         4'b0111: seg_H <= 7'b111_1000;
         4'b1000: seg_H <= 7'b000_0000;
         4'b1001: seg_H <= 7'b001_0000; 
         default: seg_H <= 7'b111_1111; 
         endcase
         always @ (dig_M)
          case(dig_M)
          4'b0000: seg_M <= 7'b100_0000;
          4'b0001: seg_M <= 7'b111_1001;
          4'b0010: seg_M <= 7'b010_0100; 
          4'b0011: seg_M <= 7'b011_0000;
          4'b0100: seg_M <= 7'b001_1001;
          4'b0101: seg_M <= 7'b001_0010;
          4'b0110: seg_M <= 7'b000_0010; 
          4'b0111: seg_M <= 7'b111_1000;
          4'b1000: seg_M <= 7'b000_0000;
          4'b1001: seg_M <= 7'b001_0000; 
          default: seg_M <= 7'b111_1111; 
         endcase
         always @ (dig_L)
          case(dig_L)
          4'b0000: seg_L <= 7'b100_0000;
          4'b0001: seg_L <= 7'b111_1001;
          4'b0010: seg_L <= 7'b010_0100; 
          4'b0011: seg_L <= 7'b011_0000;
          4'b0100: seg_L <= 7'b001_1001;
          4'b0101: seg_L <= 7'b001_0010;
          4'b0110: seg_L <= 7'b000_0010; 
          4'b0111: seg_L <= 7'b111_1000;
          4'b1000: seg_L <= 7'b000_0000;
          4'b1001: seg_L <= 7'b001_0000; 
          default: seg_L <= 7'b111_1111; 
          endcase
           always @ (dig_T)
          case(dig_T)
            4'b0000: seg_T <= 7'b100_0000;
            4'b0001: seg_T <= 7'b111_1001;
            4'b0010: seg_T <= 7'b010_0100; 
            4'b0011: seg_T <= 7'b011_0000;
            4'b0100: seg_T <= 7'b001_1001;
            4'b0101: seg_T <= 7'b001_0010;
            4'b0110: seg_T <= 7'b000_0010; 
            4'b0111: seg_T <= 7'b111_1000;
            4'b1000: seg_T <= 7'b000_0000;
            4'b1001: seg_T <= 7'b001_0000; 
            default: seg_T <= 7'b111_1111; 
            endcase
//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//
//---------- clk_gen_inst ----------
always@(posedge cnt_gate_s[15] or negedge rst_n)
    if(rst_n == 1'b0)begin
        state<=0;
        dig <= 0;
        seg <= 0;
    end
  else begin
      case(state[1:0])
      2'h0:begin seg=seg_L;dig<=4'b1110;state<=state+1'b1;end
      2'h1:begin seg=seg_M;dig<=4'b1101;state<=state+1'b1;end
      2'h2:begin seg=seg_H;dig<=4'b1011;state<=state+1'b1;end
      2'h3:begin seg=seg_T;dig<=4'b0111;state<=state+1'b1;end
      endcase
      end


endmodule
