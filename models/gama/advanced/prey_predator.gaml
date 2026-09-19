/**
* Nome: Presa-Predador
* Nível: avançado
* Conceitos: múltiplas espécies, herança (parent), polimorfismo, grid como recurso,
*            energia, reprodução, morte, movimento dirigido, monitores, gráficos,
*            condição de parada
*
* DESCRIÇÃO GERAL
* ---------------
* Modelo clássico de cadeia alimentar com três camadas:
*   - a VEGETAÇÃO é uma grade cujas células acumulam alimento a cada ciclo;
*   - as PRESAS percorrem a grade, comem a vegetação da célula em que estão e ganham energia;
*   - os PREDADORES caçam pela grade e comem as presas que encontram.
* Todos os agentes gastam energia a cada ciclo, morrem quando ela chega a zero e se
* reproduzem quando ela passa de um limiar, dividindo a própria energia com os filhotes.
* O resultado esperado é a oscilação acoplada das duas populações: quando há muitas presas,
* os predadores prosperam; quando os predadores ficam numerosos demais, as presas somem e
* os predadores morrem de fome, permitindo que as presas se recuperem.
*
* O QUE ESTE MODELO ENSINA DE NOVO
* Em relação aos modelos básicos, três mecanismos aparecem pela primeira vez:
*   1. HERANÇA E POLIMORFISMO - presa e predador compartilham quase todo o comportamento
*      (mover, comer, morrer, reproduzir). Esse comportamento comum fica em uma espécie-mãe
*      ('generic_species'), e as ações 'energy_from_eat' e 'choose_cell' são declaradas
*      vazias nela e sobrescritas por cada filha. É a mesma chamada produzindo
*      comportamentos diferentes conforme a espécie de quem executa.
*   2. INTERAÇÃO ENTRE AGENTES - o predador localiza presas e ordena que uma delas morra
*      ('ask ... { do die; }').
*   3. CICLO DE VIDA - agentes nascem e morrem durante a simulação, e não apenas no init.
*
* POR QUE O MOVIMENTO DIRIGIDO É ESSENCIAL (e não um detalhe de refinamento)
* Se presas e predadores caminhassem ao acaso, o modelo não funcionaria: o predador tem
* energia para cerca de 25 ciclos sem comer, e com 200 presas espalhadas por 2500 células a
* chance de cair por acaso em uma célula ocupada é de apenas ~8% por ciclo. O resultado é a
* extinção sistemática dos predadores nos primeiros ciclos, antes que qualquer dinâmica
* apareça. Por isso cada espécie tem uma regra de escolha de destino ('choose_cell'):
* a presa vai à célula com mais alimento, o predador vai a uma célula que contenha presas.
* É o que torna a busca eficiente o bastante para as duas populações coexistirem.
*
* Referência: tutorial oficial "Predator Prey" do GAMA, arquivo
* gama.library/tutorials/Predator Prey/models/Model 09.gaml
*/

model PreyPredator

// =====================================================================================
// BLOCO GLOBAL
// -------------------------------------------------------------------------------------
// Concentra todos os parâmetros do modelo. Deixá-los aqui, e não espalhados dentro das
// espécies, é o que permite expô-los na interface e variá-los em experimentos.
// Os nomes seguem o padrão <espécie>_<grandeza> para tornar óbvio a quem cada valor se aplica.
// =====================================================================================
global {

    // --- tamanho inicial das populações ---
    int nb_preys_init <- 200;                 // quantidade de presas criadas no início
    int nb_predators_init <- 20;              // quantidade de predadores criados no início

    // --- energia das presas ---
    float prey_max_energy <- 1.0;             // teto de energia que uma presa acumula
    float prey_max_transfer <- 0.1;           // quanto de alimento a presa retira da célula por ciclo
    float prey_energy_consum <- 0.05;         // energia gasta pela presa a cada ciclo

    // --- energia dos predadores ---
    float predator_max_energy <- 1.0;         // teto de energia de um predador
    float predator_energy_transfer <- 0.5;    // energia ganha ao devorar uma presa
    float predator_energy_consum <- 0.02;     // energia gasta pelo predador a cada ciclo

    // --- reprodução ---
    float prey_proba_reproduce <- 0.01;       // chance por ciclo de uma presa apta se reproduzir
    int prey_nb_max_offsprings <- 5;          // nº máximo de filhotes por ninhada de presa
    float prey_energy_reproduce <- 0.5;       // energia mínima para uma presa se reproduzir
    float predator_proba_reproduce <- 0.01;   // chance por ciclo de um predador apto se reproduzir
    int predator_nb_max_offsprings <- 3;      // nº máximo de filhotes por ninhada de predador
    float predator_energy_reproduce <- 0.5;   // energia mínima para um predador se reproduzir

    // --- variáveis calculadas ---
    // A seta '->' declara um atributo derivado: não é armazenado, é recalculado toda vez
    // que alguém o lê. 'length(prey)' devolve o tamanho atual da população de presas.
    int nb_preys -> {length(prey)};
    int nb_predators -> {length(predator)};

    init {
        create prey number: nb_preys_init;            // cria a população inicial de presas
        create predator number: nb_predators_init;    // cria a população inicial de predadores
    }

    // Encerra a simulação quando ela perde o sentido: uma das populações foi extinta.
    // 'do pause' apenas pausa a execução, mantendo a última imagem e os gráficos na tela.
    // ATENÇÃO: uma simulação pausada aqui não volta a andar no botão Play — ela já acabou.
    // Para rodar de novo com outros parâmetros é preciso RECARREGAR a simulação.
    reflex stop_simulation when: (nb_preys = 0) or (nb_predators = 0) {
        do pause;
    }
}

