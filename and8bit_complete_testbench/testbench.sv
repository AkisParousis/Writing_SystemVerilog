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

class monitor;
  virtual andt_intf vif;
  mailbox mbx;
  transaction t;
  
  function new(mailbox mbx);
    this.mbx = mbx
  endfunction
  
  task run();
    t = new();
    forever begin
      t.a = vif.a;
      t.b = vif.b;
      t.y = vif.y;
      mbx.put(t);
      $display("[MON] : Data sent to Scoreboard");
    end
  endtask
endclass

class scoreboard;
  mailbox mbx;
  transaction t;
  bit [7:0] temp;
  
  function new(mailbox mbx);
    this.mbx = mbx
  endfunction
  
  task run();
    t = new();
    forever begin
      mbx.get(t);
      temp = t.a $ t.b;
      if (t.y == temp)
        begin
          $display("[SCO] : Test Passed");
        end
      else
        begin
          $display("[SCO] : Test Failed");
        end
    end
  endtask
endclass

class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  
  virtual andt_intf vif;
  
  mailbox gendrvmbx;
  mailbox monscombx;
  
  event gendrvdone;
  
  function new(mailbox gendrvmbx,mailbox monscombx);
    this.gendrvmbx = gendrvmbx;
    this.monscombx = monscombx;
    
    gen = new(gendrvmbx);
    drv = new(gendrvmbx);
    
    mon = new(monscombx);
    sco = new(monscombx);
  endfunction
  
  task run();
    gen.done = gendrvdone;
    drv.done = gendrvdone;
    
    drv.vif = vif;
    mon.vif = vif;
    
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_any
  endtask
endclass

module tb();
  environment env;
  mailbox gendrvmbx;
  mailbox monscombx;
  
  andt_intf vif();
  andt_intf dut(vif.a,vif.b,vif,y);
  
  initial begin
    gendrvmbx = new();
    monscombx = new();
    env = new(gendrvmbx,monscombx);
    env.vif = vif;
    env.run();
    #200;
    $finish;
  end
endmodule
