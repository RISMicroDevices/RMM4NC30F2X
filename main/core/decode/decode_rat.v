
module decode_rat (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    // Query - src0
    input   wire [4:0]      addra,

    output  wire            douta_valid,
    output  wire [3:0]      douta_rob,
    
    // Query - src1
    input   wire [4:0]      addrb,

    output  wire            doutb_valid,
    output  wire [3:0]      doutb_rob,

    // ROB allocate
    input   wire [4:0]      addrc,
    input   wire            wec,

    input   wire [7:0]      dinc_fid,
    input   wire [3:0]      dinc_rob,

    // ROB commit
    input   wire [4:0]      addre,
    input   wire            wee,

    input   wire [7:0]      dine_fid,

    // Refresh on BCO
    input   wire            bco_valid
);
    
    //
    genvar i;


    //
    reg         valid_R [31:1];
    reg  [7:0]  fid_R   [31:1];
    reg  [3:0]  rob_R   [31:1];

    generate 
        for (i = 1; i < 32; i = i + 1) begin : GENERATED_DECODE_RAT_ENTRY

            wire i_en_al, i_en_cm;

            assign i_en_al = wec && (addrc == i);
            assign i_en_cm = wee && (addre == i) && (dine_fid == fid_R[i]);

            always @(posedge clk) begin

                if (~resetn) begin

                    valid_R [i] <= 'b0;
                end
                else if (snoop_hit) begin

                    valid_R [i] <= 'b0;
                end
                else if (bco_valid) begin

                    valid_R [i] <= 'b0;
                end
                else if (i_en_al) begin
                    
                    valid_R [i] <= 'b1;
                    fid_R   [i] <= dinc_fid;
                    rob_R   [i] <= dinc_rob;
                end
                else if (i_en_cm) begin

                    valid_R [i] <= 1'b0;
                end
            end
        end
    endgenerate

    //
    assign douta_valid  = addra == 'b0 ? 'b0 : valid_R [addra];
    assign douta_rob    = addra == 'b0 ? 'b0 : rob_R   [addra];

    assign doutb_valid  = addrb == 'b0 ? 'b0 : valid_R [addrb];
    assign doutb_rob    = addrb == 'b0 ? 'b0 : rob_R   [addrb];

    //

endmodule
