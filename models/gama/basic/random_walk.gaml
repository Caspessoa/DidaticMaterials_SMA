/**
* Nome: RandomWalk
* Nível: básico
* Autor: Cassiano
*/


model RandomWalk

// 1. Bloco Global: o mundo e a inicialização
global {
    int nb_walkers <- 100;                // parâmetro exposto no experimento

    init {
        create walker number: nb_walkers; // cria os agentes da espécie walker
    }
}

// 2. Bloco Species: definição dos agentes móveis
//    skills: [moving] concede os atributos speed/heading e a ação wander
species walker skills: [moving] {
    rgb color <- #red;                    // atributo de cor

    init {
        speed <- 1.0;                     // distância percorrida por ciclo
    }

    // Comportamento executado a cada ciclo
    reflex move {
        do wander bounds: world;          // movimento aleatório, restrito ao mundo
    }

    // Visualização do agente
    aspect default {
        draw circle(1) color: color;
    }
}

// 3. Bloco Experiment: interface gráfica
experiment RandomWalkExp type: gui {
    parameter "Número de agentes" var: nb_walkers min: 1 max: 1000;

    output {
        display map_view {
            species walker aspect: default; // desenha a espécie com o aspecto padrão
        }
    }
}
