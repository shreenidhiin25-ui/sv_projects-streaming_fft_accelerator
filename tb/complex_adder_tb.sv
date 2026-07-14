`timescale 1ns/1ps

module complex_adder_tb;

parameter WIDTH = 16;

//=====================================================
// Testbench Signals
//=====================================================

logic signed [WIDTH-1:0] a_real;
logic signed [WIDTH-1:0] a_imag;
logic signed [WIDTH-1:0] b_real;
logic signed [WIDTH-1:0] b_imag;

logic signed [WIDTH-1:0] p_real;
logic signed [WIDTH-1:0] p_imag;

//=====================================================
// DUT
//=====================================================

complex_adder #(
    .WIDTH(WIDTH)
) dut (
    .a_real(a_real),
    .a_imag(a_imag),
    .b_real(b_real),
    .b_imag(b_imag),
    .p_real(p_real),
    .p_imag(p_imag)
);

//=====================================================
// Reference Model
//=====================================================

function automatic logic signed [WIDTH-1:0] expected_real(

    input logic signed [WIDTH-1:0] a,
    input logic signed [WIDTH-1:0] b

);

    expected_real = a + b;

endfunction


function automatic logic signed [WIDTH-1:0] expected_imag(

    input logic signed [WIDTH-1:0] a,
    input logic signed [WIDTH-1:0] b

);

    expected_imag = a + b;

endfunction

//=====================================================
// Immediate Assertions
//=====================================================

always_comb begin

    // Avoid checking when signals are X
    if (!$isunknown({a_real,a_imag,b_real,b_imag,p_real,p_imag})) begin

        assert (p_real == a_real + b_real)
        else
            $error("ASSERTION FAILED : p_real mismatch");

        assert (p_imag == a_imag + b_imag)
        else
            $error("ASSERTION FAILED : p_imag mismatch");

    end

end

//=====================================================
// Functional Coverage
//=====================================================

covergroup cg;

    coverpoint a_real {
        bins positive = {[1:32767]};
        bins negative = {[-32768:-1]};
        bins zero     = {0};
    }

    coverpoint a_imag {
        bins positive = {[1:32767]};
        bins negative = {[-32768:-1]};
        bins zero     = {0};
    }

    coverpoint b_real {
        bins positive = {[1:32767]};
        bins negative = {[-32768:-1]};
        bins zero     = {0};
    }

    coverpoint b_imag {
        bins positive = {[1:32767]};
        bins negative = {[-32768:-1]};
        bins zero     = {0};
    }
    

endgroup

// Create coverage object ONLY ONCE
cg coverage = new();

//=====================================================
// Reusable Test Task
//=====================================================

task automatic test_case(

    input logic signed [WIDTH-1:0] in_a_real,
    input logic signed [WIDTH-1:0] in_a_imag,
    input logic signed [WIDTH-1:0] in_b_real,
    input logic signed [WIDTH-1:0] in_b_imag

);

logic signed [WIDTH-1:0] exp_real;
logic signed [WIDTH-1:0] exp_imag;

begin

    //-------------------------------------------------
    // Apply Inputs
    //-------------------------------------------------

    a_real = in_a_real;
    a_imag = in_a_imag;
    b_real = in_b_real;
    b_imag = in_b_imag;

    //-------------------------------------------------
    // Reference Model
    //-------------------------------------------------

    exp_real = expected_real(in_a_real,in_b_real);
    exp_imag = expected_imag(in_a_imag,in_b_imag);

    //-------------------------------------------------
    // Wait for DUT
    //-------------------------------------------------

    #10;

    //-------------------------------------------------
    // Sample Coverage
    //-------------------------------------------------

    coverage.sample();

    //-------------------------------------------------
    // Compare
    //-------------------------------------------------

    if ((p_real == exp_real) && (p_imag == exp_imag))
    begin

        $display("PASS : A=(%0d,%0d) B=(%0d,%0d)",
                 a_real,a_imag,
                 b_real,b_imag);

    end

    else
    begin

        $display("----------------------------------");
        $display("FAIL");

        $display("Input A   : (%0d,%0d)",a_real,a_imag);
        $display("Input B   : (%0d,%0d)",b_real,b_imag);

        $display("Expected  : (%0d,%0d)",exp_real,exp_imag);
        $display("Actual    : (%0d,%0d)",p_real,p_imag);

        $display("----------------------------------");

    end

end

endtask

//=====================================================
// Testcases
//=====================================================

initial begin

    // Directed Tests

    test_case(2,3,4,5);
    test_case(-2,-3,-4,-5);
    test_case(2,3,-4,-5);
    test_case(-2,-3,4,5);
    test_case(0,0,0,0);
    test_case(32767,32767,0,0);
    test_case(-32768,-32768,0,0);
    test_case(32767,32767,1,1);
    test_case(-32768,-32768,-1,-1);

    // Random Tests

    repeat(100)
    begin
        test_case($random,$random,$random,$random);
    end

    $display("--------------------------------");
    $display("Simulation Completed");
    $display("--------------------------------");

    $finish;

end

endmodule