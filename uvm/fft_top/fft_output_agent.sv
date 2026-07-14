//==============================================================
// Class       : fft_output_agent
// Project     : Streaming FFT Accelerator (UVM environment)
//
// PASSIVE agent: monitor only, deliberately with no driver or
// sequencer fields at all. A passive agent that structurally
// cannot drive is the clearest way to express "observe-only" --
// contrast with fft_input_agent, which can be either role and
// picks at build time.
//==============================================================

class fft_output_agent extends uvm_agent;

    `uvm_component_utils(fft_output_agent)

    fft_output_monitor monitor;

    function new(string name = "fft_output_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        monitor = fft_output_monitor::type_id::create("monitor", this);

    endfunction

endclass
