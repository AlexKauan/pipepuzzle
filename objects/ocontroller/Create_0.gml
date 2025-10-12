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
cell_size = 64;

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

// Contador de peças
total_pecas = 0;

// Estado do jogo
jogo_pausado = false;
jogo_completo = false;
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

// Calcular offset para centralizar o grid
offset_x = (room_width - (grid_width * cell_size)) / 2;
offset_y = (room_height - (grid_height * cell_size)) / 2 - 50; 
// subtrai 50 para deixar espaço para a bancada embaixo

// Inicia o timer
tempo_inicio = current_time;

// Funções de IA removidas - apenas movimento manual das peças

// ============================================
// FUNÇÕES DE VALIDAÇÃO DE CAMINHO
// ============================================

/// @function verificar_caminho()
/// @description Valida se existe um caminho válido da origem ao destino usando BFS
verificar_caminho = function() {
    // Reseta o estado de água de todas as peças
    with(opeca) {
        tem_agua = false;
    }
    
    // Inicializa estruturas para BFS
    var fila = ds_list_create();
    var visitados = ds_grid_create(grid_width, grid_height);
    ds_grid_clear(visitados, 0);
    
    // Array de direções: [dx, dy]
    // Direções: 0 = cima, 1 = direita, 2 = baixo, 3 = esquerda
    var dir_x = [0, 1, 0, -1];
    var dir_y = [-1, 0, 1, 0];
    
    // Adiciona origem à fila
    ds_list_add(fila, ponto_origem_x, ponto_origem_y);
    visitados[# ponto_origem_x, ponto_origem_y] = 1;
    
    var encontrou_destino = false;
    
    // BFS simplificado
    while (ds_list_size(fila) > 0) {
        var cx = ds_list_find_value(fila, 0);
        var cy = ds_list_find_value(fila, 1);
        ds_list_delete(fila, 0);
        ds_list_delete(fila, 0);
        
        // Verifica se chegou ao destino
        if (cx == ponto_destino_x && cy == ponto_destino_y) {
            encontrou_destino = true;
            break;
        }
        
        // Marca a peça atual como tendo água (se existir)
        var peca_atual = grid[# cx, cy];
        if (peca_atual != -1 && instance_exists(peca_atual)) {
            peca_atual.tem_agua = true;
        }
        
        // Verifica todas as direções
        for (var i = 0; i < 4; i++) {
            var nx = cx + dir_x[i];
            var ny = cy + dir_y[i];
            
            // Verifica limites do grid
            if (nx < 0 || nx >= grid_width || ny < 0 || ny >= grid_height) {
                continue;
            }
            
            // Verifica se já foi visitado
            if (visitados[# nx, ny] == 1) {
                continue;
            }
            
            // Se é o destino, adiciona à fila (destino não precisa ter peça)
            if (nx == ponto_destino_x && ny == ponto_destino_y) {
                ds_list_add(fila, nx, ny);
                visitados[# nx, ny] = 1;
                continue;
            }
            
            // Se é a origem, adiciona à fila (origem não precisa ter peça)
            if (nx == ponto_origem_x && ny == ponto_origem_y) {
                ds_list_add(fila, nx, ny);
                visitados[# nx, ny] = 1;
                continue;
            }
            
            // Verifica se há peça na próxima célula
            var proxima_peca_id = grid[# nx, ny];
            if (proxima_peca_id == -1 || !instance_exists(proxima_peca_id)) {
                continue;
            }
            
            var proxima_peca = proxima_peca_id;
            var conexoes_proxima = proxima_peca.conexoes;
            
            // Verifica se a próxima peça tem conexão de volta (direção oposta)
            var dir_entrada = (i + 2) mod 4; // direção oposta
            var proxima_tem_conexao = false;
            for (var k = 0; k < array_length(conexoes_proxima); k++) {
                if (conexoes_proxima[k] == dir_entrada) {
                    proxima_tem_conexao = true;
                    break;
                }
            }
            
            // Se a peça atual tem conexão nesta direção E a próxima tem conexão de volta
            var peca_atual_id = grid[# cx, cy];
            var peca_atual_tem_conexao = false;
            
            if (peca_atual_id != -1 && instance_exists(peca_atual_id)) {
                var peca_atual_obj = peca_atual_id;
                var conexoes_atual = peca_atual_obj.conexoes;
                for (var j = 0; j < array_length(conexoes_atual); j++) {
                    if (conexoes_atual[j] == i) {
                        peca_atual_tem_conexao = true;
                        break;
                    }
                }
            } else {
                // Se não há peça na posição atual (origem), considera que tem conexão
                peca_atual_tem_conexao = true;
            }
            
            if (proxima_tem_conexao && peca_atual_tem_conexao) {
                ds_list_add(fila, nx, ny);
                visitados[# nx, ny] = 1;
            }
        }
    }
    
    // Limpa estruturas
    ds_list_destroy(fila);
    ds_grid_destroy(visitados);
    
    // Atualiza estado
    caminho_valido = encontrou_destino;
    fluxo_ativo = encontrou_destino;
    
    // Debug
    show_debug_message("Validação do caminho: " + string(encontrou_destino ? "VÁLIDO" : "INVÁLIDO"));
    
    return encontrou_destino;
}

// Valida o caminho inicial
verificar_caminho();

// ============================================
// FUNÇÃO DE CRIAÇÃO DE PEÇAS
// ============================================

/// @function criar_pecas_do_nivel()
/// @description Cria peças aleatórias no grid para o jogador organizar
function criar_pecas_do_nivel() {
    // Limpa o grid primeiro
    ds_grid_clear(grid, -1);
    total_pecas = 0;
    
    // Tipos de peças disponíveis baseado na dificuldade
    var tipos_disponiveis = [opeca, opeca2, opeca3, opeca4];
    
    // Adiciona peças mais complexas em níveis mais altos
    if (dificuldade >= 2) {
        array_push(tipos_disponiveis, opeca5); // Cruz
    }
    if (dificuldade >= 3) {
        array_push(tipos_disponiveis, opeca6); // T
    }
    
    // Define quantas peças criar baseado no tamanho do grid
    var num_pecas = floor((grid_width * grid_height) * 0.4); // 40% do grid
    
    // Cria as peças em posições aleatórias
    var pecas_criadas = 0;
    var tentativas = 0;
    
    while (pecas_criadas < num_pecas && tentativas < 1000) {
        tentativas++;
        
        var gx = irandom(grid_width - 1);
        var gy = irandom(grid_height - 1);
        
        // Não coloca peça na origem ou destino
        if ((gx == ponto_origem_x && gy == ponto_origem_y) || 
            (gx == ponto_destino_x && gy == ponto_destino_y)) {
            continue;
        }
        
        // Verifica se a célula está vazia
        if (grid[# gx, gy] == -1) {
            // Escolhe um tipo aleatório de peça
            var tipo_peca = tipos_disponiveis[irandom(array_length(tipos_disponiveis) - 1)];
            
            // Cria a peça
            var peca_x = offset_x + gx * cell_size + cell_size / 2;
            var peca_y = offset_y + gy * cell_size + cell_size / 2;
            
            var peca = instance_create_layer(peca_x, peca_y, "Instances", tipo_peca);
            
            // Define a posição inicial da peça
            peca.start_x = peca_x;
            peca.start_y = peca_y;
            peca.grid_x_inicial = gx;
            peca.grid_y_inicial = gy;
            
            // Marca a célula como ocupada
            grid[# gx, gy] = peca.id;
            total_pecas++;
            pecas_criadas++;
        }
    }
    
    // Cria obstáculos em níveis mais avançados
    if (dificuldade >= 2) {
        var num_obstaculos = 2 + floor(nivel_atual / 3); // Mais obstáculos em níveis altos
        var obstaculos_criados = 0;
        var tentativas_obstaculo = 0;
        
        while (obstaculos_criados < num_obstaculos && tentativas_obstaculo < 50) {
            tentativas_obstaculo++;
            var obs_x = irandom(grid_width - 1);
            var obs_y = irandom(grid_height - 1);
            
            // Não coloca obstáculo na origem ou destino
            if ((obs_x == ponto_origem_x && obs_y == ponto_origem_y) ||
                (obs_x == ponto_destino_x && obs_y == ponto_destino_y)) {
                continue;
            }
            
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
    
    show_debug_message("Total de peças criadas: " + string(total_pecas));
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

// Valida o caminho inicial
verificar_caminho();

