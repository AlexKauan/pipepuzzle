// ============================================
// DESENHAR MENU INICIAL
// ============================================

// Centro da tela
var centro_x = room_width / 2;
var centro_y = room_height / 2;

// ============================================
// OPÇÕES DO MENU
// ============================================
draw_set_valign(fa_middle);

for (var i = 0; i < total_opcoes; i++) {
    var opcao_x = centro_x + opcao_x_offset;
    var opcao_y = opcoes_y_inicio + (i * espacamento_opcoes);
    
    // Muda cor se o mouse estiver sobre a opção
    if (opcao_hover == i) {
        draw_set_color(cor_opcao_hover);
    } else {
        draw_set_color(cor_opcao_normal);
    }
    
    // Desenha a opção
    var scale_opcao = tamanho_fonte_opcao;
    draw_text_ext_transformed(opcao_x, opcao_y, opcoes[i], 2.0, 2000, scale_opcao, scale_opcao, 0);
}

// Restaura configurações padrão
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

