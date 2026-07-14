class complex_sub_agent extends uvm_agent;

    `uvm_component_utils(complex_sub_agent)

    //--------------------------------------------
    // Components
    //--------------------------------------------

    complex_sub_driver driver;
    complex_sub_monitor monitor;
    uvm_sequencer #(complex_sub_transaction) sequencer;

    //--------------------------------------------
    // Constructor
    //--------------------------------------------

    function new(
        string name = "complex_sub_agent",
        uvm_component parent = null
    );

        super.new(name,parent);

    endfunction

    //--------------------------------------------
    // Build Phase
    //--------------------------------------------

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        driver = complex_driver::
                 type_id::create("driver",this);

        monitor = complex_monitor::
                  type_id::create("monitor",this);

        sequencer = uvm_sequencer #(complex_transaction)::
                    type_id::create("sequencer",this);

    endfunction

    //--------------------------------------------
    // Connect Phase
    //--------------------------------------------

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        // Connect Driver and Sequencer
        driver.seq_item_port.connect(
            sequencer.seq_item_export
        );

    endfunction

endclass