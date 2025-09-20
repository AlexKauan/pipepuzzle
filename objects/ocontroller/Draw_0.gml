draw_set_color(c_gray);
draw_set_alpha(0.5);

for (var i = 0; i <= grid_width; i++) {
    draw_line(offset_x + i * cell_size, offset_y, 
              offset_x + i * cell_size, offset_y + grid_height * cell_size);
}

for (var j = 0; j <= grid_height; j++) {
    draw_line(offset_x, offset_y + j * cell_size, 
              offset_x + grid_width * cell_size, offset_y + j * cell_size);
}

draw_set_alpha(1);
draw_set_color(c_white);

// Desenha todas as peças
