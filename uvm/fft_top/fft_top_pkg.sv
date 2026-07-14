//==============================================================
// Package     : fft_top_pkg
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Bundles the whole environment into one compilable unit in
// dependency order (transactions -> sequences/driver/monitor ->
// agents -> virtual sequencer/sequence -> predictor -> scoreboard
// -> coverage -> env -> test). This is a deliberate structural
// step up from complex_adder's uvm folder (loose files relying
// on implicit compile order) -- for a "production-style" env,
// a package is the standard way to make compile order explicit
// and the whole thing importable with a single statement.
//
// fft_top_if.sv is NOT included here: interfaces are compiled
// at $unit/compilation-unit scope, not inside packages, so it
// stays a separate file compiled before this package (see the
// filelist ordering note in fft_top_top.sv).
//==============================================================

`ifndef FFT_TOP_PKG_SV
`define FFT_TOP_PKG_SV

package fft_top_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "fft_input_transaction.sv"
    `include "fft_output_transaction.sv"

    `include "fft_input_sequence.sv"
    `include "fft_input_driver.sv"
    `include "fft_input_monitor.sv"
    `include "fft_input_agent.sv"

    `include "fft_output_monitor.sv"
    `include "fft_output_agent.sv"

    `include "fft_virtual_sequencer.sv"
    `include "fft_virtual_sequence.sv"

    `include "fft_predictor.sv"
    `include "fft_scoreboard.sv"
    `include "fft_coverage_subscriber.sv"

    `include "fft_env.sv"
    `include "fft_test.sv"

endpackage

`endif
