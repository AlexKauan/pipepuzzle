// ============================================
// MENU INICIAL - PIPE PUZZLE
// ============================================

// Opções do menu
opcao_selecionada = 0;
opcoes = ["JOGAR", "CONTINUAR", "SAIR"];
total_opcoes = array_length(opcoes);

// Posições e tamanhos
// Alinha texto aos slots do background
titulo_y = 150;
opcoes_y_inicio = 300; // sobe um pouco as opções no menu
espacamento_opcoes = 170;
opcao_x_offset = -100; // ajuste fino para alinhar ao centro visual dos slots

// Cores
cor_titulo = c_white;
cor_opcao_normal = c_white;
cor_opcao_hover = c_red; // texto em vermelho no hover
cor_fundo = c_black;

// Tamanho da fonte (ajustável)
tamanho_fonte_titulo = 3;
tamanho_fonte_opcao = 1.5;

// Variável para detectar hover
opcao_hover = -1;

