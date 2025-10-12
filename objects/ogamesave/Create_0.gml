// Sistema de salvamento do jogo
// Este objeto deve ser criado apenas uma vez na room principal

// Arquivo de save
save_file = "pipe_puzzle_save.ini";

// Carrega dados salvos
function carregar_dados() {
    if (file_exists(save_file)) {
        nivel_atual = ini_read_real("progresso", "nivel", 1);
        pontuacao = ini_read_real("progresso", "pontuacao", 0);
        hints_disponiveis = ini_read_real("progresso", "hints", 3);
        
        show_debug_message("Dados carregados - Nível: " + string(nivel_atual) + ", Pontuação: " + string(pontuacao));
    } else {
        show_debug_message("Nenhum arquivo de save encontrado. Iniciando novo jogo.");
    }
}

// Salva dados do jogo
function salvar_dados() {
    ini_write_real("progresso", "nivel", nivel_atual);
    ini_write_real("progresso", "pontuacao", pontuacao);
    ini_write_real("progresso", "hints", hints_disponiveis);
    ini_write_string("progresso", "data", string(date_current_datetime()));
    
    show_debug_message("Dados salvos!");
}

// Reseta o progresso
function resetar_progresso() {
    if (file_exists(save_file)) {
        file_delete(save_file);
    }
    
    nivel_atual = 1;
    pontuacao = 0;
    hints_disponiveis = 3;
    
    show_debug_message("Progresso resetado!");
}

// Carrega dados na inicialização
carregar_dados();





