module SS_Driver(
input Clk, Reset,
input      [3:0]BCD3, BCD2, BCD1, BCD0, // Binary-coded decimal input
input			[7:0]PWM,
output reg [7:0]SegmentDrivers,         // Digit drivers (active low)
//output reg [7:4]SegmentDrivers,
output reg [7:0]SevenSegment            // Segments (active low)
);
//------------------------------------------------------------------------------
// Make use of a subcircuit to decode the BCD to seven-segment (SS)
wire [6:0]SS[3:0];
BCD_Decoder BCD_Decoder0(BCD0, SS[0]);
BCD_Decoder BCD_Decoder1(BCD1, SS[1]);
BCD_Decoder BCD_Decoder2(BCD2, SS[2]);
BCD_Decoder BCD_Decoder3(BCD3, SS[3]);
//------------------------------------------------------------------------------
// Counter to reduce the 100 MHz clock to 762.939 Hz (100 MHz / 2^17)
reg [16:0]Count;
reg [7:0]pwmCount;
// Scroll through the digits, switching one on at a time
always @(posedge Clk) begin
Count <= Count + 1'b1;
pwmCount<=pwmCount + 1'b1;
if     ( Reset) SegmentDrivers <= 8'hE;
else if(&Count) SegmentDrivers <= {SegmentDrivers[6:0], SegmentDrivers[7]};
end
//------------------------------------------------------------------------------
always @(*) begin // This describes a purely combinational circuit
SevenSegment[7] <= 1'b1; // Decimal point always off
if(Reset) begin
SevenSegment[6:0] <= 7'h7F; // All off during Reset
end else if(pwmCount<PWM)begin
	SevenSegment[6:0] <= 7'h7F;
end
else begin
case(~SegmentDrivers)                  // Connect the correct signals,
4'h1   : SevenSegment[6:0] <= ~SS[0]; // depending on which digit is on at
4'h2   : SevenSegment[6:0] <= ~SS[1]; // this point
4'h4   : SevenSegment[6:0] <= ~SS[2];
4'h8   : SevenSegment[6:0] <= ~SS[3];
4'h10   : SevenSegment[6:0] <= 7'h7F;
4'h20   : SevenSegment[6:0] <= 7'h7F;
4'h40   : SevenSegment[6:0] <= 7'h7F;
4'h80   : SevenSegment[6:0] <= 7'h7F;
default: SevenSegment[6:0] <=  7'h7F;
endcase
end
end
endmodule
