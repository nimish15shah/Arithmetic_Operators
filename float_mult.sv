///////////////////////////////
//////    Float Mult    / ////
///////////////////////////////
module flt_mul # (parameter EXP_L=`part_1_len, MNT_L=`part_2_len)( //EXP_L should not be less than 3
    input [EXP_L+MNT_L-1:0] in1, 
    input [EXP_L+MNT_L-1:0] in2, 
    output [EXP_L+MNT_L-1:0] out 
  );
logic unsigned [MNT_L:0] sigX ;
logic unsigned [MNT_L:0] sigY ;
logic unsigned [2*MNT_L+1:0] sigProd ;
logic unsigned [2*MNT_L+1:0] sigProdExt_pre;
logic unsigned [2*MNT_L+1:0] sigProdExt ;

logic unsigned [EXP_L-1:0] expX ;
logic unsigned [EXP_L-1:0] expY ;
logic unsigned [EXP_L:0] expSumPreSub ;
logic unsigned [EXP_L-2:0] bias_dummy;
logic unsigned [EXP_L:0] bias ;
logic unsigned [EXP_L:0] expSum ;
logic unsigned [EXP_L:0] expPostNorm;
logic unsigned [EXP_L:0] expPostNorm_fin;

logic unsigned [EXP_L+MNT_L:0] expSig; 
logic unsigned [EXP_L+MNT_L:0] expSigPostRound;

logic unsigned norm;
logic unsigned sticky ;
logic unsigned round  ;
 
  assign expX = in1[EXP_L+MNT_L-1 : MNT_L];
  assign expY = in2[EXP_L+MNT_L-1 : MNT_L];
  assign sigX = {1'b1 , in1[MNT_L-1:0]};
  assign sigY = {1'b1 , in2[MNT_L-1:0]};
  
  assign sigProd= sigX*sigY; 
  assign norm= sigProd[2*MNT_L+1];

  assign expSumPreSub = {1'b0, expX} + {1'b0, expY};
  assign bias_dummy= '1;  // All ones 
  assign bias = {2'b00, bias_dummy}; //CONV_STD_LOGIC_VECTOR(127,10);
  assign expSum = expSumPreSub + norm - bias;
  assign expPostNorm= expSum;
  
  // significand normalization shift
  always @(*)
  begin
    if (norm == 1) begin
      sigProdExt_pre = {sigProd[2*MNT_L : 0], 1'b0};
    end else begin
      sigProdExt_pre = {sigProd[2*MNT_L-1 : 0], 2'b00};
    end
  end
  
  always @(*)
  begin
    if ((bias > (expSumPreSub+norm)) || (in1==0) || (in2==0)) begin // Underflow check and check if any of the operand is zero ** SPECIAL SUPPORT FOR 0 **
      expPostNorm_fin= '0; // All zeroes
      sigProdExt= '0;
    end else if (expPostNorm[EXP_L]) begin // Overflow
      expPostNorm_fin= '1; // All ones
      sigProdExt= { {MNT_L{1'b1}} , {2+MNT_L{1'b0}} }; // First MNT_L bits toward MSB are 1, rest 0s
    end else begin
      expPostNorm_fin= expPostNorm;
      sigProdExt= sigProdExt_pre;
    end
  end
  
  assign expSig = {expPostNorm_fin , sigProdExt[2*MNT_L+1: MNT_L+2]};
  assign sticky = sigProdExt[MNT_L+1];
  
  assign expSigPostRound= sticky+ expSig; // This will not overflow Mantissa because there will always be a zero in Mantissa to absorb the propogation of 1, hence no overflow check required for this

  assign out = expSigPostRound[EXP_L+MNT_L-1:0];
  
endmodule

