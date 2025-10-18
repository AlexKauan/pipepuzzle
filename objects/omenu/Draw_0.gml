// ============================================
// DESENHAR MENU INICIAL
// ============================================

// Fundo
draw_set_color(cor_fundo);
draw_rectangle(0, 0, room_width, room_height, false);

// Centro da tela
var centro_x = room_width / 2;
var centro_y = room_height / 2;

// ============================================
// TÍTULO
// ============================================
draw_set_font(fnt_game);
draw_set_color(cor_titulo);
draw_set_halign(fa_center);
draw_set_valign(fa_top);

// Desenha o título com tamanho maior
var scale_titulo = tamanho_fonte_titulo;
draw_text_transformed(centro_x, titulo_y, "PIPEPUZZLE", scale_titulo, scale_titulo, 0);

// ============================================
// OPÇÕES DO MENU
// ============================================
draw_set_valign(fa_middle);

for (var i = 0; i < total_opcoes; i++) {
    var opcao_x = centro_x;
    var opcao_y = opcoes_y_inicio + (i * espacamento_opcoes);
    
    // Se o mouse estiver sobre a opção, desenha um retângulo de destaque
    if (opcao_hover == i) {
        draw_set_color(cor_opcao_hover);
        draw_set_alpha(0.3);
        
        var texto_largura = string_width(opcoes[i]) * tamanho_fonte_opcao;
        var texto_altura = string_height(opcoes[i]) * tamanho_fonte_opcao;
        
        draw_rectangle(centro_x - texto_largura/2 - 20, opcao_y - texto_altura/2 - 10,
                      centro_x + texto_largura/2 + 20, opcao_y + texto_altura/2 + 10, false);
        
        draw_set_alpha(1);
    }
    
    // Muda cor se o mouse estiver sobre a opção
    if (opcao_hover == i) {
        draw_set_color(cor_opcao_hover);
    } else {
        draw_set_color(cor_opcao_normal);
    }
    
    // Desenha a opção
    var scale_opcao = tamanho_fonte_opcao;
    draw_text_transformed(opcao_x, opcao_y, opcoes[i], scale_opcao, scale_opcao, 0);
}

// Restaura configurações padrão
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

