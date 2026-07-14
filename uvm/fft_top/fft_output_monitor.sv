//==============================================================
// Class       : fft_output_monitor
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Lives in the PASSIVE output agent. Watches the same `busy`
// rising edge as fft_input_monitor (so both monitors stay
// synchronized to the same transaction boundary), then captures
// N output samples gated on out_valid during DRAIN -- this part
// is self-timed off a real handshake signal, unlike the input
// side which has no such signal and must assume the fixed LOAD
// window (see fft_input_monitor.sv).
//==============================================================

class fft_output_monitor extends uvm_monitor;

    `uvm_component_utils(fft_output_monitor)

    virtual fft_top_if vif;

    uvm_analysis_port #(fft_output_transaction) ap;

    function new(string name = "fft_output_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        ap = new("ap", this);

        if (!uvm_config_db#(virtual fft_top_if)::get(this, "", "vif", vif))
            `uvm_fatal("fft_output_monitor", "Virtual interface 'vif' not set via uvm_config_db")

    endfunction

    task run_phase(uvm_phase phase);

        fft_output_transaction tr;
        bit busy_d;
        int i;

        busy_d = 1'b0;

        forever begin

            @(posedge vif.clk);

            if (vif.busy && !busy_d) begin

                tr = fft_output_transaction::type_id::create("tr");

                i = 0;
                while (i < fft_output_transaction::N) begin
                    @(posedge vif.clk);
                    if (vif.out_valid) begin
                        tr.out_real[i] = vif.out_real;
                        tr.out_imag[i] = vif.out_imag;
                        i = i + 1;
                    end
                end

                `uvm_info("fft_output_monitor",
                          $sformatf("Captured %s", tr.convert2string()),
                          UVM_MEDIUM)

                ap.write(tr);

            end

            busy_d = vif.busy;

        end

    endtask

endclass
