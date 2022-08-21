
module execute_mul_sdffs (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            i_valid,
    input   wire [3:0]      i_dst_rob,
    input   wire [7:0]      i_fid,

    //
    output  wire            o_valid,
    output  wire [3:0]      o_dst_rob,
    output  wire [7:0]      o_fid
);
    
    //
    reg         valid_R     [2:0];
    reg [3:0]   dst_rob_R   [2:0];
    reg [7:0]   fid_R       [2:0];

    integer i;
    always @(posedge clk) begin

        //
        if (~resetn) begin
            valid_R[0] <= 'b0;
        end
        else begin
            valid_R[0] <= i_valid;
        end

        dst_rob_R[0] <= i_dst_rob;
        fid_R    [0] <= i_fid;

        //
        for (i = 1; i < 3; i = i + 1) begin

            if (~resetn) begin
                valid_R[i] <= 'b0;
            end
            else begin
                valid_R[i] <= valid_R[i - 1];
            end

            dst_rob_R[i] <= dst_rob_R[i - 1];
            fid_R    [i] <= fid_R    [i - 1];
        end
    end

    //
    assign o_valid      = valid_R  [2];
    assign o_dst_rob    = dst_rob_R[2];
    assign o_fid        = fid_R    [2];

    //

endmodule