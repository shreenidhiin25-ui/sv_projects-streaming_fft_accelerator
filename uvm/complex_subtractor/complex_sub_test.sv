class complex_sub_test extends uvm_test;

    `uvm_component_utils(complex_sub_test)

    //-----------------------------------------------------
    // Components
    //-----------------------------------------------------

    complex_env env;
    complex_sequence seq;

    //-----------------------------------------------------
    // Constructor
    //-----------------------------------------------------

    function new(
        string name = "complex_test",
        uvm_component parent = null
    );

        super.new(name,parent);

    endfunction

    //-----------------------------------------------------
    // Build Phase
    //-----------------------------------------------------

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        env = complex_env::
              type_id::create("env",this);

    endfunction

    //-----------------------------------------------------
    // Run Phase
    //-----------------------------------------------------

    task run_phase(uvm_phase phase);

        phase.raise_objection(this);

        seq = complex_sequence::
              type_id::create("seq");

        seq.start(env.agent.sequencer);

        #100;

        phase.drop_objection(this);

    endtask

endclass