// ============================================
// DETECÇÃO DE CLIQUES E HOVER
// ============================================

var centro_x = room_width / 2;
var mouse_x_pos = mouse_x;
var mouse_y_pos = mouse_y;

// Detecta qual opção está sob o cursor
opcao_hover = -1;

for (var i = 0; i < total_opcoes; i++) {
    var opcao_y = opcoes_y_inicio + (i * espacamento_opcoes);
    
    // Área aproximada de cada opção (aumentada para facilitar o clique)
    var texto_largura = string_width(opcoes[i]) * tamanho_fonte_opcao;
    var texto_altura = string_height(opcoes[i]) * tamanho_fonte_opcao;
    
    // Aumenta a área de clique em 50 pixels para cada lado
    var margem = 50;
    var x1 = centro_x - texto_largura / 2 - margem;
    var x2 = centro_x + texto_largura / 2 + margem;
    var y1 = opcao_y - texto_altura / 2 - margem;
    var y2 = opcao_y + texto_altura / 2 + margem;
    
    // Verifica se o mouse está sobre a opção
    if (mouse_x_pos >= x1 && mouse_x_pos <= x2 &&
        mouse_y_pos >= y1 && mouse_y_pos <= y2) {
        opcao_hover = i;
        
        // Se clicar
        if (mouse_check_button_pressed(mb_left)) {
            show_debug_message("Clicou na opcao: " + opcoes[i]);
            
            switch(i) {
                case 0: // JOGAR
                    // Vai para Room1 (nível 1)
                    show_debug_message("Indo para Room1...");
                    
                    // Verifica se a sala existe
                    if (room_exists(Room1)) {
                        show_debug_message("Room1 existe! Mudando de sala...");
                        room_goto(Room1);
                    } else {
                        show_debug_message("ERRO: Room1 não existe!");
                        // Tenta ir para a próxima sala
                        room_goto_next();
                    }
                    break;
                    
                case 1: // CONTINUAR
                    // Por enquanto não faz nada
                    show_debug_message("Continuar - Ainda não implementado");
                    break;
                    
                case 2: // SAIR
                    // Fecha o jogo
                    show_debug_message("Saindo do jogo...");
                    game_end();
                    break;
            }
        }
    }
}

