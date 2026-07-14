//==============================================================
// Class       : fft_scoreboard
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Advanced concept -- uvm_tlm_analysis_fifo: rather than the
// scoreboard implementing uvm_analysis_imp/write() directly
// (as complex_adder_scoreboard.sv does), it owns two TLM FIFOs:
//   - expected_fifo, fed by fft_predictor
//   - actual_fifo,   fed by fft_output_monitor (passive agent)
// run_phase blocking-gets one item from each and compares them.
// Since fft_controller drives one transaction fully to
// completion (LOAD..DRAIN..DONE) before the driver accepts the
// next sequence item, transactions can never overlap, so simple
// in-order pairing across the two FIFOs is safe.
//
// Implements check_phase (fires if either FIFO still has
// unconsumed items at end of test -- a real protocol/count
// mismatch) and report_phase (final PASS/FAIL tally), completing
// the "proper UVM phases" requirement together with build/connect/run.
//==============================================================

class fft_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(fft_scoreboard)

    localparam int N = 8;

    uvm_tlm_analysis_fifo #(fft_output_transaction) expected_fifo;
    uvm_tlm_analysis_fifo #(fft_output_transaction) actual_fifo;

    int pass_count;
    int fail_count;

    function new(string name = "fft_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        expected_fifo = new("expected_fifo", this);
        actual_fifo   = new("actual_fifo", this);

        pass_count = 0;
        fail_count = 0;

    endfunction

    task run_phase(uvm_phase phase);

        fft_output_transaction exp_tr;
        fft_output_transaction act_tr;

        forever begin

            expected_fifo.get(exp_tr);
            actual_fifo.get(act_tr);

            compare(exp_tr, act_tr);

        end

    endtask

    function void compare(
        fft_output_transaction exp_tr,
        fft_output_transaction act_tr
    );

        int i;
        bit ok;

        begin

            ok = 1'b1;

            for (i = 0; i < N; i = i + 1) begin
                if (exp_tr.out_real[i] !== act_tr.out_real[i] ||
                    exp_tr.out_imag[i] !== act_tr.out_imag[i]) begin

                    ok = 1'b0;

                    `uvm_error("fft_scoreboard",
                        $sformatf("Mismatch at index %0d: expected (%0d,%0d), got (%0d,%0d)",
                                  i,
                                  exp_tr.out_real[i], exp_tr.out_imag[i],
                                  act_tr.out_real[i], act_tr.out_imag[i]))

                end
            end

            if (ok) begin
                `uvm_info("fft_scoreboard", "PASS", UVM_LOW)
                pass_count = pass_count + 1;
            end else begin
                fail_count = fail_count + 1;
            end

        end

    endfunction

    //----------------------------------------------------------
    // check_phase: runs once after run_phase ends. A non-empty
    // FIFO here means the predictor and output monitor produced
    // an unequal number of transactions -- a real bug, not a
    // data mismatch (which compare() already caught).
    //----------------------------------------------------------

    function void check_phase(uvm_phase phase);

        super.check_phase(phase);

        if (expected_fifo.used() != 0)
            `uvm_warning("fft_scoreboard",
                $sformatf("expected_fifo still has %0d unconsumed transaction(s)",
                          expected_fifo.used()))

        if (actual_fifo.used() != 0)
            `uvm_warning("fft_scoreboard",
                $sformatf("actual_fifo still has %0d unconsumed transaction(s)",
                          actual_fifo.used()))

    endfunction

    //----------------------------------------------------------
    // report_phase: final PASS/FAIL summary.
    //----------------------------------------------------------

    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info("fft_scoreboard",
            $sformatf("--------------------------------------------------"),
            UVM_LOW)

        `uvm_info("fft_scoreboard",
            $sformatf("SCOREBOARD SUMMARY : PASS=%0d  FAIL=%0d", pass_count, fail_count),
            UVM_LOW)

        `uvm_info("fft_scoreboard",
            $sformatf("--------------------------------------------------"),
            UVM_LOW)

    endfunction

endclass