// =====================================================================================
// GRID: A VEGETAÇÃO
// -------------------------------------------------------------------------------------
// A grade não é cenário: cada célula é um agente com um estoque de alimento que cresce
// sozinho a cada ciclo. É o recurso disputado na base da cadeia alimentar.
// O facet 'update:' de um atributo é executado automaticamente a cada ciclo — é a forma
// mais concisa de escrever uma dinâmica contínua, sem precisar de um reflex.
// 'neighbors: 4' define a vizinhança ortogonal usada pelo GAMA como padrão da grade.
// =====================================================================================
grid vegetation_cell width: 50 height: 50 neighbors: 4 {

    float max_food <- 1.0;                                // estoque máximo de alimento da célula
    float food_prod <- rnd(0.01);                         // produtividade da célula, sorteada uma vez entre 0 e 0.01
    float food <- rnd(1.0) max: max_food update: food + food_prod;  // estoque atual: começa aleatório e cresce a cada ciclo, limitado por 'max'

    // Verde mais escuro = mais alimento. O 'update:' repete o cálculo a cada ciclo para
    // que a cor acompanhe o consumo feito pelas presas.
    rgb color <- rgb(int(255 * (1 - food)), 255, int(255 * (1 - food)))
        update: rgb(int(255 * (1 - food)), 255, int(255 * (1 - food)));

    // Campo de percepção dos agentes: todas as células a até 2 passos de distância (24
    // células ao redor). É dentro dessa janela que presa e predador escolhem o destino.
    // Com raio 1 (apenas as 4 células adjacentes) a busca fica cega demais e os predadores
    // não encontram presas o bastante para sobreviver.
    list<vegetation_cell> neighbors2 <- (self neighbors_at 2);
}

