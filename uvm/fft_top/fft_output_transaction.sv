//==============================================================
// Class       : fft_output_transaction
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Result of one full FFT block (N complex samples), drained
// one sample per clock, gated on out_valid. Produced by BOTH:
//   - fft_output_monitor (PASSIVE agent)   -> the "actual" side
//   - fft_predictor (reference model)      -> the "expected" side
// The scoreboard compares one of each, pulled from two separate
// uvm_tlm_analysis_fifo instances.
//==============================================================

class fft_output_transaction extends uvm_sequence_item;

    `uvm_object_utils(fft_output_transaction)

    localparam int N = 8;

    logic signed [15:0] out_real [0:N-1];
    logic signed [15:0] out_imag [0:N-1];

    function new(string name = "fft_output_transaction");
        super.new(name);
    endfunction

    function string convert2string();

        string s;
        int i;

        s = "output samples: ";

        for (i = 0; i < N; i = i + 1)
            s = {s, $sformatf("(%0d,%0d) ", out_real[i], out_imag[i])};

        return s;

    endfunction

endclass
