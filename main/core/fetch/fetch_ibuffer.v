
module fetch_ibuffer (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            uncached_we,
    input   wire [31:0]     uncached_addr,
    input   wire [35:0]     uncached_din,

    output  wire            uncached_done,

    //
    input   wire            refilled_wea,
    input   wire [31:0]     refilled_addra,
    
    input   wire            refilled_web,
    input   wire [3:0]      refilled_addrb,
    input   wire [35:0]     refilled_dinb,

    input   wire            refilled_reset,

    output  wire            refilled_hit,

    //
    input   wire            snoop_hit,
    input   wire [31:0]     snoop_addr,

    //
    input   wire [31:0]     q_addr,

    output  wire            q_hit,
    output  wire [35:0]     q_data
);

    //
    wire [6:0]  snoop_line;

    assign snoop_line = snoop_addr[12:6];

    // uncached buffer (hold for only 1 cycle)
    reg         buffer_uncached_valid_R;
    reg [29:0]  buffer_uncached_addr_R;
    reg [35:0]  buffer_uncached_data_R;

    // *NOTICE: NOT NECESSARY to setup a snoop filter for uncached buffer,
    //          because its data and address only hold for 1 cycle.
    /*
    wire        buffer_uncached_snoop_hit;
    */

    always @(posedge clk) begin

        if (~resetn) begin
            buffer_uncached_valid_R <= 'b0;
        end
        else if (uncached_we) begin
            buffer_uncached_valid_R <= 'b1;
        end
        else begin
            buffer_uncached_valid_R <= 'b0;
        end
    end

    always @(posedge clk) begin

        if (uncached_we) begin

            buffer_uncached_addr_R  <= uncached_addr[31:2];
            buffer_uncached_data_R  <= uncached_din;
        end
        else begin

            buffer_uncached_addr_R  <= 'b0;
            buffer_uncached_data_R  <= 'b0;
        end
    end

    // uncached buffer hit logic
    wire    buffer_uncached_hit;

    assign buffer_uncached_hit = buffer_uncached_valid_R && (buffer_uncached_addr_R == q_addr[31:2]);


    // refill buffer (hold till reset)
    reg [25:0]  buffer_refilled_addr_R;

    reg         buffer_refilled_valid_R [15:0];
    reg [35:0]  buffer_refilled_data_R  [15:0];

    wire        buffer_refilled_snoop_hit;

    assign buffer_refilled_snoop_hit = snoop_hit && (buffer_refilled_addr_R[6:0] == snoop_line);

    integer i;
    always @(posedge clk) begin

        if (~resetn) begin

            buffer_refilled_addr_R <= 'b0;

            for (i = 0; i < 16; i = i + 1) begin
                buffer_refilled_valid_R[i] <= 'b0;
            end
        end
        else if (refilled_reset | buffer_refilled_snoop_hit) begin

            buffer_refilled_addr_R <= 'b0;

            for (i = 0; i < 16; i = i + 1) begin
                buffer_refilled_valid_R[i] <= 'b0;
            end
        end
        else begin

            if (refilled_wea) begin
                buffer_refilled_addr_R <= refilled_addra[31:6];
            end

            if (refilled_web) begin
                buffer_refilled_valid_R[refilled_addrb] <= 'b1;
            end
        end
    end

    always @(posedge clk) begin

        if (refilled_web) begin
            buffer_refilled_data_R[refilled_addrb] <= refilled_dinb;
        end
    end

    // refill buffer hit logic
    wire    buffer_refilled_hit;

    assign buffer_refilled_hit = (buffer_refilled_addr_R == q_addr[31:6]) && buffer_refilled_valid_R[q_addr[5:2]];


    // output register
    reg         q_hit_R;
    reg [35:0]  q_data_R;

    always @(posedge clk) begin

        if (~resetn) begin

            q_hit_R  <= 'b0;
            q_data_R <= 'b0;
        end
        else begin

            q_hit_R  <= buffer_uncached_hit | buffer_refilled_hit;
            q_data_R <= buffer_uncached_hit ? buffer_uncached_data_R : buffer_refilled_data_R[q_addr[5:2]];
        end
    end


    // output logic
    assign uncached_done = buffer_uncached_hit;
    assign refilled_hit  = buffer_refilled_hit;

    assign q_hit  = q_hit_R;
    assign q_data = q_data_R;

    //

endmodule
