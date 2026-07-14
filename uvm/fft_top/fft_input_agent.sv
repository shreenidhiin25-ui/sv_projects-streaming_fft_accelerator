//==============================================================
// Class       : fft_input_agent
// Project     : Streaming FFT Accelerator (UVM environment)
//
// ACTIVE agent: owns a driver, a sequencer, and a monitor.
//
// Advanced concept -- configurable active/passive: real agent
// classes are usually written so the SAME class can run active
// (drives + monitors) or passive (monitors only), decided at
// elaboration time via uvm_config_db rather than hardcoded, so
// the class is reusable across testbenches that reuse this DUT
// as a sub-block. This project always runs it ACTIVE (it's the
// only way to get stimulus into fft_top), but the mechanism is
// implemented for real, not stubbed.
//==============================================================

class fft_input_agent extends uvm_agent;

    `uvm_component_utils(fft_input_agent)

    // NOTE: `is_active` itself is NOT redeclared here -- uvm_agent
    // already provides it as a `protected` field (default
    // UVM_ACTIVE) with a get_is_active() accessor. Declaring a
    // same-named field in this subclass would silently SHADOW the
    // base class's field: get_is_active() would keep returning the
    // base class's copy while this class checked its own, so any
    // config_db override below would silently fail to take effect
    // through the accessor. Using the inherited protected field
    // directly avoids that trap.

    fft_input_driver                       driver;
    fft_input_monitor                      monitor;
    uvm_sequencer #(fft_input_transaction) sequencer;

    function new(string name = "fft_input_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Config Database: look up whether this instance should
        // be active or passive. Falls back to the UVM_ACTIVE
        // default above if nothing was set.
        void'(uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active));

        monitor = fft_input_monitor::type_id::create("monitor", this);

        if (is_active == UVM_ACTIVE) begin
            driver    = fft_input_driver::type_id::create("driver", this);
            sequencer = uvm_sequencer #(fft_input_transaction)::type_id::create("sequencer", this);
        end

    endfunction

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        if (is_active == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);

    endfunction

endclass
