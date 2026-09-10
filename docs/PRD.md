# PRD — Pata Amiga (complementar ao README)

Este arquivo define **o que o produto precisa cumprir e para quem**.  
O [README](../README.md) é a fonte de verdade de **como** o modelo foi construído, dos números e das respostas.

| Ler no README | Não repetir aqui |
|---------------|-------------------|
| Case, 5 perguntas, 3 sistemas | [§1](../README.md#1-explicação-do-case) |
| Modelo estrela, grão, chaves, fluxo ELT | [§2](../README.md#2-descrição-do-modelo-construído) |
| Decisões de modelagem, tratamento e SQL | [§3](../README.md#3-decisões-tomadas) |
| Scripts, ordem, psql/pgAdmin | [§4–5](../README.md#5-como-executar) |
| Defeitos da origem e tratamentos | [§6](../README.md#6-diagnóstico-da-origem) |
| Dimensões, fato, colunas, o que ficou de fora | [§7–8](../README.md#7-dimensões-customizadas) |
| Respostas P1–P5 e recomendações | [§9](../README.md#9-respostas-das-5-perguntas-de-negócio) |
| 16 conferências | [§10](../README.md#10-validações-realizadas) |
| Limitações, melhorias, LGPD, stack | [§11–14](../README.md#11-limitações-dos-dados) |

---

## 1. Produto

**Nome:** data warehouse analítico da rede Pata Amiga (`dw_pata_amiga`).

**Não é** um dashboard nem um sistema transacional.  
**É** o pipeline ELT + modelo estrela que tornam as 5 perguntas da diretoria **repetíveis e auditáveis**, sem alterar a staging.

**Visão:** três origens sujas → staging imutável → dimensões + fato → cinco respostas com o mesmo número em qualquer reexecução.

---

## 2. Para quem

| Persona | Usa o produto para | Entrega que consome |
|--------|---------------------|----------------------|
| Diretoria / expansão | Abrir loja e ver concentração geográfica | P4, P5 + caveats |
| Operações / logística | Priorizar o gargalo (não a última milha) | P1 por porte |
| Comercial | Mix de categoria e política de desconto | P2, P3 |
| Analista / sustentação | Reconstruir o DW e defender os números | scripts + conferência |

Fora da v1: cliente final, franqueado no PDV, time de ML. Consumo atual = SQL; BI fica no pós-v1 ([README §12](../README.md#12-melhorias-futuras)).

---

## 3. Fronteira de escopo

**Entra:** carga crus, modelo estrela, tratamento só nos INSERTs, 5 análises, diagnóstico e conferência, SQL puro na lista fechada do documento acadêmico.

**Não entra:** alterar origem ou staging; dashboard; Python/orquestração; CTE, window, trigger, view, índice; SCD2 de faixa de franquia; PII de cliente; ML.

Detalhe técnico e “o que não foi usado” → [README §3 e §14](../README.md#3-decisões-tomadas).

---

## 4. Definição de pronto

A v1 está aceita quando, após rodar o pipeline na ordem do [README §5](../README.md#5-como-executar):

1. `06-analises.sql` responde P1–P5 sobre a fato (não sobre a staging).
2. Os 16 itens de [§10](../README.md#10-validações-realizadas) batem, inclusive faturamento e rateio (diferença R$ 0,00).
3. Staging só foi lida (SELECT). Nenhuma FK da fato é nula (linha -1).
4. A documentação declara o que **não** se pode afirmar ([§11](../README.md#11-limitações-dos-dados)) — sobretudo na P5.

Números esperados (linhas, %, dias, R$) ficam só no README.

---

## 5. Requisitos (o que, não o como)

Cada RF aponta o script. Regras de máscara, CASE, `TRANSLATE`, `100.0` e colunas da fato **não** estão aqui — estão no README §§3, 6–8.

| ID | O produto deve | Evidência |
|----|----------------|-----------|
| RF-01 | Carregar as 3 origens **sem transformar** | `01-carga-staging.sql` |
| RF-02 | Disponibilizar tempo e loja (com linha -1) | `02-dimensoes-prontas.sql` |
| RF-03 | Padronizar categoria e praça; ratear loja×praça sem dupla contagem | `04-dimensoes-customizadas.sql` |
| RF-04 | Materializar 1 linha por pedido, com FKs, `vl_liquido`, `qt_itens` e 5 intervalos de dias | `05-carga-fato.sql` |
| RF-05 | Calcular P1–P5 no modelo (AVG ignora NULL; P4 usa fator da ponte; P3 não afirma causalidade) | `06-analises.sql` |
| RF-06 | Permitir auditar origem e conferir o pipeline sem mudar tabelas | `03-diagnostico.sql`, `00-conferencia.sql` |

**Não negociável:** uma só coluna de dinheiro na fato; praça **não** liga direto na fato; canal WHATS antes de APP; categoria MED antes de RA.

---


## 7. Riscos de entrega (não cobertos como “decisão” no README)

| Se falhar | O número mente | Travado por |
|----------|----------------|-------------|
| Ordem errada no CASE de canal/categoria | Mix e ticket distorcidos | README §3.2 |
| P4 sem fator / praça na fato | Faturamento duplicado | conferência #16 |
| `INT / INT` nos % | P2–P4 zerados | `100.0` |
| pgAdmin no `\c` do script 01 | Pipeline não sobe | README §5.5 |
| P5 lida como histórico de faixa | Decisão de expansão inválida | README §9 e §11 |

---

*README = construção e evidência. PRD = fronteira, usuários e aceite.*
