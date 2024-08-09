`timescale 1ns / 1ps

module Controller (
    //Input
    input logic [6:0] Opcode,
    //7-bit opcode field from the instruction

    //Outputs
    output logic ALUSrc,
    //0: The second ALU operand comes from the second register file output (Read data 2); 
    //1: The second ALU operand is the sign-extended, lower 16 bits of the instruction.
    output logic MemtoReg,
    //0: The value fed to the register Write data input comes from the ALU.
    //1: The value fed to the register Write data input comes from the data memory.
    output logic RegWrite, //The register on the Write register input is written with the value on the Write data input 
    output logic MemRead,  //Data memory contents designated by the address input are put on the Read data output
    output logic MemWrite, //Data memory contents designated by the address input are replaced by the value on the Write data input.
    output logic [1:0] ALUOp,  // 2-bit opcode field from the Controller--00: LW/SW/AUIPC; 01:Branch; 10: Rtype/Itype; 11:JAL/JALR/LUI
    output logic Branch,  // 0: branch is not taken; 1: branch is taken
    output logic haltPut, // sinal que criamos para indicar halt (fim da execucao)
    output logic [1:0] branchPutJJL // Sinal indicando se a instrucao eh um JALR, JAL ou LUI
);

  // Definicão dos opcodes para diferentes tipos de instrucoes
  logic [6:0] R_TYPE, I_TYPE, LOAD, STORE, BR, JAL, JALR, LUI;

  assign R_TYPE = 7'b0110011;       // add,and, ...
  assign I_TYPE = 7'b0010011;      // slti, addi, ...
  assign LOAD = 7'b0000011;       // lw, lb, lbu, lh
  assign STORE = 7'b0100011;     // sw, sb, sh
  assign BR = 7'b1100011;       // beq, bne, blt, bge
  assign JAL = 7'b1101111;  
  assign JALR = 7'b1100111;
  assign LUI = 7'b0110111;
  assign HALT = 7'b1001100;   // opcode hipotetico que criamos para o halt

  // Atribuicao de sinais de controle com base no opcode da instrucao
  
  // ALUSrc define a segunda fonte de operando para a ALU: 0 (o segundo operando vem do segundo registrador (Read data 2)), 1 (o segundo operando eh a extensao de sinal dos 16 bits inferiores da instrucao)
  assign ALUSrc = (Opcode == LOAD || Opcode == STORE || Opcode == I_TYPE || Opcode == JALR);
  
  // MemtoReg define a fonte dos dados de escrita no registrador: 0 (o valor vem da ALU), 1 (o valor vem da memoria de dados)
  assign MemtoReg = (Opcode == LOAD);

  // RegWrite define se o registrador vai ser escrito: 0 (nao escreve no registrador), 1 (escreve no registrador)
  assign RegWrite = (Opcode == R_TYPE || Opcode == I_TYPE || Opcode == LOAD || Opcode == LUI || Opcode == JALR || Opcode == JAL); // jal e jalr escrevem no registrador de destino (rd) -implementar!-
  
  // MemRead define se a memoria de dados vai ser lida: 0 (nao lê a memória), 1 (lê a memória)
  assign MemRead = (Opcode == LOAD);

  // MemWrite define se a memoria de dados vai ser escrita: 0 (nao escreve na memoria), 1 (escreve na memoria)
  assign MemWrite = (Opcode == STORE);

  // tratamos jalr como ALUOp = 00 para evitar confusôes na distinção com jal e lui 
  assign ALUOp[0] = (Opcode == BR || Opcode == JAL || Opcode == LUI || Opcode == HALT);
  assign ALUOp[1] = (Opcode == R_TYPE || Opcode == I_TYPE || Opcode == JAL || Opcode == LUI);
  assign Branch = (Opcode == BR || Opcode == JAL);
  assign branchPutJJL[0] = (Opcode == JALR) || (Opcode == LUI);
  assign branchPutJJL[1] = (Opcode == JAL) || (Opcode == LUI);
  assign haltPut = (Opcode == HALT);
endmodule
