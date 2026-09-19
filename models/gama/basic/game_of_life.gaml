/**
* Nome: Jogo da Vida (Conway)
* Nível: básico
* Conceitos: grid, vizinhança, atualização síncrona, autômato celular, mundo em toro
*
* DESCRIÇÃO GERAL
* ---------------
* O Jogo da Vida é o autômato celular mais conhecido. O mundo é uma grade em que cada
* célula está viva ou morta, e o estado da geração seguinte depende apenas da quantidade
* de vizinhos vivos, por duas regras:
*   1. célula VIVA continua viva se tiver 2 ou 3 vizinhos vivos; caso contrário, morre;
*   2. célula MORTA nasce se tiver exatamente 3 vizinhos vivos.
*
* Este é o complemento natural do modelo de caminhada aleatória (random walk): lá os
* agentes eram móveis (species + skill moving); aqui os agentes são estacionários e
* formam o próprio ambiente (grid), que é o equivalente aos "patches" do NetLogo.
*
* PONTO CENTRAL DO MODELO: ATUALIZAÇÃO SÍNCRONA
* As regras precisam ser aplicadas simultaneamente a todas as células. Se cada célula
* já mudasse seu estado ao ser avaliada, as células avaliadas depois leriam vizinhos
* que já pertencem à geração seguinte, e o resultado seria outro modelo. Por isso o
* ciclo é dividido em duas fases:
*   Fase 1 - o mundo pede a TODAS as células que CALCULEM o próximo estado (sem aplicar);
*   Fase 2 - cada célula APLICA o estado calculado.
* Isso funciona porque, em um ciclo do GAMA, os reflexos do bloco global são executados
* antes dos reflexos das espécies.
*
* Referência: modelo "Life Using Grid Agents" da biblioteca oficial do GAMA. Você pode
* pesquisar dentro do gama por "life", que o modelo vem instalado, mas este aqui é mais
* simplificado.
*/

model GameOfLife

// =====================================================================================
// BLOCO GLOBAL
// -------------------------------------------------------------------------------------
// Define o mundo, os parâmetros da simulação e a Fase 1 do ciclo (o cálculo).
// O facet 'torus: true' faz as bordas se conectarem: a coluna da direita é vizinha da
// coluna da esquerda e a linha de cima é vizinha da de baixo. Sem isso, as células das
// bordas teriam menos vizinhos e os padrões se deformariam ao encostar na borda.
// =====================================================================================
global torus: true {

    int grid_size <- 100 min: 10 max: 300;        // número de linhas e de colunas da grade
    int initial_density <- 25 min: 1 max: 99;     // % de células que começam vivas
    list<int> survival_conditions <- [2, 3];      // nº de vizinhos vivos que mantém uma célula viva
    list<int> birth_conditions <- [3];            // nº de vizinhos vivos que faz nascer uma célula

    geometry shape <- square(grid_size);          // mundo quadrado; com a grade de mesmo tamanho, cada célula mede 1x1

    // FASE 1 do ciclo: pedir a todas as células que calculem o próximo estado.
    // 'ask' envia uma ordem a um conjunto de agentes; aqui, a toda a população da grade.
    reflex compute_generation {
        ask life_cell {                           // para cada célula da grade...
            do compute_next_state();              // ...executa a ação que decide o estado seguinte
        }
    }
}

// =====================================================================================
// GRID: AS CÉLULAS
// -------------------------------------------------------------------------------------
// 'grid' é uma espécie especial de agentes estacionários dispostos em matriz. Os facets
// 'width' e 'height' definem as dimensões, e 'neighbors: 8' define a vizinhança de Moore
// (as 8 células ao redor, incluindo as diagonais). Com 'neighbors: 4' teríamos a
// vizinhança de Von Neumann, apenas as 4 ortogonais.
// Cada célula guarda o estado atual ('alive') e o estado calculado para a geração
// seguinte ('next_state'), que é o que permite a atualização síncrona.
// =====================================================================================
grid life_cell width: grid_size height: grid_size neighbors: 8 {

    bool alive <- rnd(100) < initial_density;     // estado atual: sorteia se a célula nasce viva
    bool next_state;                              // estado da próxima geração (false por padrão)
    list<life_cell> neighbours <- self neighbors_at 1; // lista das 8 células vizinhas, calculada uma única vez
    rgb color <- alive ? #white : #black;         // cor exibida na tela: viva = branca, morta = preta

    // Ação chamada pelo bloco global na Fase 1. Ela apenas CALCULA e guarda o resultado
    // em 'next_state' — nada é aplicado aqui, e é isso que garante a simultaneidade.
    action compute_next_state {
        int nb_alive <- neighbours count each.alive;  // conta quantos vizinhos estão vivos ('each' = cada vizinho)
        if alive {                                    // se a célula está viva agora...
            next_state <- nb_alive in survival_conditions;  // ...sobrevive se o total estiver na lista de sobrevivência
        } else {                                      // se está morta...
            next_state <- nb_alive in birth_conditions;     // ...nasce se o total estiver na lista de nascimento
        }
    }

    // FASE 2 do ciclo: aplicar o estado calculado. Como é um 'reflex' da espécie, só roda
    // depois que o reflexo do bloco global terminou de percorrer todas as células.
    reflex apply_next_state {
        alive <- next_state;                      // o estado calculado vira o estado atual
        color <- alive ? #white : #black;         // atualiza a cor de acordo com o novo estado
    }
}

// =====================================================================================
// EXPERIMENT
// -------------------------------------------------------------------------------------
// Define a interface gráfica: quais variáveis o usuário pode alterar antes de rodar
// ('parameter') e o que é exibido durante a execução ('output').
// O facet 'category' apenas agrupa os parâmetros em seções na tela.
// =====================================================================================
experiment life type: gui {

    parameter "Tamanho da grade" var: grid_size category: "Mundo";
    parameter "Densidade inicial de células vivas (%)" var: initial_density category: "Mundo";
    parameter "Vizinhos vivos para sobreviver" var: survival_conditions category: "Regras";
    parameter "Vizinhos vivos para nascer" var: birth_conditions category: "Regras";

    output {
        // Exibição do tabuleiro. 'antialias: false' mantém as células com bordas nítidas.
        display board type: 2d antialias: false {
            grid life_cell;                       // desenha a grade usando o atributo 'color' de cada célula
        }

        // Gráfico de série temporal com o total de células vivas a cada ciclo.
        display population type: 2d {
            chart "Células vivas" type: series {
                data "vivas" value: life_cell count each.alive color: #blue;
            }
        }
    }
}
