///////////////////////////////
////// Fix Point Mult  ////////
///////////////////////////////

`define part_1_len 4 // Integer part length
`define part_2_len 17 //Fraction part length (Both len)

`define word_len (`part_1_len + `part_2_len)

module fx_pt_mul (
    input [`word_len-1:0] in1,
    input [`word_len-1:0] in2,
    output [`word_len-1:0] out
  );
  
  logic unsigned [(2*`word_len) : 0] resPreRound;
  logic unsigned [2*`word_len-`part_2_len : 0] resRound;
  logic unsigned [`word_len-1:0] temp_out;
  logic unsigned [2*`word_len-`part_2_len :0] intrst_part;
  
  assign resPreRound= in1 * in2;
  assign intrst_part= resPreRound[2*`word_len: `part_2_len];
  assign resRound= intrst_part + resPreRound[`part_2_len-1];
  // Check if overflow has happened
always @(*) 
begin  
   if(resRound[2*`word_len-`part_2_len: `word_len]==0) begin //Non_Overflow
    temp_out= resRound[`word_len-1:0];
  end else begin
    temp_out= '1; // All 1s
  end
end
  assign out= temp_out; 
endmodule

