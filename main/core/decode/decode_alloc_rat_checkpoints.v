
module decode_alloc_rat_checkpoints (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            snoop_hit,

    // Checkpoint write/allocation enable & Branch information
    input   wire            en_alloc,

    input   wire            bp_valid,
    input   wire [3:0]      bp_bid,

    // Checkpoint recovery & set invalidation (on BCO)
    input   wire            bco_valid,

    // Checkpoint invalidation (on Branch Commit, sync with BCO)
    input   wire            bc_valid,
    input   wire [3:0]      bc_bid,

    //
    output  wire            readyn
);

    //
    reg [3:0]   valid_R;

    integer i;
    always @(posedge clk) begin

        for (i = 0; i < 4; i = i + 1) begin

            if (~resetn) begin
                valid_R[i] <= 'b0;
            end
            else if (snoop_hit) begin
                valid_R[i] <= 'b0;
            end
            else if (bco_valid) begin
                valid_R[i] <= 'b0;
            end
            else if (bc_valid && (bc_bid[1:0] == i)) begin
                valid_R[i] <= 'b0; 
            end
            else if (en_alloc && bp_valid && (bp_bid[1:0] == i)) begin
                valid_R[i] <= 'b1;
            end
        end
    end

    //
    assign readyn = (valid_R == 4'b1000)
                 || (valid_R == 4'b0100)
                 || (valid_R == 4'b0010)
                 || (valid_R == 4'b0001)
                 || (valid_R == 4'b0011)
                 || (valid_R == 4'b1001)
                 || (valid_R == 4'b1100)
                 || (valid_R == 4'b0110)
                 || (valid_R == 4'b0111)
                 || (valid_R == 4'b1011)
                 || (valid_R == 4'b1101)
                 || (valid_R == 4'b1110)
                 || (valid_R == 4'b1111);

    //

endmodule
