module scan
#(
    parameter CHAIN = 0
)
(
    input clk,
    input en,
    output scan_out,

    input [18:0] scan_data
);

    reg last_en;

    always @(posedge clk) begin
        last_en <= en;
    end

    generate
        if (CHAIN == 0) begin
            reg [4:0] count;

            always @(posedge clk) begin
                if (en & !last_en) begin
                    count <= 0;
                end else begin
                    count <= count + 1;
                end
            end

            assign scan_out = scan_data[count];
        end else begin
            reg [18:0] chain;

            always @(posedge clk) begin
                if (en & !last_en) begin
                    chain <= scan_data;
                end else begin
                    chain[17:0] <= chain[18:1];
                end
            end

            assign scan_out = chain[0];
        end
    endgenerate

endmodule