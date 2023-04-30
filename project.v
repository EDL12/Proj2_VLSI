`define MAXPATTERNS 	2000
`define MAXCOUNT	57

//Ethan Litchauer and Harsh Bakadia

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
  
  /*
  wire [15:0] LFSRwires = {LFSRreg[14], LFSRreg[13], LFSRreg[12], LFSRreg[11], LFSRreg[10], LFSRreg[9], LFSRreg[8],
  LFSRreg[7], LFSRreg[6], LFSRreg[5], LFSRreg[4] ^ LFSRreg[15], LFSRreg[3] ^ LFSRreg[15], 
  LFSRreg[2] ^ LFSRreg[15], LFSRreg[1], LFSRreg[0], LFSRreg[15] ^ 1};*/
  
  wire LFSRwires15 = LFSRreg[14];
  wire LFSRwires14 = LFSRreg[13];
  wire LFSRwires13 = LFSRreg[12];
  wire LFSRwires12 = LFSRreg[11];
  wire LFSRwires11 = LFSRreg[10];
  wire LFSRwires10 = LFSRreg[9];
  wire LFSRwires9 = LFSRreg[8];
  wire LFSRwires8 = LFSRreg[7];
  wire LFSRwires7 = LFSRreg[6];
  wire LFSRwires6 = LFSRreg[5];
  wire LFSRwires5 = LFSRreg[4] ^ LFSRreg[15];
  wire LFSRwires4 = LFSRreg[3] ^ LFSRreg[15];
  wire LFSRwires3 = LFSRreg[2] ^ LFSRreg[15];
  wire LFSRwires2 = LFSRreg[1];
  wire LFSRwires1 = LFSRreg[0];
  wire LFSRwires0 = LFSRreg[15] ^ 1;

  /*
  wire LFSRwires14 = {LFSRreg[15] ^ 1, LFSRreg[0], LFSRreg[1], LFSRreg[2] ^ LFSRreg[15], 
  LFSRreg[3] ^ LFSRreg[15], LFSRreg[4] ^ LFSRreg[15], LFSRreg[5], LFSRreg[6], LFSRreg[7], LFSRreg[8], 
  LFSRreg[9], LFSRreg[10], LFSRreg[11], LFSRreg[12], LFSRreg[13], LFSRreg[14]};*/
  reg [3:0] cut_sdi_reg;
  initial cut_sdi_reg = 0;
  assign cut_sdi = cut_sdi_reg;
  reg cut_scanmodeReg;
  initial cut_scanmodeReg = 0;
  assign cut_scanmode = cut_scanmodeReg;
  //For MISR
  reg sampReg;
  initial sampReg = 0;
  wire sampWire = sampReg;
  reg MISRreg [15:0];
  initial for(i = 0; i < 16; i = i + 1) MISRreg[i] = 0;

  /*
  wire [15:0] MISRwires = {MISRreg[14], MISRreg[13], MISRreg[12], MISRreg[11], MISRreg[10], MISRreg[9], MISRreg[8],
  MISRreg[7], MISRreg[6], MISRreg[5], MISRreg[4] ^ MISRreg[15] ^ cut_sdo[0], MISRreg[3] ^ MISRreg[15] ^ cut_sdo[1], 
  MISRreg[2] ^ MISRreg[15] ^ cut_sdo[2], MISRreg[1], MISRreg[0], MISRreg[15] ^ cut_sdo[3]};*/
  
  /*wire [15:0] MISRwires = {MISRreg[15] ^ cut_sdo[3], MISRreg[0], MISRreg[1], MISRreg[2] ^ MISRreg[15] ^ cut_sdo[2], 
  MISRreg[3] ^ MISRreg[15] ^ cut_sdo[1], MISRreg[4] ^ MISRreg[15] ^ cut_sdo[0], MISRreg[5], MISRreg[6], MISRreg[7], 
  MISRreg[8], MISRreg[9], MISRreg[10], MISRreg[11], MISRreg[12], MISRreg[13], MISRreg[14]};*/

  wire MISRwires15 = MISRreg[14];
  wire MISRwires14 = MISRreg[13];
  wire MISRwires13 = MISRreg[12];
  wire MISRwires12 = MISRreg[11];
  wire MISRwires11 = MISRreg[10];
  wire MISRwires10 = MISRreg[9];
  wire MISRwires9 = MISRreg[8];
  wire MISRwires8 = MISRreg[7];
  wire MISRwires7 = MISRreg[6];
  wire MISRwires6 = MISRreg[5];
  wire MISRwires5 = MISRreg[4] ^ MISRreg[15] ^ cut_sdo[0];
  wire MISRwires4 = MISRreg[3] ^ MISRreg[15] ^ cut_sdo[1];
  wire MISRwires3 = MISRreg[2] ^ MISRreg[15] ^ cut_sdo[2];
  wire MISRwires2 = MISRreg[1];
  wire MISRwires1 = MISRreg[0];
  wire MISRwires0 = MISRreg[15] ^ cut_sdo[3];

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
  reg satReg;
  initial satReg = 0;
  wire satWire = satReg;

  always@(*) begin
    //system start or end?
    if((rst & bistmode) | bistdone) begin
      startState = (rst & bistmode) | (startWire ^ 1);
      $display("startState value = %d", startState);
      bistdone_reg = 0;

      for(i = 0; i < 16; i = i + 1) $display("LFSRreg = %h", LFSRreg[i]);
      for(i = 0; i < 16; i = i + 1) $display("MISRreg = %h", MISRreg[i]);
      $display("cut_sdi = %h", cut_sdi);
      $display("cut_sdo = %h", cut_sdo);
    end
  end
  
  always@(posedge clk) begin
    //initialize LFSR (16 moves in)
    if(LFSRinitWire < 16) begin
      //$display("LFSRinitWire value = %d", LFSRinitWire);

      LFSRreg[0] = LFSRwires0;
      LFSRreg[1] = LFSRwires1;
      LFSRreg[2] = LFSRwires2;
      LFSRreg[3] = LFSRwires3;
      LFSRreg[4] = LFSRwires4;
      LFSRreg[5] = LFSRwires5;
      LFSRreg[6] = LFSRwires6;
      LFSRreg[7] = LFSRwires7;
      LFSRreg[8] = LFSRwires8;
      LFSRreg[9] = LFSRwires9;
      LFSRreg[10] = LFSRwires10;
      LFSRreg[11] = LFSRwires11;
      LFSRreg[12] = LFSRwires12;
      LFSRreg[13] = LFSRwires13;
      LFSRreg[14] = LFSRwires14;
      LFSRreg[15] = LFSRwires15;

      LFSRinitReg = LFSRinitWire + 1;
    end

    //start system
    if(startWire) begin
      if (LFSRinitWire == 16) begin
        if(countWire == 57) begin
          #1 cut_scanmodeReg = 0;
          countReg = 0;
          satReg = 1;
          sampReg = 0;
        end
        else begin
          if(satWire == 1) begin
            #1 cut_scanmodeReg = 1;
            sampReg = 1;
            countReg = 57;
            cut_sdi_reg = {LFSRreg[3], LFSRreg[6], LFSRreg[9], LFSRreg[11]};
          end
          else begin
          #1 cut_scanmodeReg = 1;
          countReg = countWire + 1;
          cut_sdi_reg = {LFSRreg[3], LFSRreg[6], LFSRreg[9], LFSRreg[11]};
          end
        end
      end
      
      if(cut_scanmode) begin
        //LFSR
        LFSRreg[0] = LFSRwires0;
        LFSRreg[1] = LFSRwires1;
        LFSRreg[2] = LFSRwires2;
        LFSRreg[3] = LFSRwires3;
        LFSRreg[4] = LFSRwires4;
        LFSRreg[5] = LFSRwires5;
        LFSRreg[6] = LFSRwires6;
        LFSRreg[7] = LFSRwires7;
        LFSRreg[8] = LFSRwires8;
        LFSRreg[9] = LFSRwires9;
        LFSRreg[10] = LFSRwires10;
        LFSRreg[11] = LFSRwires11;
        LFSRreg[12] = LFSRwires12;
        LFSRreg[13] = LFSRwires13;
        LFSRreg[14] = LFSRwires14;
        LFSRreg[15] = LFSRwires15;
        //$display("LFSRwires = %h %h %h", LFSRwires0, LFSRwires1, LFSRwires2);

        if(sampWire == 1) begin
          //MISR
          
          MISRreg[0] = MISRwires0;
          MISRreg[1] = MISRwires1;
          MISRreg[2] = MISRwires2;
          MISRreg[3] = MISRwires3;
          MISRreg[4] = MISRwires4;
          MISRreg[5] = MISRwires5;
          MISRreg[6] = MISRwires6;
          MISRreg[7] = MISRwires7;
          MISRreg[8] = MISRwires8;
          MISRreg[9] = MISRwires9;
          MISRreg[10] = MISRwires10;
          MISRreg[11] = MISRwires11;
          MISRreg[12] = MISRwires12;
          MISRreg[13] = MISRwires13;
          MISRreg[14] = MISRwires14;
          MISRreg[15] = MISRwires15;

          endReg = endWire + 1;

          //$display ("cut_sdo = %h", cut_sdo);
          if(endWire == 2000) begin
            MISRoutputReg = {MISRwires0, MISRwires1, MISRwires2, MISRwires3, MISRwires4, MISRwires5, MISRwires6, 
            MISRwires7, MISRwires8, MISRwires9, MISRwires10, MISRwires11, MISRwires12, MISRwires13, MISRwires14, MISRwires15};
            if(firstPassWire == 0) begin 
              #1 faultFreeReg = MISRoutputWire;
              firstPassReg = 1;
            end
            if (MISRoutputWire == faultFreeWire) bistpass_reg = 1;
            else bistpass_reg = 0;
            //$display ("MISRoutputReg = %h", MISRoutputReg);
            //$display ("Fault free register value = %h", faultFreeReg);
            bistdone_reg = 1;
            #1 endReg = 0;
            #1 MISRoutputReg = 0;
            #1 sampReg = 0;
            #1 countReg = 0;
            #1 for(i = 0; i < 16; i = i + 1) MISRreg[i] = 0;
            #1 cut_scanmodeReg = 0;
            //#1 for(i = 0; i < 16; i = i + 1) LFSRreg[i] = 0;
            //#1 LFSRinitReg = 0;
            #1 cut_sdi_reg = 0;
            #1 satReg = 0;
            $display("end");
            for(i = 0; i < 16; i = i + 1) $display("LFSRreg = %h", LFSRreg[i]);
            for(i = 0; i < 16; i = i + 1) $display("MISRreg = %h", MISRreg[i]);
            $display("cut_sdi = %h", cut_sdi);
            $display("cut_sdo = %h", cut_sdo);
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
