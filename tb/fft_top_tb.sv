`timescale 1ns/1ps

//==============================================================
// Testbench    : fft_top_tb
// Project      : Streaming FFT Accelerator
//
// Protocol under test (fixed-latency streaming, 1 sample/cycle):
//   pulse start (1 cycle) -> drive N samples, one per clock,
//   during LOAD -> wait through UNLOAD/COMPUTE -> capture N
//   output samples gated on out_valid during DRAIN -> done
//   pulses for 1 cycle.
//
// Reference model mirrors the ACTUAL RTL structure (not a
// textbook FFT formula): fft_stage is unchanged in this project
// -- every stage pairs index i with i+N/2 and uses ONE shared
// twiddle constant per stage. Stages 2/3 are therefore NOT a
// mathematically exact FFT recursion; this is a known, accepted
// simplification (see rtl/top/top.sv header). The self-check
// below is bit-exact against what the RTL is actually built to
// compute, not against a canonical DFT.
//==============================================================

module fft_top_tb;

parameter WIDTH = 16;
parameter DEPTH = 16;
parameter N     = 8;

//=====================================================
// DUT Signals
//=====================================================

logic clk;
logic rst_n;
logic start;

logic signed [WIDTH-1:0] in_real;
logic signed [WIDTH-1:0] in_imag;

logic signed [WIDTH-1:0] out_real;
logic signed [WIDTH-1:0] out_imag;

logic busy;
logic done;
logic out_valid;

fft_top #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH),
    .N(N)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .in_real(in_real),
    .in_imag(in_imag),
    .out_real(out_real),
    .out_imag(out_imag),
    .busy(busy),
    .done(done),
    .out_valid(out_valid)
);

//=====================================================
// Clock Generation
//=====================================================

initial
    clk = 0;

always #5 clk = ~clk;

//=====================================================
// Waveform Dump
//=====================================================

initial begin
    $dumpfile("fft_top_tb.vcd");
    $dumpvars(0, fft_top_tb);
end

//=====================================================
// Reset Task
//=====================================================

task automatic reset();
begin
    rst_n   = 1'b0;
    start   = 1'b0;
    in_real = '0;
    in_imag = '0;
    repeat (3) @(posedge clk);
    rst_n   = 1'b1;
    repeat (2) @(posedge clk);
end
endtask

//=====================================================
// Functional Coverage
//=====================================================

covergroup cg;

    coverpoint in_real {
        bins positive = {[1:32767]};
        bins negative = {[-32768:-1]};
        bins zero     = {0};
    }

    coverpoint in_imag {
        bins positive = {[1:32767]};
        bins negative = {[-32768:-1]};
        bins zero     = {0};
    }

endgroup

cg coverage = new();

//=====================================================
// Reusable Sample-Send Task
//
// Drives one sample so it is stable across the clock
// edge on which the DUT's input FIFOs capture it, then
// returns after that edge.
//=====================================================

task automatic send_sample(
    input logic signed [WIDTH-1:0] re,
    input logic signed [WIDTH-1:0] im
);
begin
    in_real <= re;
    in_imag <= im;
    coverage.sample();
    @(posedge clk);
end
endtask

//=====================================================
// Reference Model
//
// Mirrors butterfly.sv / fft_stage.sv / top.sv exactly:
// same bit widths, same >>> (WIDTH-1) truncation, same
// "pair i with i+N/2, one twiddle per stage" structure.
//=====================================================

localparam signed [WIDTH-1:0] TW1_REAL = 16'sd32767;
localparam signed [WIDTH-1:0] TW1_IMAG = 16'sd0;

localparam signed [WIDTH-1:0] TW2_REAL = 16'sd23170;
localparam signed [WIDTH-1:0] TW2_IMAG = -16'sd23170;

localparam signed [WIDTH-1:0] TW3_REAL = 16'sd0;
localparam signed [WIDTH-1:0] TW3_IMAG = -16'sd32767;

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

        for (i = 0; i < N/2; i = i + 1)
        begin

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

//=====================================================
// Protocol Assertions
//=====================================================

// busy and done are never both asserted together
property p_busy_done_exclusive;
    @(posedge clk) disable iff (!rst_n)
    !(busy && done);
endproperty

assert property (p_busy_done_exclusive)
else $error("ASSERTION FAILED : busy and done asserted simultaneously");

// out_valid must never rise while the DUT is idle
property p_valid_needs_busy;
    @(posedge clk) disable iff (!rst_n)
    out_valid |-> busy;
endproperty

assert property (p_valid_needs_busy)
else $error("ASSERTION FAILED : out_valid asserted while !busy");

// done must be a single-cycle pulse (this FSM always drops
// start before DONE is reached, so done never stays high
// for more than one cycle)
property p_done_pulse;
    @(posedge clk) disable iff (!rst_n)
    done |=> !done;
endproperty

assert property (p_done_pulse)
else $error("ASSERTION FAILED : done stayed high for more than one cycle");

//=====================================================
// Continuous X/Z Monitor
//=====================================================

always_ff @(posedge clk) begin
    if (rst_n) begin
        if ($isunknown({out_real, out_imag, busy, done, out_valid}))
            $error("ASSERTION FAILED : X/Z detected on DUT outputs");
    end
end

//=====================================================
// Transaction Task
//
// Pulses start, streams N samples in, waits through
// UNLOAD/COMPUTE, captures N output samples gated on
// out_valid, then waits for done. Bounded by a watchdog
// so a protocol bug hangs the test instead of the sim.
//=====================================================

task automatic run_transaction(

    ref logic signed [WIDTH-1:0] in_re  [0:N-1],
    ref logic signed [WIDTH-1:0] in_im  [0:N-1],
    ref logic signed [WIDTH-1:0] out_re [0:N-1],
    ref logic signed [WIDTH-1:0] out_im [0:N-1]
);

    int i;
    int watchdog;

    begin

        @(posedge clk);
        start <= 1'b1;
        @(posedge clk);
        start <= 1'b0;

        for (i = 0; i < N; i = i + 1)
            send_sample(in_re[i], in_im[i]);

        i = 0;
        watchdog = 0;

        while (i < N) begin

            @(posedge clk);

            if (out_valid) begin
                out_re[i] = out_real;
                out_im[i] = out_imag;
                i = i + 1;
            end

            watchdog = watchdog + 1;
            if (watchdog > 200) begin
                $error("WATCHDOG : timed out waiting for out_valid");
                i = N;
            end

        end

        watchdog = 0;
        while (!done && watchdog < 50) begin
            @(posedge clk);
            watchdog = watchdog + 1;
        end

        if (!done)
            $error("WATCHDOG : timed out waiting for done");

        @(posedge clk); // let DONE -> IDLE settle before next transaction

    end

endtask

//=====================================================
// Compare + Report
//=====================================================

int pass_count;
int fail_count;

task automatic check_transaction(

    input string name,
    ref logic signed [WIDTH-1:0] in_re   [0:N-1],
    ref logic signed [WIDTH-1:0] in_im   [0:N-1],
    ref logic signed [WIDTH-1:0] out_re  [0:N-1],
    ref logic signed [WIDTH-1:0] out_im  [0:N-1]
);

    logic signed [WIDTH-1:0] exp_re [0:N-1];
    logic signed [WIDTH-1:0] exp_im [0:N-1];
    int i;
    bit ok;

    begin

        fft_ref(in_re, in_im, exp_re, exp_im);

        ok = 1'b1;

        for (i = 0; i < N; i = i + 1) begin
            if (out_re[i] !== exp_re[i] || out_im[i] !== exp_im[i]) begin
                ok = 1'b0;
                $display("----------------------------------");
                $display("FAIL [%s] index %0d", name, i);
                $display("Expected : (%0d,%0d)", exp_re[i], exp_im[i]);
                $display("Actual   : (%0d,%0d)", out_re[i], out_im[i]);
                $display("----------------------------------");
            end
        end

        if (ok) begin
            $display("PASS [%s]", name);
            pass_count = pass_count + 1;
        end else begin
            fail_count = fail_count + 1;
        end

    end

endtask

//=====================================================
// Testcases
//=====================================================

logic signed [WIDTH-1:0] in_re  [0:N-1];
logic signed [WIDTH-1:0] in_im  [0:N-1];
logic signed [WIDTH-1:0] out_re [0:N-1];
logic signed [WIDTH-1:0] out_im [0:N-1];

int t;

initial begin

    pass_count = 0;
    fail_count = 0;

    reset();

    //-------------------------------------------------
    // Directed: impulse (sample 0 = 1, rest 0)
    //-------------------------------------------------

    in_re[0] = 16'sd1;
    in_im[0] = 16'sd0;
    for (t = 1; t < N; t = t + 1) begin
        in_re[t] = 16'sd0;
        in_im[t] = 16'sd0;
    end

    run_transaction(in_re, in_im, out_re, out_im);
    check_transaction("impulse", in_re, in_im, out_re, out_im);

    //-------------------------------------------------
    // Directed: small DC (same value on every sample,
    // kept small to avoid 16-bit wraparound obscuring
    // the check -- reference model uses identical
    // wraparound arithmetic either way)
    //-------------------------------------------------

    for (t = 0; t < N; t = t + 1) begin
        in_re[t] = 16'sd100;
        in_im[t] = 16'sd0;
    end

    run_transaction(in_re, in_im, out_re, out_im);
    check_transaction("small DC", in_re, in_im, out_re, out_im);

    //-------------------------------------------------
    // Directed: extreme alternating values
    //-------------------------------------------------

    for (t = 0; t < N; t = t + 1) begin
        in_re[t] = (t % 2) ? 16'sd32767 : -16'sd32768;
        in_im[t] = (t % 2) ? -16'sd32768 : 16'sd32767;
    end

    run_transaction(in_re, in_im, out_re, out_im);
    check_transaction("extreme values", in_re, in_im, out_re, out_im);

    //-------------------------------------------------
    // Randomized
    //-------------------------------------------------

    for (t = 0; t < 20; t = t + 1) begin

        int k;
        for (k = 0; k < N; k = k + 1) begin
            in_re[k] = $random;
            in_im[k] = $random;
        end

        run_transaction(in_re, in_im, out_re, out_im);
        check_transaction($sformatf("random_%0d", t), in_re, in_im, out_re, out_im);

    end

    //-------------------------------------------------
    // Summary
    //-------------------------------------------------

    $display("--------------------------------");
    $display("Simulation Completed");
    $display("PASS : %0d", pass_count);
    $display("FAIL : %0d", fail_count);
    $display("--------------------------------");

    $finish;

end

endmodule
