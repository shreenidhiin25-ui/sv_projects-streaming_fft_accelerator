//========================================================
// Module : complex_subtractor
// Project : Streaming FFT Accelerator
// Author : Shreenidhi Inamadar
//
// Description:
//
// Performs complex subtraction.
//
// P = A - B
//
//========================================================

module complex_subtractor #(
    parameter WIDTH =16
)
(
    input logic signed [WIDTH-1:0] a_real,
    input logic signed [WIDTH-1:0] a_imag,
    input logic signed [WIDTH-1:0] b_real,
    input logic signed [WIDTH-1:0] b_imag,
    output logic signed [WIDTH-1:0] q_real,
    output logic signed [WIDTH-1:0] q_imag
);

 assign q_real = a_real-b_real;
 assign q_imag = a_imag-b_imag;

endmodule 