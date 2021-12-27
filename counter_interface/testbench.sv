// Code your testbench here
// or browse Examples
interface counter_intf();
  logic clk,rst,up;
  logic [3:0] dout;
endinterface


module tb;
  
  counter_intf vif();
  
  counter dut (vif.clk,vif.rst,vif.up,vif.dout);
  
  initial begin
    vif.clk = 0;
    vif.rst = 0;
    vif.up = 0;
  end
  
  always #5 vif.clk = ~vif.clk;
  
  initial begin
    vif.rst = 1;
    #30;
    vif.rst = 0;
    #200;
    vif.rst = 1;
    #100;
    vif.rst = 0;
  end

  integer i;
  initial begin
    for(i = 0; i <50; i++) begin
      vif.up = $urandom;
      @(posedge vif.clk);
    end
  
  end

  initial begin
  $dumpvars;
  $dumpfile("dump.vcd"); 
  end

  initial begin
    #500
    $finish;
  end
  
endmodule
