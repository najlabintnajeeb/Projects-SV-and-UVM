/*The transaction class simulates a FIFO transaction with control signals (w_en for write and r_en for read), data signals (data_in and data_out), and status flags (full and empty). It includes constraints to ensure proper behavior, like preventing simultaneous read and write operations, and ensures data_in is within a valid range. The class also defines coverage for data values, FIFO states, and potential edge cases, such as writing when full or reading when empty. It features a deep copy method to clone transaction objects. */

class transaction;
  // Parameter declarations - Parameters allow for flexible configuration of the class
  parameter DEPTH = 16;            // Depth of FIFO, defining the number of elements it can hold (default 16)
  parameter DATA_WIDTH = 32;       // Width of data, here it’s 32 bits by default
  
  // Control signals
  rand bit w_en;                  // Write enable signal, randomizes during simulation to control write operations
  rand bit r_en;                  // Read enable signal, randomizes during simulation to control read operations

  // Data signals
  randc bit [DATA_WIDTH-1:0] data_in;  // Data input (randomized and constrained to valid range). `randc` ensures all values are used before repeating.
  bit [DATA_WIDTH-1:0] data_out;       // Data output, no randomization here (read-only)

  // Status signals
  bit full;  // FIFO full flag, indicates if the FIFO is full (1 if full)
  bit empty; // FIFO empty flag, indicates if the FIFO is empty (1 if empty)

  // Constraints
  // Constraint to ensure that the write and read enable signals are never both active at the same time
  constraint no_wr_rd_together {
    w_en != r_en;  // Ensures write enable (w_en) and read enable (r_en) are never both high at the same time
    // Alternatives: You could allow simultaneous read and write with a different design, 
    // but for this FIFO, we enforce the read/write separation for simplicity.
  }

  // Constraint on data_in to ensure it is within the valid range of values (0 to 2^DATA_WIDTH - 1)
  constraint data { 
    data_in inside {[0 : (1 << DATA_WIDTH) - 1]};  // Ensures that `data_in` stays within the valid range for a given `DATA_WIDTH`
    // Alternatives: You could use different value ranges or specific subsets for testing purposes.
  }

  // Coverage group to track coverage points and ensure the full range of possible values is covered
  covergroup cg;
    // Coverage for the input data range. Bins represent three sections of data range: low, mid, high
    coverpoint data_in {
      bins low  = {[0 : (2**DATA_WIDTH/4 - 1)]};     // Data range covering the lowest 1/4th of the possible values
      bins mid  = {[(2**DATA_WIDTH/4) : (3*(2**DATA_WIDTH)/4 - 1)]};  // Data range covering the middle 1/2 of the possible values
      bins high = {[(3*(2**DATA_WIDTH)/4) : (2**DATA_WIDTH - 1)]};   // Data range covering the highest 1/4th of the possible values
    }

    // Coverage for the FIFO full state (whether the FIFO is full or not)
    coverpoint full {
      bins fifo_full = {1};        // Full state, when the FIFO is full
      bins fifo_not_full = {0};    // Not full state, when the FIFO is not full
    }

    // Coverage for the FIFO empty state (whether the FIFO is empty or not)
    coverpoint empty {
      bins fifo_empty = {1};       // Empty state, when the FIFO is empty
      bins fifo_not_empty = {0};  // Not empty state, when the FIFO is not empty
    }

    // Cross-coverage for combinations of full/empty states and write/read enable signals
    cross full, empty, w_en, r_en {
      bins write_when_full = binsof(full) intersect {1} && binsof(w_en) intersect {1};   // Coverage when trying to write to a full FIFO
      bins read_when_empty = binsof(empty) intersect {1} && binsof(r_en) intersect {1};  // Coverage when trying to read from an empty FIFO
    }
  
  
   // Cross coverage for data_in and w_en/r_en (*** ADDED ***)
    cross data_in, w_en {
      bins write_low  = binsof(data_in.low)  && binsof(w_en) intersect {1};
      bins write_mid  = binsof(data_in.mid)  && binsof(w_en) intersect {1};
      bins write_high = binsof(data_in.high) && binsof(w_en) intersect {1};
    }
    cross data_in, r_en {
      bins read_low  = binsof(data_in.low)  && binsof(r_en) intersect {1};
      bins read_mid  = binsof(data_in.mid)  && binsof(r_en) intersect {1};
      bins read_high = binsof(data_in.high) && binsof(r_en) intersect {1};
    }
  endgroup


  // Constructor for the class
  function new();
    
    cg = new(); // Instantiate the coverage group when a new transaction is created
  endfunction

  // Deep copy method, creates a copy of the current transaction object with the same values
  function transaction do_copy();
    transaction trans;
    trans = new();  // Create a new instance of the `transaction` class
    trans.w_en = this.w_en;  // Copy write enable signal
    trans.r_en = this.r_en;  // Copy read enable signal
    trans.data_in = this.data_in;  // Copy data input signal
    trans.data_out = this.data_out;  // Copy data output signal
    trans.full = this.full;  // Copy full status
    trans.empty = this.empty;  // Copy empty status
    return trans;  // Return the new copied transaction object
  endfunction
endclass
