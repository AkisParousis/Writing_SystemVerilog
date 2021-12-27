// Code your testbench here
// or browse Examples

class driver;
  
  virtual or4_intf vif;
  integer i;
  
  task run();
    for(i = 0; i <50; i++) begin
      vif.a = $urandom;
      vif.b = $urandom;
      #10;
    end
  endtask
  
endclass


interface or4_intf();
  logic [3:0] a;
  logic [3:0] b;
  logic [3:0] y;
endinterface


module tb;
  
  or4_intf vif();
  driver drv;
  
  or4 dut (vif.a,vif.b,vif.y);
  
  initial begin
    drv = new();
    drv.vif = vif;
    drv.run();
  end
  

  initial begin
  $dumpvars;
  $dumpfile("dump.vcd"); 
  end

  
endmodule
