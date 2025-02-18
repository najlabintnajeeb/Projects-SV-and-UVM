//class observes the signals from the DUT, captures transactions (e.g., read/write operations), and forwards the captured data to the scoreboard for validation. It also tracks FIFO status and generates transaction reports, helping to verify the DUT's functionality.


class monitor;
  
  // Creating virtual interface handle to monitor DUT signals
  virtual intf.MON vif;
  
  int mon_transaction_count = 0;  // Counts the number of valid monitored transactions
  transaction trans;     // Transaction object to hold monitored data
  int wr_cnt = 0;        // Counts the number of write transactions
  int rd_cnt = 0;        // Counts the number of read transactions
  
  // Mailbox for communication between monitor and scoreboard
  mailbox mon2scb;

  // Constructor: Accepts virtual interface and mailbox handles from the environment
  function new(virtual intf.MON vif, mailbox mon2scb);
    this.vif = vif;               // Get the interface handle
    this.mon2scb = mon2scb;       // Get the mailbox handle to communicate with scoreboard
  endfunction

  // Main task: Samples signals from the interface and sends the transaction to the scoreboard
  task main;
    forever begin
      trans = new();  // Create a new transaction object each time a new transaction is captured
      
      // Wait until the monitor interface signals either a write or read transaction
      @(vif.mon_cb);
      wait(vif.mon_cb.w_en || vif.mon_cb.r_en);  // Wait for either write or read to be enabled
      mon_transaction_count++;   // Increment monitored transaction count

      $display("[MONITOR] Transaction Count: %0d", mon_transaction_count); // Display transaction count

      // Capture transaction details for write and read
      trans.w_en = vif.mon_cb.w_en;  // Capture write enable signal
      trans.r_en = vif.mon_cb.r_en;  // Capture read enable signal
      trans.data_in = vif.mon_cb.data_in;  // Capture data_in for writes

      // If it's a write transaction, increment the write counter and print the data
      if (vif.mon_cb.w_en) begin
        wr_cnt++;  // Increment the write counter
        $display("[MONITOR] Write Transaction Detected - DATA = %0h at time %0t", trans.data_in, $time);
      end

      // If it's a read transaction, capture the read data and increment the read counter
      if (vif.mon_cb.r_en) begin
        @(vif.mon_cb); // Wait for the read signal to settle
        rd_cnt++;      // Increment the read counter
        #1;            // Small delay to ensure the read data is stable
        trans.data_out = vif.mon_cb.data_out;  // Capture the data_out for reads
        $display("[MONITOR] Read Transaction Detected - DATA = %0h at time %0t", trans.data_out, $time);
      end

      // Capture FIFO status (Full and Empty flags)
      trans.full = vif.mon_cb.full;
      trans.empty = vif.mon_cb.empty;
      $display("[MONITOR] FIFO Status - Full: %0b, Empty: %0b at time %0t", trans.full, trans.empty, $time);

      // Sample the functional coverage (if applicable) and send transaction to scoreboard
      trans.cg.sample;
      mon2scb.put(trans);  // Send the captured transaction to the scoreboard via mailbox
    end
  endtask

  // Report function to display a summary of the monitored transactions
  function void report();
    $display("[MONITOR] Total Transactions: %0d  Write Transactions: %0d  Read Transactions: %0d", mon_transaction_count, wr_cnt, rd_cnt);
  endfunction

endclass
