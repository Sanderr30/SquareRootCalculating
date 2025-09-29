`include "sqrt2.sv"

module 
    test_module(
    input wire[15:0] IO_DATA,
    input wire IS_NAN,
    input wire IS_PINF,
    input wire IS_NINF,
    input wire RESULT,
    input wire CLK,
    input wire ENABLE
);
endmodule 


module sqrt2_tb;
    wire CLK;
    wire [15:0] IO_DATA;
    wire IS_NAN;
    wire IS_PINF;
    wire IS_NINF;
    wire RESULT;
    wire ENABLE;


    sqrt2 my_sqrt_checker (
        .IO_DATA(IO_DATA),
        .IS_NAN(IS_NAN),
        .IS_PINF(IS_PINF),
        .IS_NINF(IS_NINF),
        .RESULT(RESULT),
        .CLK(CLK),
        .ENABLE(ENABLE)
    );

    test_module correct_sqrt_checker (
        .IO_DATA(IO_DATA),
        .IS_NAN(IS_NAN),
        .IS_PINF(IS_PINF),
        .IS_NINF(IS_NINF),
        .RESULT(RESULT),
        .CLK(CLK),
        .ENABLE(ENABLE)
    );


    reg clk;
    reg enable = 1;
    reg[3:0] counter = 0;
    reg[15:0] inpout_value;

    initial clk = 0;
    
    assign CLK = clk;
    assign ENABLE = enable;
    assign IO_DATA = inpout_value;

    always #1 clk = ~clk;

    integer output_file;

    initial begin
        output_file = $fopen("sqrt2_tb.csv", "w");
        $fdisplay(output_file, "│ %8s │ %3s │ %6s │ %6s │ %7s │ %7s │ %8s  │", "TIME", "CLK", "RESULT", "IS_NAN", "IS_PINF", "IS_NINF", "IO_DATA");
        $fdisplay(output_file, "├──────────┼─────┼────────┼────────┼─────────┼─────────┼──────────┤\n\n");


// ///////////////////////////////////////////////////////////////////////////////////        
        $fstrobe(output_file, "\n\nPLUS ZERO TEST (0x0000 -> 0x0000)");
        #0
        enable = 0;
        enable = 1;
        inpout_value = 16'h0000;

        #3
        inpout_value = 16'hzzzz;

        #25
        counter = counter + 1;


// ///////////////////////////////////////////////////////////////////////////////////
		$fstrobe(output_file, "\n\nMINUS ZERO TEST (0x8000 -> 0x8000)");
        #0 
        enable = 0;
        enable = 1;
        inpout_value = 16'h8000;

        #3
        inpout_value = 16'hzzzz;

        #25
        counter = counter + 1;


// ///////////////////////////////////////////////////////////////////////////////////
		$fstrobe(output_file, "\n\nNEGATIVE(QUIET NAN) TEST(0x8234 -> 0xFE00)");
        #0 
        enable = 0;
        enable = 1;
        inpout_value = 16'h8234;

        #3
        inpout_value = 16'hzzzz;

        #25
        counter = counter + 1;


// ///////////////////////////////////////////////////////////////////////////////////
		$fstrobe(output_file, "\n\nNAN TEST(0x7E08 -> 0x7E08)");
        #0 
        enable = 0;
        enable = 1;
        inpout_value = 16'h7E08;

        #3
        inpout_value = 16'hzzzz;

        #25
        counter = counter + 1;
        

// ///////////////////////////////////////////////////////////////////////////////////
		$fstrobe(output_file, "\n\nPLUS INFINITY TEST(0x7C00 -> 0x7C00)");
        #0 
        enable = 0;
        enable = 1;
        inpout_value = 16'h7C00;

        #3
        inpout_value = 16'hzzzz;

        #25
        counter = counter + 1;


// ///////////////////////////////////////////////////////////////////////////////////
		$fstrobe(output_file, "\n\nMINUS INFINITY TEST(0xFC00 -> 0xFC00)");
        #0 
        enable = 0;
        enable = 1;
        inpout_value = 16'hFC00;

        #3
        inpout_value = 16'hzzzz;

        #25
        counter = counter + 1;
        

// ///////////////////////////////////////////////////////////////////////////////////
		$fstrobe(output_file, "\n\nDENORMAL TEST(0x0001 -> 0x0C00)");
        #0 
        enable = 0;
        enable = 1;
        inpout_value = 16'h0001;

        #3
        inpout_value = 16'hzzzz;

        #25
        counter = counter + 1;


// ///////////////////////////////////////////////////////////////////////////////////
		$fstrobe(output_file, "\n\nDENORMAL TEST(0x0085 -> 0x19C4)");
        #0 
        enable = 0;
        enable = 1;
        inpout_value = 16'h0085;

        #3
        inpout_value = 16'hzzzz;

        #25
        counter = counter + 1;

        
// ///////////////////////////////////////////////////////////////////////////////////
		$fstrobe(output_file, "\n\nDENORMAL(NEGATIVE) TEST(0x80A1 -> 0xFE00)");
        #0 
        enable = 0;
        enable = 1;
        inpout_value = 16'h80A1;

        #3
        inpout_value = 16'hzzzz;

        #25
        counter = counter + 1;
        

// ///////////////////////////////////////////////////////////////////////////////////
		$fstrobe(output_file, "\n\USUAL TEST(0x1234 -> 0x270B)");
        #0 
        enable = 0;
        enable = 1;
        inpout_value = 16'h1234;

        #3
        inpout_value = 16'hzzzz;

        #25
        counter = counter + 1;


// ///////////////////////////////////////////////////////////////////////////////////
		$fstrobe(output_file, "\n\USUAL TEST(0x3514 -> 0x3881)");
        #0 
        enable = 0;
        enable = 1;
        inpout_value = 16'h3514;

        #3
        inpout_value = 16'hzzzz;

        #25
        counter = counter + 1;

        $finish;
    end


    always @(negedge CLK) 
    begin
        if (ENABLE) 
        begin
            $fstrobe(output_file, "│ %8t │ %3d │ %6d │ %6d │ %7d │ %7d │  0x%04h  │",
                                    $time, CLK, RESULT, IS_NAN, IS_PINF, IS_NINF, IO_DATA);
        end
    end

endmodule