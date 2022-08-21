`include "axi_def.v"

module axi_agu32 #(
    parameter   FIRST_ADDRESS_FALL_THROUGH      = 1
) (
    input   wire            clk,
    input   wire            resetn,

    //
    input   wire            set_en,
    input   wire [31:0]     set_addr,
    input   wire [1:0]      set_burst_type,
    input   wire [2:0]      set_burst_size,
    input   wire [7:0]      set_burst_len,

    //
    input   wire            incr_en,

    //
    output  wire [31:0]     o_addr,
    output  wire            o_last
);

    //
    reg [1:0]   burst_type_R;
    reg [2:0]   burst_size_R;
    reg [7:0]   burst_len_R;

    always @(posedge clk) begin

        if (set_en) begin

            burst_type_R    <= set_burst_type;
            burst_size_R    <= set_burst_size;
            burst_len_R     <= set_burst_len;
        end
    end

    //
    reg [31:0]  addr_R;
    reg [7:0]   counter_R;

    always @(posedge clk) begin

        if (set_en) begin

            addr_R      <= set_addr;
            counter_R   <= incr_en ? 8'd1 : 8'd0;
        end
        else if (incr_en) begin

            counter_R   <= counter_R + 'd1;
        end
    end

    //
    reg [31:0]  o_addr_comb;

    always @(*) begin

        case (burst_type_R)

            `AXI_BURST_TYPE_FIXED:  begin
                o_addr_comb = addr_R;
            end

            `AXI_BURST_TYPE_INCR:   begin
                o_addr_comb = addr_R + ({ 24'b0, counter_R } << burst_size_R);
            end

            `AXI_BURST_TYPE_WRAP:   begin

                case (burst_len_R)

                    //
                    `AXI_BURST_LEN_2:   begin

                        case (burst_size_R)

                            `AXI_BURST_SIZE_1:  begin
                                o_addr_comb = { addr_R[31:1], addr_R[0] + counter_R[0] };
                            end

                            `AXI_BURST_SIZE_2:  begin
                                o_addr_comb = { addr_R[31:2], addr_R[1] + counter_R[0], 1'b0 };
                            end

                            `AXI_BURST_SIZE_4:  begin
                                o_addr_comb = { addr_R[31:3], addr_R[2] + counter_R[0], 2'b0 }; 
                            end

                            default:    begin
                                o_addr_comb = addr_R;
                            end
                        endcase
                    end

                    //
                    `AXI_BURST_LEN_4:   begin

                        case (burst_size_R)

                            `AXI_BURST_SIZE_1:  begin
                                o_addr_comb = { addr_R[31:2], addr_R[1:0] + counter_R[1:0] };
                            end

                            `AXI_BURST_SIZE_2:  begin
                                o_addr_comb = { addr_R[31:3], addr_R[2:1] + counter_R[1:0], 1'b0 };
                            end

                            `AXI_BURST_SIZE_4:  begin
                                o_addr_comb = { addr_R[31:4], addr_R[3:2] + counter_R[1:0], 2'b0 };
                            end

                            default:    begin
                                o_addr_comb = addr_R;
                            end
                        endcase
                    end

                    //
                    `AXI_BURST_LEN_8:   begin

                        case (burst_size_R)

                            `AXI_BURST_SIZE_1:  begin
                                o_addr_comb = { addr_R[31:3], addr_R[2:0] + counter_R[2:0] };
                            end

                            `AXI_BURST_SIZE_2:  begin
                                o_addr_comb = { addr_R[31:4], addr_R[3:1] + counter_R[2:0], 1'b0 };
                            end

                            `AXI_BURST_SIZE_4:  begin
                                o_addr_comb = { addr_R[31:5], addr_R[4:2] + counter_R[2:0], 2'b0 };
                            end

                            default:    begin
                                o_addr_comb = addr_R;
                            end
                        endcase
                    end

                    `AXI_BURST_LEN_16:  begin
                        
                        case (burst_size_R)

                            `AXI_BURST_SIZE_1:  begin
                                o_addr_comb = { addr_R[31:4], addr_R[3:0] + counter_R[3:0] };
                            end

                            `AXI_BURST_SIZE_2:  begin
                                o_addr_comb = { addr_R[31:5], addr_R[4:1] + counter_R[3:0], 1'b0 };
                            end

                            `AXI_BURST_SIZE_4:  begin
                                o_addr_comb = { addr_R[31:6], addr_R[5:2] + counter_R[3:0], 2'b0 };
                            end
                            
                            default:    begin
                                o_addr_comb = addr_R;
                            end
                        endcase
                    end

                    default:    begin
                        o_addr_comb = addr_R;
                    end
                endcase
            end
            
            default:    begin
                o_addr_comb = addr_R;
            end

        endcase
    end

    //
    assign o_addr = (FIRST_ADDRESS_FALL_THROUGH && set_en) ? set_addr
                  : o_addr_comb;

    assign o_last = (FIRST_ADDRESS_FALL_THROUGH && set_en) ? (set_burst_len == `AXI_BURST_LEN_1)
                  : (counter_R == burst_len_R);

    //

endmodule