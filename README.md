# DidaticMaterials_SMA

Repositório voltado à criação de tutoriais e divulgação de ferramentas de programação multiagente, do básico ao avançado.

## Sumário
- [Conteúdo Didático](#conteúdo-didático)
- [Ferramentas](#ferramentas)
  - [NetLogo](#netlogo)
  - [GAMA Platform](#gama-platform)
  - [Comparativo](#comparativo)
- [Trilha de Aprendizado](#trilha-de-aprendizado)
- [Estrutura](#estrutura)
- [Licença](#licença)

## Conteúdo Didático

| Ferramenta | Guia de uso | Modelos básicos | Modelos avançados |
| --- | --- | --- | --- |
| NetLogo | [docs/netlogo/guias.md](./docs/netlogo/guias.md) | *em breve* | *em breve* |
| GAMA Platform | [docs/gama/guias.md](./docs/gama/guias.md) | [Random walk](./models/gama/basic/random_walk.gaml) · [Jogo da Vida](./models/gama/basic/game_of_life.gaml) | [Presa-Predador](./models/gama/advanced/prey_predator.gaml) · [Epidemia SIR](./models/gama/advanced/sir_epidemic.gaml) |

Os modelos são arquivos comentados linha a linha, com a explicação geral de cada bloco. Veja a apresentação de cada um em [Modelos Comentados](./docs/gama/guias.md#modelos-comentados).

## Ferramentas

### NetLogo

O [NetLogo](https://www.netlogo.org/) é um ambiente de modelagem e simulação programável para a criação de modelos baseados em agentes (ABM). Ele simula fenômenos naturais e sociais complexos, onde múltiplos agentes independentes interagem entre si e com o ambiente.

Ferramenta amplamente utilizada para pesquisa e educação, desenvolvida por [Uri Wilensky](https://ccl.northwestern.edu/Uri.shtml) no *[Center for Connected Learning and Computer-Based Modeling (CCL)](https://ccl.northwestern.edu/)* da Northwestern University.

**Acesse os materiais didáticos e guias:** [docs/netlogo/guias.md](./docs/netlogo/guias.md)

### GAMA Platform

O [GAMA](https://gama-platform.org/) é uma plataforma de modelagem e simulação baseada em agentes voltada a modelos de grande escala e espacialmente explícitos. Seu diferencial é a integração nativa com dados geográficos (GIS), permitindo que as simulações ocorram sobre mapas reais importados de shapefiles.

Escrito em Java e distribuído como software livre (GPL-3.0), é desenvolvido por um consórcio internacional de parceiros acadêmicos e industriais liderado pelo *[UMMISCO](https://ummisco.fr/)* (IRD/Sorbonne Université). Os modelos são escritos em GAML, linguagem dedicada criada para ser usada por não programadores.

**Acesse os materiais didáticos e guias:** [docs/gama/guias.md](./docs/gama/guias.md)

### Comparativo

| Aspecto | NetLogo | GAMA Platform |
| --- | --- | --- |
| Linguagem | NetLogo (dialeto Logo) | GAML (GAMA Modeling Language) |
| Curva de aprendizado | Suave, voltada ao ensino | Mais íngreme, voltada à pesquisa aplicada |
| Ambiente | Grid de *patches* (mundo abstrato) | Geometrias e dados GIS (mundo georreferenciado) |
| Tipos de agente | Observer, turtles, patches, links | `global` (mundo), `species`, `grid` |
| Movimento | Embutido em toda turtle (`forward`, `right`) | Requer anexar a skill `moving` à espécie |
| Fronteira do mundo | Toro por padrão: o agente reaparece do lado oposto | Sem fronteira por padrão: o agente pode sair do mundo |
| Interface | Widgets montados na aba Interface | Declarada em código no bloco `experiment` |
| Escala típica | Centenas a milhares de agentes | Milhares a milhões de agentes |
| Execução em lote | BehaviorSpace | Modo headless / gama-server |
| Formato do arquivo | `.nlogox` (XML, a partir da v7) | `.gaml` (texto puro) |
| Licença | GPL-2.0 | GPL-3.0 |
| Uso recomendado | Primeiro contato com ABM e ensino | Modelos urbanos, ambientais e epidemiológicos realistas |

> **Versões de referência.** O material foi conferido contra o **NetLogo 7.0.4** e o **GAMA 2025-06** em setembro de 2026. Duas mudanças recentes merecem atenção: o NetLogo migrou o site para `netlogo.org` e adotou o formato `.nlogox` na versão 7; o GAMA passou a numerar suas versões por data (`2025-06`) em vez de `1.x`.

## Trilha de Aprendizado

1. **Fundamentos** — Entender o paradigma de agentes, ambiente e interação. Comece pelo [guia do NetLogo](./docs/netlogo/guias.md), cuja sintaxe é mais direta.
2. **Modelos básicos** — Reproduzir modelos clássicos (*random walk*, difusão, presa-predador) a partir das bibliotecas embutidas de cada ferramenta.
3. **Modelos próprios** — Construir simulações do zero, definindo variáveis, comportamentos e visualizações.
4. **Modelos avançados** — Migrar para o [GAMA](./docs/gama/guias.md) para explorar dados geográficos (GIS), múltiplas espécies de agentes e experimentos em larga escala.
5. **Análise de resultados** — Executar simulações em lote (BehaviorSpace no NetLogo, Headless no GAMA) e analisar os dados gerados.

## Estrutura
```text
├── README.md           # Guia principal e índice
├── LICENSE             # Licença
├── docs/               # Teoria, tutoriais e referências
│   ├── netlogo/        # Guias específicos de NetLogo
│   └── gama/           # Guias específicos de GAMA Platform
├── models/             # Código-fonte dos modelos
│   ├── README.md       # Convenções e níveis dos modelos
│   ├── netlogo/        # Arquivos .nlogox
│   │   ├── basic/      # Modelos introdutórios
│   │   └── advanced/   # Modelos complexos
│   └── gama/           # Arquivos .gaml
│       ├── basic/      # Modelos introdutórios
│       └── advanced/   # Modelos complexos
└── assets/             # Imagens e GIFs das simulações
    ├── netlogo/
    └── gama/
```

## Licença

Distribuído sob a licença MIT. Veja [LICENSE](./LICENSE).
