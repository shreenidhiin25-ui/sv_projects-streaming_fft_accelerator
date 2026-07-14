//==============================================================
// Class       : fft_virtual_sequencer
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Advanced concept -- virtual sequencer: owns no seq_item_export
// of its own and drives no interface directly. It exists purely
// to hold handles to the PHYSICAL sequencers in the env so that
// a virtual sequence has one place to reach into any agent it
// needs to coordinate. With a single active agent this looks
// like overhead, but the pattern is what lets a virtual sequence
// scale to coordinating multiple agents without every sequence
// needing direct handles into env internals.
//==============================================================

class fft_virtual_sequencer extends uvm_sequencer;

    `uvm_component_utils(fft_virtual_sequencer)

    uvm_sequencer #(fft_input_transaction) input_sequencer;

    function new(string name = "fft_virtual_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass
