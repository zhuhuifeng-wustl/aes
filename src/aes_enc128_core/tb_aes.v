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

            //    .encdec(tb_encdec),
               .init(tb_init),
               .next(tb_next),
               .ready(tb_ready),

            //    .key(tb_key),
            //    .keylen(tb_keylen),

               .block(tb_block),
               .result(tb_result),
               .result_valid(tb_result_valid)
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
     wait_valid();
   end
  endtask // run_one_encryption

  //----------------------------------------------------------------
  // ecb_mode_single_block_test()
  //
  // Perform ECB mode encryption or decryption single block test.
  //----------------------------------------------------------------
  task ecb_mode_single_block_test(input [7 : 0]   tc_number,
                                  input [127 : 0] key,
                                  input [127 : 0] block,
                                  input [127 : 0] expected);
   begin
     $display("*** TC %0d ECB mode test started.", tc_number);
    //  tc_ctr = tc_ctr + 1;

     // Init the cipher with the given key.
     tb_key = key;
     tb_init = 1;
     #(2 * CLK_PERIOD);
     tb_init = 0;
     wait_ready();

     $display("Key expansion done");
     $display("");

     // Perform encipher operation on the block.
     tb_block = block;
     tb_next = 1;
     #(2 * CLK_PERIOD);
     tb_next = 0;
     wait_ready();
     wait_valid();

     if (tb_result == expected)
       begin
         $display("*** TC %0d successful.", tc_number);
         $display("");
       end
     else
       begin
         $display("*** ERROR: TC %0d NOT successful.", tc_number);
         $display("Expected: 0x%032x", expected);
         $display("Got:      0x%032x", tb_result);
         $display("");

        //  error_ctr = error_ctr + 1;
       end
   end
  endtask // ecb_mode_single_block_test

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
//   initial
//     begin : aes_core_test
  
//       reg [127 : 0] nist_aes128_key;
//       nist_aes128_key = 256'h2b7e151628aed2a6abf7158809cf4f3c;
      
//       $display("   -= Testbench for aes core started =-");
//       $display("     ================================");
//       $display("");
    
//       init_sim();
//       reset_dut();

//     //   $display("ECB 128 bit key tests");
//       $display("---------------------");
//       for (i=1; i<=PLAINTEXT_NUMBER; i=i+1)
// 	    begin
//             run_one_encryption(nist_aes128_key, nist_plaintexts[i]);
// 	    end
      

//       $display("");
//       $display("*** AES core simulation done. ***");
//       $finish;
//     end // aes_core_test



  //----------------------------------------------------------------
  // aes_core_test
  // The main test functionality.
  //----------------------------------------------------------------
  initial
    begin : aes_core_test
      reg [127 : 0] nist_aes128_key;

      reg [127 : 0] nist_plaintext0;
      reg [127 : 0] nist_plaintext1;
      reg [127 : 0] nist_plaintext2;
      reg [127 : 0] nist_plaintext3;
  
      reg [127 : 0] nist_ecb_128_enc_expected0;
      reg [127 : 0] nist_ecb_128_enc_expected1;
      reg [127 : 0] nist_ecb_128_enc_expected2;
      reg [127 : 0] nist_ecb_128_enc_expected3;

      nist_aes128_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;

      nist_plaintext0 = 128'h6bc1bee22e409f96e93d7e117393172a;
      nist_plaintext1 = 128'hae2d8a571e03ac9c9eb76fac45af8e51;
      nist_plaintext2 = 128'h30c81c46a35ce411e5fbc1191a0a52ef;
      nist_plaintext3 = 128'hf69f2445df4f9b17ad2b417be66c3710;

      nist_ecb_128_enc_expected0 = 128'h3ad77bb40d7a3660a89ecaf32466ef97;
      nist_ecb_128_enc_expected1 = 128'hf5d3d58503b9699de785895a96fdbaaf;
      nist_ecb_128_enc_expected2 = 128'h43b1cd7f598ece23881b00e3ed030688;
      nist_ecb_128_enc_expected3 = 128'h7b0c785e27e8ad3f8223207104725dd4;


      $display("   -= Testbench for aes core started =-");
      $display("     ================================");
      $display("");
    
      init_sim();
      reset_dut();

      $display("ECB 128 bit key tests");
      $display("---------------------");
      ecb_mode_single_block_test(8'h01, nist_aes128_key, nist_plaintext0, nist_ecb_128_enc_expected0);
      ecb_mode_single_block_test(8'h02, nist_aes128_key, nist_plaintext1, nist_ecb_128_enc_expected1);
      ecb_mode_single_block_test(8'h03, nist_aes128_key, nist_plaintext2, nist_ecb_128_enc_expected2);
      ecb_mode_single_block_test(8'h04, nist_aes128_key, nist_plaintext3, nist_ecb_128_enc_expected3);

     
      $display("");
      $display("*** AES core simulation done. ***");
      $finish;
    end
endmodule
//======================================================================
// EOF tb_aes_core.v
//======================================================================