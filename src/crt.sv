`default_nettype none

module crt(
        input        clk,
        input       [7:0] x,
        input       [7:0] y,
        input        rst,
        // output [7:0] out,
        output reg signal,
        output signed [7:0] DEBUG
    );

    initial signal = 1'b1;

    // Pixel counter
    reg [7:0] count_reg = 0;
    // 'X' register
    reg signed [7:0] reg_X = 1;

    // ROM connections
    wire [7:0] rom_addr;
    wire signed [7:0] rom_data;
    ROM rom_instance (.addr(rom_addr), .data(rom_data));

    // last read from ROM
    reg signed [7:0] cur_rom = 0;
    // Read addr
    assign rom_addr = count_reg;


    wire signed [7:0] pixel_diff;
    assign pixel_diff = x - reg_X;


    // DEBUG
    assign DEBUG = count_reg;


    // Pixel clock
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_X <= 1;
            count_reg <= 0;
            signal <= 1'b1;
        end else begin
            // Next pixel
            count_reg <= count_reg + 1;
            // Evaluate addx
            reg_X <= reg_X + cur_rom;
            // PIXEL OUTPUT
            signal <= (pixel_diff == 0) | (pixel_diff == -1) | (pixel_diff == 1);
            // rom_addr <= 8'b00000000;
            // rom_req_read <= 1'b1;
            // rom_req_read <= 1'b0;
        end
    end


    // Read rom when rom is ready
    always @(negedge clk) begin
        cur_rom <= rom_data;
    end
endmodule