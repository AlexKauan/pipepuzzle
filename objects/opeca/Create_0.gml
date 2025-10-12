tem_agua = false;       // indica se a peça já foi preenchida com água
arrastando = false;     // se a peça está sendo arrastada
offset_x_mouse = 0;
offset_y_mouse = 0;

// Posição inicial no grid (será atualizada sempre que a peça for solta com sucesso)
start_x = x;
start_y = y;
grid_x_inicial = 0;  // será definido pelo controller
grid_y_inicial = 0;  // será definido pelo controller

// Sistema de conexões - define quais lados da peça conectam
// Direções: 0 = cima, 1 = direita, 2 = baixo, 3 = esquerda
// Array contém as direções que esta peça conecta
conexoes = [];

// Define as conexões para cada tipo de peça
// opeca (Sprite3) - tubo reto vertical
conexoes = [0, 2]; // conecta cima e baixo

// Rotação da peça (0, 90, 180, 270)
rotacao = 0;
