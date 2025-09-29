module sqrt2 (
    inout wire [15:0] IO_DATA,
    output wire IS_NAN,
    output wire IS_PINF,
    output wire IS_NINF,
    output wire RESULT,
    input wire CLK,
    input wire ENABLE
);

    reg [15:0] input_value,
                    output_value;
    
    reg is_result_getted, is_nan_getted, 
            is_pinf_getted, is_ninf_getted, 
                is_p_zero_getted, is_n_zero_getted;

    reg [8:0] counter;

    reg sign;

    reg [15:0] exponent, mantissa;

    reg [23:0] shifted_mantissa,
                    remainder; 
    
    reg [15:0] result;
    
    always @(negedge ENABLE)
    begin
        input_value = 16'bzzzzzzzzzzzzzzzz;
        output_value = 16'bzzzzzzzzzzzzzzzz;
        counter = 8'b00000000;

        is_result_getted = 1'b0;
        is_nan_getted = 1'b0;
        is_pinf_getted = 1'b0;
        is_ninf_getted = 1'b0;
        is_p_zero_getted = 1'b0;
        is_n_zero_getted = 1'b0;

        sign = 1'bz;
        exponent = 16'bzzzzzzzzzzzzzzzz;
        mantissa = 16'bzzzzzzzzzzzzzzzz;

        shifted_mantissa = 24'bzzzzzzzzzzzzzzzzzzzzzzzz;
        remainder = 24'bzzzzzzzzzzzzzzzzzzzzzzzz;
        result = 16'bzzzzzzzzzzzzzzzz;
    end

    always @(negedge CLK) 
    begin
        if (!is_result_getted && ENABLE)
        begin
            
            if (counter == 0)
            begin
                input_value = IO_DATA;
            end

            else if (counter == 1)
            begin
                sign = input_value[15];

                exponent[4:0] = input_value[14:10];
                exponent[15:5] = 10'b0000000000;
                
                mantissa = input_value[9:0];
                mantissa[15:10] = 5'b00000;
                
                if (sign == 1'b1)                                            // negative 
                begin
                    is_result_getted = 1'b1;
                        
                    is_ninf_getted = 1'b0;
                    is_pinf_getted = 1'b0;
                    is_p_zero_getted = 1'b0;
                    is_n_zero_getted = 1'b0;
                    
                    is_nan_getted = 1'b1;
                    output_value = 16'b1111111000000000;
                end
                
                if (exponent[4:0] == 5'b11111) 
                begin

                    if (mantissa[9:0] != 10'b0000000000)                      // nan
                    begin
                        is_result_getted = 1'b1;
                        
                        is_ninf_getted = 1'b0;
                        is_pinf_getted = 1'b0;
                        is_p_zero_getted = 1'b0;
                        is_n_zero_getted = 1'b0;
                        
                        is_nan_getted = 1'b1;
                        output_value = input_value;
                    end
                    
                    else if (mantissa[9:0] == 10'b0000000000 && sign == 1'b0) // pinf
                    begin
                        is_result_getted = 1'b1;
                        
                        is_nan_getted = 1'b0;
                        is_ninf_getted = 1'b0;
                        is_p_zero_getted = 1'b0;
                        is_n_zero_getted = 1'b0;
                        
                        is_pinf_getted = 1'b1;
                        output_value = 16'b0111110000000000;
                    end
                    
                    else                                                      // ninf
                    begin
                        is_result_getted = 1'b1;
                        
                        is_nan_getted = 1'b0;
                        is_pinf_getted = 1'b0;
                        is_p_zero_getted = 1'b0;
                        is_n_zero_getted = 1'b0;
                        
                        is_ninf_getted = 1'b1;
                        output_value = 16'b1111110000000000;
                    end
                end

                if (exponent[4:0] == 5'b00000 && mantissa == 10'b0000000000)
                begin

                    if (sign == 1'b0)                                         // plus zero
                    begin
                        is_result_getted = 1'b1;

                        is_nan_getted = 1'b0;
                        is_pinf_getted = 1'b0;
                        is_ninf_getted = 1'b0;
                        is_n_zero_getted = 1'b0;
                        
                        is_p_zero_getted = 1'b1;
                        output_value = 16'b0000000000000000;
                    end

                    else if (sign == 1'b1)                                    // minus zero
                    begin
                        is_result_getted = 1'b1;

                        is_nan_getted = 1'b0;
                        is_pinf_getted = 1'b0;
                        is_ninf_getted = 1'b0;
                        is_p_zero_getted = 1'b0;
                        
                        is_n_zero_getted = 1'b1;
                        output_value = 16'b1000000000000000;
                    end
                end

                if ((exponent[4:0] == 5'b00000 && mantissa[9:0] != 10'b0000000000))
                begin
                    exponent = 16'b0000000000010010;
                    casez (mantissa)
                        16'b0000001?????????: begin mantissa = mantissa << 1; 
                                                    exponent = 17;
                                              end
                        16'b00000001????????: begin mantissa = mantissa << 2; 
                                                    exponent = 16; 
                                              end
                        16'b000000001???????: begin mantissa = mantissa << 3; 
                                                    exponent = 15; 
                                              end
                        16'b0000000001??????: begin mantissa = mantissa << 4; 
                                                    exponent = 14; 
                                              end
                        16'b00000000001?????: begin mantissa = mantissa << 5; 
                                                    exponent = 13; 
                                              end
                        16'b000000000001????: begin mantissa = mantissa << 6; 
                                                    exponent = 12; 
                                              end
                        16'b0000000000001???: begin mantissa = mantissa << 7; 
                                                    exponent = 11; 
                                              end
                        16'b00000000000001??: begin mantissa = mantissa << 8; 
                                                    exponent = 10; 
                                              end
                        16'b000000000000001?: begin mantissa = mantissa << 9;
                                                    exponent = 9; 
                                              end
                        16'b0000000000000001: begin mantissa = mantissa << 10;
                                                    exponent = 8; 
                                              end 
                    endcase
                end
                
                else 
                begin
                    exponent  = exponent + 17;
                    mantissa |= 16'b0000010000000000;
                end

                if (exponent [0] & 1'b1)
                begin
                    mantissa = mantissa << 1'b1;
                    exponent  = exponent - 1'b1;
                end
                
                exponent = ((exponent - 6'b100000) >> 1'b1) + 4'b1111;

                result = 16'b0000000000000000;
                remainder = 24'b000000000000000000000000;
                shifted_mantissa [9:0] = 10'b0000000000;
                shifted_mantissa [21:10] = mantissa[11:0];
                shifted_mantissa[23:22] = 3'b000;
            end

            if (counter >= 2'b10 && is_result_getted == 1'b0)
            begin
                remainder = remainder << 2'b10;
                remainder[1:0] = shifted_mantissa[21:20];
                shifted_mantissa = shifted_mantissa << 2'b10;

                if (remainder < ((result << 2'b10) + 1'b1))
                begin
                    result = result << 1'b1;

                end

                else
                begin
                    remainder = remainder - ((result << 2'b10) + 1'b1);
                    result = (result << 1'b1) + 1'b1;
                end 
                // $display("dbg: %b", result);
            end
            
            if (counter >= 2)
            begin
                output_value [15] = sign;
                output_value [14:10] = exponent;
                output_value [9:0] = result;
            end

            if (counter == 12)
            begin
                is_result_getted = 1'b1;
            end
        end
        counter = counter + 1'b1;
    end

    assign IO_DATA = output_value;
    assign RESULT = is_result_getted;
    assign IS_NINF = is_ninf_getted;
    assign IS_PINF = is_pinf_getted;
    assign IS_NAN = is_nan_getted;
endmodule