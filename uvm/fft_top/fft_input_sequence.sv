//==============================================================
// Class       : fft_input_sequence
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Runs on the input agent's PHYSICAL sequencer. Generates
// num_transactions randomized fft_input_transaction items.
// Started by fft_virtual_sequence via p_sequencer.input_sequencer
// -- see fft_virtual_sequence.sv for why that indirection exists.
//==============================================================

class fft_input_sequence extends uvm_sequence #(fft_input_transaction);

    `uvm_object_utils(fft_input_sequence)

    int num_transactions = 5;

    function new(string name = "fft_input_sequence");
        super.new(name);
    endfunction

    task body();

        fft_input_transaction tr;
        int t;

        for (t = 0; t < num_transactions; t = t + 1) begin

            tr = fft_input_transaction::type_id::create("tr");

            start_item(tr);
            assert(tr.randomize())
            else `uvm_error("fft_input_sequence", "Randomization failed")
            finish_item(tr);

        end

    endtask

endclass
