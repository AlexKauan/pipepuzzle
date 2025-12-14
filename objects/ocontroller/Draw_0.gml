// ============================================
// BG geral
// ============================================
var spr_bg = asset_get_index("SpriteBgGame");
if (spr_bg != -1 && sprite_exists(spr_bg)) {
    draw_set_alpha(1);
    draw_sprite_stretched(spr_bg, 0, 0, 0, room_width, room_height);
}

// ============================================
// Grade
// ============================================
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

// ===============================
// DESENHA PONTO DE ORIGEM (sprite do oorigem_agua)
// ===============================
var origem_x = offset_x + (ponto_origem_x) * cell_size;
var origem_y = offset_y + (ponto_origem_y) * cell_size;

// Pega o sprite do objeto oorigem_agua
var spr_origem = object_get_sprite(oorigem_agua);

// Verifica se o sprite existe antes de desenhar
if (sprite_exists(spr_origem)) {
    // Escala para ajustar o sprite ao tamanho da célula
    var escala = cell_size / sprite_get_width(spr_origem);
    
    draw_sprite_ext(
        spr_origem,
        0, // subimagem
        origem_x,
        origem_y,
        escala,
        escala,
        0, // rotação
        c_white,
        1  // alpha
    );
}

// ===============================
// DESENHA PONTO DE DESTINO (sprite do odestino_agua)
// ===============================
var destino_x = offset_x + ponto_destino_x * cell_size;
var destino_y = offset_y + ponto_destino_y * cell_size;

var spr_destino = object_get_sprite(odestino_agua);

if (sprite_exists(spr_destino)) {
    var escala = cell_size / sprite_get_width(spr_destino);
    
    draw_sprite_ext(
        spr_destino,
        0,
        destino_x,
        destino_y,
        escala,
        escala,
        0,
        c_white,
        1
    );
}

// Desenha status do caminho (mais abaixo da grade)
draw_set_color(c_white);
var status_y = offset_y + grid_height * cell_size + 60;
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

// Informações do nível (HUD horizontal sobre o grid)
var hud_x1 = offset_x - 12;
var hud_x2 = offset_x + grid_width * cell_size + 12;
var hud_y2 = offset_y - 8;
var hud_y1 = hud_y2 - 40; // altura um pouco maior

draw_set_alpha(0.72);
draw_set_color(make_color_rgb(16, 28, 44)); // fundo escuro azulado
draw_roundrect(hud_x1, hud_y1, hud_x2, hud_y2, false);

draw_set_color(make_color_rgb(255, 204, 80)); // contorno dourado
draw_roundrect(hud_x1 + 2, hud_y1 + 2, hud_x2 - 2, hud_y2 - 2, false);

draw_set_alpha(1);
draw_set_font(fnt_game);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var minutos = floor(tempo_restante / 60);
var segundos = floor(tempo_restante mod 60);
var cor_tempo = c_white;
if (tempo_restante < 30) cor_tempo = c_red;
else if (tempo_restante < 60) cor_tempo = c_yellow;

var segundos_str = string(segundos);
if (segundos < 10) segundos_str = "0" + segundos_str;

var texto_dificuldade = "Fácil";
if (dificuldade == 2) texto_dificuldade = "Médio";
if (dificuldade == 3) texto_dificuldade = "Difícil";

var linha_info = "Nível: " + string(nivel_atual)
    + "  |  Pontuação: " + string(pontuacao)
    + "  |  Dificuldade: " + texto_dificuldade
    + "  |  Tempo: " + string(minutos) + ":" + segundos_str
    + "  |  Dicas: " + string(hints_disponiveis);

// Texto único na horizontal
draw_set_color(c_white);
var texto_x = (hud_x1 + hud_x2) * 0.5;
var texto_y = (hud_y1 + hud_y2) * 0.5;
draw_text_ext(texto_x, texto_y, linha_info, 1.6, 4000);

