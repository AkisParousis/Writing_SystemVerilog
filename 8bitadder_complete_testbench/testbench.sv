class transaction;
  randc bit [7:0] a;
  randc bit [7:0] b;
  bit [8:0] sum;
endclass

class generator;
  transaction t;
  mailbox mbx;
  event done;
  integer i;
  
  function new(mailbox mbx);
    this.mbx = mbx;
  endfunction
  
  task run();
    t = new();
    for(i=0;i<20;i++)begin
      t.randomize();
      mbx.get(t);
      $display("[GEN] : Data sent to Driver");
    end
    @(done);
    #10;
  endtask
  
endclass

interface add_intf();
  logic [7:0] a;
  logic [7:0] b;
  logic [8:0] sum;
endinterface

class driver;
  transaction t;
  mailbox mbx;
  event done;
  
  virtual add_intf vif;
  
  function new(mailbox mbx);
    this.mbx = mbx;
  endfunction
  
  task run();
    t = new();
    forever begin
      mbx.get(t);
      vif.a = t.a;
      vif.b = t.b;
      $display("[DRV] : Trigger Interface");
      -> done;
      #10;
    end
  endtask
endclass

class monitor;
  transaction t;
  mailbox mbx;
  event done;
  
  virtual add_intf vif;
  
  function new(mailbox mbx);
    this.mbx = mbx;
  endfunction
  
  task run();
    t = new();
    forever begin
      t.a = vif.a;
      t.b = vif.b;
      t.y = vif.y;
      mbx.put(t);
      $display("[MON] : Data sent to Scoreboard");
      #10;
    end
  endtask
endclass
      
class scoreboard;
  transaction t;
  mailbox mbx;
  bit [7:0] temp;
  
  function new(mailbox mbx);
    this.mbx = mbx;
  endfunction
  
  task run();
    t = new();
    forever begin
      mbx.get(t);
      temp = t.a + t.b;
      if(t.y == temp)
        begin
          $display("[SCO] : Test Passed");
        end
      else
        begin
          $display("[SCO] : Test Failed");
        end
      #10;
    end
  endtask
endclass

class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  
  mailbox gendrv;
  mailbox monsco;
  
  virtual add_intf vif;
  
  event gendrv_done;
  
  function new(mailbox gendrv,mailbox monsco);
    this.gendrv = gendrv;
    this.monsco = monsco;
    
    gen = new(gendrv);
    drv = new(gendrv);
    
    mon = new(monsco);
    sco = new(monsco);
  endfunction
  
  task run();
    gen.done = gendrv_done;
    drv.done = gendrv_done;
    
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
  mailbox gendrv;
  mailbox monsco;
    
  add_intf vif();
  add_intf dut(vif.a,vif.b,vif.sum);
  
  initial begin
    gendrv = new();
    monsco = new();
    env = new(gendrv,monsco);
    env.vif = vif;
    env.run();
    #200;
    $finish;
  end
  
  initial begin
  $dumpvars;
  $dumpfile("dump.vcd"); 
  end
endmodule
