//
// The `environment` class acts as the verification environment, 
// connecting various components like the generator, driver, monitor, and scoreboard.
// It manages communication between these components using mailboxes and synchronization events.
// Including required verification components
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"



class environment;
  
  // Instances of verification components
  generator  gen;       // Generates transactions
  driver     driv;      // Drives transactions to DUT
  monitor    mon;       // Monitors transactions and sends them to scoreboard
  scoreboard scb;       // Compares expected and actual outputs
  
  // Mailboxes for inter-component communication
  mailbox gen2driv;     // Connects generator to driver
  mailbox mon2scb;      // Connects monitor to scoreboard
  
  // Event to signal the end of transaction generation
  event gen_ended;
  
  // Virtual interface for connecting to DUT
  virtual intf vif;
  
  // Constructor: Initializes and connects all components
  function new(virtual intf vif);
    // Assigning the interface handle passed from the test
    this.vif = vif;
    
    // Creating mailboxes (shared communication channels)
    gen2driv = new();
    mon2scb  = new();
    
    // Creating instances of all components and passing required handles
    gen  = new(gen2driv, gen_ended);  // Generator sends transactions to driver
    driv = new(vif.DRV, gen2driv);    // Driver receives transactions and drives them to DUT
    mon  = new(vif.MON, mon2scb);     // Monitor observes DUT outputs and sends to scoreboard
    scb  = new(mon2scb);              // Scoreboard checks expected vs actual outputs
  endfunction
  
  // Pre-test task: Performs reset operation before starting the test
  task pre_test();
    driv.reset();  // Reset the DUT via the driver
  endtask
  
  // Test execution task: Runs all verification components in parallel
  task test();
    fork 
      gen.main();  // Start transaction generation
      driv.main(); // Start driving transactions
      mon.main();  // Start monitoring DUT outputs
      scb.main();  // Start checking results in scoreboard
    join_any       // Exit once any one of the processes finishes
  endtask
  
  // Post-test task: Waits for completion and prints reports
  task post_test();
    wait(gen_ended.triggered);                 // Wait for generator to finish
    wait(gen.repeat_count == driv.no_transactions); // Ensure driver processed all transactions
    wait(gen.repeat_count == scb.no_transactions); // Ensure scoreboard received all transactions

    // Generate and print reports
    mon.report();                              // Monitor report
    scb.report();                              // Scoreboard report (pass/fail status)
    $display("Functional Coverage: %0.2f%%", mon.trans.cg.get_coverage()); 
                                              // Display functional coverage percentage

    // Indicate simulation completion
    $display("Simulation finished.");
  endtask  
  
  // Run task: Calls pre-test, test, and post-test in sequence
  task run;
    pre_test();  // Perform reset
    test();      // Run the test
    post_test(); // Check results and finish
   
    #100;
    $finish;     // End simulation
  endtask
  
  
endclass
