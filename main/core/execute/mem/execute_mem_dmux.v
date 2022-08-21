
module execute_mem_dmux (
    //
    input   wire            s_byte,
    input   wire [1:0]      s_addr,
    input   wire            s_uncached,

    //
    input   wire            dcache_hit,
    input   wire [31:0]     dcache_data,

    //
    input   wire [3:0]      storebuffer_qstrb,
    input   wire [31:0]     storebuffer_qdata,

    //
    input   wire [3:0]      postcmtbuffer_qstrb,
    input   wire [31:0]     postcmtbuffer_qdata,

    //
    output  wire            o_valid,
    output  wire [31:0]     o_data
);

    //
    integer i;
    genvar  j;


    //
    wire [3:0]  vmask_word;
    wire [3:0]  vmask_byte;

    assign vmask_word = 4'b1111;

    assign vmask_byte = { s_addr == 2'd3,
                          s_addr == 2'd2,
                          s_addr == 2'd1,
                          s_addr == 2'd0 };

    //
    wire [3:0]  vmask;

    assign vmask = s_byte ? vmask_byte
                 :          vmask_word;


    //
    wire [7:0]  bn_data [3:0];
    wire        bn_strb [3:0];

    generate
        for (j = 0; j < 4; j = j + 1) begin

            assign bn_data[j] = storebuffer_qstrb  [j] ? storebuffer_qdata  [j * 8 +: 8]
                              : postcmtbuffer_qstrb[j] ? postcmtbuffer_qdata[j * 8 +: 8]
                              :                          dcache_data        [j * 8 +: 8];  

            assign bn_strb[j] = dcache_hit | postcmtbuffer_qstrb[j] | storebuffer_qstrb[j];
        end
    endgenerate


    //
    assign o_valid = ( ~vmask[0] | bn_strb[0] )
                   & ( ~vmask[1] | bn_strb[1] )
                   & ( ~vmask[2] | bn_strb[2] )
                   & ( ~vmask[3] | bn_strb[3] )
                   &   ~s_uncached;

    assign o_data  = s_byte ? { 24'b0, bn_data[s_addr] }
                   :          { bn_data[3], bn_data[2], bn_data[1], bn_data[0] };

    //

endmodule
