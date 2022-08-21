
module commit_snooptable (
    input   wire            clk,
    input   wire            resetn,

    // Clear enable
    input   wire            en_clear,   // clear on single snoop hit

    // Commit enable (on any instruction commit)
    input   wire            en_commit,

    // Snoop address shift-in (on store commit)
    input   wire            wea,
    input   wire [31:0]     dina_addr,

    // Snoop filter query
    input   wire [31:0]     q_addr,
    output  wire            q_hit
);

    //
    reg [26:0]  addr_R  [15:0];
    reg         valid_R [15:0];

    integer i;
    always @(posedge clk or negedge resetn) begin

        if (~resetn) begin

            for (i = 0; i < 16; i = i + 1) begin

                addr_R [i] <= 'b0;
                valid_R[i] <= 'b0;
            end
        end
        else if (wea | en_commit) begin

            if (wea) begin

                addr_R [0] <= dina_addr[31:6];
                valid_R[0] <= 1'b1;
            end
            else begin

                valid_R[0] <= 1'b0;
            end

            for (i = 1; i < 16; i = i + 1) begin

                addr_R [i] <= addr_R [i - 1];
                valid_R[i] <= valid_R[i - 1];
            end
        end
    end

    //
    reg  [15:0] snoop_hit_comb;

    always @(*) begin
        
        for (i = 0; i < 16; i = i + 1) begin
            snoop_hit_comb[i] = valid_R[i] && (q_addr[31:6] == addr_R[i]);
        end
    end

    //
    assign q_hit = |{ snoop_hit_comb };

    //

endmodule
