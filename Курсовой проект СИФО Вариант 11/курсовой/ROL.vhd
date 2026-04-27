module roll(input wire [7:0] data_1, input wire [7:0] data_2,output wire [7:0] result);
result  <= data_1 rol CONV_INTEGER(data_2);
endmodule
