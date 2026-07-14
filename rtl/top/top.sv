//==============================================================
// Module      : fft_top
// Project     : Streaming FFT Accelerator
// Author      : Shreenidhi Inamadar
//
// Description:
// Top-level module for simplified Streaming FFT Accelerator
//
// Architecture:
//
//      Input
//        │
//        ▼
//   +-------------+
//   | Controller  |
//   +-------------+
//        │
//        ▼
//    FFT Stage 1
//        │
//        ▼
//    FFT Stage 2
//        │
//        ▼
//    FFT Stage 3
//        │
//        ▼
//      Output
//
//==============================================================

module fft_top #(
    parameter WIDTH = 16,
    parameter DEPTH = 16,
    parameter N = 8
)(
    input logic clk,
    input logic rst_n,
    input logic start,

    //-----------------------------
    // Input Stream
    //-----------------------------

    input logic signed [WIDTH-1:0] in_real,
    input logic signed [WIDTH-1:0] in_imag,

    //-----------------------------
    // Output Stream
    //-----------------------------

    output logic signed [WIDTH-1:0] out_real,
    output logic signed [WIDTH-1:0] out_imag,

    //-----------------------------
    // Status
    //-----------------------------

    output logic busy,
    output logic done
);

    //----------------------------------------------------------
    // Controller Signals
    //----------------------------------------------------------

    logic fifo_wr_en;
    logic fifo_rd_en;

    logic butterfly_en;
    logic pipeline_en;

    logic feedback_sel;

    logic valid;

    logic [$clog2($clog2(N))-1:0] stage;

    //----------------------------------------------------------
    // Stage Connections
    //----------------------------------------------------------

    logic signed [WIDTH-1:0] stage1_real;
    logic signed [WIDTH-1:0] stage1_imag;

    logic signed [WIDTH-1:0] stage2_real;
    logic signed [WIDTH-1:0] stage2_imag;

    logic signed [WIDTH-1:0] stage3_real;
    logic signed [WIDTH-1:0] stage3_imag;

    //----------------------------------------------------------
    // Example Twiddle Factors
    //----------------------------------------------------------
    // Replace these with a Twiddle ROM later

    localparam signed [WIDTH-1:0] TW1_REAL = 16'sd32767;
    localparam signed [WIDTH-1:0] TW1_IMAG = 16'sd0;

    localparam signed [WIDTH-1:0] TW2_REAL = 16'sd23170;
    localparam signed [WIDTH-1:0] TW2_IMAG = -16'sd23170;

    localparam signed [WIDTH-1:0] TW3_REAL = 16'sd0;
    localparam signed [WIDTH-1:0] TW3_IMAG = -16'sd32767;

    //----------------------------------------------------------
    // Controller
    //----------------------------------------------------------

    fft_controller #(
        .N(N)
    ) u_controller (

        .clk(clk),
        .rst_n(rst_n),
        .start(start),

        .busy(busy),
        .done(done),
        .valid(valid),

        .fifo_wr_en(fifo_wr_en),
        .fifo_rd_en(fifo_rd_en),

        .butterfly_en(butterfly_en),
        .pipeline_en(pipeline_en),

        .feedback_sel(feedback_sel),

        .stage(stage)

    );

    //----------------------------------------------------------
    // FFT Stage 1
    //----------------------------------------------------------

    fft_stage #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) u_stage1 (

        .clk(clk),
        .rst_n(rst_n),

        .fifo_wr_en(fifo_wr_en),
        .fifo_rd_en(fifo_rd_en),

        .butterfly_en(butterfly_en),
        .pipeline_en(pipeline_en),

        .feedback_sel(feedback_sel),

        .in_real(in_real),
        .in_imag(in_imag),

        .tw_real(TW1_REAL),
        .tw_imag(TW1_IMAG),

        .out_real(stage1_real),
        .out_imag(stage1_imag)

    );

    //----------------------------------------------------------
    // FFT Stage 2
    //----------------------------------------------------------

    fft_stage #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) u_stage2 (

        .clk(clk),
        .rst_n(rst_n),

        .fifo_wr_en(fifo_wr_en),
        .fifo_rd_en(fifo_rd_en),

        .butterfly_en(butterfly_en),
        .pipeline_en(pipeline_en),

        .feedback_sel(feedback_sel),

        .in_real(stage1_real),
        .in_imag(stage1_imag),

        .tw_real(TW2_REAL),
        .tw_imag(TW2_IMAG),

        .out_real(stage2_real),
        .out_imag(stage2_imag)

    );

    //----------------------------------------------------------
    // FFT Stage 3
    //----------------------------------------------------------

    fft_stage #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) u_stage3 (

        .clk(clk),
        .rst_n(rst_n),

        .fifo_wr_en(fifo_wr_en),
        .fifo_rd_en(fifo_rd_en),

        .butterfly_en(butterfly_en),
        .pipeline_en(pipeline_en),

        .feedback_sel(feedback_sel),

        .in_real(stage2_real),
        .in_imag(stage2_imag),

        .tw_real(TW3_REAL),
        .tw_imag(TW3_IMAG),

        .out_real(stage3_real),
        .out_imag(stage3_imag)

    );

    //----------------------------------------------------------
    // Final Output
    //----------------------------------------------------------

    assign out_real = stage3_real;
    assign out_imag = stage3_imag;

endmodule