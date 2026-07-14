//==============================================================
// Class       : fft_input_monitor
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Passively reconstructs the input transaction actually seen on
// the bus (as opposed to trusting what the driver intended to
// drive), by watching `busy` rise -- the same cycle fft_controller
// enters LOAD and starts capturing one sample per clock. This
// is what makes it a genuine bus monitor rather than a copy of
// the driver's internal state.
//
// Feeds TWO independent subscribers off one analysis port (a
// broadcast, many-to-one connection made in fft_env.sv):
//   - fft_predictor            (reference model)
//   - fft_coverage_subscriber  (functional coverage)
//==============================================================

class fft_input_monitor extends uvm_monitor;

    `uvm_component_utils(fft_input_monitor)

    virtual fft_top_if vif;

    uvm_analysis_port #(fft_input_transaction) ap;

    function new(string name = "fft_input_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        ap = new("ap", this);

        if (!uvm_config_db#(virtual fft_top_if)::get(this, "", "vif", vif))
            `uvm_fatal("fft_input_monitor", "Virtual interface 'vif' not set via uvm_config_db")

    endfunction

    task run_phase(uvm_phase phase);

        fft_input_transaction tr;
        bit busy_d;
        int i;

        busy_d = 1'b0;

        forever begin

            @(posedge vif.clk);

            // Rising edge of busy == first cycle of LOAD == the
            // DUT is capturing sample 0 on this very edge.
            if (vif.busy && !busy_d) begin

                tr = fft_input_transaction::type_id::create("tr");

                tr.in_real[0] = vif.in_real;
                tr.in_imag[0] = vif.in_imag;

                for (i = 1; i < fft_input_transaction::N; i = i + 1) begin
                    @(posedge vif.clk);
                    tr.in_real[i] = vif.in_real;
                    tr.in_imag[i] = vif.in_imag;
                end

                `uvm_info("fft_input_monitor",
                          $sformatf("Captured %s", tr.convert2string()),
                          UVM_MEDIUM)

                ap.write(tr);

            end

            busy_d = vif.busy;

        end

    endtask

endclass
