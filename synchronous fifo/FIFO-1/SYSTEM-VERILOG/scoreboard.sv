//-------------------------------------------------------------------------
// Scoreboard Class
//-------------------------------------------------------------------------
// Description: 
//   - Receives transactions from the monitor.
//   - Simulates FIFO behavior using a queue.
//   - Compares the actual FIFO output with the expected result.
//-------------------------------------------------------------------------

class scoreboard;

  // Mailbox to receive transactions from the monitor
  mailbox mon2scb;
  transaction tr;
  
  // Parameters for FIFO depth and data width
  parameter DEPTH=16; 
  parameter DATA_WIDTH=32;

  // Counters to track number of transactions, passes, and failures
  int no_transactions;
  int num_passes = 0;
  int num_fails = 0;
  int wrcnt = 0;
  int rdcnt = 0;

  // Queue to simulate FIFO storage
  bit [DATA_WIDTH-1:0] fifo_queue[$];  // FIFO storage
  bit [DATA_WIDTH-1:0] expected_data;  // Expected data for comparison

  // Constructor: Initializes the scoreboard with mailbox
  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  // Main task: Processes transactions and verifies FIFO behavior
  task main;
    

    forever begin
      #50;  // Small delay to simulate real-time behavior

      // Get a transaction from the monitor
      mon2scb.get(tr);

      // Check if write and read happen at the same time (illegal condition)
      if (tr.w_en && tr.r_en) begin
        $error("[SCOREBOARD] %0t: ERROR - Write and Read triggered together!", $time);
      end

      // Handle write operation
      if (tr.w_en) begin
        if (fifo_queue.size() < DEPTH) begin
          wrcnt++;
          fifo_queue.push_front(tr.data_in);  // Store the written data into FIFO
          $display("[SCOREBOARD] %0t: WRITE - Data Stored: %0h", $time, tr.data_in);
        end else begin
          $error("[SCOREBOARD] %0t: WRITE ERROR - FIFO is full!", $time);  // Error if FIFO is full
        end
      end

      // Handle read operation
      if (tr.r_en) begin
        if (fifo_queue.size() > 0) begin
          rdcnt++;
          expected_data = fifo_queue.pop_back();  // Retrieve data from FIFO

          // Compare actual output with expected data
          if (tr.data_out == expected_data) begin
            $display("[SCOREBOARD] %0t: READ - Data Match : Expected = %0h, Actual = %0h",
                     $time, expected_data, tr.data_out);
            num_passes++;  // Increment passes counter if data matches
          end else begin
            $error("[SCOREBOARD] %0t: READ ERROR - Data Mismatch : Expected = %0h, Actual = %0h",
                   $time, expected_data, tr.data_out);
            num_fails++;  // Increment failures counter if data doesn't match
          end
        end else begin
          $error("[SCOREBOARD] %0t: READ ERROR - FIFO is empty!", $time);  // Error if FIFO is empty
        end
      end

      // Increment transaction counter
      no_transactions++;
      $display("[SCOREBOARD] %0t: no_transactions: %0d FIFO Size: %0d, Write Count: %0d, Read Count: %0d",
               $time, no_transactions, fifo_queue.size(), wrcnt, rdcnt);
    end
  endtask
  
  // Report function: Prints the summary of scoreboard operations
  function void report();
    int expected_fifo_size = wrcnt - rdcnt;  // Calculate expected FIFO size

    // Print the scoreboard report
    $display("----------------------------------------------------------");
    $display("                         Scoreboard Report               ");
    $display("----------------------------------------------------------");
    $display(" Final FIFO size: %0d (Expected: %0d)", fifo_queue.size(), expected_fifo_size);
    $display(" No: of Writes  : %0d", wrcnt);
    $display(" No: of Reads   : %0d", rdcnt);
    $display(" FIFO Full Status  : %0d", tr.full);
    $display(" FIFO Empty Status  : %0d", tr.empty);
    $display(" Passes         : %0d", num_passes);
    $display(" Fails          : %0d", num_fails);
    $display("----------------------------------------------------------");

    // Validate FIFO size: Ensure that the final FIFO size matches the expected value
    if (fifo_queue.size() != expected_fifo_size) begin
        $error("[SCOREBOARD] ERROR: Final FIFO size does not match expected value!");
    end

    // Final test result based on the presence of any failures
    if (num_fails == 0) 
        $display("TEST PASSED");
    else 
        $display("TEST FAILED");
    
    $display("----------------------------------------------------------");
  endfunction

endclass
