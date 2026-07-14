`timescale 1ns/1ps

module top;

    //--------------------------------------------------
    // Clock
    //--------------------------------------------------

    logic clk;

    initial clk = 0;

    always #5 clk = ~clk;

    //--------------------------------------------------
    // Interface
    //--------------------------------------------------

    complex_if vif();

    //--------------------------------------------------
    // DUT
    //--------------------------------------------------

    complex_subtractor dut(

        .a_real(vif.a_real),
        .a_imag(vif.a_imag),

        .b_real(vif.b_real),
        .b_imag(vif.b_imag),

        .p_real(vif.q_real),
        .p_imag(vif.q_imag)

    );

    //--------------------------------------------------
    // UVM
    //--------------------------------------------------

    initial begin

        uvm_config_db#(virtual complex_if)::set(

            null,

            "*",

            "vif",

            vif

        );

        run_test("complex_test");

    end

endmodule