// Code your testbench here
// or browse Examples
interface mul_intf();
  logic [3:0] a,b;
  logic [15:0] y;
endinterface


module tb;
  
  mul_intf vif();
  
  mul dut (vif.a,vif.b,vif.y);
  

  integer i;
  initial begin
    for(i = 0; i <20; i++) begin
      vif.a = $urandom;
      vif.b = $urandom;
      #10;
    end
  
  end

  initial begin
  $dumpvars;
  $dumpfile("dump.vcd"); 
  end

  
  
endmodule
