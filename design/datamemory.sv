`timescale 1ns / 1ps

module datamemory #(
    parameter DM_ADDRESS = 9,
    parameter DATA_W = 32
) (
    input logic clk,
    input logic MemRead,  // comes from control unit
    input logic MemWrite,  // Comes from control unit
    input logic [DM_ADDRESS - 1:0] a,  // Read / Write address - 9 LSB bits of the ALU output
    input logic [DATA_W - 1:0] wd,  // Write Data
    input logic [2:0] Funct3,  // bits 12 to 14 of the instruction
    output logic [DATA_W - 1:0] rd  // Read Data
);

  logic [31:0] raddress;
  logic [31:0] waddress;
  logic [31:0] Datain;
  logic [31:0] Dataout;
  logic [ 3:0] Wr;

  Memoria32Data mem32 (
      .raddress(raddress),
      .waddress(waddress),
      .Clk(~clk),
      .Datain(Datain),
      .Dataout(Dataout),
      .Wr(Wr)
  );

  always_ff @(*) begin
    raddress = {{22{1'b0}}, a};
    waddress = {{22{1'b0}}, a[8:2], {2{1'b0}}};
    Datain = wd;
    Wr = 4'b0000;

    // bloco de codigo para operacoes de leitura da memoria 
    if (MemRead) begin

      case (Funct3)
        
        // leitura de uma palavra completa (32 bits) da memoria
        3'b010:  // LW
          rd <= Dataout;
        
        // leitura de uma palavra meia palavra (16 bits) da memoria 
        // aqui, os 16 bits menos significativos de Dataout sao estendidos para 32 bits com sinal (sign-extended)
        // isso significa que o bit mais significativo desses 16 bits (bit 15) eh copiado para os 16 bits mais significativos do valor de saida
        3'b001:  // LH
         rd <= {Dataout[15] ? 16'hFFFF : 16'b0, Dataout[15:0]};  

        // leitura de um byte (8 bits) da memoria
        // os 8 bits menos significativos de Dataout sao estendidos para 32 bits com sinal 
        // isso significa que o bit mais significativo desses 8 bits (bit 7) eh copiado para os 24 bits mais significativos do valor de saida
        3'b000:  // LB
          rd <= {Dataout[7] ? 24'hFFFFFF : 24'b0, Dataout[7:0]};  

        // leitura de um byte especifico da memoria (baseado nos bits menos significativos do endereco a[1:0])
        3'b100:  // LBU 
          // faz a leitura de um byte especifico da memoria com base nos bits menos significativos do endereco (a[1:0]) e estende esse byte com zeros para formar um valor de 32 bits sem sinal
          case (a[1:0])
            2'b00: rd <= {24'b0, Dataout[7:0]};
            2'b01: rd <= {24'b0, Dataout[15:8]};
            2'b10: rd <= {24'b0, Dataout[23:16]};
            2'b11: rd <= {24'b0, Dataout[31:24]};
          endcase

        default: rd <= Dataout;
      endcase
    end 
    
    // bloco de codigo para operacoes de escrita na memoria 
    else if (MemWrite) begin
      
      // seleciona a operacao especifica baseada no valor de Funct3
      case (Funct3)

        3'b000: begin  // SB 
          
          // determina qual byte especifico dentro da palavra vai ser escrito com base em a[1:0]
          case (a[1:0])
            2'b00: Wr <= 4'b0001;  // escreve no byte menos significativo
            2'b01: Wr <= 4'b0010;  // escreve no segundo byte
            2'b10: Wr <= 4'b0100;  // escreve no terceiro byte
            2'b11: Wr <= 4'b1000;  // escreve no byte mais significativo
          endcase
          
          // repete o byte a ser escrito (wd[7:0]) quatro vezes para alinhamento correto
          Datain <= {4{wd[7:0]}};
        end

        3'b001: begin  // SH 
          
          // determina qual meia palavra (halfword) especifica dentro da palavra vai ser escrita com base em a[1]
          case (a[1])
            1'b0: Wr <= 4'b0011;  // escreve nos dois bytes menos significativos
            1'b1: Wr <= 4'b1100;  // escreve nos dois bytes mais significativos
          endcase
          // repete a meia palavra a ser escrita (wd[15:0]) duas vezes para alinhamento correto
          Datain <= {2{wd[15:0]}};
        end

        3'b010: begin  // SW 
          
          // especifica que todos os quatro bytes da palavra serão escritos
          Wr <= 4'b1111;
          // a palavra inteira (wd) eh preparada para ser escrita na memoria
          Datain <= wd;
        end

        default: begin
          // comportamento padrão para instruções não especificadas (trata como SW)
          Wr <= 4'b1111;
          Datain <= wd;
        end

      endcase
    end
  end

endmodule
