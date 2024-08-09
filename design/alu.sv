`timescale 1ns / 1ps

module alu#(
        parameter DATA_WIDTH = 32,
        parameter OPCODE_LENGTH = 4
        )
        (
        input logic [DATA_WIDTH-1:0]    SrcA,
        input logic [DATA_WIDTH-1:0]    SrcB,
        input logic [OPCODE_LENGTH-1:0]    Operation,
         
        output logic[DATA_WIDTH-1:0] ALUResult
        );
    
        always_comb
        begin
            case(Operation)
            4'b0000:        // AND
                    ALUResult = SrcA & SrcB;            
            
            4'b0001:        // OR
                    ALUResult = SrcA | SrcB;           
            
            // JALR usa o imm, ou seja, o SrcB, para calcular PC = imediato + offset; como no comando jalr o SrcA eh zero, essa soma vai retornar o valor requisitado pelo jalr: o SrcB
            4'b0010:        // ADD/JALR
                    ALUResult = $signed(SrcA) + $signed(SrcB);
            
            4'b0011:        // XOR                      
                    ALUResult = SrcA ^ SrcB;              
            
            4'b0100:        // SUB
                    ALUResult = $signed(SrcA) - $signed(SrcB);

            4'b0101:        // SLT, SLTI                                // no resuminho diz que o imediato eh o SrcB
                    ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 1 : 0;

            4'b0110:        // HALT (fim da execucao)
                    ALUResult = 0;                   

            4'b0111:        // ADDI
                    ALUResult = $signed(SrcA) + SrcB;                   // no resuminho diz que o imediato eh o SrcB 
            
            4'b1000:        // BEQ
                    ALUResult = (SrcA == SrcB) ? 1 : 0;

            4'b1001:        // SLLI
                    ALUResult = SrcA << SrcB[4:0];                   // no resuminho diz que o imediato eh o SrcB, sendo especificamente shamt, de 5 bits

            4'b1010:        // SRLI
                    ALUResult = SrcA >> SrcB[4:0];                   // no resuminho diz que o imediato eh o SrcB, sendo especificamente shamt, de 5 bits

            4'b1011:        // SRAI                                         // por ser operacao aritmetica, leva em consideracao o sinal (alteracao para especificar no relatorio)
                    ALUResult = $signed(SrcA) >>> SrcB[4:0];                 //  no resuminho diz que o imediato eh o SrcB, sendo especificamente shamt, de 5 bits
 
            4'b1100:        // BGE
                    ALUResult = ($signed(SrcA) >= $signed(SrcB)) ? 1 : 0;        

            4'b1101:        // BNE
                    ALUResult = (SrcA != SrcB) ? 1 : 0;        

            4'b1110:        // BLT
                    ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 1 : 0;        
        
            4'b1111:        // JAL, LUI 
            begin
                    ALUResult = 1; // util apenas para o Jal no BranchUnit, ja pro LUI o valor do registrador eh determinado do Datapath
            end
            
            default:
                    ALUResult = 0;
            endcase
        end
endmodule
