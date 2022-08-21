
module decode_rat_checkpoints (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    // Checkpoint valid query
    output  wire [3:0]      valid,

    // Checkpoint write
    input   wire            wea,
    input   wire [1:0]      addra,
    input   wire [31:0]     dina_valid,
    input   wire [255:0]    dina_fid,
    input   wire [127:0]    dina_rob,

    // Checkpoint recovery & set invalidation (on BCO)
    input   wire            web,
    input   wire [1:0]      addrb,
    output  wire [31:0]     doutb_valid,
    output  wire [255:0]    doutb_fid,
    output  wire [127:0]    doutb_rob,

    // Checkpoint entry invalidation (on commit)
    input   wire            wed,
    input   wire [4:0]      addrd,
    input   wire [7:0]      dind_fid,

    // Checkpoint line invalidation (on branch commit, sync with BCO)
    input   wire            wef,
    input   wire [3:0]      dinf_bid
);

    //
    genvar  i;
    integer j;

    //
    reg [3:0]   valid_R;

    always @(posedge clk) begin

        for (j = 0; j < 4; j = j + 1) begin

            if (~resetn) begin
                valid_R[j] <= 'b0;
            end
            else if (snoop_hit) begin
                valid_R[j] <= 'b0;
            end
            else if (web) begin
                valid_R[j] <= 'b0;
            end
            else if (wef && (dinf_bid[1:0] == j)) begin
                valid_R[j] <= 'b0;
            end
            else if (wea && (addra == j)) begin
                valid_R[j] <= 'b1;
            end
        end
    end

    //
    reg         cp0_valid_R [31:1];
    reg         cp1_valid_R [31:1];
    reg         cp2_valid_R [31:1];
    reg         cp3_valid_R [31:1];

    reg  [7:0]  cp0_fid_R   [31:1];
    reg  [7:0]  cp1_fid_R   [31:1];
    reg  [7:0]  cp2_fid_R   [31:1];
    reg  [7:0]  cp3_fid_R   [31:1];

    reg  [3:0]  cp0_rob_R   [31:1];
    reg  [3:0]  cp1_rob_R   [31:1];
    reg  [3:0]  cp2_rob_R   [31:1];
    reg  [3:0]  cp3_rob_R   [31:1];

    always @(posedge clk) begin

        for (j = 1; j < 32; j = j + 1) begin

            cp0_valid_R[j] <= (wed && addrd == j && (  (valid_R[0] ? (dind_fid == cp0_fid_R[j]) : 1'b0)
                                                    || ((wea && addra == 2'd0) ? (dind_fid == dina_fid[j * 8 +: 8]) : 1'b0))) ? 1'b0
                            : (wea && addra == 2'd0) ? dina_valid[j * 1 +: 1] : cp0_valid_R[j];
            cp0_fid_R  [j] <= (wea && addra == 2'd0) ? dina_fid  [j * 8 +: 8] : cp0_fid_R  [j];
            cp0_rob_R  [j] <= (wea && addra == 2'd0) ? dina_rob  [j * 4 +: 4] : cp0_rob_R  [j];

            cp1_valid_R[j] <= (wed && addrd == j && (  (valid_R[1] ? (dind_fid == cp1_fid_R[j]) : 1'b0)
                                                    || ((wea && addra == 2'd1) ? (dind_fid == dina_fid[j * 8 +: 8]) : 1'b0))) ? 1'b0
                            : (wea && addra == 2'd1) ? dina_valid[j * 1 +: 1] : cp1_valid_R[j];
            cp1_fid_R  [j] <= (wea && addra == 2'd1) ? dina_fid  [j * 8 +: 8] : cp1_fid_R  [j];
            cp1_rob_R  [j] <= (wea && addra == 2'd1) ? dina_rob  [j * 4 +: 4] : cp1_rob_R  [j];

            cp2_valid_R[j] <= (wed && addrd == j && (  (valid_R[2] ? (dind_fid == cp2_fid_R[j]) : 1'b0)
                                                    || ((wea && addra == 2'd2) ? (dind_fid == dina_fid[j * 8 +: 8]) : 1'b0))) ? 1'b0
                            : (wea && addra == 2'd2) ? dina_valid[j * 1 +: 1] : cp2_valid_R[j];
            cp2_fid_R  [j] <= (wea && addra == 2'd2) ? dina_fid  [j * 8 +: 8] : cp2_fid_R  [j];
            cp2_rob_R  [j] <= (wea && addra == 2'd2) ? dina_rob  [j * 4 +: 4] : cp2_rob_R  [j];

            cp3_valid_R[j] <= (wed && addrd == j && (  (valid_R[3] ? (dind_fid == cp3_fid_R[j]) : 1'b0)
                                                    || ((wea && addra == 2'd3) ? (dind_fid == dina_fid[j * 8 +: 8]) : 1'b0))) ? 1'b0
                            : (wea && addra == 2'd3) ? dina_valid[j * 1 +: 1] : cp3_valid_R[j];
            cp3_fid_R  [j] <= (wea && addra == 2'd3) ? dina_fid  [j * 8 +: 8] : cp3_fid_R  [j];
            cp3_rob_R  [j] <= (wea && addra == 2'd3) ? dina_rob  [j * 4 +: 4] : cp3_rob_R  [j];
        end
    end

    //
    assign valid = valid_R;

    //
    wire [31:0]     cp0_valid_ow;
    wire [31:0]     cp1_valid_ow;
    wire [31:0]     cp2_valid_ow;
    wire [31:0]     cp3_valid_ow;

    wire [255:0]    cp0_fid_ow;
    wire [255:0]    cp1_fid_ow;
    wire [255:0]    cp2_fid_ow;
    wire [255:0]    cp3_fid_ow;

    wire [127:0]    cp0_rob_ow;
    wire [127:0]    cp1_rob_ow;
    wire [127:0]    cp2_rob_ow;
    wire [127:0]    cp3_rob_ow;

    generate

        for (i = 1; i < 32; i = i + 1)  begin

            assign cp0_valid_ow[i * 1 +: 1] = cp0_valid_R[i] ? ~(wed && addrd == i && dind_fid == cp0_fid_R[i]) : 1'b0;
            assign cp1_valid_ow[i * 1 +: 1] = cp1_valid_R[i] ? ~(wed && addrd == i && dind_fid == cp1_fid_R[i]) : 1'b0;
            assign cp2_valid_ow[i * 1 +: 1] = cp2_valid_R[i] ? ~(wed && addrd == i && dind_fid == cp2_fid_R[i]) : 1'b0;
            assign cp3_valid_ow[i * 1 +: 1] = cp3_valid_R[i] ? ~(wed && addrd == i && dind_fid == cp3_fid_R[i]) : 1'b0;

            assign cp0_fid_ow  [i * 8 +: 8] = cp0_fid_R[i];
            assign cp1_fid_ow  [i * 8 +: 8] = cp1_fid_R[i];
            assign cp2_fid_ow  [i * 8 +: 8] = cp2_fid_R[i];
            assign cp3_fid_ow  [i * 8 +: 8] = cp3_fid_R[i];

            assign cp0_rob_ow  [i * 4 +: 4] = cp0_rob_R[i];
            assign cp1_rob_ow  [i * 4 +: 4] = cp1_rob_R[i];
            assign cp2_rob_ow  [i * 4 +: 4] = cp2_rob_R[i];
            assign cp3_rob_ow  [i * 4 +: 4] = cp3_rob_R[i];
        end
    endgenerate

    //
    assign { doutb_valid, doutb_fid, doutb_rob }
        = addrb == 2'd0 ? { cp0_valid_ow, cp0_fid_ow, cp0_rob_ow }
        : addrb == 2'd1 ? { cp1_valid_ow, cp1_fid_ow, cp1_rob_ow }
        : addrb == 2'd2 ? { cp2_valid_ow, cp2_fid_ow, cp2_rob_ow }
        :                 { cp3_valid_ow, cp3_fid_ow, cp3_rob_ow };

    //

endmodule
