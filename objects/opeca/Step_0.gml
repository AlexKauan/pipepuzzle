// Botão esquerdo - arrastar peça
var half = global.gc.cell_size * 0.5;

if (mouse_check_button_pressed(mb_left) &&
    mouse_x > x - half && mouse_x < x + half &&
    mouse_y > y - half && mouse_y < y + half) {
    
    arrastando = true;
    offset_x_mouse = mouse_x - x;
    offset_y_mouse = mouse_y - y;

    // 🔹 Se já estava numa célula, libera antes de arrastar
    var gc = global.gc;
    if (gc != noone) {
        var grid_x = floor((x - gc.offset_x) / gc.cell_size);
        var grid_y = floor((y - gc.offset_y) / gc.cell_size);
        if (grid_x >= 0 && grid_x < gc.grid_width &&
            grid_y >= 0 && grid_y < gc.grid_height) {
            if (gc.grid[# grid_x, grid_y] == id) {
                gc.grid[# grid_x, grid_y] = -1; // libera slot
            }
        }
    }
}


if (arrastando) {
    x = mouse_x - offset_x_mouse;
    y = mouse_y - offset_y_mouse;
}


if (arrastando && mouse_check_button_released(mb_left)) {
    arrastando = false;

    var gc = global.gc;

    if (gc != noone) {

        // Verifica se a peça está dentro da área do grid
        var dentro_x = x >= gc.offset_x && x <= gc.offset_x + gc.grid_width * gc.cell_size;
        var dentro_y = y >= gc.offset_y && y <= gc.offset_y + gc.grid_height * gc.cell_size;

        if (dentro_x && dentro_y) {
            // Calcula célula
            var grid_x = floor((x - gc.offset_x) / gc.cell_size);
            var grid_y = floor((y - gc.offset_y) / gc.cell_size);

            // Limita dentro da grade
            grid_x = clamp(grid_x, 0, gc.grid_width - 1);
            grid_y = clamp(grid_y, 0, gc.grid_height - 1);

            // 🔹 Verifica se a célula está disponível
            if (gc.grid[# grid_x, grid_y] == -1) {
                // Célula vazia → posiciona a peça
                gc.grid[# grid_x, grid_y] = id;

                // Centraliza na célula
                x = gc.offset_x + grid_x * gc.cell_size + gc.cell_size/2;
                y = gc.offset_y + grid_y * gc.cell_size + gc.cell_size/2;
                
                // Atualiza a posição inicial para esta nova posição
                start_x = x;
                start_y = y;
                
                // Valida o caminho após mover a peça
                gc.verificar_caminho();
                
                // Efeito visual de movimento bem-sucedido
                gc.criar_efeito_agua(x, y);
            } else {
                // Célula ocupada (por peça ou obstáculo) → volta para última posição válida no grid
                x = start_x;
                y = start_y;
                
                // Efeito visual de erro
                gc.criar_efeito_erro(x, y);
                
                // Feedback visual/sonoro opcional para obstáculo
                if (gc.grid[# grid_x, grid_y] == -2) {
                    show_debug_message("Não é possível colocar peça em obstáculo!");
                }
            }

        } else {
            // Fora da grade → volta para última posição válida no grid
            x = start_x;
            y = start_y;
            
            // Efeito visual de erro
            gc.criar_efeito_erro(x, y);
        }

    } else {
        // Segurança
        x = start_x;
        y = start_y;
        show_debug_message("Erro: GameController não encontrado!");
    }
}