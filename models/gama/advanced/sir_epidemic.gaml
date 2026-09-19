/**
* Nome: Epidemia SIR (com experimento em lote)
* Nível: avançado
* Conceitos: máquina de estados, contágio por proximidade, ordem dos reflexos,
*            indicadores agregados, experimento batch, exploração de parâmetros, exportação CSV
*
* DESCRIÇÃO GERAL
* ---------------
* SIR é o modelo epidemiológico de referência. Cada indivíduo está em um de três estados:
*   S (Susceptível)  - pode ser contaminado;
*   I (Infectado)    - transmite a doença a quem estiver por perto;
*   R (Recuperado)   - já teve a doença e ficou imune.
* As transições são de mão única: S -> I -> R. Aqui o contágio não é uma equação global,
* e sim o resultado de encontros espaciais: agentes caminham pela grade e, a cada ciclo,
* cada contato entre um susceptível e um infectado é uma chance independente de transmissão.
* A curva de infectados resultante sobe, atinge um pico e cai — mesmo sem que ninguém
* tenha programado esse formato, que emerge do encontro entre contágio e imunização.
*
* O QUE ESTE MODELO ENSINA DE NOVO
*   1. MÁQUINA DE ESTADOS - o comportamento do agente depende do estado em que ele está,
*      controlado pelo facet 'when:' dos reflexos.
*   2. ORDEM DOS REFLEXOS IMPORTA - dentro de um ciclo, os reflexos de um agente rodam na
*      ordem em que foram escritos. Aqui a recuperação vem antes do contágio de propósito:
*      assim quem acabou de ser infectado só terá a primeira chance de se curar no ciclo
*      seguinte, e não no mesmo em que adoeceu.
*   3. EXPERIMENTO EM LOTE - o mesmo modelo é usado por dois experimentos diferentes: um
*      'gui', para observar uma execução, e um 'batch', que roda centenas de simulações sem
*      interface, varrendo combinações de parâmetros e gravando os resultados em CSV.
*      É a ponte entre construir um modelo e usá-lo para produzir dados.
*
* NOTA SOBRE O NOME DA ESPÉCIE
* A espécie se chama 'person', e não 'host', porque 'host' é um atributo embutido de todo
* agente do GAMA (o agente que o contém na hierarquia). Usar um nome reservado como nome de
* espécie gera conflitos difíceis de diagnosticar. O modelo oficial contorna isso escrevendo
* 'Host' com maiúscula; aqui preferimos um nome sem ambiguidade.
*
* Referência: modelo "Susceptible Infected Recovered (SIR)" da biblioteca oficial do GAMA
* (Toy Models/Epidemiology) e a documentação de Batch Experiments.
*/

model SIREpidemic

