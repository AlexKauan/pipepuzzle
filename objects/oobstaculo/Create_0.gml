// Sistema de obstáculos que bloqueiam o caminho
// Obstáculos não podem ser movidos e impedem a passagem de peças

tipo_obstaculo = "bloco"; // bloco, agua, fogo
cor_obstaculo = c_gray;

// Configuração baseada no tipo
switch (tipo_obstaculo) {
    case "bloco":
        cor_obstaculo = c_gray;
        break;
    case "agua":
        cor_obstaculo = c_aqua;
        break;
    case "fogo":
        cor_obstaculo = c_red;
        break;
}





