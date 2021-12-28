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
