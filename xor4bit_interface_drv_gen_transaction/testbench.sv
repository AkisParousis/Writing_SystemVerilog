// Code your testbench here
// or browse Examples
class transaction;

  randc bit [3:0] a;
  randc bit [3:0] b;
  bit [3:0] y;

endclass

class generator;
  
  transaction t;
  mailbox mbx;
  
  event done;
  integer i;
  
  function new(mailbox mbx); //help us specify the mailbox that we will use
    this.mbx = mbx;
  endfunction
  
  
  task run();
    t = new();
    for(i=0;i<50;i++) begin
      t.randomize();
      mbx.put(t);
      $display("[GEN] : Data sent to Driver, a: %b, b: %b",t.a,t.b);
      #10;
    end
    -> done;
  endtask
  
  
endclass

class driver;
  
  mailbox mbx;
  transaction t; //to store our data
  
  virtual xor4_intf vif;
  
  function new(mailbox mbx); //help us specify the mailbox that we will use
    this.mbx = mbx;
  endfunction
  
  
  task run();
    t = new();
    forever begin
      mbx.get(t);
      vif.a = t.a;
      vif.b = t.b;
      $display("[DRV] : Trigger interface");
      #10;
    end
  endtask
  
endclass


interface xor4_intf();
  logic [3:0] a;
  logic [3:0] b;
  logic [3:0] y;
endinterface


module tb;
  
  xor4_intf vif();
  mailbox mbx;
  generator gen;
  driver drv;
  
  xor4 dut (vif.a,vif.b,vif.y);
  
  initial begin
    mbx = new();
    gen = new(mbx);
    drv = new(mbx);
    
    drv.vif = vif;
    
    fork
      gen.run();
      drv.run();
    join_any
    wait(gen.done.triggered);
  end
  

  initial begin
  $dumpvars;
  $dumpfile("dump.vcd"); 
  end

  
endmodule
