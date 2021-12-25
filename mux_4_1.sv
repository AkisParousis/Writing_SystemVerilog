// Code your testbench here
// or browse Examples
class transaction;

  randc bit [3:0] a;

  randc bit [3:0] b;

  randc bit [3:0] c;

  randc bit [3:0] d;

  randc bit [1:0] sel;

  bit [3:0] y;

 

  function void mux ();

    if (sel == 2'b00) y = a;

    else if (sel == 2'b01) y = b;

    else if (sel == 2'b10) y = c;

    else if (sel == 2'b11) y = d;

  endfunction

endclass 

class generator;
  transaction t;
  mailbox mbx;
  event done;
  integer i;
  
  function new(mailbox mbx); //help us specify the mailbox that we will use
    this.mbx = mbx;
  endfunction
  
  
  task main();
    for(i=0;i<1;i++) begin
      t = new();
      t.randomize();
      mbx.put(t);
      $display("[GEN] : Data sent to Driver, a: %b, b: %b, c: %b, d: %b",t.a,t.b,t.c,t.d);
      #1;
    end
    -> done;
  endtask
  
  
endclass

class driver;
  mailbox mbx;
  transaction t; //to store our data
  
  function new(mailbox mbx); //help us specify the mailbox that we will use
    this.mbx = mbx;
  endfunction

  
  task main();
    forever begin
      t = new();
      mbx.get(t);
      
      if (t.sel == 2'b00) t.y = t.a;

      else if (t.sel == 2'b01) t.y = t.b;

      else if (t.sel == 2'b10) t.y = t.c;

      else if (t.sel == 2'b11) t.y = t.d;
      
      $display("[DRV] : Data received, a: %b, b: %b, c: %b, d: %b",t.a,t.b,t.c,t.d);
      $display("sel is : %b , so y value is %b",t.sel,t.y);
    end
  endtask
  
endclass

module tb() ; 
  transaction t;
  mailbox mbx;
  generator gen;
  driver drv;
  
  initial begin
    mbx = new();
    gen = new(mbx);
    drv = new(mbx);
    
    fork
      gen.main();
      drv.main();
    join_any
    wait(gen.done.triggered);
  end
  
endmodule
