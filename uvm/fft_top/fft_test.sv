//==============================================================
// Class       : fft_test
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Builds the env and runs fft_virtual_sequence on the env's
// virtual sequencer (never touching a physical sequencer
// directly -- see fft_virtual_sequence.sv).
//
// Objection handling: raise_objection/drop_objection bracket
// run_phase so the simulation doesn't end before the sequence
// (and the transactions still draining through the scoreboard)
// finish.
//==============================================================

class fft_test extends uvm_test;

    `uvm_component_utils(fft_test)

    fft_env              env;
    fft_virtual_sequence vseq;

    function new(string name = "fft_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        env = fft_env::type_id::create("env", this);

    endfunction

    task run_phase(uvm_phase phase);

        phase.raise_objection(this, "fft_virtual_sequence running");

        vseq = fft_virtual_sequence::type_id::create("vseq");
        vseq.num_transactions = 5;

        vseq.start(env.v_sequencer);

        // Small drain margin: the passive output agent's capture
        // (gated on out_valid/DRAIN) can trail slightly behind
        // the driver observing `done` for the very last
        // transaction it drove -- give the scoreboard time to
        // pull the final pair out of both TLM FIFOs before the
        // objection drops.
        #50;

        phase.drop_objection(this, "fft_virtual_sequence complete");

    endtask

endclass
