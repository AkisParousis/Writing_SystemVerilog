// Code your testbench here
// or browse Examples
class temp;
  bit [3:0] a = 4'b0010;
  bit [3:0] b = 4'b1001;
  rand bit [3:0] d;
  randc bit [3:0] d2;
  
  constraint d_constraint {d>10; d<15;}; //internal constraint
  extern constraint d2_constraint; //external constraint
  
  task show();
    $display("decimal value of a is :%0d" , a);
  endtask
  
  function bit [3:0] add(input bit[3:0] a, input bit[3:0] b);
    return a+b;
  endfunction
  
  function void read(input bit[3:0] data);
    this.a = data;
  endfunction
  
  function void pre_randomize(); //calling function before randomization
    $display("The value of d before randomization: %0d",d);   
  endfunction
  
  function void post_randomize(); //calling function after randomization
    $display("The value of d after randomization: %0d",d);   
  endfunction
  
endclass

class temp_extend extends temp;
  bit [3:0] b = 4'b1111;
endclass

class process1;
  
  task run();
    #14
    $display("process 1 finished at %0t",$time);
  endtask
  
endclass

class process2;
  
  task run();
    #6
    $display("process 2 finished at %0t",$time);
  endtask
  
endclass


constraint temp::d2_constraint {d2<5;d2>1;}; //external constraint

module tb ; 
  temp t; //create handler
  temp_extend t2;
  process1 p1;
  process2 p2;
  bit [4:0] result;
  integer i;
  
  initial begin
    t = new();
    t2 = new();
    p1 = new();
    p2 = new();
    
    $display ("value of a is %b", t.a);
    t.a = 4'b1101;
    $display ("value of a is %0b", t.a);
    
    //check task
    t.show();
    //check function of addition
    result = t.add(4'b0001 , 4'b0010);
    $display ("value of add is %0d", result);
    
    t.read(4'b1010);
    #10;
    $display ("value of a is %0b", t.a);
    
    //inheritance
    $display ("value of a is %b", t2.a);
    $display ("value of b is %0b", t2.b);
    
    //randomization
    for(i=0 ; i<5; i++)begin
      t.randomize();
      $display("value of d is %0d" , t.d);
      $display("value of d2 is %0d", t.d2);
      #10;
    end
    
    //checking
    assert (t.a==t.b)
      begin
        $info("a is equal to b");
      end
    else
      begin
        $warning("a is not equal to b");
      end
    
    //checking if randomization fails
    for(i=0 ; i<5; i++)begin
      assert(t.randomize())
      else $error("Randomization failed");
    end
    
    //fork-join
    fork
      p1.run();
      p2.run();
    join
    $display("all processes completed at %0t",$time); // join_any or join_none
    
  end
  
endmodule
