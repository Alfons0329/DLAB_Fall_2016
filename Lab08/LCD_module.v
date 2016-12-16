
module LCD_module(
  input clk,
  input reset,
  input [127:0] row_A,
  input [127:0] row_B,
  output LCD_E,
  output LCD_RS,     // register select or not
  output LCD_RW,     // read/write the lcd module or not
  output [3:0] LCD_D // 1602 lcd data
  );

reg lcd_inited;

reg [23:0] init_count;
reg [3:0] init_d, icode;
reg init_e, init_rs, init_rw;

reg [23:0] text_count;
reg [3:0] text_d, mytcode;
reg text_e, text_rs, text_rw;

// Signal drivers for the 1602 LCD module if it is initialized we write text or write the initialize part
assign LCD_E  = (lcd_inited)? text_e  : init_e;
assign LCD_RS = (lcd_inited)? text_rs : init_rs;
assign LCD_RW = (lcd_inited)? text_rw : init_rw;
assign LCD_D  = (lcd_inited)? text_d  : init_d;

// The initialization sequence (Run once at boot up).
always @(posedge clk) begin
  if (reset) begin
    lcd_inited <= 0;
    init_count <= 0;
    init_d  <= 4'h0;
    init_e  <= 0;
    init_rs <= 0;
    init_rw <= 1;
  end
  else if (!lcd_inited) begin
    init_count <= init_count + 1;

    // Enable the LCD when bit 19 of the init_count is 1 since we have to wait over 750000 clock cycles
    // The command frequency is 50MHz/(2*2^20) = 23.84 Hz
	//or say the interval is 1/23.84=0.04s(40ms)  (enough dor the lower
	//bound of data stabalization )(since only works when init_e==1) and for init_e==0 , the system idles
    init_e  <= init_count[19];
    init_rs <= 0;
    init_rw <= 0;
    init_d  <= icode;

    case (init_count[23:20])
     0: icode <= 4'h3; // Power-on init sequence. It cause the LCD
     1: icode <= 4'h3; // to flicker if there are characters on the
     2: icode <= 4'h3; // display. So only do this once at the
     3: icode <= 4'h2; // begining.

    // Function Set. Set to 4-bit mode, 2 text lines, and 5x8 text
     4: icode <= 4'h2; // Upper nibble 0010
     5: icode <= 4'h8; // Lower nibble 1000

    // Entry Mode Set. Upper nibble: 0000, lower nibble: 0 1 I/D S
    // upper nibble: I/D bit (Incr 1, Decr 0), S bit (Shift 1, no shift 0)
     6: icode <= 4'h0; // Upper nibble 0000
     7: icode <= 4'h6; // Lower nibble 0110: Incr, Shift disabled

    // Display On/Off. Upper nibble: 0000, lower nibble 1 D C B
    // D: 1, display on, 0 off
    // C: 1, show cursor, 0 don't
    // B: 1, cursor blinks (if shown), 0 don't blink (if shown)
     8: icode <= 4'h0; // Upper nibble 0000
     9: icode <= 4'hC; // Lower nibble 1100

    // Clear Display. Upper nibble 0000, lower nibble 0001
    10: icode <= 4'h0; // Upper nibble 0000
    11: icode <= 4'h1; // Lower nibble 0001

    // We should read the Busy Flag and Address after each command
    // to determine whether we can move on to the next command.
    // However, our init counter runs quite slowly that most 1602
    // LCDs should have plenty of time to finish each command.
    default: { init_rw, lcd_inited } <= 2'b11;
    endcase
  end
end

