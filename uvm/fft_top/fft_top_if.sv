//==============================================================
// Interface   : fft_top_if
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Bound to the fft_top DUT. Kept as a plain signal bundle
// (no clocking block) so driver/monitor timing is identical,
// statement-for-statement, to the plain tb/fft_top_tb.sv
// protocol that was hand-verified cycle-by-cycle -- see that
// file's header comment for the full timing derivation.
//==============================================================

interface fft_top_if (input logic clk);

    logic rst_n;
    logic start;

    logic signed [15:0] in_real;
    logic signed [15:0] in_imag;

    logic signed [15:0] out_real;
    logic signed [15:0] out_imag;

    logic busy;
    logic done;
    logic out_valid;

endinterface
