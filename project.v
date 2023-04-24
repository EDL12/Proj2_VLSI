`define MAXPATTERNS 	2000
`define MAXCOUNT	57

module bist_hardware(clk,rst,bistmode,bistdone,bistpass,cut_scanmode,
                     cut_sdi,cut_sdo);
  /* Shifts values on every positive edge */
  input          clk;
  /* When set to 1 with bistmode, starts bist hardware */
  input          rst;
  /* When set to 1 with rst, starts bist hardware */
  input          bistmode;
  /* Signals when the bist hardware is complete */
  output         bistdone;
  /* Set to 1 if CUT passed the test; set to 0 if CUT failed the test. 
  In conjunction with bistdone */
  output         bistpass;
  /* If set to 1, shift new values into scan-chain. Otherwise don't. */
  output         cut_scanmode;
  /* If scanmode set to 1, shift these new values into the CUT. Otherwise, CUT runs as normal. */
  output [3:0]   cut_sdi;
  /* Take input from CUT outputs to run through bist hardware */
  input  [3:0]   cut_sdo;

  //initial $display ("This is the start");

  //For starting/stopping system
  reg startState;
  initial startState = 0;
  wire startWire = startState;
  reg [10:0] endReg;
  initial endReg = 0;
  wire [10:0] endWire = endReg;
  //For both MISR and LFSR
  reg [5:0] countReg;
  initial countReg = 0;
  wire [5:0] countWire = countReg;
  //For LFSR
  //LFSR: initialization
  reg [4:0] LFSRinitReg;
  initial LFSRinitReg = 0;
  wire [4:0] LFSRinitWire = LFSRinitReg;
  //LFSR: regular operation
  integer i;
  reg LFSRreg [15:0];
  initial for(i = 0; i < 16; i = i + 1) LFSRreg[i] = 0;
  wire [15:0] LFSRwires = {LFSRreg[14], LFSRreg[13], LFSRreg[12], LFSRreg[11], LFSRreg[10], LFSRreg[9], LFSRreg[8],
  LFSRreg[7], LFSRreg[6], LFSRreg[5], LFSRreg[4] ^ LFSRreg[15], LFSRreg[3] ^ LFSRreg[15], 
  LFSRreg[2] ^ LFSRreg[15], LFSRreg[1], LFSRreg[0], LFSRreg[15] ^ 1};
  assign cut_sdi = {LFSRreg[0], LFSRreg[3], LFSRreg[4], LFSRreg[5]};
  reg cut_scanmodeReg;
  initial cut_scanmodeReg = 0;
  assign cut_scanmode = cut_scanmodeReg;
  //For MISR
  reg sampReg;
  initial sampReg = 0;
  wire sampWire = sampReg;
  integer j;
  reg MISRreg [15:0];
  initial for(i = 0; i < 16; i = i + 1) MISRreg[i] = 0;
  wire [15:0] MISRwires = {MISRreg[14], MISRreg[13], MISRreg[12], MISRreg[11], MISRreg[10], MISRreg[9], MISRreg[8],
  MISRreg[7], MISRreg[6], MISRreg[5], MISRreg[4] ^ MISRreg[15] ^ cut_sdo[0], MISRreg[3] ^ MISRreg[15] ^ cut_sdo[1], 
  MISRreg[2] ^ MISRreg[15] ^ cut_sdo[2], MISRreg[1], MISRreg[0], MISRreg[15] ^ cut_sdo[3]};
  reg [15:0] MISRoutputReg;
  initial MISRoutputReg = 0;
  wire [15:0] MISRoutputWire = MISRoutputReg;
  reg bistpass_reg;
  initial bistpass_reg = 0;
  assign bistpass = bistpass_reg;
  reg bistdone_reg;
  initial bistdone_reg = 0;
  assign bistdone = bistdone_reg;
  //hardcoded fault-free value
  reg firstPassReg;
  initial firstPassReg = 0;
  wire firstPassWire = firstPassReg;
  reg [15:0] faultFreeReg;
  initial faultFreeReg = 0;
  wire [15:0] faultFreeWire = faultFreeReg;

  always@(*) begin
    //system start or end?
    if((rst & bistmode) | bistdone) begin
      startState = (rst & bistmode) | (startWire ^ 1);
      //$display("startState value = %d", startState);
    end
  end
  
  always@(posedge clk) begin
    //initialize LFSR (16 moves in)
    if(LFSRinitWire < 16) begin
      //$display("LFSRinitWire value = %d", LFSRinitWire);
      for(i = 0; i < 16; i = i + 1) LFSRreg[i] = LFSRwires[i];
      LFSRinitReg = LFSRinitWire + 1;
    end

    //start system
    if(startWire) begin
      if (LFSRinitWire == 16) begin
        if(countWire == 0) begin
          cut_scanmodeReg = 1;
          countReg = countWire + 1;
        end
        else if(countWire == 57) begin
          countReg = 0;
        end
        else begin
          cut_scanmodeReg = 0;
          sampReg = 1;
          countReg = countWire + 1;
        end
      end
      if(cut_scanmode) begin
        //LFSR
        for(i = 0; i < 16; i = i + 1) LFSRreg[i] = LFSRwires[i];
        if(sampWire == 1) begin
          //MISR
          for(i = 0; i < 16; i = i + 1) MISRreg[i] = MISRwires[i];
          endReg = endWire + 1;
          //$display ("endWire value = %d", endWire);
          if(endWire == 2000) begin
            MISRoutputReg = MISRwires;
            if(firstPassWire == 0) begin 
              faultFreeReg = MISRoutputWire;
              firstPassReg = 1;
            end
            if (MISRoutputWire == faultFreeWire) bistpass_reg = 1;
            else bistpass_reg = 0;
            bistdone_reg = 1;
          end
        end
      end
    end
  end
	
  //initial $display ("This is the end");

endmodule  




module chip(clk,rst,pi,po,bistmode,bistdone,bistpass);
  input          clk;
  input          rst;
  input	 [35:0]  pi;
  output [48:0]  po;
  input          bistmode;
  output         bistdone;
  output         bistpass;

  wire           cut_scanmode;
  wire [3:0]     cut_sdi,cut_sdo;

  reg x;
  wire w_x;
  assign w_x = x;

  scan_cut circuit(bistmode,cut_scanmode,cut_sdi,cut_sdo,clk,rst,
         pi[0],pi[1],pi[2],pi[3],pi[4],pi[5],pi[6],pi[7],pi[8],pi[9],
         pi[10],pi[11],pi[12],pi[13],pi[14],pi[15],pi[16],pi[17],pi[18],pi[19],
         pi[20],pi[21],pi[22],pi[23],pi[24],pi[25],pi[26],pi[27],pi[28],pi[29],
         pi[30],pi[31],pi[32],pi[33],pi[34],pi[35],
         po[0],po[1],po[2],po[3],po[4],po[5],po[6],po[7],po[8],po[9],
         po[10],po[11],po[12],po[13],po[14],po[15],po[16],po[17],po[18],po[19],
         po[20],po[21],po[22],po[23],po[24],po[25],po[26],po[27],po[28],po[29],
         po[30],po[31],po[32],po[33],po[34],po[35],po[36],po[37],po[38],po[39],
         po[40],po[41],po[42],po[43],po[44],po[45],po[46],po[47],po[48]);
  
  bist_hardware bist( clk,rst,bistmode,bistdone,bistpass,cut_scanmode,
                     cut_sdi,cut_sdo);
  
endmodule
