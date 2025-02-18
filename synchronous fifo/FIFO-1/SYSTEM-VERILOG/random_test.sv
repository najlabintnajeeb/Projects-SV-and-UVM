`include "environment.sv"  

// Program block for the testbench
program test(intf intf);

  // Define a transaction class that extends from base 'transaction' class
  class my_trans extends transaction;

    // Declare distribution percentages for read and write enable signals
    integer RD_EN_ON_DIST = 30;  // 30% probability for read enable
    integer WR_EN_ON_DIST = 70;  // 70% probability for write enable
    
    // Constraint for write enable with a distribution
    constraint write_enable {
      w_en dist {1 := this.WR_EN_ON_DIST, 0 := 100 - this.WR_EN_ON_DIST};
    }
/* Constraint for write enable signal (w_en) with a probability distribution.The write enable (w_en) signal is assigned a probability distribution where:
 - 1 (write enabled) will occur with a probability of WR_EN_ON_DIST% (in this case 70%),
- 0 (write disabled) will occur with a probability of (100 - WR_EN_ON_DIST)% (in this case 30%).
// This constraint ensures that the write enable signal has a controlled likelihood of being activated based on the WR_EN_ON_DIST value set earlier (which is 70%).*/
    // Constraint for read enable with a distribution
    constraint read_enable {
      r_en dist {1 := this.RD_EN_ON_DIST, 0 := 100 - this.RD_EN_ON_DIST};
    }
  endclass

  // Declare an instance of the environment class
  environment env;

  initial begin
    // Create an environment instance and pass the interface to it
    env = new(intf);

    // Set the repeat count of the generator to 200 (generate 200 transactions)
    env.gen.repeat_count = 10;
    // Call the run method of the environment, which internally runs the generator and driver
    env.run();

   #100; // End the simulation after running the environment
    $finish;
  end
endprogram
