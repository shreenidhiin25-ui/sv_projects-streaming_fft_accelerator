//==============================================================
// Module      : fft_controller
// Project     : Streaming FFT Accelerator
// Author      : Shreenidhi Inamadar
//
// Description:
// Controller for Simplified Streaming SDF FFT
//
// Protocol (fixed-latency streaming, one sample per cycle):
//   IDLE    -> wait for start
//   LOAD    -> N cycles, fifo_wr_en=1, one input sample captured
//              into the input FIFOs per cycle
//   UNLOAD  -> N+1 cycles, fifo_rd_en=1, popping the input FIFOs
//              into the parallel butterfly-stage input register.
//              The extra cycle accounts for the FIFO's registered
//              (one-cycle-latency) read data, so the last popped
//              sample has landed before COMPUTE starts.
//   COMPUTE -> NUM_STAGES cycles, pipeline_en=1, advancing the
//              fixed 3-stage pipeline one register stage per cycle
//   DRAIN   -> N cycles, valid=1, one output sample presented per
//              cycle from the already-computed parallel result
//   DONE    -> done=1 until start is released
//
//==============================================================

module fft_controller #(
    parameter N = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic start,

    //----------------------------------------------------------
    // Status Outputs
    //----------------------------------------------------------

    output logic busy,
    output logic done,
    output logic valid,

    //----------------------------------------------------------
    // Control Signals
    //----------------------------------------------------------

    output logic fifo_wr_en,
    output logic fifo_rd_en,

    output logic butterfly_en,
    output logic pipeline_en,

    output logic feedback_sel,

    //----------------------------------------------------------
    // Current FFT Stage
    //----------------------------------------------------------

    output logic [$clog2($clog2(N))-1:0] stage
);

    //----------------------------------------------------------
    // Parameters
    //----------------------------------------------------------

    localparam NUM_STAGES = $clog2(N);

    //----------------------------------------------------------
    // FSM States
    //----------------------------------------------------------

    typedef enum logic [2:0]
    {
        IDLE,
        LOAD,
        UNLOAD,
        COMPUTE,
        DRAIN,
        DONE
    } state_t;

    state_t current_state;
    state_t next_state;

    //----------------------------------------------------------
    // State Register
    //----------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    //----------------------------------------------------------
    // Stage Counter (COMPUTE)
    //----------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
            stage <= '0;

        else if(current_state == UNLOAD)
            stage <= '0;

        else if(current_state == COMPUTE)
        begin

            if(stage < NUM_STAGES-1)
                stage <= stage + 1'b1;

        end

    end

    //----------------------------------------------------------
    // Load Counter (LOAD) -- counts N samples pushed into the
    // input FIFOs, one per cycle
    //----------------------------------------------------------

    logic [$clog2(N)-1:0] load_count;

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
            load_count <= '0;

        else if(current_state != LOAD)
            load_count <= '0;

        else if(load_count < N-1)
            load_count <= load_count + 1'b1;

    end

    //----------------------------------------------------------
    // Unload Counter (UNLOAD) -- counts N+1 cycles: N pop
    // requests plus one settle cycle for the FIFO's registered
    // read data to land
    //----------------------------------------------------------

    logic [$clog2(N+1)-1:0] unload_count;

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
            unload_count <= '0;

        else if(current_state != UNLOAD)
            unload_count <= '0;

        else if(unload_count < N)
            unload_count <= unload_count + 1'b1;

    end

    //----------------------------------------------------------
    // Drain Counter (DRAIN) -- counts N output samples
    // presented, one per cycle
    //----------------------------------------------------------

    logic [$clog2(N)-1:0] drain_count;

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
            drain_count <= '0;

        else if(current_state != DRAIN)
            drain_count <= '0;

        else if(drain_count < N-1)
            drain_count <= drain_count + 1'b1;

    end

    //----------------------------------------------------------
    // Next State Logic
    //----------------------------------------------------------

    always_comb
    begin

        next_state = current_state;

        case(current_state)

            //----------------------------------------------
            // IDLE
            //----------------------------------------------

            IDLE:
            begin
                if(start)
                    next_state = LOAD;
            end

            //----------------------------------------------
            // LOAD
            //----------------------------------------------

            LOAD:
            begin
                if(load_count == N-1)
                    next_state = UNLOAD;
            end

            //----------------------------------------------
            // UNLOAD
            //----------------------------------------------

            UNLOAD:
            begin
                if(unload_count == N)
                    next_state = COMPUTE;
            end

            //----------------------------------------------
            // COMPUTE
            //----------------------------------------------

            COMPUTE:
            begin

                if(stage == NUM_STAGES-1)
                    next_state = DRAIN;

            end

            //----------------------------------------------
            // DRAIN
            //----------------------------------------------

            DRAIN:
            begin

                if(drain_count == N-1)
                    next_state = DONE;

            end

            //----------------------------------------------
            // DONE
            //----------------------------------------------

            DONE:
            begin

                if(!start)
                    next_state = IDLE;

            end

            default:
                next_state = IDLE;

        endcase

    end

    //----------------------------------------------------------
    // Output Logic
    //----------------------------------------------------------

    always_comb
    begin

        //--------------------------------------------------
        // Defaults
        //--------------------------------------------------

        busy          = 1'b0;
        done          = 1'b0;
        valid         = 1'b0;

        fifo_wr_en    = 1'b0;
        fifo_rd_en    = 1'b0;

        butterfly_en  = 1'b0;
        pipeline_en   = 1'b0;

        feedback_sel  = 1'b0;

        //--------------------------------------------------
        // FSM Outputs
        //--------------------------------------------------

        case(current_state)

            //----------------------------------------------
            // IDLE
            //----------------------------------------------

            IDLE:
            begin
                busy = 1'b0;
            end

            //----------------------------------------------
            // LOAD
            //----------------------------------------------

            LOAD:
            begin

                busy       = 1'b1;

                fifo_wr_en = 1'b1;

            end

            //----------------------------------------------
            // UNLOAD
            //----------------------------------------------

            UNLOAD:
            begin

                busy       = 1'b1;

                // Only issue N pop requests (unload_count 0..N-1).
                // The final cycle of UNLOAD (unload_count==N) is a
                // settle-only cycle with fifo_rd_en low, giving the
                // FIFO's registered read data from the last real pop
                // time to land in top.sv before COMPUTE begins.
                fifo_rd_en = (unload_count < N);

            end

            //----------------------------------------------
            // COMPUTE
            //----------------------------------------------

            COMPUTE:
            begin

                busy          = 1'b1;

                butterfly_en  = 1'b1;
                pipeline_en   = 1'b1;

                feedback_sel  = 1'b1;

            end

            //----------------------------------------------
            // DRAIN
            //----------------------------------------------

            DRAIN:
            begin

                busy  = 1'b1;
                valid = 1'b1;

            end

            //----------------------------------------------
            // DONE
            //----------------------------------------------

            DONE:
            begin

                done = 1'b1;

            end

        endcase

    end

endmodule
