`timescale 1ns / 1ps

//======================================================================
// 
// tb_aes.v
// ------------------
// For the use of AES timing simulation and generate power traces 
// based on Xilinx FPGA tool.
// 
// Generate by Huifeng Zhu @ 10/6/2019
// 
//======================================================================

module tb_aes();
  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  parameter CLK_HALF_PERIOD = 1;
  parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;


  //----------------------------------------------------------------
  // Register and Wire declarations.
  //----------------------------------------------------------------
  reg            tb_clk;
  reg            tb_reset_n;
  reg            tb_init;
  reg            tb_next;
  wire           tb_ready;
  reg [127 : 0]  tb_key;
  reg [127 : 0]  tb_block;
  wire [127 : 0] tb_result;
  wire           tb_result_valid;

  //----------------------------------------------------------------
  // Device Under Test.
  //----------------------------------------------------------------
  aes_core dut(
               .clk(tb_clk),
               .reset_n(tb_reset_n),

               .encdec(tb_encdec),
               .init(tb_init),
               .next(tb_next),
               .ready(tb_ready),

               .key(tb_key),
               .keylen(tb_keylen),

               .block(tb_block),
               .result(tb_result)
              );

  //----------------------------------------------------------------
  // clk_gen
  //
  // Always running clock generator process.
  //----------------------------------------------------------------
  always
    begin : clk_gen
      #CLK_HALF_PERIOD;
      tb_clk = !tb_clk;
    end // clk_gen

  //----------------------------------------------------------------
  // reset_dut()
  //
  // Toggle reset to put the DUT into a well known state.
  //----------------------------------------------------------------
  task reset_dut;
    begin
      $display("*** Toggle reset.");
      tb_reset_n = 0;
      #(2 * CLK_PERIOD);
      tb_reset_n = 1;
    end
  endtask // reset_dut

  //----------------------------------------------------------------
  // init_sim()
  //
  // Initialize all counters and testbed functionality as well
  // as setting the DUT inputs to defined values.
  //----------------------------------------------------------------
  task init_sim;
    begin
      tb_clk     = 0;
      tb_reset_n = 1;
      tb_init    = 0;
      tb_next    = 0;
      tb_key     = {8{32'h00000000}};
      tb_block  = {4{32'h00000000}};
    end
  endtask // init_sim

  //----------------------------------------------------------------
  // wait_ready()
  //
  // Wait for the ready flag in the dut to be set.
  //
  // Note: It is the callers responsibility to call the function
  // when the dut is actively processing and will in fact at some
  // point set the flag.
  //----------------------------------------------------------------
  task wait_ready;
    begin
      while (!tb_ready)
        begin
          #(CLK_PERIOD);
        end
    end
  endtask // wait_ready

  //----------------------------------------------------------------
  // wait_valid()
  //
  // Wait for the result_valid flag in the dut to be set.
  //
  // Note: It is the callers responsibility to call the function
  // when the dut is actively processing a block and will in fact
  // at some point set the flag.
  //----------------------------------------------------------------
  task wait_valid;
    begin
      while (!tb_result_valid)
        begin
          #(CLK_PERIOD);
        end
    end
  endtask // wait_valid

  //----------------------------------------------------------------
  // run_one_encryption()
  //
  // Perform ECB mode encryption or decryption single block test.
  //----------------------------------------------------------------
  task run_one_encryption(input [127 : 0] key,
                          input [127 : 0] block);
   begin
     // Init the cipher with the given key.
     tb_key = key;
     tb_init = 1;
     #(2 * CLK_PERIOD);
     tb_init = 0;
     wait_ready();

    //  $display("Key expansion done");
    //  $display("");

     // Perform encipher operation on the block.
     tb_block = block;
     tb_next = 1;
     #(2 * CLK_PERIOD);
     tb_next = 0;
     wait_ready();
   end
  endtask // run_one_encryption

  //----------------------------------------------------------------
  // read_plain_from_file
  // Read the plaintext from the file.
  //----------------------------------------------------------------
  integer i;
  parameter PLAINTEXT_NUMBER=2;
  reg [127 : 0] nist_plaintexts [PLAINTEXT_NUMBER:1];
  initial $readmemh("./plaintext.txt",nist_plaintexts);
  
  //----------------------------------------------------------------
  // aes_core_test
  // The main test functionality.
  //----------------------------------------------------------------
  initial
    begin : aes_core_test
  
      reg [127 : 0] nist_aes128_key;
      nist_aes128_key = 256'h2b7e151628aed2a6abf7158809cf4f3c;
      
      $display("   -= Testbench for aes core started =-");
      $display("     ================================");
      $display("");
    
      init_sim();
      reset_dut();

      $display("ECB 128 bit key tests");
      $display("---------------------");
      for (i=1; i<=PLAINTEXT_NUMBER; i=i+1)
	    begin
            run_one_encryption(nist_aes128_key, nist_plaintexts[i]);
	    end

      $display("");
      $display("*** AES core simulation done. ***");
      $finish;
    end // aes_core_test

endmodule

//======================================================================
// EOF tb_aes_core.v
//======================================================================