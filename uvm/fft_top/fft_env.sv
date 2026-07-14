//==============================================================
// Class       : fft_env
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Wires together the ACTIVE input agent, PASSIVE output agent,
// virtual sequencer, predictor, scoreboard, and coverage
// subscriber. Connection topology:
//
//   input_agent.monitor.ap ----> predictor.analysis_export
//                            \-> coverage.analysis_export
//
//   predictor.predicted_ap  ----> scoreboard.expected_fifo
//   output_agent.monitor.ap ----> scoreboard.actual_fifo
//
//   v_sequencer.input_sequencer = input_agent.sequencer
//==============================================================

class fft_env extends uvm_env;

    `uvm_component_utils(fft_env)

    fft_input_agent         input_agent;
    fft_output_agent        output_agent;
    fft_virtual_sequencer   v_sequencer;
    fft_predictor           predictor;
    fft_scoreboard          scoreboard;
    fft_coverage_subscriber coverage;

    function new(string name = "fft_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // Configuration Database: explicit for illustration --
        // fft_input_agent already defaults to UVM_ACTIVE, this
        // just demonstrates setting it the standard way.
        uvm_config_db#(uvm_active_passive_enum)::set(
            this, "input_agent", "is_active", UVM_ACTIVE);

        input_agent  = fft_input_agent::type_id::create("input_agent", this);
        output_agent = fft_output_agent::type_id::create("output_agent", this);
        v_sequencer  = fft_virtual_sequencer::type_id::create("v_sequencer", this);
        predictor    = fft_predictor::type_id::create("predictor", this);
        scoreboard   = fft_scoreboard::type_id::create("scoreboard", this);
        coverage     = fft_coverage_subscriber::type_id::create("coverage", this);

    endfunction

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        // Virtual sequencer holds the handle a virtual sequence
        // needs to reach the physical input sequencer.
        v_sequencer.input_sequencer = input_agent.sequencer;

        // One analysis port, two subscribers (broadcast).
        input_agent.monitor.ap.connect(predictor.analysis_export);
        input_agent.monitor.ap.connect(coverage.analysis_export);

        // Predictor's expected output -> scoreboard's "expected" FIFO.
        predictor.predicted_ap.connect(scoreboard.expected_fifo.analysis_export);

        // Passive output agent's captured actual output -> scoreboard's "actual" FIFO.
        output_agent.monitor.ap.connect(scoreboard.actual_fifo.analysis_export);

    endfunction

endclass
