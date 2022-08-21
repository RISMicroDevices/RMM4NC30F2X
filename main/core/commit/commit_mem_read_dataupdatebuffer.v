
module commit_mem_read_dataupdatebuffer (
    input   wire            clk,
    input   wire            resetn,

    // master write
    input   wire            wea,

    input   wire [31:0]     dina_addr,
    input   wire [31:0]     dina_data,

    // slave read
    input   wire            web,

    output  wire [31:0]     doutb_addr,
    output  wire [31:0]     doutb_data,

    //
    output  wire            s_full,
    output  wire            s_empty
);

    //
    integer i;
    genvar  j;


    //
    wire [8:0]  fifo_p;

    //
    wire r_pop;   // functionally accepted reading from FIFO
    wire r_push;  // functionally accepted writing into FIFO

    wire p_hold;  // read and write FIFO simultaneously
    wire p_pop;   // read FIFO only
    wire p_push;  // write FIFO only

    assign r_pop  = (web) & ~s_empty;
    assign r_push = (wea) & ~s_full;

    assign p_hold = r_pop & wea;
    
    assign p_pop  = ~p_hold & r_pop;
    assign p_push = ~p_hold & r_push;

    //
    wire p_shr;

    assign p_shr = r_pop;

    //
    reg [8:0]   fifo_p_R;

    assign fifo_p = fifo_p_R;

    assign s_full  = fifo_p_R[8];
    assign s_empty = fifo_p_R[0];

    always @(posedge clk) begin

        if (~resetn) begin
            fifo_p_R <= 7'b1;
        end
        else if (p_pop) begin
            fifo_p_R <= { 1'b0, fifo_p_R[8:1] };
        end
        else if (p_push) begin
            fifo_p_R <= { fifo_p_R[7:0], 1'b0 };
        end
    end


    //
    reg [31:0]  addr_R;

    always @(posedge clk) begin

        if (wea) begin
            addr_R  <= dina_addr;
        end
    end

    //
    reg [2:0]   offset_R[7:0];
    reg [31:0]  data_R  [7:0];

    always @(posedge clk) begin

        for (i = 0; i < 8; i = i + 1) begin

            if (p_shr) begin

                if (wea && fifo_p[i + 1]) begin

                    offset_R[i] <= dina_addr[4:2];
                    data_R  [i] <= dina_data;
                end
                else if (i < 7) begin

                    offset_R[i] <= offset_R[i + 1];
                    data_R  [i] <= data_R  [i + 1];
                end
            end
            else if (wea && fifo_p[i]) begin

                offset_R[i] <= dina_addr[4:2];
                data_R  [i] <= dina_data;
            end
        end
    end


    //
    assign doutb_addr = { addr_R[31:5], offset_R[0], 2'b0 };
    assign doutb_data = data_R[0];

    //

endmodule
