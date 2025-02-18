// Interface Definition: intf
// The interface contains all the signals and clocking blocks needed for communication between the driver and monitor.
// It also includes control signals (write and read enable), data signals, and status signals such as full and empty.
// The interface is parametrized by DATA_WIDTH to allow flexibility in the bit-width of the signals.

interface intf (input logic clk, input logic rst_n);
  parameter DATA_WIDTH = 32;  // Define the data width to ensure consistency with the testbench and other modules

  // Control signals
  logic w_en;  // Write enable signal
  logic r_en;  // Read enable signal

  // Data signals
  logic [DATA_WIDTH-1:0] data_in;  // Input data signal with a width defined by DATA_WIDTH
  logic [DATA_WIDTH-1:0] data_out; // Output data signal with a width defined by DATA_WIDTH

  // Status signals
  logic full;  // Indicates if the FIFO (First-In, First-Out) is full
  logic empty; // Indicates if the FIFO is empty

  // Driver Clocking Block (DRV)
  // Clocking block for the driver to synchronize signals on the positive edge of clk
  clocking drv_cb @(posedge clk);
    output w_en;      // Output: Write enable
    output r_en;      // Output: Read enable
    output data_in;   // Output: Data input
    input data_out;   // Input: Data output
    input full;       // Input: FIFO full status
    input empty;      // Input: FIFO empty status
  endclocking

  // Monitor Clocking Block (MON)
  // Clocking block for the monitor to synchronize signals on the positive edge of clk
  clocking mon_cb @(posedge clk);
    input w_en;       // Input: Write enable
    input r_en;       // Input: Read enable
    input data_in;    // Input: Data input
    input data_out;   // Input: Data output
    input full;       // Input: FIFO full status
    input empty;      // Input: FIFO empty status
  endclocking

  // Modports for the interface
  // These define how the interface can be used in driver and monitor modules
  modport DRV (clocking drv_cb, input rst_n);  // Driver modport with clocking block and reset signal
  modport MON (clocking mon_cb, input rst_n);  // Monitor modport with clocking block and reset signal

  // Optional Assertions for functional correctness:
  // These assertions ensure proper behavior, but they are commented out in this code block.
  
  // Assertion to ensure that no write operation occurs when the FIFO is full
  /*property no_write_when_full;
    @(posedge clk) disable iff (!rst_n)
    full |-> !w_en;  // If FIFO is full, w_en should be 0 (write should not happen)
  endproperty
  assert property (no_write_when_full)
    else $error("Write attempted when FIFO is full!");*/

  // Assertion to ensure that no read operation occurs when the FIFO is empty
  /*property no_read_when_empty;
    @(posedge clk) disable iff (!rst_n)
    empty |-> !r_en;  // If FIFO is empty, r_en should be 0 (read should not happen)
  endproperty
  assert property (no_read_when_empty)
    else $error("Read attempted when FIFO is empty!");*/

  // Assertion to check data integrity during read and write operations
  /*property data_integrity;
    @(posedge clk) disable iff (!rst_n)
    (w_en && !full) |=> (data_out == $past(data_in));  // Ensure that when write occurs, the output data matches the input data
  endproperty
  assert property (data_integrity)
    else $error("Data integrity violation detected!");*/

endinterface
