// ============================================
// DETECÇÃO DE CLIQUES E HOVER
// ============================================

var centro_x = room_width / 2;
var mouse_x_pos = mouse_x;
var mouse_y_pos = mouse_y;

// Garante que o objeto de save exista e persista
var obj_save = asset_get_index("ogamesave");
var inst_save = noone;
if (obj_save != -1) {
    // procura instância existente
    inst_save = instance_find(obj_save, 0);
    if (!instance_exists(inst_save)) {
        inst_save = instance_create_layer(0, 0, "Instances", obj_save);
    }
    global.save_inst = inst_save;
}

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
                    global.usar_save = false;
                    
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
                    // Carrega progresso salvo e vai para o último nível jogado
                    if (instance_exists(inst_save)) {
                        with (inst_save) carregar_dados();
                    }

                    if (variable_global_exists("has_save") && global.has_save && file_exists(global.save_file)) {
                        global.usar_save = true;
                        show_debug_message("Continuar do nível: " + string(global.nivel_salvo));
                        if (room_exists(Room1)) {
                            room_goto(Room1);
                        } else {
                            room_goto_next();
                        }
                    } else {
                        show_debug_message("Nenhum progresso salvo para continuar.");
                    }
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

