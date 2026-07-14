//==============================================================
// Module      : twiddle_multiplier
// Project     : Streaming FFT Accelerator
// Author      : Shreenidhi Inamadar
//
// Description:
//
// Performs complex multiplication of the input B with the
// FFT twiddle factor W.
//
//              WB = W × B
//
// Equations:
//
// WB_real = (Br × Wr) - (Bi × Wi)
// WB_imag = (Br × Wi) + (Bi × Wr)
//
// Fixed Point Format:
// Inputs  : Q1.(WIDTH-1)
// Products: Q2.(2*WIDTH-2)
// Outputs : Q1.(WIDTH-1)
//
//==============================================================

module twiddle_multiplier #(
    parameter WIDTH = 16
)(
    input  logic signed [WIDTH-1:0] b_real,
    input  logic signed [WIDTH-1:0] b_imag,

    input  logic signed [WIDTH-1:0] tw_real,
    input  logic signed [WIDTH-1:0] tw_imag,

    output logic signed [WIDTH-1:0] wb_real,
    output logic signed [WIDTH-1:0] wb_imag
);

    //----------------------------------------------------------
    // Fixed-point Parameters
    //----------------------------------------------------------

    localparam FRACTION_BITS = WIDTH-1;

    //----------------------------------------------------------
    // Intermediate Multiplication Results (32-bit)
    //----------------------------------------------------------

    logic signed [2*WIDTH-1:0] mul_rr;
    logic signed [2*WIDTH-1:0] mul_ii;
    logic signed [2*WIDTH-1:0] mul_ri;
    logic signed [2*WIDTH-1:0] mul_ir;

    //----------------------------------------------------------
    // Intermediate Addition/Subtraction Results
    //----------------------------------------------------------

    logic signed [2*WIDTH-1:0] real_temp;
    logic signed [2*WIDTH-1:0] imag_temp;

    //----------------------------------------------------------
    // Complex Multiplication
    //----------------------------------------------------------

    assign mul_rr = b_real * tw_real;
    assign mul_ii = b_imag * tw_imag;
    assign mul_ri = b_real * tw_imag;
    assign mul_ir = b_imag * tw_real;

    //----------------------------------------------------------
    // Real and Imaginary Components
    //----------------------------------------------------------

    assign real_temp = mul_rr - mul_ii;
    assign imag_temp = mul_ri + mul_ir;

    //----------------------------------------------------------
    // Fixed-point Scaling
    //----------------------------------------------------------

    assign wb_real = real_temp >>> FRACTION_BITS;
    assign wb_imag = imag_temp >>> FRACTION_BITS;

endmodule