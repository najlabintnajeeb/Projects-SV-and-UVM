/*

 class is responsible for generating randomized transaction packets and sending them to a driver for further processing. It creates instances of the transaction class, randomizes their values, and places them in a mailbox for communication between the generator and driver.

*/
class generator;

  // Declaring transaction class instance for generating transactions
  rand transaction trans, tr;  // 'trans' is the base transaction to randomize, 'tr' is a copy to be sent

  
  int repeat_count;  // 'repeat_count' defines how many transactions to generate

  // 'gen2driv'  Mailbox to send the generated transaction packet to the driver
  mailbox gen2driv; 

  // Event to signal when transaction generation is finished
  event ended;  // 'ended' event is triggered once all transactions are generated

 
  int count = 0;  // 'count' keeps track of the number of transactions created

  // Constructor to initialize mailbox and event handles, and create a new transaction
  function new(mailbox gen2driv, event ended);
    // Assigning the mailbox and event handles passed from the environment
    // Mailbox is shared between generator and driver to send and receive data
    this.gen2driv = gen2driv;  // Store the mailbox handle
    this.ended = ended;        // Store the event handle

    // Creating a new transaction object
    trans = new(); 
  endfunction

  // Main task to generate the transaction packets and send them to the driver
  task main();
    // Loop to repeat the generation process for the specified repeat_count
    repeat(repeat_count) begin// Increment the transaction count
      count++;  // Increase the count for each transaction generated

      // Randomizing the transaction object trans
      // If randomization fails, display an error and stop the simulation

    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed at iteration %0d", count);   
      tr = trans.do_copy();  // Copy the randomized transaction to 'tr'

      // Putting the generated transaction into the mailbox for the driver to process
      gen2driv.put(tr); 

      
      $display("[generator]   %0d", count);  // Print the count to show the current transaction number
    end

    // Triggering the ended event to indicate that the generation is complete
    -> ended;  
  endtask

endclass
