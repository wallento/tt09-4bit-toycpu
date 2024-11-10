module cpu(
    input clk,
    input rst,
    input scan_clk,
    input scan_en,

    output scan_out,
    output we,
    output [3:0] addr,
    input [7:0] data_in,
    output [7:0] data_out
);

    localparam NOP = 4'b0000;
    localparam LDA = 4'b0001;
    localparam LDA_IND = 4'b0010;
    localparam STA = 4'b0011;
    localparam ADD = 4'b0100;
    localparam ADD_IND = 4'b0101;
    localparam SUB = 4'b0110;
    localparam SUB_IND = 4'b0111;
    localparam JMP = 4'b1000;
    localparam BRZ = 4'b1001;
    localparam BRC = 4'b1010;
    localparam BRN = 4'b1011;


    wire [3:0] data_bus = data_in[3:0];
    wire [3:0] instruction_bus = data_in[7:4];

    reg [3:0] instruction_register;
    reg [3:0] data_register;
    reg [3:0] accu;
    reg [3:0] program_counter;
    reg C, Z, N;

    always @(posedge clk) begin
        instruction_register <= instruction_bus;
        data_register <= data_bus;
    end

    wire nop, lda, sta, add, sub, jmp, brz, brc, brn, ind;
    wire ld, e, k1, k0, m2, m1;

    assign nop = (instruction_register == NOP);
    assign lda = (instruction_register == LDA) || (instruction_register == LDA_IND);
    assign sta = (instruction_register == STA);
    assign add = (instruction_register == ADD) || (instruction_register == ADD_IND);
    assign sub = (instruction_register == SUB) || (instruction_register == SUB_IND);
    assign jmp = (instruction_register == JMP);
    assign brz = (instruction_register == BRZ);
    assign brc = (instruction_register == BRC);
    assign brn = (instruction_register == BRN);
    assign ind = (instruction_register == LDA_IND) ||
                 (instruction_register == ADD_IND) ||
                 (instruction_register == SUB_IND);


    assign ld = lda;
    assign e = lda | add | sub;
    assign k1 = ~((brz & Z) | (brc & C) | (brn & N) | k0);
    assign k0 = jmp;
    assign we = sta;
    assign m2 = ~clk;
    assign m1 = ~ind;

    assign data_out = { 4'b0, accu };
    reg carry;

    reg [3:0] alu;
    reg c;
    wire [3:0] operand;

    assign operand = m1 ? data_register : data_bus;

    always @(negedge clk) begin
        if (e) begin
            accu <= ld ? operand : alu;
            carry <= c;
        end
    end

    always @(*) begin
        if (sub) begin
            {c, alu} = {1'b0, accu} - {1'b0, operand};
        end else begin
            {c, alu} = {1'b0, accu} + {1'b0, operand};
        end
    end

    always @(posedge clk) begin
        C <= carry;
        Z <= ~(|accu);
        N <= accu[3];
    end


    always @(negedge clk) begin
        if (rst) begin
            program_counter <= 4'b0000;
        end else begin
            if (!k0 && !k1) begin
                program_counter <= program_counter + data_register;
            end else if (!k0 && k1) begin
                program_counter <= program_counter + 1;
            end else if (k0 && !k1) begin
                program_counter <= data_register;
            end
        end
    end

    assign addr = m2 ? program_counter : data_register;

    scan u_scan(
        .clk (scan_clk),
        .en (scan_en),
        .scan_out(scan_out),

        .scan_data({
            instruction_register,
            data_register,
            accu,
            C,
            Z,
            N,
            program_counter
        })
    );

endmodule