// =====================================================================================
// BLOCO GLOBAL
// -------------------------------------------------------------------------------------
// Parâmetros epidemiológicos e os indicadores agregados que descrevem a epidemia inteira.
// Esses indicadores existem porque, em um experimento em lote, ninguém vai olhar a tela:
// o que sobra de cada simulação é o punhado de números gravados no CSV.
// =====================================================================================
global {

    // --- população inicial ---
    int nb_susceptible <- 495;                // indivíduos saudáveis no início
    int nb_infected_init <- 5;                // focos iniciais da doença

    // --- parâmetros da doença ---
    float infection_rate <- 0.05;             // probabilidade de transmissão por contato, por ciclo
    float infection_distance <- 2.0;          // raio, em unidades do mundo, que caracteriza um contato

    // --- mecanismo de recuperação ---
    // O modelo oferece as duas formas clássicas de tirar alguém do estado infectado.
    // Elas podem ter a MESMA duração média e ainda assim produzir epidemias diferentes,
    // porque o que muda é a variação em torno dessa média:
    //
    //   fixed_duration = true  -> DURAÇÃO DEFINIDA. O agente adoece, conta os ciclos e se
    //     cura ao completar o tempo de doença. É o que acontece na natureza: uma gripe dura
    //     alguns dias, não "um dia com 10% de chance de acabar". Como todo mundo seguraria
    //     exatamente o mesmo tempo, cada agente sorteia a sua duração entre 80% e 120% do
    //     valor definido — sem essa variação, todos os contaminados juntos se curariam no
    //     mesmo ciclo, criando ondas artificiais.
    //
    //   fixed_duration = false -> SORTEIO A CADA CICLO. A cada ciclo o infectado tira uma
    //     chance de se curar. A duração vira uma distribuição geométrica de média
    //     1/recovery_rate: muita gente se cura rápido, e uma minoria fica doente muito tempo.
    //     É a hipótese embutida no modelo SIR clássico de equações diferenciais — conveniente
    //     na matemática, pouco realista na biologia.
    bool fixed_duration <- true;              // qual dos dois mecanismos usar
    int infection_duration <- 100;            // ciclos de doença, quando a duração é definida
    float recovery_rate <- 0.01;              // probabilidade de cura por ciclo, quando é sorteio

    geometry shape <- square(50);             // mundo de 50x50, do mesmo tamanho da grade

    // Arquivo de saída do experimento em lote. Caminhos relativos são resolvidos a partir
    // da pasta do próprio modelo, então o CSV aparece em models/gama/advanced/results/.
    string results_file <- "results/sir_batch_results.csv";

    // --- indicadores calculados a cada leitura ---
    int current_S -> {person count each.is_susceptible};
    int current_I -> {person count each.is_infected};
    int current_R -> {person count each.is_immune};

    // --- indicadores acumulados ao longo da simulação ---
    int peak_infected <- 0;                   // maior número de infectados simultâneos (altura do pico)
    int peak_cycle <- 0;                      // ciclo em que o pico ocorreu (quando a epidemia foi mais grave)

    init {
        // Duas chamadas a 'create' porque os dois grupos nascem em estados diferentes.
        // O bloco entre chaves roda logo após a criação de cada agente e sobrescreve os
        // valores padrão declarados na espécie.
        create person number: nb_susceptible;                // maioria saudável, usa os valores padrão
        create person number: nb_infected_init {             // os focos iniciais
            do become_infected;                              // mesma transição usada no contágio
        }
    }

    // Registra o pico da epidemia. É o principal indicador de gravidade, e só pode ser
    // obtido acompanhando a simulação ciclo a ciclo — não dá para calculá-lo no final.
    reflex track_peak {
        if (current_I > peak_infected) {      // se o número de infectados superou o recorde...
            peak_infected <- current_I;       // ...guarda o novo recorde
            peak_cycle <- cycle;              // e o instante em que ele aconteceu
        }
    }
}

// =====================================================================================
// GRID: O ESPAÇO DE CIRCULAÇÃO
// -------------------------------------------------------------------------------------
// A grade aqui não tem conteúdo próprio: serve apenas para discretizar o espaço e dar aos
// agentes um conjunto simples de destinos possíveis. Os facets 'use_individual_shapes' e
// 'use_regular_agents' em false são otimizações: como as células não têm comportamento, o
// GAMA pode representá-las de forma muito mais leve. Em troca, a grade deixa de ser uma
// população de agentes comuns — por isso é preciso convertê-la com 'as list' antes de
// sortear uma célula.
// =====================================================================================
grid sir_grid width: 50 height: 50 neighbors: 8 use_individual_shapes: false use_regular_agents: false {
    list<sir_grid> neighbours <- self neighbors_at 1;   // as 8 células vizinhas
}

