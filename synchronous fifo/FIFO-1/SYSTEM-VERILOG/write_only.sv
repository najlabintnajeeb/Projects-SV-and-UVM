`include "environment.sv"  // Include the environment file, which contains necessary definitions for the testbench

program test(intf intf);  // Define the test program that accepts the 'intf' interface as an input.
  
  // Define a class 'my_trans' that extends 'transaction', representing a transaction type.
  class my_trans extends transaction;
    
 
    
    // Function 'pre_randomize' that gets called before randomization of the signals.
    function void pre_randomize();
      // Disable randomization for 'w_en' (write enable) and 'r_en' (read enable) signals.
      w_en.rand_mode(0);
      r_en.rand_mode(0);
     
      // Set the values of control signals manually to define the transaction behavior.
      w_en = 1;   // Set write enable to 1 (enable writing).
      r_en = 0;   // Set read enable to 0 (disable reading).
       
     
    endfunction
    
  endclass

  // Declare the environment instance, which will manage the testbench components.
  environment env;
  
  // Declare an instance of the 'my_trans' class, which models the transactions.
  my_trans my_tr;
  
  initial begin
    // Create the environment instance, passing the interface 'intf' to it.
    env = new(intf);
    
    // Create the transaction instance 'my_tr'.
    my_tr = new();
    
    // Set the generator's repeat count to 20. This means the generator will generate 20 packets (transactions).
    env.gen.repeat_count = 20;
    
    // Assign the transaction instance 'my_tr' to the generator.
    env.gen.trans = my_tr;
    
    // Call the 'run' method of the environment, which starts the execution of the generator and driver tasks.
    env.run();
  end
endprogram