// Painel inferior (status e controles)
var info_y1 = status_y - 16;
var info_y2 = status_y + 120; // mais alto para espaçamento maior entre linhas
var info_x1 = offset_x - 12;
var info_x2 = offset_x + grid_width * cell_size + 12;
var info_width = (info_x2 - info_x1) - 28; // área útil para quebra de linha

draw_set_alpha(0.7);
draw_set_color(make_color_rgb(16, 28, 44)); // fundo escuro azulado
draw_roundrect(info_x1, info_y1, info_x2, info_y2, false);

draw_set_color(make_color_rgb(255, 204, 80)); // contorno dourado
draw_roundrect(info_x1 + 2, info_y1 + 2, info_x2 - 2, info_y2 - 2, false);

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Texto dentro do painel com padding
var tx_panel = info_x1 + 14;
var ty_panel = info_y1 + 12;
var line_gap = 24; // espaçamento vertical entre linhas

// Status de conexão
if (caminho_valido) {
    draw_set_color(c_lime);
    draw_text_ext(tx_panel, ty_panel, "✓ PUZZLE COMPLETO - ÁGUA FLUINDO!", 2.0, info_width);
} else {
    draw_set_color(c_red);
    draw_text_ext(tx_panel, ty_panel, "✗ Reorganize as peças para conectar do INÍCIO ao FIM", 2.0, info_width);
}

// Controles
draw_set_color(c_white);
draw_text_ext(tx_panel, ty_panel + line_gap, "Controles: Botão Esquerdo = Arrastar e Mover Peça", 2.0, info_width);
draw_text_ext(tx_panel, ty_panel + line_gap * 2, "Total de peças: " + string(total_pecas), 2.0, info_width);
draw_text_ext(tx_panel, ty_panel + line_gap * 3, "H = Dica | R = Reiniciar | ESC = Pausar | N = Próximo nível", 2.0, info_width);
draw_text_ext(tx_panel, ty_panel + line_gap * 4, "(quando completo)", 2.0, info_width);

// Dica visual de célula (somente uma célula)
if (hint_timer > 0 && hint_cell_x >= 0 && hint_cell_y >= 0) {
    var cell_cx = offset_x + hint_cell_x * cell_size + cell_size * 0.5;
    var cell_cy = offset_y + hint_cell_y * cell_size + cell_size * 0.5;
    var cell_x1 = cell_cx - cell_size * 0.5;
    var cell_y1 = cell_cy - cell_size * 0.5;
    var cell_x2 = cell_cx + cell_size * 0.5;
    var cell_y2 = cell_cy + cell_size * 0.5;

    draw_set_alpha(0.35);
    draw_set_color(c_yellow);
    draw_rectangle(cell_x1, cell_y1, cell_x2, cell_y2, false);
    draw_set_alpha(1);

    var objetos_pecas = [opeca, opeca2, opeca3, opeca4, opeca5, opeca6];
    if (hint_cell_tipo >= 0 && hint_cell_tipo < array_length(objetos_pecas)) {
        var obj_needed = objetos_pecas[hint_cell_tipo];
        var spr_needed = object_get_sprite(obj_needed);
        if (spr_needed != -1) {
            var spr_w = sprite_get_width(spr_needed);
            var scale_hint = (spr_w != 0) ? (cell_size / spr_w) : 1;
            draw_set_alpha(0.75);
            draw_sprite_ext(spr_needed, 0, cell_cx, cell_cy, scale_hint, scale_hint, 0, c_white, 1);
            draw_set_alpha(1);
        }
    }
}

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

// Hint ativo (movido para Draw GUI)

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
// VISUALIZAÇÃO DO CAMINHO CORRETO (DEBUG)
// ============================================

// Pressione D para mostrar/ocultar o caminho correto (debug)
if (!variable_global_exists("mostrar_debug")) {
    global.mostrar_debug = false;
}

