
module fetch_icache (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            update_data_wea,
    input   wire [31:0]     update_data_addr,
    input   wire [35:0]     update_data,

    input   wire            update_tag_wea,
    input   wire [32:0]     update_tag,

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

    // Tag RAMs
    wire [6:0]  tag_addra;
    wire [19:0] tag_dina;
    wire        tag_wea;

    wire [6:0]  tag_addrb;
    wire [19:0] tag_doutb;

    reg         tag_valid_R [127:0];
    reg [18:0]  tag_value_R [127:0];

    genvar i;
    generate
        for (i = 0; i < 128; i = i + 1) begin : GENERATED_ICACHE_TAG_STACK

            always @(posedge clk) begin

                if (~resetn) begin
                    tag_valid_R[i] <= 'b0;
                end
                else if (snoop_hit && (snoop_line == i)) begin
                    tag_valid_R[i] <= 'b0;
                end
                else if (tag_wea && (tag_addra == i)) begin
                    tag_valid_R[i] <= tag_dina[19];
                end
            end
        end
    endgenerate

    always @(posedge clk) begin

        if (tag_wea) begin
            tag_value_R[tag_addra] <= tag_dina[18:0];
        end
    end

    assign tag_doutb = { tag_valid_R[tag_addrb], tag_value_R[tag_addrb] };


    // Data BRAMs
    wire [10:0] data_addra;
    wire [35:0] data_dina;
    wire        data_wea;

    wire [10:0] data_addrb;
    wire [35:0] data_doutb;

    bram_icache bram_icache_data_INST (
        .clka   (clk),
        .addra  (data_addra),
        .dina   (data_dina),
        .wea    (data_wea),

        .clkb   (clk),
        .addrb  (data_addrb),
        .doutb  (data_doutb)
    );

    // Input & Update logic
    assign tag_addrb = q_addr[12:6];

    assign tag_addra = update_tag[12:6];
    assign tag_dina  = update_tag[32:13];
    assign tag_wea   = update_tag_wea;

    assign data_addrb = q_addr[12:2];

    assign data_addra = update_data_addr[12:2];
    assign data_dina  = update_data;
    assign data_wea   = update_data_wea;

    //
    wire tag_hit;

    assign tag_hit = tag_doutb[19] && (tag_doutb[18:0] == q_addr[31:13]);

    //
    reg q_hit_R;

    always @(posedge clk) begin

        if (~resetn) begin
            q_hit_R <= 'b0;
        end
        else begin
            q_hit_R <= tag_hit;
        end
    end

    // Output logic
    assign q_hit  = q_hit_R;

    assign q_data = data_doutb;

    //

endmodule
