//==============================================================
// Module      : fft_stage
// Project     : Streaming FFT Accelerator
// Author      : Shreenidhi Inamadar
//
// Description:
// Parameterized FFT Stage
// Instantiates N/2 Butterfly Units
//
//==============================================================

module fft_stage #(
    parameter WIDTH = 16,
    parameter N = 8
)(
    input  logic signed [WIDTH-1:0] real_in [0:N-1],
    input  logic signed [WIDTH-1:0] imag_in [0:N-1],

    input  logic signed [WIDTH-1:0] tw_real [0:(N/2)-1],
    input  logic signed [WIDTH-1:0] tw_imag [0:(N/2)-1],

    output logic signed [WIDTH-1:0] real_out [0:N-1],
    output logic signed [WIDTH-1:0] imag_out [0:N-1]
);

localparam NUM_BUTTERFLIES = N/2;

genvar i;

generate

for(i=0;i<NUM_BUTTERFLIES;i=i+1)
begin : GEN_BUTTERFLY

    butterfly #(
        .WIDTH(WIDTH)
    ) u_butterfly (

        .a_real(real_in[i]),
        .a_imag(imag_in[i]),

        .b_real(real_in[i+NUM_BUTTERFLIES]),
        .b_imag(imag_in[i+NUM_BUTTERFLIES]),

        .tw_real(tw_real[i]),
        .tw_imag(tw_imag[i]),

        .p_real(real_out[i]),
        .p_imag(imag_out[i]),

        .q_real(real_out[i+NUM_BUTTERFLIES]),
        .q_imag(imag_out[i+NUM_BUTTERFLIES])

    );

end

endgenerate

endmodule