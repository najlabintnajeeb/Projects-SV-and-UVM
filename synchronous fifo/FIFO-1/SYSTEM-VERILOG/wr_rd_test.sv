`include "environment.sv"  // Including the environment file to bring in relevant definitions for the testbench

// Program Block: test
// This is the top-level test program that defines a testbench to simulate the environment with a transaction (my_trans).
program test(intf intf);
  
  // Class Definition: my_trans
  // This class extends the 'transaction' class, which is likely defined elsewhere in the code (possibly from `environment.sv`).
  // It defines the behavior of the transaction, including randomization and control of signals.
  class my_trans extends transaction;
    
    int cnt;  // Counter to control the alternating behavior of write enable (w_en) and read enable (r_en) signals

    
    // Function: pre_randomize
    // This function is called before randomization of the signals (w_en and r_en). It ensures that the signals
    // alternate between write and read enable depending on the value of the counter.
    function void pre_randomize();
      w_en.rand_mode(0);  // Disables randomization for the write enable signal
      r_en.rand_mode(0);  // Disables randomization for the read enable signal
     
      // Alternate the values of w_en and r_en based on the counter value
      if(cnt % 2 == 0) begin
        w_en = 1;  // Set write enable to 1 (write operation)
        r_en = 0;  // Set read enable to 0 (no read operation)
      end 
      else begin
        w_en = 0;  // Set write enable to 0 (no write operation)
        r_en = 1;  // Set read enable to 1 (read operation)
      end
      cnt++;  // Increment the counter to alternate between write and read on each transaction
    endfunction
    
  endclass
    
  // Declaring environment instance and transaction instance
  environment env;    // Create an instance of the 'environment' class
  my_trans my_tr;     // Create an instance of the 'my_trans' class (transaction)
  
  initial begin
    // Creating environment instance and initializing it with the interface (intf)
    env = new(intf);
    
    // Create a new transaction object
    my_tr = new();
    
    // Set the repeat count for the generator to 10, meaning it will generate 10 packets of data
    env.gen.repeat_count = 10;
    
    // Assign the transaction instance to the generator's transaction
    env.gen.trans = my_tr;
    
    // Call the 'run' function of the environment, which will internally trigger the generator and driver tasks
    env.run();
  end
endprogram
