// Code your design here
module counter(
  input clk,rst,up,
  output reg [3:0] dout
);
  
  always@(posedge clk)
    begin
      if (rst == 1'b1)
        dout <= 4'b0000;
      else begin 
        if (up == 1'b1)
          dout <= dout + 1;
        else
          dout <= dout - 1;
      end
    end
  
  
endmodule
