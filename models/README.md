# Modelos

Código-fonte das simulações, organizado por ferramenta e por nível de complexidade.

[← Voltar ao índice](../README.md)

## Organização

```text
models/
├── netlogo/
│   ├── basic/      # .nlogox — modelos introdutórios
│   └── advanced/   # .nlogox — modelos complexos
└── gama/
    ├── basic/      # .gaml — modelos introdutórios
    └── advanced/   # .gaml — modelos complexos
```

| Nível | Critério | Exemplos de tema |
| --- | --- | --- |
| `basic` | Um único tipo de agente, regras simples, sem dados externos. Serve para ilustrar um conceito isolado. | Random walk, difusão, autômatos celulares |
| `advanced` | Múltiplas espécies de agentes, interação com o ambiente, dados externos (GIS/CSV) ou experimentos em lote. | Presa-predador, epidemiologia, mobilidade urbana |

## Convenções

- **Nome do arquivo:** `snake_case` descritivo, em inglês (ex.: `random_walk.nlogox`, `prey_predator.gaml`).
- **Extensão NetLogo:** use `.nlogox`, formato adotado a partir do NetLogo 7. Modelos salvos em `.nlogo` (versão 6 ou anterior) são convertidos automaticamente ao serem abertos.
- **Documentação interna:** todo modelo deve explicar o que faz, como funciona e como usar — na aba *Info* no NetLogo, ou em comentário de cabeçalho no `.gaml`.
- **Imagens:** capturas e GIFs de cada simulação vão em `assets/<ferramenta>/`.
- **Referência:** modelos adaptados da biblioteca oficial devem citar a fonte.
- **Saídas geradas:** arquivos produzidos pelos experimentos em lote vão para uma pasta `results/` ao lado do modelo e não são versionados (ver [.gitignore](../.gitignore)). Os caminhos relativos do `save` são resolvidos a partir da pasta do próprio `.gaml`.

## Modelos disponíveis

| Modelo | Ferramenta | Nível | Conceitos |
| --- | --- | --- | --- |
| [random_walk.gaml](./gama/basic/random_walk.gaml) | GAMA | `basic` | `species`, skill `moving`, `reflex`, `aspect` |
| [game_of_life.gaml](./gama/basic/game_of_life.gaml) | GAMA | `basic` | `grid`, vizinhança, atualização síncrona, toro |
| [prey_predator.gaml](./gama/advanced/prey_predator.gaml) | GAMA | `advanced` | Herança entre espécies, interação entre agentes, energia, gráficos |
| [sir_epidemic.gaml](./gama/advanced/sir_epidemic.gaml) | GAMA | `advanced` | Máquina de estados, contágio espacial, experimento `batch`, CSV |

A apresentação de cada modelo está em [Modelos Comentados](../docs/gama/guias.md#modelos-comentados). Os modelos de NetLogo ainda estão em preparação; o guia da ferramenta já traz um [exemplo mínimo comentado](../docs/netlogo/guias.md#código-exemplo).
