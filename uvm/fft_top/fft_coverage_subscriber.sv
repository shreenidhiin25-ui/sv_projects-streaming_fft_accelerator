//==============================================================
// Class       : fft_coverage_subscriber
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Advanced concept -- uvm_subscriber for functional coverage:
// rather than sampling a covergroup inline in a monitor or
// testbench (as tb/fft_top_tb.sv and complex_adder_tb.sv do),
// coverage is its own component subscribing to the input
// monitor's analysis port. This keeps "did we see enough
// stimulus variety" fully decoupled from "did the DUT compute
// the right answer" (the scoreboard's job).
//==============================================================

class fft_coverage_subscriber extends uvm_subscriber #(fft_input_transaction);

    `uvm_component_utils(fft_coverage_subscriber)

    fft_input_transaction tr;

    covergroup cg;

        option.per_instance = 1;

        // First sample of each transaction is enough to get a
        // meaningful spread across positive/negative/zero without
        // an explosion of cross bins over all N samples.
        coverpoint tr.in_real[0] {
            bins positive = {[1:32767]};
            bins negative = {[-32768:-1]};
            bins zero     = {0};
        }

        coverpoint tr.in_imag[0] {
            bins positive = {[1:32767]};
            bins negative = {[-32768:-1]};
            bins zero     = {0};
        }

    endgroup

    function new(string name = "fft_coverage_subscriber", uvm_component parent = null);
        super.new(name, parent);
        cg = new();
    endfunction

    //----------------------------------------------------------
    // uvm_subscriber callback
    //----------------------------------------------------------

    function void write(fft_input_transaction t);
        tr = t;
        cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info("fft_coverage_subscriber",
            $sformatf("Functional coverage = %0.2f%%", cg.get_coverage()),
            UVM_LOW)

    endfunction

endclass