// =====================================================================================
// ESPÉCIE-MÃE: COMPORTAMENTO COMUM
// -------------------------------------------------------------------------------------
// Reúne tudo o que presa e predador fazem igual. Os atributos são declarados aqui sem
// valor definitivo; cada espécie-filha os redeclara com o seu próprio valor.
// A ordem dos reflexos dentro da espécie é a ordem de execução dentro do ciclo:
// mover -> comer -> morrer -> reproduzir.
// =====================================================================================
species generic_species {

    float size <- 1.0;                        // raio usado no desenho do agente
    rgb color;                                // cor do agente, definida por cada espécie-filha
    float max_energy;                         // teto de energia (definido pela filha)
    float max_transfer;                       // energia máxima obtida por refeição (definido pela filha)
    float energy_consum;                      // energia gasta por ciclo (definido pela filha)
    float proba_reproduce;                    // chance de reprodução por ciclo (definido pela filha)
    int nb_max_offsprings;                    // nº máximo de filhotes (definido pela filha)
    float energy_reproduce;                   // energia mínima para reproduzir (definido pela filha)

    vegetation_cell my_cell <- one_of(vegetation_cell);  // célula onde o agente está; sorteia uma no nascimento

    // Energia do agente, com três facets em uma única linha:
    //   '<- rnd(max_energy)' sorteia a energia inicial entre 0 e o teto da espécie;
    //   'update:' desconta o gasto do ciclo automaticamente, sem precisar de um reflex;
    //   'max:' impede que a energia ultrapasse o teto, mesmo após uma refeição farta.
    float energy <- rnd(max_energy) update: energy - energy_consum max: max_energy;

    // O init roda na criação de cada agente, depois que os atributos acima foram avaliados.
    init {
        location <- my_cell.location;         // posiciona o agente no centro da sua célula
    }

    // Deslocamento: o destino é decidido por 'choose_cell', que cada filha implementa à
    // sua maneira. A mãe não sabe (nem precisa saber) como a escolha é feita.
    reflex basic_move {
        my_cell <- choose_cell();             // escolhe a célula de destino
        location <- my_cell.location;         // move o agente para o centro dessa célula
    }

    // Alimentação: soma à energia o que a ação 'energy_from_eat' devolver. O que cada
    // espécie come é decidido na sobrescrita dessa ação, não aqui.
    reflex eat {
        energy <- energy + energy_from_eat();
    }

    // Morte por inanição: energia esgotada remove o agente da simulação.
    reflex die_of_starvation when: energy <= 0 {
        do die;
    }

    // Reprodução: exige energia acima do limiar E sucesso no sorteio. 'flip(p)' devolve
    // true com probabilidade p.
    reflex reproduce when: (energy >= energy_reproduce) and (flip(proba_reproduce)) {
        int nb_offsprings <- rnd(1, nb_max_offsprings);   // sorteia o tamanho da ninhada
        // 'species(self)' cria filhotes da mesma espécie do pai — é o que permite que este
        // único bloco sirva para presas e predadores.
        create species(self) number: nb_offsprings {
            my_cell <- myself.my_cell;                    // 'myself' é o pai; 'self' seria o filhote
            location <- my_cell.location;                 // filhote nasce na célula do pai
            energy <- myself.energy / nb_offsprings;      // a energia do pai é repartida entre os filhotes
        }
        energy <- energy / nb_offsprings;                 // e o pai fica com a fração restante
    }

    // Ações declaradas vazias: a espécie-mãe não come nada e não sabe para onde ir.
    // Existem apenas para que os reflexos acima possam chamá-las; cada filha as sobrescreve.
    //
    // SINTAXE: uma ação que devolve valor é declarada com o tipo de retorno antes do nome e
    // SEM parênteses — 'float energy_from_eat { ... }'. Já a CHAMADA leva parênteses:
    // 'energy_from_eat()'. Declarar com '()' é erro de compilação no GAMA 2025-06.
    float energy_from_eat {
        return 0.0;
    }

    vegetation_cell choose_cell {
        return nil;
    }

    aspect base {
        draw circle(size) color: color;       // desenha o agente como um círculo colorido
    }

    // Aspecto alternativo, útil para depurar: mostra a energia de cada agente na tela.
    aspect info {
        draw square(size) color: color;
        draw string(energy with_precision 2) size: 3 color: #black;
    }
}

// =====================================================================================
// PRESA
// -------------------------------------------------------------------------------------
// Herda todo o comportamento da espécie-mãe ('parent:') e define apenas seus próprios
// valores, onde procurar comida e como se alimentar.
// =====================================================================================
species prey parent: generic_species {

    rgb color <- #blue;
    float max_energy <- prey_max_energy;
    float max_transfer <- prey_max_transfer;
    float energy_consum <- prey_energy_consum;
    float proba_reproduce <- prey_proba_reproduce;
    int nb_max_offsprings <- prey_nb_max_offsprings;
    float energy_reproduce <- prey_energy_reproduce;

    // Come a vegetação da própria célula, sem nunca retirar mais do que existe nela.
    float energy_from_eat {
        float energy_transfer <- 0.0;                                  // energia obtida nesta refeição
        if (my_cell.food > 0) {                                        // se ainda há alimento na célula...
            energy_transfer <- min([max_transfer, my_cell.food]);      // ...leva o menor valor entre sua capacidade e o estoque
            my_cell.food <- my_cell.food - energy_transfer;            // e desconta o que comeu do estoque da célula
        }
        return energy_transfer;                                        // devolve o ganho ao reflexo 'eat' da mãe
    }

    // Vai para a célula mais farta que enxerga. 'with_max_of' devolve o elemento da lista
    // que maximiza a expressão — aqui, a célula de maior estoque de alimento.
    vegetation_cell choose_cell {
        return (my_cell.neighbors2) with_max_of (each.food);
    }
}