// The text refreshing sequence.
always @(posedge clk) begin
  if (reset) begin
    text_count <= 0;
    text_d  <= 4'h0;
    text_e  <= 0;
    text_rs <= 0;
    text_rw <= 0;
  end
  else if (lcd_inited) begin
    text_count <= (text_count[23:17] < 68)? text_count + 1 : 0;

    // Refresh (enable) the LCD when bit 16 of the text_count is 1 which means until the 
	//writing data is stabalized for some time
	//2^16/50M=0.001 (1ms , enough for the data stable writing)
    // The command clock frequency is 50MHz/(2^17) = 381.47 Hz
    // The screen refresh frequency is 381.47Hz/68 = 5.60 Hz
    text_e  <= text_count[16]; //2^16/50M=0.001 (1ms , enough for the data stable writing)
	//text e good , OK for text writing
    text_rs <= 1;
    text_rw <= 0;
    text_d <= mytcode;

    case (text_count[23:17])
    // Position the cursor to the start of the first line.
    // Upper nibble is 1???, where ??? is the highest 3 bits of
    // the RAM address to move the cursor to.
    // Lower nibble is the lower 4 bits of the RAM address.
     0: { text_rs, text_rw, mytcode } <= 6'b001000;
     1: { text_rs, text_rw, mytcode } <= 6'b000000;

    // Print chararters by writing data to DD RAM (or CG RAM).
    // The cursor will advance to the right end of the screen.
     2: mytcode <= row_A[127:124]; //LCD Data writing content
     3: mytcode <= row_A[123:120]; //LCD Data writing content
     4: mytcode <= row_A[119:116]; //LCD Data writing content
     5: mytcode <= row_A[115:112]; //LCD Data writing content
     6: mytcode <= row_A[111:108]; //LCD Data writing content
     7: mytcode <= row_A[107:104]; //LCD Data writing content
     8: mytcode <= row_A[103:100]; //LCD Data writing content
     9: mytcode <= row_A[99 :96 ]; //LCD Data writing content
    10: mytcode <= row_A[95 :92 ]; //LCD Data writing content
    11: mytcode <= row_A[91 :88 ]; //LCD Data writing content
    12: mytcode <= row_A[87 :84 ]; //LCD Data writing content
    13: mytcode <= row_A[83 :80 ]; //LCD Data writing content
    14: mytcode <= row_A[79 :76 ]; //LCD Data writing content
    15: mytcode <= row_A[75 :72 ]; //LCD Data writing content
    16: mytcode <= row_A[71 :68 ]; //LCD Data writing content
    17: mytcode <= row_A[67 :64 ]; //LCD Data writing content
    18: mytcode <= row_A[63 :60 ]; //LCD Data writing content
    19: mytcode <= row_A[59 :56 ]; //LCD Data writing content
    20: mytcode <= row_A[55 :52 ]; //LCD Data writing content
    21: mytcode <= row_A[51 :48 ]; //LCD Data writing content
    22: mytcode <= row_A[47 :44 ]; //LCD Data writing content
    23: mytcode <= row_A[43 :40 ]; //LCD Data writing content
    24: mytcode <= row_A[39 :36 ]; //LCD Data writing content
    25: mytcode <= row_A[35 :32 ]; //LCD Data writing content
    26: mytcode <= row_A[31 :28 ]; //LCD Data writing content
    27: mytcode <= row_A[27 :24 ]; //LCD Data writing content
    28: mytcode <= row_A[23 :20 ]; //LCD Data writing content
    29: mytcode <= row_A[19 :16 ]; //LCD Data writing content
    30: mytcode <= row_A[15 :12 ]; //LCD Data writing content
    31: mytcode <= row_A[11 :8  ]; //LCD Data writing content
    32: mytcode <= row_A[7  :4  ]; //LCD Data writing content
    33: mytcode <= row_A[3  :0  ]; //LCD Data writing content

    // position the cursor to the start of the 2nd line
    34: { text_rs, text_rw, mytcode } <= 6'b001100;
    35: { text_rs, text_rw, mytcode } <= 6'b000000;

    // Print chararters by writing data to DD RAM (or CG RAM).
    // The cursor will advance to the right end of the screen.
    36: mytcode <= row_B[127:124]; //LCD Data writing content
    37: mytcode <= row_B[123:120]; //LCD Data writing content
    38: mytcode <= row_B[119:116]; //LCD Data writing content
    39: mytcode <= row_B[115:112]; //LCD Data writing content
    40: mytcode <= row_B[111:108]; //LCD Data writing content
    41: mytcode <= row_B[107:104]; //LCD Data writing content
    42: mytcode <= row_B[103:100]; //LCD Data writing content
    43: mytcode <= row_B[99 :96 ]; //LCD Data writing content
    44: mytcode <= row_B[95 :92 ]; //LCD Data writing content
    45: mytcode <= row_B[91 :88 ]; //LCD Data writing content
    46: mytcode <= row_B[87 :84 ]; //LCD Data writing content
    47: mytcode <= row_B[83 :80 ]; //LCD Data writing content
    48: mytcode <= row_B[79 :76 ]; //LCD Data writing content
    49: mytcode <= row_B[75 :72 ]; //LCD Data writing content
    50: mytcode <= row_B[71 :68 ]; //LCD Data writing content
    51: mytcode <= row_B[67 :64 ]; //LCD Data writing content
    52: mytcode <= row_B[63 :60 ]; //LCD Data writing content
    53: mytcode <= row_B[59 :56 ]; //LCD Data writing content
    54: mytcode <= row_B[55 :52 ]; //LCD Data writing content
    55: mytcode <= row_B[51 :48 ]; //LCD Data writing content
    56: mytcode <= row_B[47 :44 ]; //LCD Data writing content
    57: mytcode <= row_B[43 :40 ]; //LCD Data writing content
    58: mytcode <= row_B[39 :36 ]; //LCD Data writing content
    59: mytcode <= row_B[35 :32 ]; //LCD Data writing content
    60: mytcode <= row_B[31 :28 ]; //LCD Data writing content
    61: mytcode <= row_B[27 :24 ]; //LCD Data writing content
    62: mytcode <= row_B[23 :20 ]; //LCD Data writing content
    63: mytcode <= row_B[19 :16 ]; //LCD Data writing content
    64: mytcode <= row_B[15 :12 ]; //LCD Data writing content
    65: mytcode <= row_B[11 :8  ]; //LCD Data writing content
    66: mytcode <= row_B[7  :4  ]; //LCD Data writing content
    67: mytcode <= row_B[3  :0  ]; //LCD Data writing content
    default: { text_rs, text_rw, mytcode } <= 6'h10; // default to read mode. (00"010000") text_rs=0 text_rw=1 mytcode=0000 default
    endcase
  end
end

endmodule
