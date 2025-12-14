// ============================================
// CONTROLE DO JOGO
// ============================================

// Pausa o jogo com ESC (somente se não estiver em game over)
if (!game_over_ativo && keyboard_check_pressed(vk_escape)) {
    jogo_pausado = !jogo_pausado;
}

// Se o jogo não está pausado, completo ou em game over
if (!jogo_pausado && !jogo_completo && !game_over_ativo) {
    // Atualiza tempo
    tempo_restante = tempo_limite - ((current_time - tempo_inicio) / 1000);
    
    // Verifica se o tempo acabou
    if (tempo_restante <= 0) {
        tempo_restante = 0;
        // Game Over por tempo
        game_over_tempo();
    }
    
    // Verifica se o puzzle foi completado
    if (caminho_valido && !jogo_completo) {
        jogo_completo = true;
        completar_nivel();
    }
}

// Sistema de hints
if (keyboard_check_pressed(ord("H")) && hints_disponiveis > 0 && !jogo_completo && !game_over_ativo) {
    usar_hint();
}

// Reset do jogo com R (somente se não estiver em game over)
if (keyboard_check_pressed(ord("R")) && !game_over_ativo) {
    reiniciar_nivel();
}

// Próximo nível com N (apenas se completo)
if (keyboard_check_pressed(ord("N")) && jogo_completo) {
    proximo_nivel();
}

// ============================================
// CONTROLE DA TELA DE GAME OVER
// ============================================
if (game_over_ativo) {
    // Reiniciar fase
    if (keyboard_check_pressed(ord("R"))) {
        reiniciar_nivel();
    }

    // Sair (ESC) durante game over
    if (keyboard_check_pressed(vk_escape)) {
        game_end();
    }

    // Fechar jogo
    if (keyboard_check_pressed(ord("Q"))) {
        game_end(); // Fecha o jogo
    }
}

// ============================================
// FUNÇÕES DO SISTEMA DE JOGO
// ============================================

/// @function completar_nivel()
function completar_nivel() {
    var bonus_tempo = floor(tempo_restante * 10);
    var bonus_nivel = nivel_atual * 100;
    pontuacao += bonus_tempo + bonus_nivel;
    
    var destino_x = offset_x + ponto_destino_x * cell_size + cell_size / 2;
    var destino_y = offset_y + ponto_destino_y * cell_size + cell_size / 2;
    criar_efeito_sucesso(destino_x, destino_y);
    
    show_debug_message("Nível " + string(nivel_atual) + " completado!");
    show_debug_message("Pontuação: " + string(pontuacao));
}

/// @function game_over_tempo()
/// @description Executado quando o tempo acaba
function game_over_tempo() {
    show_debug_message("Tempo esgotado! Game Over!");
    game_over_ativo = true; // Ativa estado de game over
}

/// @function usar_hint()
function usar_hint() {
    hints_disponiveis--;
    mostrar_hint = true;
    
    // Sorteia/cicla o texto da dica
    hint_index = (hint_index + 1) mod array_length(hint_textos);
    hint_texto_atual = hint_textos[hint_index];
    
    var origem_x = offset_x + ponto_origem_x * cell_size + cell_size / 2;
    var origem_y = offset_y + ponto_origem_y * cell_size + cell_size / 2;
    criar_efeito_agua(origem_x, origem_y);
    
    alarm[0] = 180; // 3 segundos em 60 FPS
    show_debug_message("Dica usada! Restam: " + string(hints_disponiveis));
}

/// @function reiniciar_nivel()
function reiniciar_nivel() {
    with(opeca) instance_destroy();
    
    var obstaculo_id = asset_get_index("oobstaculo");
    if (obstaculo_id != -1) {
        with(obstaculo_id) instance_destroy();
    }
    
    jogo_completo = false;
    caminho_valido = false;
    fluxo_ativo = false;
    tempo_inicio = current_time;
    mostrar_hint = false;
    game_over_ativo = false;
    
    configurar_nivel(nivel_atual);
    
    // Limpa e recria os grids
    ds_grid_resize(grid, grid_width, grid_height);
    ds_grid_clear(grid, -1);
    ds_grid_resize(grid_solucao, grid_width, grid_height);
    ds_grid_clear(grid_solucao, -1);
    
    criar_pecas_do_nivel();
    verificar_caminho();
    
    show_debug_message("Nível reiniciado!");
}

/// @function proximo_nivel()
function proximo_nivel() {
    nivel_atual++;
    
    with(opeca) instance_destroy();
    
    var obstaculo_id = asset_get_index("oobstaculo");
    if (obstaculo_id != -1) {
        with(obstaculo_id) instance_destroy();
    }
    
    jogo_completo = false;
    caminho_valido = false;
    fluxo_ativo = false;
    tempo_inicio = current_time;
    mostrar_hint = false;
    game_over_ativo = false;
    
    configurar_nivel(nivel_atual);
    
    // Limpa e recria os grids
    ds_grid_resize(grid, grid_width, grid_height);
    ds_grid_clear(grid, -1);
    ds_grid_resize(grid_solucao, grid_width, grid_height);
    ds_grid_clear(grid_solucao, -1);
    
    criar_pecas_do_nivel();
    verificar_caminho();
    
    show_debug_message("Nível " + string(nivel_atual) + " iniciado!");
}

// ============================================
// ALARMES
// ============================================

if (alarm[0] <= 0) {
    mostrar_hint = false;
}