// =====================================================================================
// PREDADOR
// -------------------------------------------------------------------------------------
// Mesma estrutura da presa, mas o alimento são as próprias presas: é aqui que ocorre a
// interação direta entre agentes.
// =====================================================================================
species predator parent: generic_species {

    rgb color <- #red;
    float max_energy <- predator_max_energy;
    float max_transfer <- predator_energy_transfer;
    float energy_consum <- predator_energy_consum;
    float proba_reproduce <- predator_proba_reproduce;
    int nb_max_offsprings <- predator_nb_max_offsprings;
    float energy_reproduce <- predator_energy_reproduce;

    // Caça: procura presas dentro da própria célula e devora uma delas.
    float energy_from_eat {
        list<prey> reachable_preys <- prey inside (my_cell);  // 'inside' filtra os agentes contidos em uma geometria
        if (! empty(reachable_preys)) {                       // se encontrou alguma presa...
            ask one_of(reachable_preys) {                     // ...escolhe uma ao acaso e dá a ordem
                do die;                                     // a presa é removida da simulação
            }
            return max_transfer;                              // e o predador ganha a energia da refeição
        }
        return 0.0;                                           // nenhuma presa por perto: nada a ganhar
    }

    // Caçada propriamente dita, e o ponto que mantém a espécie viva: em vez de andar ao
    // acaso, o predador percorre as células que enxerga e vai para a primeira que contenha
    // uma presa. 'shuffle' embaralha antes para que a busca não tenha viés de direção;
    // 'first_with' devolve o primeiro elemento que satisfaz a condição.
    vegetation_cell choose_cell {
        vegetation_cell my_cell_tmp <- shuffle(my_cell.neighbors2) first_with (!(empty(prey inside (each))));
        if my_cell_tmp != nil {                   // achou uma célula com presa?
            return my_cell_tmp;                   // vai direto para ela
        } else {
            return one_of(my_cell.neighbors2);    // nenhuma presa à vista: move-se ao acaso
        }
    }
}

// =====================================================================================
// EXPERIMENT
// -------------------------------------------------------------------------------------
// Expõe os parâmetros que valem a pena manipular e monta a saída visual: o mapa com os
// três tipos de agente sobrepostos, dois monitores numéricos e o gráfico que revela o
// comportamento característico do modelo (as oscilações defasadas das duas populações).
//
// COMO ALTERAR OS PARÂMETROS NA INTERFACE
// Os valores digitados no painel de parâmetros só são lidos quando a simulação é
// INICIALIZADA. Digitar um novo número e apertar Play não muda nada, porque as populações
// já foram criadas no 'init'. Depois de alterar um parâmetro é preciso clicar em
// "Reload" (o botão de seta circular, ao lado do Play) para recriar a simulação com os
// novos valores. Isso vale em dobro aqui, porque o reflexo 'stop_simulation' pausa a
// simulação ao fim da corrida: retomar no Play não reinicia nada.
// =====================================================================================
experiment prey_predator type: gui {

    parameter "Presas iniciais" var: nb_preys_init min: 0 max: 1000 category: "Presa";
    parameter "Energia máxima da presa" var: prey_max_energy category: "Presa";
    parameter "Energia por refeição (presa)" var: prey_max_transfer category: "Presa";
    parameter "Consumo de energia por ciclo (presa)" var: prey_energy_consum category: "Presa";
    parameter "Predadores iniciais" var: nb_predators_init min: 0 max: 200 category: "Predador";
    parameter "Energia máxima do predador" var: predator_max_energy category: "Predador";
    parameter "Energia por refeição (predador)" var: predator_energy_transfer category: "Predador";
    parameter "Consumo de energia por ciclo (predador)" var: predator_energy_consum category: "Predador";

    output {
        layout #split;                                     // divide a janela igualmente entre as visualizações

        monitor "Presas" value: nb_preys;                  // valor numérico atualizado a cada ciclo
        monitor "Predadores" value: nb_predators;

        // A ordem das camadas importa: a grade é desenhada primeiro, os agentes por cima.
        display main_display type: 2d antialias: false {
            grid vegetation_cell border: #black;           // a vegetação, com as bordas das células visíveis
            species prey aspect: base;                     // as presas (azuis)
            species predator aspect: base;                 // os predadores (vermelhos)
        }

        display populations type: 2d {
            chart "Evolução das populações" type: series {
                data "presas" value: nb_preys color: #blue;
                data "predadores" value: nb_predators color: #red;
            }
        }
    }
}