if (keyboard_check_pressed(ord("D"))) {
    global.mostrar_debug = !global.mostrar_debug;
    show_debug_message("Debug visual: " + string(global.mostrar_debug ? "ON" : "OFF"));
}

if (global.mostrar_debug) {
    // Array com os objetos de peças para desenhar os sprites corretos
    var objetos_pecas = [opeca, opeca2, opeca3, opeca4, opeca5, opeca6];
    
    // Desenha o caminho correto com linhas verdes
    draw_set_color(c_lime);
    draw_set_alpha(0.5);
    
    for (var i = 0; i < ds_list_size(caminho_correto) - 2; i += 2) {
        var cx = ds_list_find_value(caminho_correto, i);
        var cy = ds_list_find_value(caminho_correto, i + 1);
        var nx = ds_list_find_value(caminho_correto, i + 2);
        var ny = ds_list_find_value(caminho_correto, i + 3);
        
        var x1 = offset_x + cx * cell_size + cell_size / 2;
        var y1 = offset_y + cy * cell_size + cell_size / 2;
        var x2 = offset_x + nx * cell_size + cell_size / 2;
        var y2 = offset_y + ny * cell_size + cell_size / 2;
        
        draw_line_width(x1, y1, x2, y2, 4);
    }
    
    draw_set_alpha(1);
    
    // Desenha as peças corretas em cada posição do caminho
    for (var i = 0; i < ds_list_size(caminho_correto); i += 2) {
        var cx = ds_list_find_value(caminho_correto, i);
        var cy = ds_list_find_value(caminho_correto, i + 1);
        
        var cell_x = offset_x + cx * cell_size + cell_size / 2;
        var cell_y = offset_y + cy * cell_size + cell_size / 2;
        
        // Mostra qual tipo de peça é necessário
        var tipo = grid_solucao[# cx, cy];
        if (tipo != -1 && tipo >= 0 && tipo < array_length(objetos_pecas)) {
            // Desenha fundo semi-transparente verde
            draw_set_color(c_lime);
            draw_set_alpha(0.3);
            draw_rectangle(cell_x - cell_size/2, cell_y - cell_size/2, 
                          cell_x + cell_size/2, cell_y + cell_size/2, false);
            
            // Desenha o sprite da peça correta com transparência
            draw_set_alpha(0.6);
            var obj_peca = objetos_pecas[tipo];
            var sprite_peca = object_get_sprite(obj_peca);
            if (sprite_exists(sprite_peca)) {
                draw_sprite(sprite_peca, 0, cell_x, cell_y);
            }
            
            draw_set_alpha(1);
            
            // Desenha label com o tipo e objeto
            draw_set_color(c_black);
            draw_set_alpha(0.8);
            draw_roundrect(cell_x - 28, cell_y - 28, cell_x - 8, cell_y - 8, false);
            draw_set_alpha(1);
            draw_set_color(c_yellow);
            var tipo_nome = "";
            var obj_nome = "";
            switch(tipo) {
                case 0: tipo_nome = "↕"; obj_nome = "1"; break; // Vertical opeca
                case 1: tipo_nome = "↗"; obj_nome = "2"; break; // Curva cima-direita opeca2
                case 2: tipo_nome = "↖"; obj_nome = "3"; break; // Curva cima-esquerda opeca3
                case 3: tipo_nome = "↔"; obj_nome = "4"; break; // Horizontal opeca4
                case 4: tipo_nome = "↘"; obj_nome = "5"; break; // Curva baixo-direita opeca5
                case 5: tipo_nome = "↙"; obj_nome = "6"; break; // Curva baixo-esquerda opeca6
            }
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(cell_x - 18, cell_y - 22, tipo_nome);
            draw_text(cell_x - 18, cell_y - 14, obj_nome);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
    
    draw_set_alpha(1);
    draw_set_color(c_white);
    
    // Texto informativo
    draw_text(10, 110, "DEBUG: Pressione D para ocultar | Verde = Peça correta nesta posição");
}

// (Game Over movido para Draw GUI)