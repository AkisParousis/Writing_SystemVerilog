class transaction;
  randc bit [7:0] a;
  randc bit [7:0] b;
  bit [7:0] y;
endclass

class generator;
  transaction t;
  mailbox mbx;
  event done;
  integer i;
  
  function new(mailbox mbx);
    this.mbx = mbx
  endfunction
  
  task run();
    t = new();
    for(i=0;i<20;i++) begin
      t.randomize();
      mbx.put(t);
      $display("[GEN] : Data sent to Driver");
      @(done);
    end
  endtask
  
endclass

interface andt_intf();
  logic [7:0] a ;
  logic [7:0] b ;
  logic [7:0] y ;
endinterface

class driver;
  transaction t;
  mailbox mbx;
  event done;
  
  virtual andt_intf vif;
  
  function new(mailbox mbx);
    this.mbx = mbx
  endfunction
  
  task run();
    t = new();
    forever begin
      mbx.get(t);
      vif.a = t.a;
      vif.b = t.b;
      $display("[DRV] : Trigger Interface");
      ->done;
    end
  endtask
endclass