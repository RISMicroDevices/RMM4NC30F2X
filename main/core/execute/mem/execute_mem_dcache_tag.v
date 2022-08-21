
module execute_mem_dcache_tag (
    input   wire            clk,
    input   wire            resetn,

    // Tag write
    input   wire            wea,
    input   wire [7:0]      addra,
    input   wire            dina_valid,
    input   wire [18:0]     dina_tag,

    // Tag read - Port 0
    input   wire [7:0]      addrb,
    output  wire            doutb_valid,
    output  wire [18:0]     doutb_tag,

    // Tag read - Port 1
    input   wire [7:0]      addrc,
    output  wire            doutc_valid,
    output  wire [18:0]     doutc_tag
);

    //
    integer i;
    genvar  j;


    //
                                   reg         valid_R [255:0];
    (*ram_style = "distributed" *) reg [18:0]  tag_R   [255:0];

    always @(posedge clk) begin

        for (i = 0; i < 256; i = i + 1) begin

            if (~resetn) begin
                valid_R[i] <= 'b0;
            end
            else if (wea && addra == i) begin
                valid_R[i] <= dina_valid;
            end
        end
    end

    always @(posedge clk) begin

        if (wea) begin
            tag_R[addra] <= dina_tag;
        end
    end

    //
    assign doutb_valid  = valid_R[addrb];
    assign doutb_tag    = tag_R  [addrb];

    //
    assign doutc_valid  = valid_R[addrc];
    assign doutc_tag    = tag_R  [addrc];

    //

endmodule