// =====================================================================================
// ESPÉCIE: OS INDIVÍDUOS
// -------------------------------------------------------------------------------------
// Cada agente é descrito por três booleanos mutuamente exclusivos — apenas um deles é
// verdadeiro a cada instante. Essa é a forma mais direta de representar uma máquina de
// estados em GAML e a que a biblioteca oficial adota no modelo SIR.
// =====================================================================================
species person {

    bool is_susceptible <- true;              // estado inicial padrão: saudável e vulnerável
    bool is_infected <- false;                // doente e transmitindo
    bool is_immune <- false;                  // curado e fora da cadeia de transmissão

    int infected_since <- -1;                 // ciclo em que adoeceu (-1 = nunca adoeceu)
    int my_duration <- 0;                     // duração sorteada desta infecção, em ciclos

    sir_grid my_cell <- one_of(sir_grid as list);   // célula ocupada no momento

    init {
        location <- my_cell.location;         // posiciona o agente no centro da célula sorteada
    }

    // Deslocamento: passo curto e aleatório para uma célula vizinha. É o que gera os
    // encontros e, portanto, o contágio.
    reflex move {
        my_cell <- one_of(my_cell.neighbours);
        location <- my_cell.location;
    }

    // Transição S -> I. Isolada em uma ação porque acontece em dois lugares: no contágio
    // durante a simulação e na criação dos focos iniciais, no 'init' do bloco global.
    action become_infected {
        is_susceptible <- false;              // deixa de ser vulnerável
        is_infected <- true;                  // e passa a transmitir
        infected_since <- cycle;              // marca o ciclo em que adoeceu
        // Sorteia a duração desta infecção entre 80% e 120% do valor definido.
        my_duration <- rnd(int(infection_duration * 0.8), int(infection_duration * 1.2));
    }

    // Transição I -> R.
    action become_immune {
        is_infected <- false;                 // deixa de transmitir
        is_immune <- true;                    // e passa a ser imune
    }

    // Recuperação (I -> R). Declarada ANTES do contágio de propósito: ver a nota 2 do
    // cabeçalho. Qual dos dois critérios vale é decidido pelo parâmetro 'fixed_duration'.
    reflex recover when: is_infected {
        if fixed_duration {
            // Duração definida: cura quando o tempo de doença se completa.
            if ((cycle - infected_since) >= my_duration) {
                do become_immune;
            }
        } else {
            // Sorteio: a cada ciclo há uma chance de se curar.
            if flip(recovery_rate) {
                do become_immune;
            }
        }
    }

    // Contágio (S -> I). Só roda para quem ainda é susceptível.
    reflex expose_to_infection when: is_susceptible {
        // 'at_distance' devolve os agentes da espécie que estão dentro do raio informado.
        list<person> nearby <- person at_distance infection_distance;

        // Cada infectado por perto representa um contato, e cada contato é um sorteio
        // independente. Modelar contato a contato, em vez de usar uma probabilidade única,
        // é o que faz o risco crescer naturalmente em aglomerações.
        loop contact over: (nearby where each.is_infected) {
            if flip(infection_rate) {         // este contato específico transmitiu a doença?
                do become_infected;
                break;                        // já foi contaminado: não faz sentido testar os demais contatos
            }
        }
    }

    // A cor é decidida na hora de desenhar, a partir do estado. Assim não existe um
    // atributo de cor para manter sincronizado com os booleanos.
    aspect base {
        draw circle(0.5) color: is_infected ? #red : (is_immune ? #blue : #green);
    }
}

// =====================================================================================
// EXPERIMENT 1 - EXECUÇÃO INTERATIVA (GUI)
// -------------------------------------------------------------------------------------
// Serve para entender o modelo: acompanhar a onda se espalhando no mapa e ver a curva
// epidêmica se formando ao lado.
//
// Lembrete de uso: os valores digitados no painel de parâmetros só valem para uma
// simulação nova. Depois de alterar um deles, clique em "Reload" (a seta circular) para
// recriar a simulação — apertar Play apenas continua a execução em andamento, com a
// população que já foi criada.
// =====================================================================================
experiment simulation type: gui {

    parameter "Susceptíveis iniciais" var: nb_susceptible min: 0 max: 2000 category: "População";
    parameter "Infectados iniciais" var: nb_infected_init min: 1 max: 100 category: "População";
    parameter "Taxa de infecção por contato" var: infection_rate min: 0.0 max: 1.0 category: "Doença";
    parameter "Distância de contágio" var: infection_distance min: 1.0 max: 10.0 category: "Doença";
    parameter "Duração definida da doença?" var: fixed_duration category: "Recuperação";
    parameter "Duração da doença (ciclos)" var: infection_duration min: 1 max: 300 category: "Recuperação";
    parameter "Taxa de recuperação (se por sorteio)" var: recovery_rate min: 0.0 max: 1.0 category: "Recuperação";

    output {
        layout #split;

        monitor "Susceptíveis (S)" value: current_S;
        monitor "Infectados (I)" value: current_I;
        monitor "Recuperados (R)" value: current_R;
        monitor "Pico de infectados" value: peak_infected;

        display map type: 2d antialias: false {
            species person aspect: base;
        }

        // As três curvas juntas formam o gráfico clássico do modelo SIR: S caindo,
        // I subindo até o pico e caindo, R crescendo até estabilizar.
        display curves type: 2d {
            chart "Curva epidêmica" type: series {
                data "Susceptíveis" value: current_S color: #green;
                data "Infectados" value: current_I color: #red;
                data "Recuperados" value: current_R color: #blue;
            }
        }
    }
}

