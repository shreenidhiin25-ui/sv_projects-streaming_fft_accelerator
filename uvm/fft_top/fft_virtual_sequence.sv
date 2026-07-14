//==============================================================
// Class       : fft_virtual_sequence
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Advanced concept -- virtual sequence: the top-level test
// starts THIS sequence on the virtual sequencer, never touching
// a physical sequencer directly. `uvm_declare_p_sequencer` binds
// `p_sequencer` to fft_virtual_sequencer, giving typed access to
// input_sequencer so this sequence can start the real,
// item-generating fft_input_sequence on it.
//==============================================================

class fft_virtual_sequence extends uvm_sequence #(uvm_sequence_item);

    `uvm_object_utils(fft_virtual_sequence)
    `uvm_declare_p_sequencer(fft_virtual_sequencer)

    int num_transactions = 5;

    function new(string name = "fft_virtual_sequence");
        super.new(name);
    endfunction

    task body();

        fft_input_sequence in_seq;

        in_seq = fft_input_sequence::type_id::create("in_seq");
        in_seq.num_transactions = num_transactions;

        in_seq.start(p_sequencer.input_sequencer);

    endtask

endclass
