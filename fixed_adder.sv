///////////////////////////////
////// Fix Point Adder ////////
///////////////////////////////
`define word_len 32

module fx_pt_add (
    input [`word_len-1:0] in1,
    input [`word_len-1:0] in2,
    output [`word_len-1:0] out
  );
  
  logic unsigned [`word_len:0] res;
  logic unsigned [`word_len-1:0] temp_out;
  assign res= in1 + in2;
  
  always @(*) begin
    if (res[`word_len]==1) begin // Overflow
      temp_out= '1;
    end else begin
      temp_out= res[`word_len-1:0];
    end
  end
  assign out= temp_out;
endmodule
