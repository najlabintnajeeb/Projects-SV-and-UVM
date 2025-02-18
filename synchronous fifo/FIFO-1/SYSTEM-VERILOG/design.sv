// Synchronous FIFO Module
module synchronous_fifo #(parameter DEPTH=16, DATA_WIDTH=32) (
  input clk, rst_n,          // Clock and active-low reset
  input w_en, r_en,         // Write enable and Read enable signals
  input [DATA_WIDTH-1:0] data_in,  // Data input
  output reg [DATA_WIDTH-1:0] data_out, // Data output
  output full, empty         // Flags to indicate FIFO status
);
  
  parameter PTR_WIDTH = $clog2(DEPTH); // Pointer width calculation (e.g., for DEPTH=8, PTR_WIDTH=3)
  reg [PTR_WIDTH:0] w_ptr, r_ptr;     // Read and Write pointers (extra bit for wrap-around detection)
  // Example: w_ptr = 0000 to 1111 (for DEPTH=8, uses 4 bits)
  reg [DATA_WIDTH-1:0] fifo[DEPTH];   // FIFO memory storage
  // Reset logic to initialize pointers and output data
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      w_ptr <= 0; 
      r_ptr <= 0;
      data_out <= 0;
    end
  end
  
  // Writing data into FIFO
  always @(posedge clk) begin
    if (w_en && !full) begin
      fifo[w_ptr[PTR_WIDTH-1:0]] <= data_in; // Store data at write pointer index
      w_ptr <= w_ptr + 1; // Increment write pointer
    end
  end
  
  // Reading data from FIFO
  always @(posedge clk) begin
    if (r_en && !empty) begin
      data_out <= fifo[r_ptr[PTR_WIDTH-1:0]]; // Read data from read pointer index
      r_ptr <= r_ptr + 1; // Increment read pointer
    end
  end
  
  // Full condition: When write pointer has wrapped around and caught up with the read pointer
  assign full = (r_ptr == {~w_ptr[PTR_WIDTH], w_ptr[PTR_WIDTH-1:0]});
  
  // Empty condition: When read pointer equals write pointer
  assign empty = (w_ptr == r_ptr);
endmodule


