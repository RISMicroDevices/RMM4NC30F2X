
module execute_mem_storebuffer_checkpoints (
    input   wire            clk,
    input   wire            resetn,

    // Checkpoint write
    input   wire            wea,
    input   wire [1:0]      addra,
    input   wire [6:0]      dina_fifo_p,

    // Checkpoint recovery
    input   wire            web,
    input   wire [1:0]      addrb,
    output  wire [6:0]      doutb_fifo_p,

    // Checkpoint modification (on Store Commit)
    input   wire            wec
);

    //
    integer i;
    genvar  j;


    //
    reg [6:0]   cp_fifo_p_R [3:0];

    always @(posedge clk) begin
        
        for (i = 0; i < 4; i = i + 1) begin

            if (wea && addra == i) begin

                if (wec && ~dina_fifo_p[0]) begin
                    cp_fifo_p_R[i] <= { 1'b0, dina_fifo_p[6:1] };
                end
                else begin
                    cp_fifo_p_R[i] <= dina_fifo_p;
                end
            end
            else if (wec && ~cp_fifo_p_R[i][0]) begin
                cp_fifo_p_R[i] <= { 1'b0, cp_fifo_p_R[i][6:1] };
            end
        end
    end

    //
    assign doutb_fifo_p = (wec && ~cp_fifo_p_R[addrb][0]) ? { 1'b0, cp_fifo_p_R[addrb][6:1] } 
                                                          : cp_fifo_p_R[addrb];

    //

endmodule
