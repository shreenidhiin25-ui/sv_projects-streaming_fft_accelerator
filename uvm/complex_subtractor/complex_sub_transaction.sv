class complex_sub_transaction extends uvm_sequence_item;

    `uvm_object_utils(complex_sub_transaction)

    // Inputs
    rand logic signed [15:0] a_real;
    rand logic signed [15:0] a_imag;
    rand logic signed [15:0] b_real;
    rand logic signed [15:0] b_imag;

    // Outputs (filled by Monitor)
    logic signed [15:0] q_real;
    logic signed [15:0] q_imag;

    function new(string name="complex_sub_transaction");
        super.new(name);
    endfunction

endclass