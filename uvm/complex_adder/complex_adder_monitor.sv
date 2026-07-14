class complex_monitor extends uvm_monitor;

    `uvm_component_utils(complex_monitor)

    //-------------------------------------------------------
    // Virtual Interface
    //-------------------------------------------------------

    virtual complex_if vif;

    //-------------------------------------------------------
    // Analysis Port
    //-------------------------------------------------------

    uvm_analysis_port #(complex_transaction) analysis_port;

    //-------------------------------------------------------
    // Constructor
    //-------------------------------------------------------

    function new(
        string name = "complex_monitor",
        uvm_component parent = null
    );

        super.new(name,parent);

    endfunction

    //-------------------------------------------------------
    // Build Phase
    //-------------------------------------------------------

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        analysis_port = new("analysis_port", this);

    endfunction

    //-------------------------------------------------------
    // Run Phase
    //-------------------------------------------------------

    task run_phase(uvm_phase phase);

        complex_transaction tr;

        forever
        begin

            tr = complex_transaction::type_id::create("tr");

            //--------------------------------------------------
            // Wait for DUT to produce outputs
            //--------------------------------------------------

            #10;

            //--------------------------------------------------
            // Capture Inputs
            //--------------------------------------------------

            tr.a_real = vif.a_real;
            tr.a_imag = vif.a_imag;

            tr.b_real = vif.b_real;
            tr.b_imag = vif.b_imag;

            //--------------------------------------------------
            // Capture Outputs
            //--------------------------------------------------

            tr.p_real = vif.p_real;
            tr.p_imag = vif.p_imag;

            //--------------------------------------------------
            // Send to Scoreboard
            //--------------------------------------------------

            analysis_port.write(tr);

        end

    endtask

endclass