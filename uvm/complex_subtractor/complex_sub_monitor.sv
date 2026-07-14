class complex_monitor extends uvm_monitor;
    `uvm_component_utils(complex_monitor)

    //-------------------------------------------------------
    virtual interface complex_sub_if vif;

    uvm_analysis_port #(complex_sub_transaction) analysis_port;

    function new(string name = "complex_monitor", uvm_component parent =null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_port = new("analysis_port", this);
    endfunction

    task run_phase(uvm_phase phase);
    
        complex_sub_transaction tr;

        forever begin

            tr = complex_sub_transaction::type_id::create("tr");

            //--------------------------------------------------
            // Wait for DUT to produce outputs
            //--------------------------------------------------

            #10;

            tr.a_real = vif.a_real;
            tr.a_imag = vif.a_imag;
            tr.b_real = vif.b_real;
            tr.b_imag = vif.b_imag;

            tr.q_real = vif.q_real;
            tr.q_imag = vif.q_imag;

            analysis_port.write(tr);

        end
    endtask 
endclass