# Guia NetLogo

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

Baixe o NetLogo no [site oficial](https://ccl.northwestern.edu/netlogo/download.shtml).

![Página de Download](../../assets/homepagenetlogo.png)

## Versões Disponíveis

- **NetLogo Desktop**
  Versão padrão em formato de software, executada localmente.

- **[NetLogo Web](https://www.netlogoweb.org/launch)**
  Versão web do NetLogo padrão, executada diretamente do navegador.

- **[Turtle Universe](https://www.turtlesim.com/products/turtle-universe/)**
  Versão mobile. Permite aprender fenômenos sociais e científicos através de representações interativas e micro mundos.

- **[NetTango](https://ccl.northwestern.edu/nettangoweb/)**
  Interface baseada em blocos para o NetLogo Web. Focada na criação de modelos educacionais com blocos de programação específicos.

- **[HubNet Web](https://hubnetweb.org/)**
  Plataforma online para criar e executar simulações participativas, onde usuários atuam como agentes no modelo.

## Guia de Uso

A interface principal do NetLogo é dividida em três abas fundamentais, essenciais para a navegação e desenvolvimento dos modelos:

- Interface: É o painel de controle e visualização. Contém o ambiente simulado (View) e os widgets de controle interativos, como botões (Buttons), controles deslizantes (Sliders), interruptores (Switches) e gráficos (Plots). Abaixo da área de visualização fica o Command Center, utilizado para enviar instruções diretas aos agentes em tempo real.

[add image]

- Info: Um editor de texto rico utilizado para documentar o modelo. Segue um padrão de tópicos (O que é o modelo?, Como funciona?, Como usar?) e suporta formatação em Markdown. É a documentação interna obrigatória para descrever as regras da simulação.

[add image]

- Code: A IDE (Integrated Development Environment) nativa do NetLogo. Onde o código-fonte da simulação é escrito. Possui recursos de destaque de sintaxe, verificação de erros e numeração de linhas.

[add image]

## Configuração

A configuração do ambiente de simulação dita as regras espaciais e temporais do modelo. Estas configurações são acessadas através do botão "Settings..." na aba Interface.

- Topologia e Dimensões (World): O ambiente é um grid de coordenadas. A janela de configurações permite definir as fronteiras máximas e mínimas nos eixos X e Y (min-pxcor, max-pxcor, min-pycor, max-pycor).

- World Wrap (Torus): Opções que definem se o mundo tem bordas rígidas ou se conecta topologicamente em um cilindro ou toro (se um agente sai pela direita, reaparece pela esquerda).

- Patch Size: Define o tamanho em pixels de cada célula (patch) na tela, afetando a resolução e o tamanho visual do ambiente sem alterar a lógica matemática.

- Velocidade de Execução (Speed Slider): Um controle deslizante na barra superior da Interface que acelera ou desacelera a renderização visual da simulação.

## Primeiros Passos

O fluxo inicial de trabalho no NetLogo geralmente envolve a exploração da Models Library (Biblioteca de Modelos) antes do desenvolvimento de código próprio.

- Acessar a Biblioteca: Vá em File > Models Library. A biblioteca contém dezenas de modelos pré-programados divididos por áreas do conhecimento (Biologia, Redes, Ciências Sociais, Matemática).

- Carregar um Modelo: Selecione um modelo (por exemplo, Biology > Wolf Sheep Predation) e clique em Open.

- Inicialização (Setup): Na aba Interface, localize o botão rotulado setup. Este botão executa o bloco de código que limpa a memória, desenha o ambiente inicial e posiciona os agentes no estado zero da simulação.

- Execução (Go): Clique no botão go. Em modelos padrão, este é um botão de iteração contínua (representado por um ícone de ciclo negro). Ele instrui o tempo a avançar, fazendo os agentes executarem suas regras de comportamento repetidamente.

### Estrutura Básica

A linguagem do NetLogo é construída sobre quatro tipos fundamentais de agentes operacionais. Compreender esta estrutura é o núcleo da programação multiagente na ferramenta.

- Observer (Observador): O controlador global. O observador não tem corpo físico no mundo, mas pode criar os outros agentes, alterar variáveis globais e controlar o fluxo do tempo.

- Turtles (Tartarugas): Agentes móveis. Eles possuem coordenadas (xcor, ycor), direção (heading), cor e podem se mover pelo espaço. Podem representar pessoas, animais, veículos ou nós em uma rede móvel.

- Patches (Células): Agentes estacionários que formam o plano de fundo. O mundo é um grid bidimensional de patches. Cada patch tem coordenadas inteiras (pxcor, pycor) e pode conter variáveis próprias (como altitude, quantidade de alimento ou poluição).

- Links (Ligações): Agentes conectores. Criam grafos e redes conectando duas turtles. Podem ser direcionados ou não-direcionados e são utilizados para simular redes sociais, rotas ou topologias de comunicação.

### Código Exemplo

O paradigma de codificação do NetLogo baseia-se em procedimentos (procedures), indicados pelas palavras-chave to e end. Um modelo exige estruturalmente um procedimento de inicialização e um procedimento de execução contínua baseada em tempo (ticks).

Abaixo, um modelo funcional e minimalista de caminhada aleatória (random walk):

```Código
;; Declaração do procedimento de inicialização
to setup
  clear-all                  ;; Limpa todo o ambiente, agentes e memória

  create-turtles 100 [       ;; O observador cria 100 agentes móveis
    setxy random-xcor random-ycor ;; Posiciona o agente em um local aleatório do mundo
    set color red            ;; Define a cor da turtle
  ]

  reset-ticks                ;; Zera o relógio interno da simulação, permitindo que os gráficos iniciem
end

;; Declaração do procedimento de execução
to go
  ask turtles [              ;; O observador ordena que todas as turtles executem os comandos internos
    right random 360         ;; Altera a direção atual aleatoriamente entre 0 e 359 graus
    forward 1                ;; Move a turtle um patch na direção atual
  ]

  tick                       ;; Avança o tempo da simulação em 1 unidade
end
```

[add imagem da simulação]

## Documentação Oficial

- [NetLogo User Manual](https://ccl.northwestern.edu/netlogo/docs/)
- [NetLogo Dictionary](https://ccl.northwestern.edu/netlogo/docs/dictionary.html)
