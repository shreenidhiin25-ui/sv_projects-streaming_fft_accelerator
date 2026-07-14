//==============================================================
// Class       : fft_input_driver
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Drives the fixed-latency streaming protocol implemented by
// fft_controller.sv: pulse start for one cycle, then hold each
// of N samples stable for exactly one clock so the DUT's input
// FIFOs capture it during LOAD. This is the SAME sequencing
// hand-verified in tb/fft_top_tb.sv's run_transaction task --
// see that file's header for the full cycle-by-cycle timing
// derivation (why sample[k] must be driven starting the edge
// after start is seen, one sample per edge thereafter).
//
// Waits for `done` before returning to the sequencer for the
// next item, so back-to-back transactions never overlap.
//==============================================================

class fft_input_driver extends uvm_driver #(fft_input_transaction);

    `uvm_component_utils(fft_input_driver)

    virtual fft_top_if vif;

    function new(string name = "fft_input_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //----------------------------------------------------------
    // Configuration Database: the virtual interface is set once
    // in the testbench top module (fft_top_top.sv) and looked
    // up here -- this is how UVM components reach real signals
    // without the interface being a constructor argument.
    //----------------------------------------------------------

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(virtual fft_top_if)::get(this, "", "vif", vif))
            `uvm_fatal("fft_input_driver", "Virtual interface 'vif' not set via uvm_config_db")

    endfunction

    task run_phase(uvm_phase phase);

        fft_input_transaction tr;

        forever begin

            seq_item_port.get_next_item(tr);

            `uvm_info("fft_input_driver",
                      $sformatf("Driving %s", tr.convert2string()),
                      UVM_MEDIUM)

            drive(tr);

            seq_item_port.item_done();

        end

    endtask

    task automatic drive(fft_input_transaction tr);

        int i;

        begin

            @(posedge vif.clk);
            vif.start <= 1'b1;

            @(posedge vif.clk);
            vif.start <= 1'b0;

            for (i = 0; i < fft_input_transaction::N; i = i + 1) begin
                vif.in_real <= tr.in_real[i];
                vif.in_imag <= tr.in_imag[i];
                @(posedge vif.clk);
            end

            while (!vif.done)
                @(posedge vif.clk);

        end

    endtask

endclass
