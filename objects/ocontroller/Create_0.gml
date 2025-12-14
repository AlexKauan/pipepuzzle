 // Variável global para acesso pelas peças
global.gc = id;

// ============================================
// SISTEMA DE NÍVEIS E DIFICULDADE
// ============================================

// Configurações do nível atual
nivel_atual = 1;
dificuldade = 1; // 1 = Fácil, 2 = Médio, 3 = Difícil
grid_width = 6;  // Começa menor e aumenta com o nível
grid_height = 6;
cell_size = 80; // aumenta o zoom visual do grid

// Pontos de origem e destino do fluxo de água (dinâmicos baseado no nível)
ponto_origem_x = 0;
ponto_origem_y = 0;
ponto_destino_x = grid_width - 1;
ponto_destino_y = grid_height - 1;

// Estado do fluxo de água
fluxo_ativo = false;
caminho_valido = false;

// Sistema de pontuação
pontuacao = 0;
tempo_inicio = 0;
tempo_limite = 0; // em segundos
tempo_restante = 0;

// Sistema de hints
hints_disponiveis = 3;
hint_usado = false;
hint_index = 0;
hint_textos = [
    "Dica: comece traçando da origem até a casa evitando becos sem saída.",
    "Dica: deixe espaço para curvas; não feche laterais que ainda não ligaram.",
    "Dica: se travar, use R para reiniciar e testar outro caminho rápido."
];

// Contador de peças
total_pecas = 0;

// Estado do jogo
jogo_pausado = false;
jogo_completo = false;
game_over_ativo = false; // <-- ADICIONE ESTA LINHA
mostrar_hint = false;

// Configurações por nível
function configurar_nivel(nivel) {
    switch (nivel) {
        case 1: case 2: case 3:
            grid_width = 6;
            grid_height = 6;
            dificuldade = 1;
            tempo_limite = 120; // 2 minutos
            break;
        case 4: case 5: case 6:
            grid_width = 7;
            grid_height = 7;
            dificuldade = 1;
            tempo_limite = 180; // 3 minutos
            break;
        case 7: case 8: case 9:
            grid_width = 8;
            grid_height = 8;
            dificuldade = 2;
            tempo_limite = 240; // 4 minutos
            break;
        case 10: case 11: case 12:
            grid_width = 8;
            grid_height = 8;
            dificuldade = 2;
            tempo_limite = 300; // 5 minutos
            break;
        default:
            grid_width = 9;
            grid_height = 9;
            dificuldade = 3;
            tempo_limite = 360; // 6 minutos
            break;
    }
    
    ponto_destino_x = grid_width - 1;
    ponto_destino_y = grid_height - 1;
    tempo_restante = tempo_limite;
}

// Configura o nível atual
configurar_nivel(nivel_atual);

