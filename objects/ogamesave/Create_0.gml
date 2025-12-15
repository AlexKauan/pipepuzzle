// Sistema de salvamento do jogo (persistente)
// Este objeto deve existir desde o menu inicial

// Nome do arquivo de save
global.save_file = "pipe_puzzle_save.ini";

// Flags globais de progresso
if (!variable_global_exists("has_save")) global.has_save = false;
if (!variable_global_exists("usar_save")) global.usar_save = false;
global.nivel_salvo = 1;
global.pontuacao_salva = 0;
global.hints_salvas = 3;

// Carrega dados salvos para variáveis globais
function carregar_dados() {
    if (file_exists(global.save_file)) {
        ini_open(global.save_file);
        global.nivel_salvo = ini_read_real("progresso", "nivel", 1);
        global.pontuacao_salva = ini_read_real("progresso", "pontuacao", 0);
        global.hints_salvas = ini_read_real("progresso", "hints", 3);
        ini_close();

        global.has_save = true;
        show_debug_message("Dados carregados - Nível: " + string(global.nivel_salvo) + ", Pontuação: " + string(global.pontuacao_salva));
    } else {
        global.has_save = false;
        show_debug_message("Nenhum arquivo de save encontrado. Iniciando novo jogo.");
    }
}

// Salva dados a partir do controlador principal
function salvar_dados() {
    // Usa a referência do controlador (global.gc) se existir
    var nivel_para_salvar = global.nivel_salvo;
    var pontuacao_para_salvar = global.pontuacao_salva;
    var hints_para_salvar = global.hints_salvas;

    if (variable_global_exists("gc") && instance_exists(global.gc)) {
        nivel_para_salvar = global.gc.nivel_atual;
        pontuacao_para_salvar = global.gc.pontuacao;
        hints_para_salvar = global.gc.hints_disponiveis;
    }

    ini_open(global.save_file);
    ini_write_real("progresso", "nivel", nivel_para_salvar);
    ini_write_real("progresso", "pontuacao", pontuacao_para_salvar);
    ini_write_real("progresso", "hints", hints_para_salvar);
    ini_write_string("progresso", "data", string(date_current_datetime()));
    ini_close();

    // Atualiza cache global
    global.nivel_salvo = nivel_para_salvar;
    global.pontuacao_salva = pontuacao_para_salvar;
    global.hints_salvas = hints_para_salvar;
    global.has_save = true;

    show_debug_message("Dados salvos! Nível: " + string(nivel_para_salvar));
}

// Reseta o progresso salvo
function resetar_progresso() {
    if (file_exists(global.save_file)) {
        file_delete(global.save_file);
    }

    global.nivel_salvo = 1;
    global.pontuacao_salva = 0;
    global.hints_salvas = 3;
    global.has_save = false;

    show_debug_message("Progresso resetado!");
}

// Carrega dados na inicialização
carregar_dados();