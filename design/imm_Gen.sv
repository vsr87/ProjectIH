`timescale 1ns / 1ps

module imm_Gen (
    input  logic [31:0] inst_code,  // Codigo da instrucao de 32 bits
    output logic [31:0] Imm_out  // Valor imediato gerado a partir da instrucao
);

  // Sempre que houver uma mudança em inst_code, este bloco vai ser executado
  always_comb
    // Seleciona o tipo de imediato a ser gerado com base nos 7 bits menos significativos da instrucao (opcode)
    case (inst_code[6:0])
      7'b0000011:  /* I-type load part */
          // Gera o imediato para instrucoes do tipo I (carga)
          Imm_out = {inst_code[31] ? 20'hFFFFF : 20'b0, inst_code[31:20]};

      7'b0100011:  /* S-type */
          // Gera o imediato para instrucoes do tipo S (armazenamento)
          Imm_out = {inst_code[31] ? 20'hFFFFF : 20'b0, inst_code[31:25], inst_code[11:7]};

      7'b1100011:  /* B-type */
          // Gera o imediato para instrucoes do tipo B (branch)
          Imm_out = {
            inst_code[31] ? 19'h7FFFF : 19'b0,  // Extensao de sinal
            inst_code[31],                       // Bit 12
            inst_code[7],                        // Bit 11
            inst_code[30:25],                    // Bits 10:5
            inst_code[11:8],                     // Bits 4:1
            1'b0                                // Bit 0, alinhado para 2 bytes
          };

      7'b0010011: /* I-type: addi, srli, srai, slli, slti */    
      begin 
          if((inst_code[31:25] == 7'b0100000) && (inst_code[14:12] == 3'b101)) // srai
            // Gera o imediato para a instrucao SRAI (shift right arithmetic immediate)
            Imm_out = {7'b0, inst_code[24:20]};
          else
            // Gera o imediato para outras instrucoes do tipo I
            Imm_out = {inst_code[31] ? 20'hFFFFF : 20'b0, inst_code[31:20]}; 
      end

      7'b1101111: // jal
          // Gera o imediato para instrucoes JAL (jump and link)
          Imm_out = {inst_code[31]? 11'h7FF : 11'b0, inst_code[31], inst_code[19:12], inst_code[20], inst_code[30:21], 1'b0};

      7'b1100111: // jalr
          // Gera o imediato para instrucoes JALR (jump and link register)
          Imm_out = {inst_code[31] ? 20'hFFFFF : 20'b0, inst_code[31:20]};

      7'b0110111:  // LUI
          // Gera o imediato para instrucoes LUI (load upper immediate)
          Imm_out = {inst_code[31:12], 12'b0};  // LUI coloca os 20 bits no topo

      default: 
          // Caso padrao para instrucoes nao especificadas
          Imm_out = 32'b0;

    endcase

endmodule
