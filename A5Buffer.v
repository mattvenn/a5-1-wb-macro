module A5Buffer (
    input wire clk,
    input wire reset_n,
    output wire [31:0] data_out,
    output wire empty,
    input wire rd_en
);

wire fifo_full;
reg fifo_wr_en;
reg [31:0] shift_reg;
wire a5_out;
wire lfsr_clk_en = ~fifo_full;

A5Generator A5Generator(
    .clk(clk),
    .reset_n(reset_n),
    .lfsr_clk_en(lfsr_clk_en),
    .d(a5_out)
);

Fifo #(
    .data_width(32),
    .depth(4)
) Fifo (
    .clk(clk),
    .reset_n(reset_n),
    .flush(1'b0),
    .wr_en(fifo_wr_en),
    .wr_data(shift_reg),
    .rd_en(rd_en),
    .rd_data(data_out),
    .empty(empty),
    .full(fifo_full)
);

always @(posedge clk or negedge reset_n)
    if (!reset_n)
        {fifo_wr_en, shift_reg} <= 33'b1;
    else
        {fifo_wr_en, shift_reg} <= fifo_wr_en ? 33'b1 :
            lfsr_clk_en ? {shift_reg[31:0], a5_out} : {fifo_wr_en, shift_reg};

endmodule