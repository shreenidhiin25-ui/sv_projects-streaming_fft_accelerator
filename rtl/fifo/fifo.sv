//==============================================================
// Module      : fifo
// Project     : Streaming FFT Accelerator
// Author      : Shreenidhi Inamadar
//
// Description:
//
// Parameterized synchronous FIFO with asynchronous active-low
// reset.
//
// Features:
// - Single Clock FIFO
// - Parameterized Width and Depth
// - Full / Empty Detection
// - Read / Write Support
//
//==============================================================

module fifo #(
    parameter WIDTH = 16,
    parameter DEPTH = 16
)(
    input  logic                    clk,
    input  logic                    rst_n,

    input  logic                    wr_en,
    input  logic                    rd_en,

    input  logic signed [WIDTH-1:0] data_in,

    output logic signed [WIDTH-1:0] data_out,

    output logic                    full,
    output logic                    empty
);

    //----------------------------------------------------------
    // Memory
    //----------------------------------------------------------

    logic signed [WIDTH-1:0] mem [0:DEPTH-1];

    //----------------------------------------------------------
    // FIFO Pointers
    //----------------------------------------------------------

    logic [$clog2(DEPTH)-1:0] wr_ptr;
    logic [$clog2(DEPTH)-1:0] rd_ptr;

    //----------------------------------------------------------
    // FIFO Counter
    //----------------------------------------------------------

    logic [$clog2(DEPTH):0] count;

    //----------------------------------------------------------
    // Sequential Logic
    //----------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n)
    begin

        //------------------------------------------------------
        // Asynchronous Reset
        //------------------------------------------------------

        if (!rst_n)
        begin

            wr_ptr   <= '0;
            rd_ptr   <= '0;
            count    <= '0;
            data_out <= '0;

        end

        //------------------------------------------------------
        // Normal Operation
        //------------------------------------------------------

        else
        begin

            //--------------------------------------------------
            // Write Operation
            //--------------------------------------------------

            if (wr_en && !full)
            begin

                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1'b1;

            end

            //--------------------------------------------------
            // Read Operation
            //--------------------------------------------------

            if (rd_en && !empty)
            begin

                data_out <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;

            end

            //--------------------------------------------------
            // FIFO Count
            //--------------------------------------------------

            case ({wr_en && !full, rd_en && !empty})

                // Write Only
                2'b10:
                    count <= count + 1'b1;

                // Read Only
                2'b01:
                    count <= count - 1'b1;

                // Read and Write Together
                2'b11:
                    count <= count;

                // Idle
                default:
                    count <= count;

            endcase

        end

    end

    //----------------------------------------------------------
    // Status Flags
    //----------------------------------------------------------

    assign full  = (count == DEPTH);

    assign empty = (count == 0);

endmodule