// =====================================================================================
// EXPERIMENT 2 - EXPLORAÇÃO EM LOTE (BATCH)
// -------------------------------------------------------------------------------------
// Aqui o modelo deixa de ser uma animação e vira um instrumento de medida. Nenhuma janela
// é aberta: o GAMA roda a simulação inteira repetidas vezes, variando os parâmetros, e
// grava apenas os indicadores finais.
//
// Como ler o cabeçalho do experimento:
//   type: batch    - sem interface, execução encadeada;
//   repeat: 5      - cada combinação de parâmetros é repetida 5 vezes. Como o modelo é
//                    estocástico, uma única execução não diz nada: é preciso a média;
//   keep_seed:true - usa a mesma sequência de sementes aleatórias em cada combinação, para
//                    que as diferenças observadas venham dos parâmetros e não do acaso;
//   until:         - condição de parada de CADA simulação. É o equivalente, no modo lote,
//                    do 'do pause' que se usa em um experimento interativo.
//
// Para rodar sem abrir a interface gráfica, use o modo headless descrito no guia:
//   gama-headless -batch explore models/gama/advanced/sir_epidemic.gaml
// =====================================================================================
experiment explore type: batch repeat: 5 keep_seed: true until: (current_I = 0) or (cycle >= 500) {

    // Os valores explorados são listados explicitamente com 'among:'. Seriam 5 valores por
    // parâmetro, 25 combinações, 125 simulações.
    //
    // POR QUE NÃO USAR 'min/max/step' AQUI
    // A forma 'min: 0.01 max: 0.09 step: 0.02' parece equivalente, mas produz 4 valores em
    // vez de 5 — e a corrida termina com 80 simulações em vez de 125. O motivo é o acúmulo
    // de erro do ponto flutuante: somando 0.02 quatro vezes a partir de 0.01 o resultado
    // interno é 0.09000000000000002, maior que o teto declarado, e o último valor fica de
    // fora. 'among:' elimina a ambiguidade — os valores são exatamente os que estão escritos.
    // As duas dimensões varridas são os dois fatores que compõem o potencial de transmissão:
    // o quanto a doença pega por contato e por quanto tempo o infectado segue transmitindo.
    // É essa combinação — e não cada uma isoladamente — que decide se a epidemia atinge
    // todo mundo, parte da população ou se apaga logo no começo.
    parameter "Taxa de infecção" var: infection_rate among: [0.01, 0.03, 0.05, 0.07, 0.09];
    parameter "Duração da doença (ciclos)" var: infection_duration among: [10, 20, 40, 70, 100];

    // 'exploration' percorre todas as combinações possíveis (plano fatorial completo).
    // Existem métodos alternativos para outros objetivos: 'sobol' e 'morris' para análise
    // de sensibilidade, 'genetic' e 'tabu' para otimizar um indicador.
    method exploration;

    // -------------------------------------------------------------------------------------
    // EXPORTAÇÃO DOS RESULTADOS
    // -------------------------------------------------------------------------------------
    // Executado ao fim de cada rodada de simulações. 'simulations' é a lista das simulações
    // que acabaram de rodar; 'ask' entra no contexto de cada uma para ler seus indicadores.
    //
    // Cada simulação vira UMA LINHA do arquivo, no formato "tidy": uma observação por linha,
    // uma variável por coluna, primeiro o que identifica a corrida, depois os parâmetros
    // testados, por último os resultados. É o formato que o Excel, o R e o pandas leem sem
    // tratamento nenhum, e que permite montar uma tabela dinâmica direto.
    //
    // O cabeçalho é escrito à mão, como uma linha de textos, antes da primeira linha de
    // dados. O facet 'header: true' do 'save' não serve aqui: ele só funciona quando se
    // salvam agentes, de onde o GAMA tira os nomes dos atributos. Salvando uma lista de
    // valores avulsos não há nome nenhum para ele usar, e o resultado é um arquivo sem
    // cabeçalho ou com rótulos genéricos.
    reflex save_results {
        ask simulations {

            // Linha de cabeçalho, escrita uma única vez: 'rewrite: true' recria o arquivo na
            // primeira simulação da varredura (índice 0), descartando o resultado da corrida
            // anterior. As linhas de dados seguem com 'rewrite: false', acrescentando ao fim.
            if (int(self) = 0) {
                save [
                    "sim_id", "infection_rate", "infection_duration", "transmission_index",
                    "duration_cycles", "ended_naturally", "peak_infected", "peak_cycle",
                    "final_immune", "total_infected", "attack_rate_pct"
                ] to: results_file format: "csv" rewrite: true header: false;
            }

            save [
                // --- identificação ---
                int(self),                                      // sim_id: número da simulação dentro da varredura

                // --- parâmetros testados ---
                // 'with_precision' arredonda antes de gravar. Sem isso o CSV sai com valores
                // como 0.030000000000000002, que atrapalham o agrupamento na planilha.
                infection_rate with_precision 3,                // infection_rate
                infection_duration,                             // infection_duration: ciclos transmitindo
                // Potencial de transmissão de um infectado ao longo de toda a doença.
                // É o produto que governa o desfecho: dobrar a duração tem o mesmo efeito
                // que dobrar a taxa de infecção.
                (infection_rate * infection_duration) with_precision 2,  // transmission_index

                // --- como a corrida terminou ---
                cycle,                                          // duration_cycles: quantos ciclos durou
                // Distingue a epidemia que acabou sozinha daquela interrompida pelo teto de
                // 500 ciclos do 'until'. Sem esta coluna, uma corrida truncada se confunde
                // com uma epidemia curta, e a média de duração fica sem sentido.
                (current_I = 0),                                // ended_naturally: true = acabou sozinha

                // --- resultados ---
                peak_infected,                                  // peak_infected: gravidade (pico simultâneo)
                peak_cycle,                                      // peak_cycle: rapidez (quando o pico ocorreu)
                current_R,                                      // final_immune: imunizados ao fim
                (current_R + current_I),                        // total_infected: quantos adoeceram ao todo
                // Percentual da população atingida. É o indicador que permite comparar
                // corridas entre si sem depender do tamanho da população.
                (((current_R + current_I) / (nb_susceptible + nb_infected_init)) * 100) with_precision 1
            ] to: results_file format: "csv" rewrite: false header: false;
        }
    }

    // -------------------------------------------------------------------------------------
    // ACOMPANHAMENTO DA VARREDURA
    // -------------------------------------------------------------------------------------
    // Um bloco 'permanent' define uma saída que sobrevive ao fim de cada simulação e
    // acompanha o lote inteiro — ao contrário do 'output', que pertence a uma simulação só.
    // Aqui ele mostra, a cada combinação testada, a média e os extremos do pico de
    // infectados entre as 5 repetições: a distância entre o mínimo e o máximo dá, de
    // relance, a noção de quanta variação vem do acaso e não dos parâmetros.
    // Só aparece quando o experimento é lançado pela interface; no modo headless é ignorado.
    permanent {
        display Sintese type: 2d {
            chart "Pico de infectados por combinação testada" type: series {
                data "Média" value: mean(simulations collect each.peak_infected) style: spline color: #blue;
                data "Mínimo" value: min(simulations collect each.peak_infected) style: spline color: #darkgreen;
                data "Máximo" value: max(simulations collect each.peak_infected) style: spline color: #red;
            }
        }
    }
}
