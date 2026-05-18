module risc_top(
    input clk
);

wire [15:0] instruction;
wire [3:0] pc;

wire [3:0] opcode;
wire [3:0] rd;
wire [3:0] rs;
wire [3:0] imm;

wire [7:0] A;
wire [7:0] B;

wire [7:0] result;

wire [7:0] mem_out;

fetch F1(
    .clk(clk),
    .instruction(instruction),
    .pc(pc)
);

decode D1(
    .instruction(instruction),
    .opcode(opcode),
    .rd(rd),
    .rs(rs),
    .imm(imm)
);

register_file RF1(
    .rs(rs),
    .rd(rd),
    .A(A),
    .B(B)
);

execute E1(
    .opcode(opcode),
    .A(A),
    .B(B),
    .imm(imm),
    .result(result)
);

memory_stage M1(
    .clk(clk),
    .data_in(result),
    .write_enable(1'b1),
    .data_out(mem_out)
);

writeback W1(
    .clk(clk),
    .rd(rd),
    .result(mem_out)
);

endmodule

module fetch(
    input clk,
    output reg [15:0] instruction,
    output reg [3:0] pc
);

reg [15:0] instr_mem [15:0];

initial begin

    pc = 0;
    instruction = 0;

    instr_mem[0] = 16'b0000_0001_0010_0000; // ADD
    instr_mem[1] = 16'b0001_0011_0001_0000; // SUB
    instr_mem[2] = 16'b0100_0100_0000_0101; // MOV

end

always @(posedge clk)
begin
    instruction <= instr_mem[pc];
    pc <= pc + 1;
end

endmodule

module decode(
    input [15:0] instruction,
    output reg [3:0] opcode,
    output reg [3:0] rd,
    output reg [3:0] rs,
    output reg [3:0] imm
);

always @(*)
begin
    opcode = instruction[15:12];
    rd     = instruction[11:8];
    rs     = instruction[7:4];
    imm    = instruction[3:0];
end

endmodule

module execute(
    input [3:0] opcode,
    input [7:0] A,
    input [7:0] B,
    input [3:0] imm,
    output reg [7:0] result
);

always @(*)begin
    result = 0;
    case(opcode)
        4'b0000: result = A + B;
        4'b0001: result = A - B;
        4'b0100: result = imm;
        default: result = 0;
    endcase
end

endmodule

module memory_stage(
    input clk,
    input [7:0] data_in,
    input write_enable,
    output reg [7:0] data_out
);

reg [7:0] data_mem [15:0];
integer i;

initial begin
    // Initialize memory to zero
    for(i = 0; i < 16; i = i + 1)
        data_mem[i] = 0;
    data_out = 0;
end

always @(posedge clk)begin
    // Write operation
    if(write_enable)
        data_mem[0] <= data_in;
    // Read operation
    data_out <= data_mem[0];
end

endmodule

module writeback(
    input clk,
    input [3:0] rd,
    input [7:0] result
);

reg [7:0] registers [7:0];
integer i;

initial begin
    // Initialize all registers to zero
    for(i = 0; i < 8; i = i + 1)
        registers[i] = 0;
end

always @(posedge clk)begin
    // Write result into destination register
    registers[rd] <= result;
end

endmodule

module register_file(
    input [3:0] rs,
    input [3:0] rd,
    output [7:0] A,
    output [7:0] B
);

reg [7:0] registers [7:0];

initial begin
    registers[0] = 8'd5;
    registers[1] = 8'd10;
    registers[2] = 8'd15;
end

assign A = registers[rd];
assign B = registers[rs];

endmodule
