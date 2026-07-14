`timescale 1ns/1ps

//==============================================================
// Module      : top (fft_top_top.sv)
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Physical testbench top: clock/reset generation, DUT +
// interface instantiation, Configuration Database set for the
// virtual interface, and run_test().
//
// Compile order (typical filelist):
//   fft_top_if.sv          (interface, compilation-unit scope)
//   fft_top_pkg.sv          (`includes every class in the env)
//   fft_top_top.sv          (this file)
//   ... plus the DUT sources under rtl/
//==============================================================

import uvm_pkg::*;
`include "uvm_macros.svh"
import fft_top_pkg::*;

module top;

    //--------------------------------------------------
    // Clock
    //--------------------------------------------------

    logic clk;

    initial clk = 0;

    always #5 clk = ~clk;

    //--------------------------------------------------
    // Interface
    //--------------------------------------------------

    fft_top_if vif(.clk(clk));

    //--------------------------------------------------
    // Reset (physical-level concern, not sequence stimulus --
    // generated directly here rather than through a sequence)
    //--------------------------------------------------

    initial begin
        vif.rst_n = 1'b0;
        vif.start = 1'b0;
        vif.in_real = '0;
        vif.in_imag = '0;
        repeat (3) @(posedge clk);
        vif.rst_n = 1'b1;
    end

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    fft_top #(
        .WIDTH(16),
        .DEPTH(16),
        .N(8)
    ) dut (

        .clk(clk),
        .rst_n(vif.rst_n),
        .start(vif.start),

        .in_real(vif.in_real),
        .in_imag(vif.in_imag),

        .out_real(vif.out_real),
        .out_imag(vif.out_imag),

        .busy(vif.busy),
        .done(vif.done),
        .out_valid(vif.out_valid)

    );

    //--------------------------------------------------
    // UVM
    //--------------------------------------------------

    initial begin

        // Configuration Database: the one place the virtual
        // interface handle is published; every driver/monitor
        // looks it up by the same "vif" key in build_phase.
        uvm_config_db#(virtual fft_top_if)::set(
            null,
            "*",
            "vif",
            vif
        );

        run_test("fft_test");

    end

endmodule
