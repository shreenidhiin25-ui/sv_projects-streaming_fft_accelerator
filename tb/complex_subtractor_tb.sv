`timescale 1ns/1ps

module complex_subtractor_tb;
    parameter WIDTH =16;

    //testbench signals
    logic signed [WIDTH-1:0] a_real;
    logic signed [WIDTH-1:0] a_imag;
    logic signed [WIDTH-1:0] b_real;
    logic signed [WIDTH-1:0] b_imag;
    logic signed [WIDTH-1:0] q_real;
    logic signed [WIDTH-1:0] q_imag;

    //DUT
    complex_subtractor #(
        .WIDTH(WIDTH)
    ) dut (
        .a_real(a_real),
        .a_imag(a_imag),
        .b_real(b_real),
        .b_imag(b_imag),
        .q_real(q_real),
        .q_imag(q_imag
    ));


    // Reference model 
    function automatic logic signed [WIDTH-1:0] expected_real(
        input logic signed [WIDTH-1:0] a,
        input logic signed [WIDTH-1:0] b
    );
        expected_real = a - b;
    endfunction

    function automatic logic signed [WIDTH-1:0] expected_imag(
        input logic signed [WIDTH-1:0] a,
        input logic signed [WIDTH-1:0] b
    );
        expected_imag = a - b;
    endfunction

    // assertions 
    always_comb 
    begin 
        if(!$isunknown(a_real,b_real, a_imag,b_imag, q_real,q_imag))
        begin
            assert(q_real== expected_real)
            else $error("Assertion Failed: q_real mismatch");
            assert(q_imag== expected_imag)
            else $error("Assertion Failed: q_imag mismatch");
        end 
    end 

    //coverage 
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

cg coverage =new();

task automatic test_case(input logic signed [WIDTH-1:0] a_r, input logic signed [WIDTH-1:0] a_i, input logic signed [WIDTH-1:0] b_r, input logic signed [WIDTH-1:0] b_i);
    begin
        a_real = a_r;
        a_imag = a_i;
        b_real = b_r;
        b_imag = b_i;

        #10; // wait for 10 time units
    end

    exp_real = expected_real(a_real, b_real);
    exp_imag = expected_imag(a_imag, b_imag);

    #10;

    coverage.sample();


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

endtask 

initial begin
    test_case(4,5,2,3,2,2);
    test_case(-4,-5,-2,-3,-2,-2);
    test_case(4,5,-2,-3,6,8);
    test_case(-4,-5,2,3,-6,-8);
    test_case(0,0,0,0,0,0);


    repeat(100)
    begin
        test_case($rand,$rand,$rand,$rand);
    end 
    $display("--------------------------------");
    $display("Simulation Completed");
    $display("--------------------------------");

    $finish;
    
end       
   

endmodule 