// Criar grid após definir as dimensões
grid = ds_grid_create(grid_width, grid_height);
for (var i = 0; i < grid_width; i++) {
    for (var j = 0; j < grid_height; j++) {
        grid[# i, j] = -1; // -1 = célula vazia
    }
}

// Grid de solução - armazena qual tipo de peça deve estar em cada célula
// -1 = sem peça necessária, 0-5 = tipo de peça necessária (opeca, opeca2, etc)
grid_solucao = ds_grid_create(grid_width, grid_height);
ds_grid_clear(grid_solucao, -1);

// Lista de células que fazem parte do caminho correto
caminho_correto = ds_list_create();

// Calcular offset para centralizar o grid (arredondado para evitar desalinhamento de 1px)
offset_x = round((room_width - (grid_width * cell_size)) / 2);
offset_y = round((room_height - (grid_height * cell_size)) / 2) - 50;
// subtrai 50 para deixar espaço para a bancada embaixo

// Inicia o timer
tempo_inicio = current_time;

// ============================================
// FUNÇÕES DE GERAÇÃO DE CAMINHO CORRETO
// ============================================

/// @function gerar_caminho_correto()
/// @description Gera um caminho aleatório válido da origem ao destino com maior variação
function gerar_caminho_correto() {
    // Limpa a solução anterior
    ds_grid_clear(grid_solucao, -1);
    ds_list_clear(caminho_correto);
    
    // Array de direções: [dx, dy]
    // Direções: 0 = cima, 1 = direita, 2 = baixo, 3 = esquerda
    var dir_x = [0, 1, 0, -1];
    var dir_y = [-1, 0, 1, 0];
    
    var caminho_gerado = false;
    var tentativa_global = 0;
    var max_tentativas_globais = 100;
    
    // Define complexidade mínima do caminho baseado no grid e dificuldade
    var tamanho_minimo = floor((grid_width + grid_height) * 0.8); // 80% do perímetro
    var tamanho_maximo = (grid_width * grid_height) * 0.4; // 40% das células
    
    while (!caminho_gerado && tentativa_global < max_tentativas_globais) {
        tentativa_global++;
        ds_list_clear(caminho_correto);
        
        // Começa na origem
        var cx = ponto_origem_x;
        var cy = ponto_origem_y;
        ds_list_add(caminho_correto, cx, cy);
        
        var passos = 0;
        var max_passos = grid_width * grid_height * 2;
        var modo_exploracao = true; // Alterna entre exploração e aproximação
        var contador_exploracao = 0;
        
        // Gera caminho até chegar ao destino
        while ((cx != ponto_destino_x || cy != ponto_destino_y) && passos < max_passos) {
            passos++;
            
            // Lista de direções possíveis
            var dirs_possiveis = [];
            var pesos_direcoes = []; // Peso para cada direção
            
        for (var i = 0; i < 4; i++) {
            var nx = cx + dir_x[i];
            var ny = cy + dir_y[i];
            
                // Verifica limites
            if (nx < 0 || nx >= grid_width || ny < 0 || ny >= grid_height) {
                continue;
            }
            
                // Evita voltar para células já no caminho (exceto destino)
                var ja_no_caminho = false;
                for (var j = 0; j < ds_list_size(caminho_correto); j += 2) {
                    var path_x = ds_list_find_value(caminho_correto, j);
                    var path_y = ds_list_find_value(caminho_correto, j + 1);
                    if (nx == path_x && ny == path_y) {
                        ja_no_caminho = true;
                        break;
                    }
                }
                
                if (ja_no_caminho && !(nx == ponto_destino_x && ny == ponto_destino_y)) {
                continue;
            }
            
                // Calcula peso para esta direção
                var dist_destino = abs(nx - ponto_destino_x) + abs(ny - ponto_destino_y);
                var dist_centro = abs(nx - grid_width/2) + abs(ny - grid_height/2);
                
                var peso = 1;
                
                // Alterna entre modo exploração e aproximação
                if (modo_exploracao) {
                    // Favorece ir para o centro ou explorar
                    peso = 100 - dist_centro * 10;
                    // Evita ir muito direto ao destino cedo demais
                    if (dist_destino == 0) peso += 1000; // Mas sempre quer chegar se possível
                } else {
                    // Favorece aproximar do destino
                    peso = 100 - dist_destino * 15;
                }
                
                // Adiciona um fator aleatório para variação
                peso += random(40);
                
                array_push(dirs_possiveis, i);
                array_push(pesos_direcoes, peso);
            }
            
            // Se não há direções possíveis, falhou - tenta novamente
            if (array_length(dirs_possiveis) == 0) {
                break; // Sai do while interno e tenta gerar novo caminho
            }
            
            // Escolhe direção baseado nos pesos
            var escolha_dir = -1;
            var maior_peso = -9999;
            
            for (var i = 0; i < array_length(dirs_possiveis); i++) {
                if (pesos_direcoes[i] > maior_peso) {
                    maior_peso = pesos_direcoes[i];
                    escolha_dir = dirs_possiveis[i];
                }
            }
            
            // Move na direção escolhida
            cx = cx + dir_x[escolha_dir];
            cy = cy + dir_y[escolha_dir];
            
            // Adiciona ao caminho
            ds_list_add(caminho_correto, cx, cy);
            
            // Alterna entre exploração e aproximação
            contador_exploracao++;
            if (contador_exploracao > irandom_range(3, 8)) {
                modo_exploracao = !modo_exploracao;
                contador_exploracao = 0;
            }
            
            // Se está muito perto do destino, força modo aproximação
            var dist_atual = abs(cx - ponto_destino_x) + abs(cy - ponto_destino_y);
            if (dist_atual <= 3) {
                modo_exploracao = false;
            }
        }
        
        // Verifica se chegou ao destino
        if (cx == ponto_destino_x && cy == ponto_destino_y) {
            var tamanho_caminho = ds_list_size(caminho_correto) / 2;
            
            // Verifica se o caminho tem tamanho adequado
            if (tamanho_caminho >= tamanho_minimo) {
                caminho_gerado = true;
                show_debug_message("Caminho válido gerado na tentativa " + string(tentativa_global));
            } else {
                show_debug_message("Caminho muito curto (" + string(tamanho_caminho) + "), tentando novamente...");
            }
        }
    }
    
    // Se falhou em gerar caminho complexo, gera um simples
    if (!caminho_gerado) {
        show_debug_message("Gerando caminho simples como fallback...");
        ds_list_clear(caminho_correto);
        gerar_caminho_simples();
    }
    
    // Mostra o caminho completo
    show_debug_message("=== CAMINHO GERADO ===");
    var caminho_str = "Caminho: ";
    for (var i = 0; i < ds_list_size(caminho_correto); i += 2) {
        var px = ds_list_find_value(caminho_correto, i);
        var py = ds_list_find_value(caminho_correto, i + 1);
        caminho_str += "[" + string(px) + "," + string(py) + "] → ";
    }
    show_debug_message(caminho_str);
    
    // Agora define qual peça deve estar em cada célula do caminho
    show_debug_message("Processando células do caminho:");
    for (var i = 0; i < ds_list_size(caminho_correto); i += 2) {
        var cell_x = ds_list_find_value(caminho_correto, i);
        var cell_y = ds_list_find_value(caminho_correto, i + 1);
        
        // Não coloca peça na origem ou destino
        if ((cell_x == ponto_origem_x && cell_y == ponto_origem_y) ||
            (cell_x == ponto_destino_x && cell_y == ponto_destino_y)) {
            show_debug_message("  [" + string(cell_x) + "," + string(cell_y) + "] = Origem/Destino (pulado)");
            continue;
        }
        
        // Determina direção de entrada e saída
        var dir_entrada = -1;
        var dir_saida = -1;
        
        // IMPORTANTE: A peça deve ter conexões nas direções POR ONDE A LINHA PASSA
        // Se a linha vem de CIMA, a peça tem conexão em CIMA
        // Se a linha vai para ESQUERDA, a peça tem conexão em ESQUERDA
        
        // Direção de onde a linha vem (qual conexão a peça precisa ter)
        if (i > 0) {
            var prev_x = ds_list_find_value(caminho_correto, i - 2);
            var prev_y = ds_list_find_value(caminho_correto, i - 1);
            
            // Calcula onde está prev em relação à célula atual
            var dx = prev_x - cell_x; // positivo = prev à direita, negativo = prev à esquerda
            var dy = prev_y - cell_y; // positivo = prev abaixo, negativo = prev acima
            
            // A peça precisa ter conexão na direção de onde vem a linha
            if (dx == 1) dir_entrada = 1; // prev à direita → peça conecta à DIREITA
            else if (dx == -1) dir_entrada = 3; // prev à esquerda → peça conecta à ESQUERDA
            // NO GAMEMAKER, Y CRESCE PARA BAIXO!
            else if (dy == 1) dir_entrada = 2; // prev abaixo → peça conecta em BAIXO
            else if (dy == -1) dir_entrada = 0; // prev acima → peça conecta em CIMA
        }
        
        // Direção para onde a linha vai (qual conexão a peça precisa ter)
        if (i + 2 < ds_list_size(caminho_correto)) {
            var next_x = ds_list_find_value(caminho_correto, i + 2);
            var next_y = ds_list_find_value(caminho_correto, i + 3);
            
            // Calcula onde está next em relação à célula atual
            var dx = next_x - cell_x; // positivo = next à direita, negativo = next à esquerda
            var dy = next_y - cell_y; // positivo = next abaixo, negativo = next acima
            
            // A peça precisa ter conexão na direção para onde vai a linha
            if (dx == 1) dir_saida = 1; // next à direita → peça conecta à DIREITA
            else if (dx == -1) dir_saida = 3; // next à esquerda → peça conecta à ESQUERDA
            // NO GAMEMAKER, Y CRESCE PARA BAIXO!
            else if (dy == 1) dir_saida = 2; // next abaixo → peça conecta em BAIXO
            else if (dy == -1) dir_saida = 0; // next acima → peça conecta em CIMA
        }
        
        // Determina qual tipo de peça precisa baseado nas direções
        var tipo_peca = determinar_tipo_peca(dir_entrada, dir_saida, dificuldade);
        grid_solucao[# cell_x, cell_y] = tipo_peca;
        
        // Debug: mostra qual peça foi atribuída
        var prev_info = "";
        var next_info = "";
        
        if (i > 0) {
            var prev_x = ds_list_find_value(caminho_correto, i - 2);
            var prev_y = ds_list_find_value(caminho_correto, i - 1);
            prev_info = "prev[" + string(prev_x) + "," + string(prev_y) + "]";
        }
        
        if (i + 2 < ds_list_size(caminho_correto)) {
            var next_x = ds_list_find_value(caminho_correto, i + 2);
            var next_y = ds_list_find_value(caminho_correto, i + 3);
            next_info = "next[" + string(next_x) + "," + string(next_y) + "]";
        }
        
        var nome_dir_entrada = "";
        var nome_dir_saida = "";
        switch(dir_entrada) {
            case 0: nome_dir_entrada = "↑cima"; break;
            case 1: nome_dir_entrada = "→direita"; break;
            case 2: nome_dir_entrada = "↓baixo"; break;
            case 3: nome_dir_entrada = "←esquerda"; break;
            default: nome_dir_entrada = "N/A"; break;
        }
        switch(dir_saida) {
            case 0: nome_dir_saida = "↑cima"; break;
            case 1: nome_dir_saida = "→direita"; break;
            case 2: nome_dir_saida = "↓baixo"; break;
            case 3: nome_dir_saida = "←esquerda"; break;
            default: nome_dir_saida = "N/A"; break;
        }
        var nome_tipo = ["Vertical[↑↓]", "Curva[↑→]", "Curva[↑←]", "Horizontal[→←]", "Curva[↓→]", "Curva[↓←]"];
        show_debug_message("  [" + string(cell_x) + "," + string(cell_y) + "] " + prev_info + " " + next_info + 
                          " | Conexões: " + nome_dir_entrada + "+" + nome_dir_saida + " = " + nome_tipo[tipo_peca]);
    }
    
    show_debug_message("Caminho correto gerado com " + string(ds_list_size(caminho_correto) / 2) + " células");
}

/// @function gerar_caminho_simples()
/// @description Gera um caminho simples direto (fallback)
function gerar_caminho_simples() {
    var dir_x = [0, 1, 0, -1];
    var dir_y = [-1, 0, 1, 0];
    
    var cx = ponto_origem_x;
    var cy = ponto_origem_y;
    ds_list_add(caminho_correto, cx, cy);
    
    // Vai primeiro na horizontal, depois na vertical
    while (cx != ponto_destino_x) {
        if (cx < ponto_destino_x) cx++;
        else cx--;
        ds_list_add(caminho_correto, cx, cy);
    }
    
    while (cy != ponto_destino_y) {
        if (cy < ponto_destino_y) cy++;
        else cy--;
        ds_list_add(caminho_correto, cx, cy);
    }
}

/// @function determinar_tipo_peca(dir1, dir2, nivel_dificuldade)
/// @description Determina qual tipo de peça é necessária baseado nas direções de conexão
function determinar_tipo_peca(dir1, dir2, nivel_dificuldade = 1) {
    // Garante que dir1 <= dir2 para facilitar comparação
    if (dir1 > dir2) {
        var temp = dir1;
        dir1 = dir2;
        dir2 = temp;
    }
    
    // Direções: 0 = cima, 1 = direita, 2 = baixo, 3 = esquerda
    // MAPEAMENTO CORRETO DOS SPRITES (CONFIRMADO):
    // opeca (0): [0, 2] - vertical (cima-baixo) ↕
    // opeca2 (1): [0, 1] - curva cima-direita ↗
    // opeca3 (2): [0, 3] - curva cima-esquerda ↖
    // opeca4 (3): [1, 3] - horizontal (direita-esquerda) ↔
    // opeca5 (4): [2, 1] - curva baixo-direita ↘
    // opeca6 (5): [2, 3] - curva baixo-esquerda ↙
    
    // Peças retas
    if (dir1 == 0 && dir2 == 2) return 0; // opeca - vertical (cima-baixo) ↕
    if (dir1 == 1 && dir2 == 3) return 3; // opeca4 - horizontal (direita-esquerda) ↔
    
    // Curvas L - todas as 4 orientações possíveis
    if (dir1 == 0 && dir2 == 1) return 1; // opeca2 - cima-direita ↗
    if (dir1 == 0 && dir2 == 3) return 2; // opeca3 - cima-esquerda ↖
    if (dir1 == 1 && dir2 == 2) return 4; // opeca5 - baixo-direita ↘
    if (dir1 == 2 && dir2 == 3) return 5; // opeca6 - baixo-esquerda ↙
    
    // Fallback - retorna peça reta
    return choose(0, 3);
}

/// @function verificar_caminho()
/// @description Valida se o jogador colocou as peças corretas no caminho
function verificar_caminho() {
    // Reseta o estado de água de todas as peças
    with(opeca) {
        tem_agua = false;
    }
    
    var todas_corretas = true;
    
    // Verifica se cada célula do caminho tem a peça correta
    for (var i = 0; i < ds_list_size(caminho_correto); i += 2) {
        var cell_x = ds_list_find_value(caminho_correto, i);
        var cell_y = ds_list_find_value(caminho_correto, i + 1);
        
        // Origem e destino não precisam de peça
        if ((cell_x == ponto_origem_x && cell_y == ponto_origem_y) ||
            (cell_x == ponto_destino_x && cell_y == ponto_destino_y)) {
            continue;
        }
        
        // Verifica se há uma peça esperada nesta célula
        var tipo_esperado = grid_solucao[# cell_x, cell_y];
        if (tipo_esperado == -1) continue; // Não precisa de peça
        
        // Verifica se há uma peça na célula
        var peca_id = grid[# cell_x, cell_y];
        if (peca_id == -1 || !instance_exists(peca_id)) {
            todas_corretas = false;
            continue;
        }
        
        // Verifica se a peça é do tipo correto
        var peca = peca_id;
        var tipo_atual = -1;
        
        if (object_get_name(peca.object_index) == "opeca") tipo_atual = 0;
        else if (object_get_name(peca.object_index) == "opeca2") tipo_atual = 1;
        else if (object_get_name(peca.object_index) == "opeca3") tipo_atual = 2;
        else if (object_get_name(peca.object_index) == "opeca4") tipo_atual = 3;
        else if (object_get_name(peca.object_index) == "opeca5") tipo_atual = 4;
        else if (object_get_name(peca.object_index) == "opeca6") tipo_atual = 5;
        
        if (tipo_atual != tipo_esperado) {
            todas_corretas = false;
        } else {
            // Marca a peça como tendo água se estiver correta
            peca.tem_agua = true;
        }
    }
    
    // Atualiza estado
    caminho_valido = todas_corretas;
    fluxo_ativo = todas_corretas;
    
    show_debug_message("Validação do caminho: " + string(todas_corretas ? "VÁLIDO" : "INVÁLIDO"));
    
    return todas_corretas;
}

// ============================================
// FUNÇÃO DE CRIAÇÃO DE PEÇAS
// ============================================

/// @function criar_pecas_do_nivel()
/// @description Cria peças no grid baseado no caminho correto gerado
function criar_pecas_do_nivel() {
    // Limpa o grid primeiro
    ds_grid_clear(grid, -1);
    total_pecas = 0;
    
    // Gera o caminho correto primeiro
    gerar_caminho_correto();
    
    // Array com TODOS os objetos de peças (índices 0-5)
    // Sempre mantém todos os 6 tipos no array para correspondência correta
    var objetos_pecas = [opeca, opeca2, opeca3, opeca4, opeca5, opeca6];
    
    // Lista para armazenar peças do caminho que serão criadas
    var pecas_caminho = ds_list_create();
    
    // Primeiro, identifica quais peças fazem parte do caminho correto
    for (var i = 0; i < ds_list_size(caminho_correto); i += 2) {
        var cell_x = ds_list_find_value(caminho_correto, i);
        var cell_y = ds_list_find_value(caminho_correto, i + 1);
        
        // Pula origem e destino
        if ((cell_x == ponto_origem_x && cell_y == ponto_origem_y) ||
            (cell_x == ponto_destino_x && cell_y == ponto_destino_y)) {
            continue;
        }
        
        var tipo_esperado = grid_solucao[# cell_x, cell_y];
        if (tipo_esperado != -1) {
            ds_list_add(pecas_caminho, cell_x, cell_y, tipo_esperado);
        }
    }
    
    // Agora cria as peças do caminho em posições ALEATÓRIAS no grid (não nas posições corretas)
    for (var i = 0; i < ds_list_size(pecas_caminho); i += 3) {
        var tipo = ds_list_find_value(pecas_caminho, i + 2);
        
        // Tenta encontrar uma posição aleatória vazia
        var tentativas = 0;
        var colocada = false;
        
        while (!colocada && tentativas < 100) {
            tentativas++;
            var rand_x = irandom(grid_width - 1);
            var rand_y = irandom(grid_height - 1);
            
            // Não coloca na origem ou destino
            if ((rand_x == ponto_origem_x && rand_y == ponto_origem_y) ||
                (rand_x == ponto_destino_x && rand_y == ponto_destino_y)) {
                continue;
            }
            
            // Verifica se está vazia
            if (grid[# rand_x, rand_y] == -1) {
                // Cria a peça do tipo correto
                var obj_peca = objetos_pecas[tipo];
                var peca_x = offset_x + rand_x * cell_size + cell_size / 2;
                var peca_y = offset_y + rand_y * cell_size + cell_size / 2;
                
                var peca = instance_create_layer(peca_x, peca_y, "Instances", obj_peca);
                peca.start_x = peca_x;
                peca.start_y = peca_y;
                peca.grid_x_inicial = rand_x;
                peca.grid_y_inicial = rand_y;
                
                grid[# rand_x, rand_y] = peca.id;
                total_pecas++;
                colocada = true;
            }
        }
    }
    
    // Adiciona peças "distratoras" (peças erradas) para dificultar
    var num_distratoras = floor(ds_list_size(pecas_caminho) / 3 * 0.5); // 50% do número de peças corretas
    
    // Define quais tipos de peças podem ser usados nas distratoras baseado na dificuldade
    var tipos_distratoras = [0, 1, 2, 3]; // Básicas sempre disponíveis
    if (dificuldade >= 2) {
        array_push(tipos_distratoras, 4); // Adiciona Cruz
    }
    if (dificuldade >= 3) {
        array_push(tipos_distratoras, 5); // Adiciona T
    }
    
    for (var i = 0; i < num_distratoras; i++) {
        var tentativas = 0;
        var colocada = false;
        
        while (!colocada && tentativas < 50) {
            tentativas++;
            var rand_x = irandom(grid_width - 1);
            var rand_y = irandom(grid_height - 1);
            
            // Não coloca na origem ou destino
            if ((rand_x == ponto_origem_x && rand_y == ponto_origem_y) ||
                (rand_x == ponto_destino_x && rand_y == ponto_destino_y)) {
                continue;
            }
            
            // Verifica se está vazia
            if (grid[# rand_x, rand_y] == -1) {
                // Escolhe um tipo aleatório dos disponíveis para distração
                var tipo_aleatorio = tipos_distratoras[irandom(array_length(tipos_distratoras) - 1)];
                var obj_peca = objetos_pecas[tipo_aleatorio];
                
                var peca_x = offset_x + rand_x * cell_size + cell_size / 2;
                var peca_y = offset_y + rand_y * cell_size + cell_size / 2;
                
                var peca = instance_create_layer(peca_x, peca_y, "Instances", obj_peca);
            peca.start_x = peca_x;
            peca.start_y = peca_y;
                peca.grid_x_inicial = rand_x;
                peca.grid_y_inicial = rand_y;
            
                grid[# rand_x, rand_y] = peca.id;
            total_pecas++;
                colocada = true;
            }
        }
    }
    
    // Cria obstáculos em níveis mais avançados
    if (dificuldade >= 2) {
        var num_obstaculos = 1 + floor(nivel_atual / 4); // Menos obstáculos agora
        var obstaculos_criados = 0;
        var tentativas_obstaculo = 0;
        
        while (obstaculos_criados < num_obstaculos && tentativas_obstaculo < 50) {
            tentativas_obstaculo++;
            var obs_x = irandom(grid_width - 1);
            var obs_y = irandom(grid_height - 1);
            
            // Não coloca obstáculo na origem, destino ou no caminho correto
            if ((obs_x == ponto_origem_x && obs_y == ponto_origem_y) ||
                (obs_x == ponto_destino_x && obs_y == ponto_destino_y)) {
                continue;
            }
            
            // Verifica se faz parte do caminho correto
            var eh_caminho = false;
            for (var j = 0; j < ds_list_size(caminho_correto); j += 2) {
                var cam_x = ds_list_find_value(caminho_correto, j);
                var cam_y = ds_list_find_value(caminho_correto, j + 1);
                if (obs_x == cam_x && obs_y == cam_y) {
                    eh_caminho = true;
                    break;
                }
            }
            
            if (eh_caminho) continue;
            
            if (grid[# obs_x, obs_y] == -1) {
                var obstaculo_x = offset_x + obs_x * cell_size + cell_size / 2;
                var obstaculo_y = offset_y + obs_y * cell_size + cell_size / 2;
                
                var obj_id = asset_get_index("oobstaculo");
                if (obj_id != -1) {
                    var obstaculo = instance_create_layer(obstaculo_x, obstaculo_y, "Instances", obj_id);
                    obstaculo.tipo_obstaculo = choose("bloco", "agua", "fogo");
                }
                
                // Marca como obstáculo no grid
                grid[# obs_x, obs_y] = -2; // -2 = obstáculo
                
                obstaculos_criados++;
            }
        }
    }
    
    // Limpa a lista temporária
    ds_list_destroy(pecas_caminho);
    
    // Conta quantas peças de cada tipo foram criadas
    var contador_tipos = [0, 0, 0, 0, 0, 0];
    with(opeca) {
        var tipo_atual = -1;
        if (object_get_name(object_index) == "opeca") tipo_atual = 0;
        else if (object_get_name(object_index) == "opeca2") tipo_atual = 1;
        else if (object_get_name(object_index) == "opeca3") tipo_atual = 2;
        else if (object_get_name(object_index) == "opeca4") tipo_atual = 3;
        else if (object_get_name(object_index) == "opeca5") tipo_atual = 4;
        else if (object_get_name(object_index) == "opeca6") tipo_atual = 5;
        
        if (tipo_atual != -1) {
            contador_tipos[tipo_atual]++;
        }
    }
    
    show_debug_message("=== ESTATÍSTICAS DO NÍVEL ===");
    show_debug_message("Total de peças criadas: " + string(total_pecas));
    show_debug_message("Peças necessárias no caminho: " + string((ds_list_size(caminho_correto) / 2) - 2));
    show_debug_message("Tipos de peças:");
    show_debug_message("  - Vertical ↕ (opeca): " + string(contador_tipos[0]));
    show_debug_message("  - Curva ↗ (opeca2): " + string(contador_tipos[1]));
    show_debug_message("  - Curva ↖ (opeca3): " + string(contador_tipos[2]));
    show_debug_message("  - Horizontal ↔ (opeca4): " + string(contador_tipos[3]));
    show_debug_message("  - Curva ↘ (opeca5): " + string(contador_tipos[4]));
    show_debug_message("  - Curva ↙ (opeca6): " + string(contador_tipos[5]));
    show_debug_message("=============================");
}

// ============================================
// SISTEMA DE EFEITOS
// ============================================

/// @function criar_efeito_agua(x, y)
/// @description Cria partículas de água fluindo
function criar_efeito_agua(x, y) {
    // Verifica se o objeto oparticula existe
    var obj_id = asset_get_index("oparticula");
    if (obj_id == -1) {
        show_debug_message("Erro: objeto oparticula não encontrado!");
        return;
    }
    
    for (var i = 0; i < 5; i++) {
        var particula = instance_create_layer(x, y, "Instances", obj_id);
        particula.efeito = "agua";
        particula.vel_x = random_range(-2, 2);
        particula.vel_y = random_range(-2, 2);
        particula.gravidade = 0.1;
        particula.vida = 30;
        particula.vida_max = 30;
    }
}

/// @function criar_efeito_sucesso(x, y)
/// @description Cria efeito visual de sucesso
function criar_efeito_sucesso(x, y) {
    // Verifica se o objeto oparticula existe
    var obj_id = asset_get_index("oparticula");
    if (obj_id == -1) {
        show_debug_message("Erro: objeto oparticula não encontrado!");
        return;
    }
    
    for (var i = 0; i < 10; i++) {
        var particula = instance_create_layer(x, y, "Instances", obj_id);
        particula.efeito = "sucesso";
        particula.vel_x = random_range(-5, 5);
        particula.vel_y = random_range(-5, 5);
        particula.gravidade = 0.2;
        particula.vida = 60;
        particula.vida_max = 60;
        particula.scale_inicial = random_range(0.5, 1.5);
    }
}

/// @function criar_efeito_erro(x, y)
/// @description Cria efeito visual de erro
function criar_efeito_erro(x, y) {
    // Verifica se o objeto oparticula existe
    var obj_id = asset_get_index("oparticula");
    if (obj_id == -1) {
        show_debug_message("Erro: objeto oparticula não encontrado!");
        return;
    }
    
    for (var i = 0; i < 8; i++) {
        var particula = instance_create_layer(x, y, "Instances", obj_id);
        particula.efeito = "erro";
        particula.vel_x = random_range(-3, 3);
        particula.vel_y = random_range(-3, 3);
        particula.gravidade = 0.1;
        particula.vida = 40;
        particula.vida_max = 40;
    }
}

// ============================================
// INICIALIZAÇÃO DO JOGO
// ============================================

// Cria as peças do nível inicial
criar_pecas_do_nivel();

// Valida o caminho inicial (vai retornar false pois as peças estão em posições aleatórias)
verificar_caminho();

