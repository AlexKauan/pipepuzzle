if (mouse_check_button_pressed(mb_left) &&
    mouse_x > x-32 && mouse_x < x+32 &&
    mouse_y > y-32 && mouse_y < y+32) {
    
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

            // 🔹 Verifica se já existe peça
            if (gc.grid[# grid_x, grid_y] == -1) {
                // Célula vazia → posiciona a peça
                gc.grid[# grid_x, grid_y] = id;

                // Centraliza na célula
                x = gc.offset_x + grid_x * gc.cell_size + gc.cell_size/2;
                y = gc.offset_y + grid_y * gc.cell_size + gc.cell_size/2;
            } else {
                // Célula ocupada → volta para bancada
                x = start_x;
                y = start_y;
            }

        } else {
            // Fora da grade → volta para bancada
            x = start_x;
            y = start_y;
        }

    } else {
        // Segurança
        x = start_x;
        y = start_y;
        show_debug_message("Erro: GameController não encontrado!");
    }
}