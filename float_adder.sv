
//////////////////////////////////
////// Floating Adder  ///////////
// Degined by Steven Lauwereins //
// KU Leuven //
//////////////////////////////////

module flt_add #(
  parameter EXP_W = 8,
  parameter MAN_W = 23
)(
  input [EXP_W+MAN_W-1:0] in1,
  input [EXP_W+MAN_W-1:0] in2,
  output reg [EXP_W+MAN_W-1:0] out
 );

  /************************************************
   ************** INTERNAL VARIABLES **************
   ************************************************/
  logic unsigned [MAN_W-1:0] man1;
  logic unsigned [EXP_W-1:0] exp1;
  logic unsigned [MAN_W-1:0] man2;
  logic unsigned [EXP_W-1:0] exp2;
  logic unsigned [MAN_W-1:0] manO;
  logic unsigned [EXP_W-1:0] expO;


  logic signed [EXP_W:0] exp1S;
  logic signed [EXP_W:0] exp2S;
  logic signed [EXP_W:0] dExpS;
  logic signed [EXP_W:0] dExp;
  logic unsigned [EXP_W:0] shiftExp;

  logic unsigned [EXP_W-1:0] expSel;
  logic unsigned [EXP_W:0] expInc;
  logic unsigned increment;
  logic unsigned [EXP_W:0] expPreOverflow;

  logic unsigned [MAN_W:0] man1E; // MSB Extended man1
  logic unsigned [MAN_W:0] man2E; // MSB Extended man2
  logic unsigned [MAN_W+1:0] manPreShift;
  logic unsigned [MAN_W+1:0] manShift;
  logic unsigned [MAN_W+1:0] manNormal;
  logic unsigned [MAN_W+2:0] man_raw;
  logic unsigned [MAN_W+1:0] manPreRound;
  logic unsigned [MAN_W+1:0] manRound;
  logic unsigned [MAN_W:0] manPreOverflow;

  /************************************************
   ***************** FUNCTIONALITY ****************
   ************************************************/
  always_comb begin
    // Exponent difference calculation
    man1 = in1[MAN_W-1:0];
    exp1= in1[EXP_W + MAN_W-1: MAN_W];
    man2 = in2[MAN_W-1:0];
    exp2= in2[EXP_W + MAN_W-1: MAN_W];

    exp1S = $signed({1'b0,exp1});
    exp2S = -$signed({1'b0,exp2});
    dExpS = exp1S + exp2S;
    if (dExpS[EXP_W]==1)
      shiftExp = $unsigned(-dExpS);
    else
      shiftExp = $unsigned(dExpS);
    
    // Mantissa calculation
    if (in1 == 0) begin // ** SPECIAL SUPPORT FOR 0 **
      man1E = {1'b0, man1};
    end else begin
      man1E = {1'b1, man1};
    end
    
    if (in2 == 0) begin // ** SPECIAL SUPPORT FOR 0 **
      man2E = {1'b0, man2};
    end else begin
      man2E = {1'b1, man2};
    end

    if (dExpS[EXP_W]==1) begin
      manPreShift = {man1E,1'b0};
      manNormal = {man2E,1'b0};
    end else begin
      manPreShift = {man2E,1'b0};
      manNormal = {man1E,1'b0};
    end
    manShift = manPreShift>>>shiftExp[EXP_W-1:0];
    man_raw = manShift + manNormal;
    if (man_raw[MAN_W+2]) begin
      manPreRound = man_raw[MAN_W+2:1];
    end else begin
      manPreRound = man_raw[MAN_W+1:0]; 
    end

    manRound = manPreRound[MAN_W+1:1] + manPreRound[0]; // Rounding
    
    if (manRound[MAN_W+1]) begin
      manPreOverflow = manRound[MAN_W+1:1];
    end else begin
      manPreOverflow = manRound[MAN_W:0];
    end

    // Exponent calculation
    if (dExpS[EXP_W]) begin
      expSel = exp2;
    end else begin
      expSel = exp1;
    end
    
    expPreOverflow = {1'b0,expSel} + (man_raw[MAN_W+2]==1 || manRound[MAN_W+1]==1);

    // Overflow detection
    if (expPreOverflow[EXP_W]) begin
      expO = {EXP_W{1'b1}};
      manO = {MAN_W{1'b1}};
    end else begin
      expO = expPreOverflow[EXP_W-1:0];
      manO = manPreOverflow[0+:MAN_W];
    end
    out= {expO, manO};
  end
endmodule
