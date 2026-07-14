//==============================================================
// Class       : fft_input_transaction
// Project     : Streaming FFT Accelerator (UVM environment)
//
// Sequence item for the ACTIVE input agent: one full FFT block
// (N complex samples) to be streamed into fft_top one sample
// per clock. `rand` so sequences can randomize it directly.
//==============================================================

class fft_input_transaction extends uvm_sequence_item;

    `uvm_object_utils(fft_input_transaction)

    // Must match fft_top's N parameter (default 8). Kept as a
    // plain localparam rather than a class parameter, matching
    // the project's existing non-parameterized UVM style.
    localparam int N = 8;

    rand logic signed [15:0] in_real [0:N-1];
    rand logic signed [15:0] in_imag [0:N-1];

    function new(string name = "fft_input_transaction");
        super.new(name);
    endfunction

    //----------------------------------------------------------
    // Transaction-level logging: uvm_info calls throughout the
    // env print tr.convert2string() rather than raw field
    // dumps, which is the standard UVM way to get readable
    // waveform-free logs.
    //----------------------------------------------------------

    function string convert2string();

        string s;
        int i;

        s = "input samples: ";

        for (i = 0; i < N; i = i + 1)
            s = {s, $sformatf("(%0d,%0d) ", in_real[i], in_imag[i])};

        return s;

    endfunction

endclass
