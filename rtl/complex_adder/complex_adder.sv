//========================================================
// Module : complex_adder
// Project : Streaming FFT Accelerator
// Author : Shreenidhi Inamadar
//
// Description:
//
// Performs complex addition.
//
// P = A + B
//
//========================================================

module complex_adder #(
    parameter WIDTH = 16
) (
    input  logic signed [WIDTH-1:0] a_real,
    input  logic signed [WIDTH-1:0] a_imag,
    input  logic signed [WIDTH-1:0] b_real,
    input  logic signed [WIDTH-1:0] b_imag,
    
    output  logic signed [WIDTH-1 :0] p_real,
    output  logic signed [WIDTH-1: 0] p_imag
);

    //Real part addition 
    assign p_real = a_real + b_real;
    //Imaginary part addition
    assign p_imag = a_imag + b_imag;

endmodule