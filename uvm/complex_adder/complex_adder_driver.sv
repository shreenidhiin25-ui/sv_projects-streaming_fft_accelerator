class complex_driver extends uvm_driver #(complex_transaction);

    `uvm_component_utils(complex_driver)

    virtual complex_if vif;

    function new(
        string name = "complex_driver",
        uvm_component parent = null
    );
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);

        complex_transaction tr;

        forever begin

            seq_item_port.get_next_item(tr);

            vif.a_real = tr.a_real;
            vif.a_imag = tr.a_imag;

            vif.b_real = tr.b_real;
            vif.b_imag = tr.b_imag;

            seq_item_port.item_done();

        end

    endtask

endclass