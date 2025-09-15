// Tamanho da grade
grid_width = 8;
grid_height = 8;
cell_size = 64;

// Criar grid
grid = ds_grid_create(grid_width, grid_height);
for (var i = 0; i < grid_width; i++) {
    for (var j = 0; j < grid_height; j++) {
        grid[# i, j] = -1; // -1 = célula vazia
    }
}

// Calcular offset para centralizar o grid
offset_x = (room_width - (grid_width * cell_size)) / 2;
offset_y = (room_height - (grid_height * cell_size)) / 2 - 50; 
// subtrai 50 para deixar espaço para a bancada embaixo

// Variável global para acesso pelas peças
global.gc = id;

// Posição da bancada de peças
bancada_y = offset_y + grid_height * cell_size + 50;

// Criar peças fixas na bancada
pecas_disponiveis = [];

