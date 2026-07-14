//==============================================================
// Class       : fft_predictor
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Advanced concept -- predictor: the reference model lives in
// its OWN component, separate from the scoreboard. It subscribes
// to the input monitor (uvm_subscriber#(T) gives it a built-in
// analysis_export + write() callback for free) and, for every
// captured input transaction, computes the expected output and
// publishes it on its own analysis port. The scoreboard never
// runs any FFT math itself -- it only compares two transactions
// handed to it. This separation is what lets the reference model
// be reused/tested independently of the comparison logic.
//
// The math here is bit-exact with butterfly.sv / fft_stage.sv /
// top.sv: same >>> (WIDTH-1) truncation, same "pair i with
// i+N/2, one shared twiddle per stage" structure (fft_stage.sv
// is intentionally unchanged in this project -- see rtl/top/top.sv
// header for why stages 2/3 are not a textbook FFT recursion).
// This is the SAME reference model already hand-verified against
// an impulse response in tb/fft_top_tb.sv.
//==============================================================

class fft_predictor extends uvm_subscriber #(fft_input_transaction);

    `uvm_component_utils(fft_predictor)

    localparam int WIDTH = 16;
    localparam int N     = 8;

    uvm_analysis_port #(fft_output_transaction) predicted_ap;

    localparam signed [WIDTH-1:0] TW1_REAL = 16'sd32767;
    localparam signed [WIDTH-1:0] TW1_IMAG = 16'sd0;

    localparam signed [WIDTH-1:0] TW2_REAL = 16'sd23170;
    localparam signed [WIDTH-1:0] TW2_IMAG = -16'sd23170;

    localparam signed [WIDTH-1:0] TW3_REAL = 16'sd0;
    localparam signed [WIDTH-1:0] TW3_IMAG = -16'sd32767;

    function new(string name = "fft_predictor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        predicted_ap = new("predicted_ap", this);
    endfunction

    //----------------------------------------------------------
    // Reference Model
    //----------------------------------------------------------

    function automatic void butterfly_ref(

        input  logic signed [WIDTH-1:0] a_real,
        input  logic signed [WIDTH-1:0] a_imag,
        input  logic signed [WIDTH-1:0] b_real,
        input  logic signed [WIDTH-1:0] b_imag,
        input  logic signed [WIDTH-1:0] w_real,
        input  logic signed [WIDTH-1:0] w_imag,

        output logic signed [WIDTH-1:0] p_real,
        output logic signed [WIDTH-1:0] p_imag,
        output logic signed [WIDTH-1:0] q_real,
        output logic signed [WIDTH-1:0] q_imag
    );

        logic signed [2*WIDTH-1:0] mul_rr, mul_ii, mul_ri, mul_ir;
        logic signed [2*WIDTH-1:0] real_temp, imag_temp;
        logic signed [WIDTH-1:0]   diff_real, diff_imag;

        begin

            p_real = a_real + b_real;
            p_imag = a_imag + b_imag;

            diff_real = a_real - b_real;
            diff_imag = a_imag - b_imag;

            mul_rr = diff_real * w_real;
            mul_ii = diff_imag * w_imag;
            mul_ri = diff_real * w_imag;
            mul_ir = diff_imag * w_real;

            real_temp = mul_rr - mul_ii;
            imag_temp = mul_ri + mul_ir;

            q_real = real_temp >>> (WIDTH-1);
            q_imag = imag_temp >>> (WIDTH-1);

        end

    endfunction

    function automatic void stage_ref(

        ref   logic signed [WIDTH-1:0] din_real  [0:N-1],
        ref   logic signed [WIDTH-1:0] din_imag  [0:N-1],
        input logic signed [WIDTH-1:0] w_real,
        input logic signed [WIDTH-1:0] w_imag,
        ref   logic signed [WIDTH-1:0] dout_real [0:N-1],
        ref   logic signed [WIDTH-1:0] dout_imag [0:N-1]
    );

        int i;
        logic signed [WIDTH-1:0] pr, pi, qr, qi;

        begin

            for (i = 0; i < N/2; i = i + 1) begin

                butterfly_ref(
                    din_real[i], din_imag[i],
                    din_real[i+N/2], din_imag[i+N/2],
                    w_real, w_imag,
                    pr, pi, qr, qi
                );

                dout_real[i]     = pr;
                dout_imag[i]     = pi;
                dout_real[i+N/2] = qr;
                dout_imag[i+N/2] = qi;

            end

        end

    endfunction

    function automatic void fft_ref(

        ref logic signed [WIDTH-1:0] in_real_arr  [0:N-1],
        ref logic signed [WIDTH-1:0] in_imag_arr  [0:N-1],
        ref logic signed [WIDTH-1:0] out_real_arr [0:N-1],
        ref logic signed [WIDTH-1:0] out_imag_arr [0:N-1]
    );

        logic signed [WIDTH-1:0] s1_real [0:N-1], s1_imag [0:N-1];
        logic signed [WIDTH-1:0] s2_real [0:N-1], s2_imag [0:N-1];

        begin

            stage_ref(in_real_arr, in_imag_arr, TW1_REAL, TW1_IMAG, s1_real, s1_imag);
            stage_ref(s1_real, s1_imag, TW2_REAL, TW2_IMAG, s2_real, s2_imag);
            stage_ref(s2_real, s2_imag, TW3_REAL, TW3_IMAG, out_real_arr, out_imag_arr);

        end

    endfunction

    //----------------------------------------------------------
    // uvm_subscriber callback: fired once per input transaction
    // captured by fft_input_monitor.
    //----------------------------------------------------------

    function void write(fft_input_transaction t);

        fft_output_transaction exp;

        exp = fft_output_transaction::type_id::create("exp");

        fft_ref(t.in_real, t.in_imag, exp.out_real, exp.out_imag);

        `uvm_info("fft_predictor",
                  $sformatf("Predicted %s", exp.convert2string()),
                  UVM_MEDIUM)

        predicted_ap.write(exp);

    endfunction

endclass
