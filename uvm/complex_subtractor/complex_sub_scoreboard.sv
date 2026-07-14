class complex_scoreboard extends uvm_scoreboard;
    'uvm_component_utils(complex_scoreboard)
    complex_transaction tr;
    uvm_analysis_imp #(complex_transaction, complex_scoreboard) analysis_export;
    function new(string name = "complex_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        analysis_export = new("analysis_export", this);

    endfunction

    //refernce model 

    function automatic logic signed [15:0] expected_real(

        input logic signed [15:0] a,
        input logic signed [15:0] b

    );

        return a + b;

    endfunction

    function automatic logic signed [15:0] expected_imag(

        input logic signed [15:0] a,
        input logic signed [15:0] b

    );

        return a - b;
    endfunction

        function void write(complex_transaction tr);

        logic signed [15:0] exp_real;
        logic signed [15:0] exp_imag;

        exp_real = expected_real(tr.a_real,
                                 tr.b_real);

        exp_imag = expected_imag(tr.a_imag,
                                 tr.b_imag);

        if( (tr.p_real == exp_real) &&
            (tr.p_imag == exp_imag) )

        begin

            `uvm_info("SCOREBOARD",
                      "PASS",
                      UVM_LOW)

        end

        else

        begin

            `uvm_error("SCOREBOARD","Mismatch Detected")

            $display("--------------------------------");

            $display("Input A : (%0d,%0d)",
                     tr.a_real,
                     tr.a_imag);

            $display("Input B : (%0d,%0d)",
                     tr.b_real,
                     tr.b_imag);

            $display("Expected : (%0d,%0d)",
                     exp_real,
                     exp_imag);

            $display("Actual : (%0d,%0d)",
                     tr.p_real,
                     tr.p_imag);

            $display("--------------------------------");

        end

    endfunction

endclass
