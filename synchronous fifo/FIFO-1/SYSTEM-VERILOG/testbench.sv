/*
  Testbench Top-Level Module:
  - This is the main testbench module that instantiates the following:
    1. Design Under Test (DUT) – the FIFO module
    2. Interface – acts as a bridge between DUT and test
    3. Testcase – applies stimulus and checks response
  - It also generates clock and reset signals.
*/

// Including interface and test case files
`include "interface.sv"

//-------------------------[NOTE]---------------------------------
// Particular test case can be run by uncommenting and commenting the rest
//`include "random_test.sv"// Applies random writes and reads.
`include "wr_rd_test.sv"
// `include "read_only.sv"
 //`include "write_only.sv"
//----------------------------------------------------------------



module tbench_top;
  parameter DEPTH = 16;       // FIFO depth (number of entries in the queue)
  parameter DATA_WIDTH = 32;  // Width of each data word in the FIFO

  // Clock and reset signal declarations
  bit clk;
  bit reset;

  // Clock generation
  always #5 clk = ~clk; // Generates a clock signal with a period of 10 time units (T = 2 × 5)

  // Reset generation (Active low reset assumed)
  initial begin
    reset = 0;  // Assert reset
    #5 reset = 1;  // Deassert reset after 5 time units
  end

  /*
    Interface Instance:
    - The interface (`intf`) is instantiated to connect the DUT and the test.
    - This helps in easy signal passing and avoids direct signal handling in multiple places.
  */
  intf vif(clk, reset);

  /*
    Testcase Instance:
    - The test module is instantiated, and the interface handle (`vif`) is passed as an argument.
    - This allows the testbench to drive and monitor DUT signals.
  */
  test t1(vif);

  /*
    DUT (Design Under Test) Instance:
    - The FIFO module (synchronous_fifo) is instantiated.
    - The interface signals (`vif`) are connected to the corresponding DUT ports.
  */
  synchronous_fifo #(DEPTH, DATA_WIDTH) s_fifo (
    .clk(vif.clk),       // Connect clock
    .rst_n(vif.rst_n),   // Connect active-low reset
    .w_en(vif.w_en),     // Write enable signal
    .r_en(vif.r_en),     // Read enable signal
    .data_in(vif.data_in),   // Input data
    .data_out(vif.data_out), // Output data
    .full(vif.full),     // FIFO full flag
    .empty(vif.empty)    // FIFO empty flag
  );

  /*
    Waveform Dumping:
    - This enables waveform dumping for debugging and visualization using tools like GTKWave.
    - The `.vcd` file stores the signal transitions for analysis.
  */
  initial begin 
    $dumpfile("dump.vcd"); // Output waveform file
    $dumpvars; // Dump all variables/signals into the file
  end
endmodule
