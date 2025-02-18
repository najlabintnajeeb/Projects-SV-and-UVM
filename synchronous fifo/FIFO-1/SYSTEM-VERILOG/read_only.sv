`include "environment.sv"  // Include the environment file that contains the necessary definitions for the testbench

program test(intf intf);  // Define the test program which takes the 'intf' interface as an input.
  
  // Define a class 'my_trans' which extends 'transaction' to model the transaction behavior.
  class my_trans extends transaction;
    
  
    
    // Define a function 'pre_randomize' to modify signal values before randomization.
    function void pre_randomize();
      w_en.rand_mode(0);  // Disable randomization of the write enable signal (w_en).
      r_en.rand_mode(0);  // Disable randomization of the read enable signal (r_en).
     
      // Manually assign values to control signals for this transaction.
      w_en = 0;   // Set write enable to 0 (disable writing).
      r_en = 1;   // Set read enable to 1 (enable reading).
       
     
    endfunction
    
  endclass

  // Declare an instance of the environment class.
  environment env;
  
  // Declare an instance of the 'my_trans' class.
  my_trans my_tr;
  
  initial begin
    // Create the environment instance and pass the interface 'intf'.
    env = new(intf);
    
    // Create the transaction instance 'my_tr'.
    my_tr = new();
    
    // Set the repeat count of the generator to 20, which means generating 20 packets (transactions).
    env.gen.repeat_count = 20;
    
    // Set the transaction instance 'my_tr' to be used by the generator.
    env.gen.trans = my_tr;
    
    // Call the 'run' function of the environment, which internally invokes the generator and driver main tasks.
    env.run();
  end
endprogram
