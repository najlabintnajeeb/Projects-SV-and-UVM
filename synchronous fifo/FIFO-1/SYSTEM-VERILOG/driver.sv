//This class drives the randomized transactions into the DUT (FIFO) via the interface. It handles both read and write operations.

class driver;
  
  // Used to count the number of transactions
  int no_transactions;
  
  // Creating virtual interface handle to communicate with DUT
  virtual intf.DRV vif;
  
  // Creating a mailbox handle to receive transactions from the generator
  mailbox gen2driv;
  
  // Constructor: Initializes the interface and mailbox handles
  function new(virtual intf.DRV vif, mailbox gen2driv);
    this.vif = vif;  // Assigning the virtual interface handle
    this.gen2driv = gen2driv;  // Assigning the mailbox handle
  endfunction
  
  // Reset task: Ensures the interface signals are reset properly
  task reset();
    $display("--------- [DRIVER] Waiting for Reset ---------");
    wait(!vif.rst_n);  // Wait until reset goes low (active)
    $display("--------- [DRIVER] Reset Detected ---------");
    wait(vif.rst_n);  // Wait until reset goes high (inactive)
    $display("--------- [DRIVER] Reset Completed ---------");
  endtask
  
  // Drive task: Reads transactions from the mailbox and drives interface signals
  task drive;
    transaction trans;
  //  trans = new();  // Create a new transaction object
    
    // Initialize interface signals to default values
    vif.drv_cb.w_en <= 0;
    vif.drv_cb.r_en <= 0;
    
    // Get the next transaction from the generator through the mailbox
    gen2driv.get(trans);
    @(vif.drv_cb);  // Wait for the next clock edge
    
    // Handle Write Operation
    if (trans.w_en) begin
      vif.drv_cb.w_en <= trans.w_en;  // Enable write
      vif.drv_cb.data_in <= trans.data_in;  // Provide data input
      @(vif.drv_cb);  // Wait for clock edge to register write operation
      vif.drv_cb.w_en <= 0;  // Disable write after one cycle
    end
    
    // Handle Read Operation
    if (trans.r_en) begin
      @(vif.drv_cb);  // Wait for the next clock edge
      vif.drv_cb.r_en <= trans.r_en;  // Enable read
      trans.data_out = vif.drv_cb.data_out;  // Capture data output
      trans.full = vif.drv_cb.full;  // Capture FIFO full flag
      trans.empty = vif.drv_cb.empty;  // Capture FIFO empty flag
      @(vif.drv_cb);  // Wait for clock edge to complete read
      vif.drv_cb.r_en <= 0;  // Disable read after one cycle
    end
    
    // Transaction counter for debugging
    $display("-----------------------------------------");
    no_transactions++;
    $display("[DRIVER] Transaction Count: %0d", no_transactions);
  endtask
  
  // Main task: Continuously drives transactions until reset is asserted
  task main;
    forever begin
      fork
        // Thread-1: Wait for reset to occur
        begin
          wait(!vif.rst_n);
        end
        
        // Thread-2: Continuously execute drive task
        begin
          forever drive();
        end
      join_any  // Exit once any thread completes
      disable fork;  // Kill remaining threads
    end
  endtask
        
endclass
