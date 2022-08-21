
module commit_mem_loadbuffer (
    input   wire            clk,
    input   wire            resetn,

    // Uncached fetch buffer write
    input   wire            wea,
    input   wire [31:0]     addra,
    input   wire [31:0]     dina,

    // Cache fetch buffer write
    input   wire            web,
    input   wire [31:0]     addrb,
    input   wire [31:0]     dinb,

    // Cache fetch buffer invalidation
    input   wire            wec,

    // Cache fetch buffer state query
    input   wire [31:0]     s_qaddr,

    output  wire            s_busy,

    // 
    input   wire [31:0]     qaddr,

    output  wire            qhit,
    output  wire [31:0]     qdata
);

    //
    reg         uncached_valid_R;
    reg [31:0]  uncached_addr_R;
    reg [31:0]  uncached_data_R;

    always @(posedge clk) begin

        if (~resetn) begin
            uncached_valid_R <= 1'b0;
        end
        else if (wea) begin
            uncached_valid_R <= 1'b1;
        end
        else begin
            uncached_valid_R <= 1'b0;
        end

        uncached_addr_R <= addra;
        uncached_data_R <= dina;
    end

    //
    wire    uncached_hit;

    assign uncached_hit = uncached_valid_R && qaddr == uncached_addr_R;


    //
    reg [7:0]   fetched_valid_R;
    reg [31:0]  fetched_addr_R;
    reg [31:0]  fetched_data_R  [7:0];

    always @(posedge clk) begin

        if (~resetn) begin
            fetched_valid_R <= 'b0;
        end
        else if (wec) begin
            fetched_valid_R <= 'b0;
        end
        else if (web) begin
            fetched_valid_R[addrb[4:2]] <= 1'b1;
        end

        if (web) begin
            
            fetched_addr_R              <= addrb;
            fetched_data_R[addrb[4:2]]  <= dinb;
        end
    end

    //
    wire    fetched_hit;

    assign fetched_hit = fetched_valid_R[qaddr[4:2]] && qaddr[31:5] == fetched_addr_R[31:5];

    assign s_busy = {|(fetched_valid_R)};


    //
    assign qhit     = uncached_hit | fetched_hit;
    assign qdata    = uncached_hit ? uncached_data_R : fetched_data_R[qaddr[4:2]];

    //

endmodule
