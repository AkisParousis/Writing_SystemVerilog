// Code your testbench here
// or browse Examples

module tb;
  mailbox mbx;
  integer i;
  integer data;
  event a;
  
  initial begin
    
  mbx = new();
    
  fork
    begin
      #20;
      -> a;
    end
    
    begin
      @(a.triggered); // @() = wait
      $display("Event Triggered at %0t",$time);
      
      for(i=0;i<5;i++)begin
        mbx.put(i);
        $display("value of i is %0d" , i);
        #10;
      end
    end
    
    begin
      forever begin
      mbx.get(data);
      $display("value of data is %0d" , data);
        #10;
      end
    end
    
  join
    
  end
  
endmodule
