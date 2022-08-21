//
// Wake-up History Table (1 entry)
//

module issue_wht (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            wea,
    input   wire [3:0]      dina_rob,
    input   wire [31:0]     dina_value,

    //
    input   wire            web,
    input   wire [3:0]      dinb_rob,
    input   wire [31:0]     dinb_value,

    //
    input   wire [3:0]      qina_rob,
    input   wire            qina_rdy,
    input   wire [31:0]     qina_value,

    output  wire            qouta_rdy,
    output  wire [31:0]     qouta_value,

    //
    input   wire [3:0]      qinb_rob,
    input   wire            qinb_rdy,
    input   wire [31:0]     qinb_value,

    output  wire            qoutb_rdy,
    output  wire [31:0]     qoutb_value
);

    //
    reg         valid_aR;
    reg [3:0]   rob_aR;
    reg [31:0]  value_aR;

    always @(posedge clk) begin

        if (~resetn) begin
            valid_aR <= 'b0;
        end
        else begin
            valid_aR <= wea;
        end

        rob_aR   <= dina_rob;
        value_aR <= dina_value;
    end

    //
    reg         valid_bR;
    reg [3:0]   rob_bR;
    reg [31:0]  value_bR;

    always @(posedge clk) begin

        if (~resetn) begin
            valid_bR <= 'b0;
        end
        else begin
            valid_bR <= web;
        end

        rob_bR   <= dinb_rob;
        value_bR <= dinb_value;
    end


    //
    wire qa_hita;
    wire qa_hitb;
    wire qa_hit;

    wire qb_hita;
    wire qb_hitb;
    wire qb_hit;

    assign qa_hita = valid_aR && (qina_rob == rob_aR);
    assign qa_hitb = valid_bR && (qina_rob == rob_bR);
    assign qa_hit  = qa_hita | qa_hitb;

    assign qb_hita = valid_aR && (qinb_rob == rob_aR);
    assign qb_hitb = valid_bR && (qinb_rob == rob_bR);
    assign qb_hit  = qb_hita | qb_hitb;

    //
    assign qouta_rdy   = qina_rdy ? 1'b1       : qa_hit;
    assign qouta_value = qina_rdy ? qina_value
                       : qa_hita  ? value_aR
                       :            value_bR;

    assign qoutb_rdy   = qinb_rdy ? 1'b1       : qb_hit;
    assign qoutb_value = qinb_rdy ? qinb_value
                       : qb_hita  ? value_aR
                       :            value_bR;

    //

endmodule
