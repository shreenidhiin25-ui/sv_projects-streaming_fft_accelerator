//==============================================================
// Module      : fft_controller
// Project     : Streaming FFT Accelerator
// Author      : Shreenidhi Inamadar
//
// Description:
// Controller for Simplified Streaming SDF FFT
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

    typedef enum logic [1:0]
    {
        IDLE,
        LOAD,
        COMPUTE,
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
    // Stage Counter
    //----------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        if(!rst_n)
            stage <= '0;

        else if(current_state == LOAD)
            stage <= '0;

        else if(current_state == COMPUTE)
        begin

            if(stage < NUM_STAGES-1)
                stage <= stage + 1'b1;

        end

    end

    //----------------------------------------------------------
    // Next State Logic
    //----------------------------------------------------------

    always_comb
    begin

        next_state = current_state;

        case(current_state)

            //----------------------------------------------
            IDLE
            //----------------------------------------------

            IDLE:
            begin
                if(start)
                    next_state = LOAD;
            end

            //----------------------------------------------
            LOAD
            //----------------------------------------------

            LOAD:
            begin
                next_state = COMPUTE;
            end

            //----------------------------------------------
            COMPUTE
            //----------------------------------------------

            COMPUTE:
            begin

                if(stage == NUM_STAGES-1)
                    next_state = DONE;

            end

            //----------------------------------------------
            DONE
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
            // COMPUTE
            //----------------------------------------------

            COMPUTE:
            begin

                busy          = 1'b1;
                valid         = 1'b1;

                fifo_rd_en    = 1'b1;
                fifo_wr_en    = 1'b1;

                butterfly_en  = 1'b1;
                pipeline_en   = 1'b1;

                feedback_sel  = 1'b1;

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