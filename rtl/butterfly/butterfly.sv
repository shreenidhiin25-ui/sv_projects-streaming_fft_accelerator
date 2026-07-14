//==============================================================
// Module      : butterfly
// Project     : Streaming FFT Accelerator
// Author      : Shreenidhi Inamadar
//
// Description:
//
// Radix-2 butterfly, built from the existing complex_adder /
// complex_subtractor / twiddle_multiplier blocks.
//
//   P = A + B                (sum, no twiddle)
//   Q = W * (A - B)          (twiddled difference)
//
//==============================================================

module butterfly #(
    parameter WIDTH = 16
)(
    input  logic signed [WIDTH-1:0] a_real,
    input  logic signed [WIDTH-1:0] a_imag,
    input  logic signed [WIDTH-1:0] b_real,
    input  logic signed [WIDTH-1:0] b_imag,

    input  logic signed [WIDTH-1:0] tw_real,
    input  logic signed [WIDTH-1:0] tw_imag,

    output logic signed [WIDTH-1:0] p_real,
    output logic signed [WIDTH-1:0] p_imag,

    output logic signed [WIDTH-1:0] q_real,
    output logic signed [WIDTH-1:0] q_imag
);

    //----------------------------------------------------------
    // A - B (fed into the twiddle multiplier below)
    //----------------------------------------------------------

    logic signed [WIDTH-1:0] diff_real;
    logic signed [WIDTH-1:0] diff_imag;

    //----------------------------------------------------------
    // P = A + B
    //----------------------------------------------------------

    complex_adder #(
        .WIDTH(WIDTH)
    ) u_add (
        .a_real(a_real),
        .a_imag(a_imag),
        .b_real(b_real),
        .b_imag(b_imag),
        .p_real(p_real),
        .p_imag(p_imag)
    );

    //----------------------------------------------------------
    // A - B
    //----------------------------------------------------------

    complex_subtractor #(
        .WIDTH(WIDTH)
    ) u_sub (
        .a_real(a_real),
        .a_imag(a_imag),
        .b_real(b_real),
        .b_imag(b_imag),
        .q_real(diff_real),
        .q_imag(diff_imag)
    );

    //----------------------------------------------------------
    // Q = W * (A - B)
    //----------------------------------------------------------

    twiddle_multiplier #(
        .WIDTH(WIDTH)
    ) u_tw (
        .b_real(diff_real),
        .b_imag(diff_imag),
        .tw_real(tw_real),
        .tw_imag(tw_imag),
        .wb_real(q_real),
        .wb_imag(q_imag)
    );

endmodule
