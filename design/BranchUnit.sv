`timescale 1ns / 1ps

module BranchUnit #(
    parameter PC_W = 9
) (
    input logic [PC_W-1:0] Cur_PC,
    input logic [31:0] Imm,
    input logic Branch,
    input logic [1:0] branchPutJJL,   // Sinal indicando se a instrucao eh um JALR, JAL ou LUI
    input logic [31:0] AluResult,
    output logic [31:0] PC_Imm,
    output logic [31:0] PC_Four,
    output logic [31:0] BrPC,
    output logic PcSel
);

  logic Branch_Sel;
  logic [31:0] PC_Full;

  // O endereco atual do PC eh concatenado com 23 zeros para a esquerda, o que eh necessario para adequar o PC ao formato de 32 bits
  assign PC_Full = {23'b0, Cur_PC};

  // O endereco do proximo PC se o salto for tomado (PC + offset imediato)
  assign PC_Imm = PC_Full + Imm;

  // O endereco da proxima instrucao sequencial (PC + 4)
  assign PC_Four = PC_Full + 32'b100;

  // Sinal de selecao para branch, ativado se a instrucao for um branch e o resultado da ALU for verdadeiro
  assign Branch_Sel = Branch && AluResult[0];

  // Seleção do endereço de salto final:
  // Se `branchPutJJL` for verdadeiro para JALR, o endereco eh o resultado da ALU
  // Caso contrario, se `Branch_Sel` for verdadeiro, o endereco eh calculado com o imediato
  // Se nenhum dos dois, o endereco de salto eh zero
  assign BrPC = (branchPutJJL == 2'b01) ? AluResult : (Branch_Sel) ? PC_Imm : 32'b0;

  // Sinal de seleção do PC: ativado se `branchPutJJL` (JAL ou JALR) ou `Branch_Sel` forem verdadeiros, indicando que o proximo PC deve ser um endereco de salto
  assign PcSel = branchPutJJL == 2'b10 || branchPutJJL == 2'b01 || Branch_Sel ;

endmodule

