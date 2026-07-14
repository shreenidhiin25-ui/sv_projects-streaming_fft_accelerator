class complex_sub_env extends uvm_env;

    `uvm_component_utils(complex_sub_env)

    //--------------------------------------------------
    // Components
    //--------------------------------------------------

    complex_agent agent;

    complex_scoreboard scoreboard;

    //--------------------------------------------------
    // Constructor
    //--------------------------------------------------

    function new(

        string name = "complex_env",

        uvm_component parent = null

    );

        super.new(name,parent);

    endfunction

    //--------------------------------------------------
    // Build Phase
    //--------------------------------------------------

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        agent = complex_agent::
                type_id::create("agent",this);

        scoreboard = complex_scoreboard::
                     type_id::create("scoreboard",this);

    endfunction

    //--------------------------------------------------
    // Connect Phase
    //--------------------------------------------------

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        agent.monitor.analysis_port.connect(

            scoreboard.analysis_export

        );

    endfunction

endclass