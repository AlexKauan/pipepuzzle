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

// Desenha ponto de origem (verde)
var origem_x = offset_x + ponto_origem_x * cell_size + cell_size / 2;
var origem_y = offset_y + ponto_origem_y * cell_size + cell_size / 2;
draw_set_color(c_lime);
draw_circle(origem_x, origem_y, 16, false);
draw_set_color(c_black);
draw_text(origem_x - 15, origem_y - 10, "INÍCIO");

// Desenha ponto de destino (vermelho)
var destino_x = offset_x + ponto_destino_x * cell_size + cell_size / 2;
var destino_y = offset_y + ponto_destino_y * cell_size + cell_size / 2;
draw_set_color(c_red);
draw_circle(destino_x, destino_y, 16, false);
draw_set_color(c_black);
draw_text(destino_x - 10, destino_y - 10, "FIM");

// Desenha status do caminho
draw_set_color(c_white);
var status_y = offset_y + grid_height * cell_size + 20;
if (caminho_valido) {
    draw_set_color(c_lime);
    draw_text(offset_x, status_y, "✓ PUZZLE COMPLETO - ÁGUA FLUINDO!");
} else {
    draw_set_color(c_red);
    draw_text(offset_x, status_y, "✗ Reorganize as peças para conectar do INÍCIO ao FIM");
}

// ============================================
// INTERFACE DO JOGO
// ============================================

// Informações do nível
draw_set_color(c_white);
draw_set_font(fnt_game);
draw_text(10, 10, "Nível: " + string(nivel_atual));
draw_text(10, 30, "Pontuação: " + string(pontuacao));
var texto_dificuldade = "Fácil";
if (dificuldade == 2) texto_dificuldade = "Médio";
if (dificuldade == 3) texto_dificuldade = "Difícil";
draw_text(10, 50, "Dificuldade: " + texto_dificuldade);

// Timer
var minutos = floor(tempo_restante / 60);
var segundos = floor(tempo_restante mod 60);
var cor_tempo = c_white;
if (tempo_restante < 30) cor_tempo = c_red;
else if (tempo_restante < 60) cor_tempo = c_yellow;

draw_set_color(cor_tempo);
// Formata os segundos com zero à esquerda se necessário
var segundos_str = string(segundos);
if (segundos < 10) segundos_str = "0" + segundos_str;
draw_text(10, 70, "Tempo: " + string(minutos) + ":" + segundos_str);

// Hints
draw_set_color(c_white);
draw_text(10, 90, "Dicas: " + string(hints_disponiveis));

// Controles
draw_set_color(c_white);
draw_text(offset_x, status_y + 25, "Controles: Botão Esquerdo = Arrastar e Mover Peça");
draw_text(offset_x, status_y + 40, "Total de peças: " + string(total_pecas));
draw_text(offset_x, status_y + 55, "H = Dica | R = Reiniciar | ESC = Pausar | N = Próximo nível (quando completo)");

// Pausa
if (jogo_pausado) {
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);
    
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(room_width/2, room_height/2, "JOGO PAUSADO\n\nPressione ESC para continuar");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Hint ativo
if (mostrar_hint) {
    draw_set_color(c_yellow);
    draw_set_halign(fa_center);
    draw_text(room_width/2, 100, "💡 DICA: Conecte as peças do INÍCIO ao FIM!");
    draw_set_halign(fa_left);
}

// Jogo completo
if (jogo_completo) {
    draw_set_color(c_lime);
    draw_set_halign(fa_center);
    draw_text(room_width/2, room_height/2 - 50, "🎉 NÍVEL COMPLETO! 🎉");
    draw_text(room_width/2, room_height/2 - 20, "Pressione N para o próximo nível");
    draw_set_halign(fa_left);
}

draw_set_color(c_white);

// Desenha todas as peças

// ============================================
// TELA DE GAME OVER
// ============================================

if (game_over_ativo) {
    // Fundo escurecido
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
    
    // Texto principal (centralizado)
    var centro_x = display_get_gui_width() / 2;
    var centro_y = display_get_gui_height() / 2;
    
    draw_set_color(c_white);
    draw_set_font(fnt_game);
    draw_set_halign(fa_center);
    
    draw_text(centro_x, centro_y - 40, "GAME OVER");
    draw_text(centro_x, centro_y + 10, "Pressione R para Reiniciar");
    draw_text(centro_x, centro_y + 40, "Pressione Q para Sair");
    
    draw_set_halign(fa_left); // volta alinhamento padrão
}
