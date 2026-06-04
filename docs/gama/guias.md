# Guia GAMA Platform

## Sumário

- [Download da Ferramenta](#download-da-ferramenta)
- [Versões Disponíveis](#versões-disponíveis)
- [Guia de Uso](#guia-de-uso)
- [Configuração](#configuração)
- [Primeiros Passos](#primeiros-passos)
  - [Estrutura Básica](#estrutura-básica)
  - [Código Exemplo](#código-exemplo)
- [Documentação Oficial](#documentação-oficial)

## Download da Ferramenta

Baixe o GAMA no [site oficial](https://gama-platform.org/download).

![Página de Download](../../assets/homepagegama.png)

## Versões Disponíveis

- **GAMA Desktop**
  Versão padrão com interface gráfica avançada, baseada no Eclipse IDE. Executada localmente para modelagem, simulação e análise.

- **GAMA Headless**
  Versão via linha de comando para execução de simulações em lote ou em servidores, sem interface gráfica (foco em alto desempenho e HPC).

- **GAMA Server**
  Facilita a integração do GAMA com outros softwares ou interfaces web por meio de solicitações de rede.

## Guia de Uso

A interface principal do GAMA é dividida em diferentes perspectivas e visualizações, herdadas da estrutura do Eclipse:

- **Navigator (Model Library):** Fica na lateral esquerda. É o gerenciador de arquivos onde ficam os seus projetos (`User models`) e a vasta biblioteca de exemplos do GAMA (`Models`).

[add image]

- **Editor:** A área central onde o código na linguagem GAML (GAMA Modeling Language) é escrito. Inclui preenchimento automático, destaque de sintaxe e detecção de erros em tempo real.

[add image]

- **Interface de Simulação (Views):** Quando um modelo é executado, a perspectiva muda. Esta área exibe os monitores (Displays), inspetores de agentes, parâmetros interativos e gráficos.

[add image]

## Configuração

Diferente do NetLogo, no GAMA a configuração espacial e temporal é feita via código no bloco `global`, e a configuração da interface é feita no bloco `experiment`.

- **Topologia (Geometry):** O formato e tamanho do mundo são definidos no bloco `global` através da variável `shape`. Pode ser um quadrado, um polígono importado de um arquivo shapefile (GIS) ou geometrias complexas.
- **Torus:** Definido definindo a variável `torus` do ambiente como `true` ou `false`.
- **Passo de Tempo (Step):** A variável global `step` define o tempo que cada ciclo representa (ex: 1 segundo, 1 dia).
- **Parâmetros:** São definidos declarando variáveis no bloco global e vinculando-as à diretiva `parameter` no bloco do experimento.

## Primeiros Passos

Para entender a estrutura do GAMA, o fluxo recomendado é iniciar pelos modelos embutidos.

- **Acessar a Biblioteca:** No painel lateral esquerdo (Navigator), expanda a pasta `Models`. Os modelos estão categorizados por temas (Toy Models, Epidemiology, Urban, etc.).
- **Carregar um Modelo:** Dê um duplo clique no arquivo `.gaml` desejado para abri-lo no Editor.
- **Executar:** Acima do editor, localize e clique no botão verde com ícone de engrenagem referente ao experimento configurado no código.
- **Controle de Simulação:** A interface mudará para o modo simulação. Utilize os botões de "Play" (para rodar continuamente), "Step" (avanço manual de um ciclo) e "Pause" localizados na barra superior.

### Estrutura Básica

O código GAML é modular e estritamente estruturado em seções fundamentais.

- **Global:** É o núcleo da simulação. Define as condições iniciais (bloco `init`), variáveis globais de estado do modelo, o limite do ambiente geográfico e dinâmicas que afetam todo o sistema. Funciona como o observador e as configurações iniciais juntas.

- **Species:** Representam os agentes no GAMA. Cada espécie define atributos (variáveis), ações (métodos executáveis), reflexos (comportamentos automáticos em cada ciclo) e aspectos (como os agentes são desenhados na tela).

- **Grid:** Uma espécie especial de agentes estacionários, semelhante aos "patches" do NetLogo. Criam matrizes de células com tamanho fixo que podem ter atributos dinâmicos e interagir com agentes móveis.

- **Experiment:** Define como o modelo será visualizado e testado. É aqui que você cria botões, expõe parâmetros para o usuário na interface gráfica e define os blocos de `output` (gráficos e mapas de exibição).

### Código Exemplo

O paradigma do GAMA separa rigidamente a estrutura (variáveis), o comportamento (reflexos) e a visualização (aspectos e experimentos).

Abaixo, um modelo funcional e minimalista de caminhada aleatória (random walk):

```gaml
model RandomWalk

// 1. Bloco Global: O mundo e a inicialização
global {
    init {
        // O mundo cria 100 agentes da espécie 'walker'
        create walker number: 100;
    }
}

// 2. Bloco Species: Definição dos agentes móveis
species walker {
    rgb color <- #red; // Atributo de cor

    // Comportamento executado a cada ciclo (tick)
    reflex move {
        do wander; // Ação embutida de movimento aleatório contínuo
    }

    // Visualização do agente
    aspect default {
        draw circle(1) color: color;
    }
}

// 3. Bloco Experiment: Interface gráfica
experiment RandomWalkExp type: gui {
    output {
        display map_view {
            // Desenha a espécie usando o aspecto padrão
            species walker aspect: default;
        }
    }
}
```

## Documentação Oficial

- [GAMA Platform Documentation](https://gama-platform.org/wiki/Home)
- [GAML Reference](https://www.google.com/search?q=https://gama-platform.org/wiki/GAML-References)
