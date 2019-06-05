module sign_extended(input logic [31:0]Instruction, input logic [6:0]opcode, output logic [63:0]immExtended);
logic [11:0]imm;
logic [20:0]imm2;

always_comb begin
	case(opcode)
		7'b0010011: begin
			imm = Instruction[31:20];
		end
		7'b0000011: begin
			imm = Instruction[31:20];
		end
		7'b0100011: begin
			imm = {Instruction[31:25], Instruction[11:7]};
		end
		7'b1100011: begin
			imm[11] = Instruction[31];
			imm[10] = Instruction[7];
			imm[9:4] = Instruction[30:25];
			imm[3:0] = Instruction[11:8];
		end
		7'b1100111: begin
			case(Instruction[14:12])
			3'b000: begin
				imm = Instruction[31:20];
			end
			default: begin //bne
				imm[11] = Instruction[31];
				imm[10] = Instruction[7];
				imm[9:4] = Instruction[30:25];
				imm[3:0] = Instruction[11:8];
			end
			endcase
		end
		7'b0110111: begin
			immExtended[31:12] = Instruction[31:12];
			immExtended[11:0] = 12'd0;
		end
		7'b1101111: begin //jal
			imm2[20] = Instruction[31];
			imm2[10:1] = Instruction[30:21];
			imm2[11] = Instruction[20];
			imm2[19:12] = Instruction[19:12];
			imm2[0] = 1'b0;
		end
		default: immExtended =  64'd0;
	endcase
	//lbu, lhu, lwu
	if(opcode == 7'b0000011 && Instruction[14:12] == 3'b100 || opcode == 7'b0000011 && Instruction[14:12] == 3'b101 ||
		opcode == 7'b0000011 && Instruction[14:12] == 3'b110) begin
		immExtended = {52'b0000000000000000000000000000000000000000000000000000, imm[11:0]};
	end else if(opcode == 7'b1101111) begin//jal
		if(imm2[20] == 1'b1) immExtended = {43'b1111111111111111111111111111111111111111111, imm2[20:0]};
		else immExtended = {43'b0000000000000000000000000000000000000000000, imm2[20:0]};
	end else if(opcode != 7'b0110111) begin //resto
		if(imm[11] == 1'b1) immExtended = {52'b1111111111111111111111111111111111111111111111111111, imm[11:0]};
		else immExtended = {52'b0000000000000000000000000000000000000000000000000000, imm[11:0]};
	end else begin //lui
		if(immExtended[31] == 1'b1) immExtended = {32'b11111111111111111111111111111111, immExtended[31:0]};
		else immExtended = {32'd0, immExtended[31:0]};
	end
end		
endmodule
