
`define     SRAM_IDLE               3'b000

`define     SRAM_READ_PHASE0        3'b001
`define     SRAM_READ_PHASE1        3'b010
`define     SRAM_READ_PHASE2        3'b011

`define     SRAM_WRITE_PHASE0       3'b101
`define     SRAM_WRITE_PHASE1       3'b110
`define     SRAM_WRITE_PHASE2       3'b111

module soc_sram_ctrl (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            ena,
    input   wire [3:0]      wea,
    input   wire [19:0]     addra,
    input   wire [31:0]     dina,
    output  wire [31:0]     douta,

    output  wire            readya,

    //
    output  wire [19:0]     mem_A,

    output  wire            mem_CEN,
    output  wire            mem_OEN,
    output  wire            mem_WEN,

    output  wire            mem_BE0N,
    output  wire            mem_BE1N,
    output  wire            mem_BE2N,
    output  wire            mem_BE3N,

    inout   wire [31:0]     mem_D
);

    //
    (*MAX_FANOUT = 2 *) reg [2:0]   state_R,    state_next;

    always @(posedge clk) begin

        if (~resetn) begin
            state_R <= `SRAM_IDLE;
        end
        else begin
            state_R <= state_next;
        end
    end

    always @(*) begin

        state_next = state_R;

        case (state_R)

            //
            `SRAM_READ_PHASE2,
            `SRAM_WRITE_PHASE2,
            `SRAM_IDLE: begin

                if (ena) begin

                    if (wea) begin
                        state_next = `SRAM_WRITE_PHASE0;
                    end
                    else begin
                        state_next = `SRAM_READ_PHASE0;
                    end
                end
                else begin
                    state_next = `SRAM_IDLE;
                end
            end

            //
            `SRAM_READ_PHASE0:  begin
                state_next = `SRAM_READ_PHASE1;
            end

            `SRAM_READ_PHASE1:  begin
                state_next = `SRAM_READ_PHASE2;
            end

            //
            `SRAM_WRITE_PHASE0: begin
                state_next = `SRAM_WRITE_PHASE1;
            end

            `SRAM_WRITE_PHASE1: begin
                state_next = `SRAM_WRITE_PHASE2;
            end

            //
            default:    begin
                state_next = state_R;
            end
        endcase
    end

    //
    reg [19:0]  A_R,    A_next;

    reg         CEN_R,  CEN_next;
    reg         OEN_R,  OEN_next;
    (*MAX_FANOUT = 2 *) reg         WEN_R,  WEN_next;

    reg         BE0N_R, BE0N_next;
    reg         BE1N_R, BE1N_next;
    reg         BE2N_R, BE2N_next;
    reg         BE3N_R, BE3N_next;

    reg [31:0]  Dout_R, Dout_next;
    reg [31:0]  Din_R,  Din_next;

    always @(posedge clk) begin

        if (~resetn) begin
            
            CEN_R   <= 1'b1;
            OEN_R   <= 1'b1;
            WEN_R   <= 1'b1;

            BE0N_R  <= 1'b1;
            BE1N_R  <= 1'b1;
            BE2N_R  <= 1'b1;
            BE3N_R  <= 1'b1;
        end
        else begin

            CEN_R   <= CEN_next;
            OEN_R   <= OEN_next;
            WEN_R   <= WEN_next;

            BE0N_R  <= BE0N_next;
            BE1N_R  <= BE1N_next;
            BE2N_R  <= BE2N_next;
            BE3N_R  <= BE3N_next;
        end

        A_R     <= A_next;

        Dout_R  <= Dout_next;
        Din_R   <= Din_next;
    end

    always @(*) begin

        CEN_next    = CEN_R;
        OEN_next    = OEN_R;
        WEN_next    = WEN_R;

        BE0N_next   = BE0N_R;
        BE1N_next   = BE1N_R;
        BE2N_next   = BE2N_R;
        BE3N_next   = BE3N_R;

        A_next      = A_R;

        Dout_next   = Dout_R;
        Din_next    = Din_R;

        case (state_R)

            `SRAM_READ_PHASE2:  begin
                
                Din_next    = mem_D;
            end
        endcase

        case (state_next)

            `SRAM_IDLE: begin

                CEN_next    = 1'b1;
                OEN_next    = 1'b1;
                WEN_next    = 1'b1;

                BE0N_next   = 1'b1;
                BE1N_next   = 1'b1;
                BE2N_next   = 1'b1;
                BE3N_next   = 1'b1;
            end

            `SRAM_READ_PHASE0:  begin

                CEN_next    = 1'b0;
                OEN_next    = 1'b0;
                WEN_next    = 1'b1;

                BE0N_next   = 1'b0;
                BE1N_next   = 1'b0;
                BE2N_next   = 1'b0;
                BE3N_next   = 1'b0;

                A_next      = addra;
            end

            `SRAM_READ_PHASE1:  begin
                //
            end
            
            `SRAM_READ_PHASE2:  begin
                //
            end

            `SRAM_WRITE_PHASE0: begin

                CEN_next    = 1'b0;
                OEN_next    = 1'b1;
                WEN_next    = 1'b0;

                BE0N_next   = ~wea[0];
                BE1N_next   = ~wea[1];
                BE2N_next   = ~wea[2];
                BE3N_next   = ~wea[3];

                A_next      = addra;
                Dout_next   = dina;
            end

            `SRAM_WRITE_PHASE1: begin
                //
            end

            `SRAM_WRITE_PHASE2: begin

                BE0N_next   = 1'b1;
                BE1N_next   = 1'b1;
                BE2N_next   = 1'b1;
                BE3N_next   = 1'b1;
            end

            default:    begin
            end
        endcase
    end


    //
    assign douta  = Din_R;

    assign readya = state_R == `SRAM_IDLE
                 || state_R == `SRAM_READ_PHASE2
                 || state_R == `SRAM_WRITE_PHASE2;


    //
    assign mem_A    = A_R;
    
    assign mem_CEN  = CEN_R;
    assign mem_OEN  = OEN_R;
    assign mem_WEN  = WEN_R;

    assign mem_BE0N = BE0N_R;
    assign mem_BE1N = BE1N_R;
    assign mem_BE2N = BE2N_R;
    assign mem_BE3N = BE3N_R;

    assign mem_D    = ~WEN_R ? Dout_R : 32'hZZZZZZZZ;

    //

endmodule
