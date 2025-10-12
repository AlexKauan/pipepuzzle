// ============================================
// CONTROLE DO JOGO
// ============================================

// Pausa o jogo com ESC
if (keyboard_check_pressed(vk_escape)) {
    jogo_pausado = !jogo_pausado;
}

// Se o jogo não está pausado e não está completo
if (!jogo_pausado && !jogo_completo) {
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
if (keyboard_check_pressed(ord("H")) && hints_disponiveis > 0 && !jogo_completo) {
    usar_hint();
}

// Reset do jogo com R
if (keyboard_check_pressed(ord("R"))) {
    reiniciar_nivel();
}

// Próximo nível com N (apenas se completo)
if (keyboard_check_pressed(ord("N")) && jogo_completo) {
    proximo_nivel();
}

// ============================================
// FUNÇÕES DO SISTEMA DE JOGO
// ============================================

/// @function completar_nivel()
/// @description Executado quando o nível é completado
function completar_nivel() {
    // Calcula pontuação baseada no tempo restante
    var bonus_tempo = floor(tempo_restante * 10);
    var bonus_nivel = nivel_atual * 100;
    pontuacao += bonus_tempo + bonus_nivel;
    
    // Efeito visual de vitória
    var destino_x = offset_x + ponto_destino_x * cell_size + cell_size / 2;
    var destino_y = offset_y + ponto_destino_y * cell_size + cell_size / 2;
    criar_efeito_sucesso(destino_x, destino_y);
    
    // Efeito visual/sonoro de vitória
    show_debug_message("Nível " + string(nivel_atual) + " completado!");
    show_debug_message("Pontuação: " + string(pontuacao));
}

/// @function game_over_tempo()
/// @description Executado quando o tempo acaba
function game_over_tempo() {
    show_debug_message("Tempo esgotado! Game Over!");
    // Aqui você pode adicionar lógica para voltar ao menu ou reiniciar
}

/// @function usar_hint()
/// @description Mostra uma dica para o jogador
function usar_hint() {
    hints_disponiveis--;
    mostrar_hint = true;
    
    // Efeito visual na origem
    var origem_x = offset_x + ponto_origem_x * cell_size + cell_size / 2;
    var origem_y = offset_y + ponto_origem_y * cell_size + cell_size / 2;
    criar_efeito_agua(origem_x, origem_y);
    
    // Remove a dica após 3 segundos
    alarm[0] = 180; // 3 segundos em 60 FPS
    
    show_debug_message("Dica usada! Restam: " + string(hints_disponiveis));
}

/// @function reiniciar_nivel()
/// @description Reinicia o nível atual
function reiniciar_nivel() {
    // Destroi todas as peças e obstáculos
    with(opeca) {
        instance_destroy();
    }
    
    // Destroi obstáculos usando asset_get_index
    var obstaculo_id = asset_get_index("oobstaculo");
    if (obstaculo_id != -1) {
        with(obstaculo_id) {
            instance_destroy();
        }
    }
    
    // Reinicia variáveis
    jogo_completo = false;
    caminho_valido = false;
    fluxo_ativo = false;
    tempo_inicio = current_time;
    mostrar_hint = false;
    
    // Recria o nível
    configurar_nivel(nivel_atual);
    criar_pecas_do_nivel();
    verificar_caminho();
    
    show_debug_message("Nível reiniciado!");
}

/// @function proximo_nivel()
/// @description Avança para o próximo nível
function proximo_nivel() {
    nivel_atual++;
    
    // Salva progresso
    with(ogamesave) {
        salvar_dados();
    }
    
    // Destroi todas as peças e obstáculos
    with(opeca) {
        instance_destroy();
    }
    
    // Destroi obstáculos usando asset_get_index
    var obstaculo_id = asset_get_index("oobstaculo");
    if (obstaculo_id != -1) {
        with(obstaculo_id) {
            instance_destroy();
        }
    }
    
    // Reinicia variáveis
    jogo_completo = false;
    caminho_valido = false;
    fluxo_ativo = false;
    tempo_inicio = current_time;
    mostrar_hint = false;
    
    // Configura novo nível
    configurar_nivel(nivel_atual);
    criar_pecas_do_nivel();
    verificar_caminho();
    
    show_debug_message("Nível " + string(nivel_atual) + " iniciado!");
}

// ============================================
// ALARMES
// ============================================

// Alarm 0: Remove hint após 3 segundos
if (alarm[0] <= 0) {
    mostrar_hint = false;
}
