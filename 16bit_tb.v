module testbench;

reg clk;

risc_top uut(
    .clk(clk)
);

initial begin
    clk = 0;
end

always #5 clk = ~clk;

initial begin
    #100;
    $finish;
end

endmodule
