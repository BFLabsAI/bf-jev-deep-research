---
title: Jev — Armadilhas Conhecidas e Anti-Padrões
description: Lista acionável de armadilhas documentadas ao usar a Jev/System One — jaggedness, dependência de contexto, casos reais de falha (Vampire Survivors, compactação de contexto, day-trading) — cada uma como lição 'se X então Y'.
tags:
  - Jev
  - TypeSafe AI
  - Pitfalls
  - Anti-patterns
  - Jaggedness
  - Reference
---
# Armadilhas conhecidas e anti-padrões

Parte de [../SKILL.md](../SKILL.md). Cada item abaixo é uma lição acionável ("se X, então Y"), fundamentada em casos reais documentados nas fontes da base — não é especulação.

## 1. Jaggedness — ausência de invariantes estruturais de senso comum

**Se** você fizer a mesma pergunta de negócio como `noul` e como `choice` binária no mesmo `state`, **então** não espere que os números sejam diretamente comparáveis — um teste documentado do `jev-1.13.0` mostrou `noul = 0.22` para "o cliente está pedindo reembolso?" enquanto a mesma pergunta como `choice` binária devolveu `yes = 0.01 / no = 0.99 / confidence = 0.97` no mesmo ticket.

**Se** você fizer uma pergunta e sua negação como dois `noul`s separados, **então** não assuma que as probabilidades somam 1.0 — um exemplo documentado somou 1.19.

**Ação prática:** não construa lógica de negócio que dependa de coerência matemática entre formulações diferentes da "mesma" pergunta. Se precisar comparar, use sempre a mesma formulação (mesmo `type` de pergunta) em todo o pipeline. Fonte: [study/sources/model-jaggedness-jev-1-13.md](../../study/sources/model-jaggedness-jev-1-13.md), [../../02 - Jev Model Thesis.md](../../study/curated/02%20-%20Jev%20Model%20Thesis.md).

## 2. Dependência total da qualidade do `state` (caso Vampire Survivors)

Um mod de Vampire Survivors enviava o estado do jogo a cada 250ms para um controlador Python powered by Jev, mas **não incluía dados de obstáculos** no payload. Resultado: o personagem travava em paredes e morria repetidamente.

**Se** o payload de `state` não incluir a informação necessária para a decisão, **então** a Jev vai falhar de forma silenciosa e consistente — ela não tem como "adivinhar" um dado que nunca recebeu, por mais rápida ou calibrada que seja. Antes de confiar numa decisão em tempo real, audite explicitamente se todo dado relevante para aquele julgamento está de fato no `state` — latência baixa não compensa contexto incompleto. Fonte: [../../01 - Jev Use Cases.md, seção 5](../../study/curated/01%20-%20Jev%20Use%20Cases.md).

## 3. Compactação de contexto pode piorar a latência (caso do projeto "Yoshi")

No projeto Yoshi, uma implementação de compactação de contexto usando Jev (decidir quais chamadas de ferramenta antigas manter/encurtar/remover numa sessão longa de coding agent) reduziu o uso de tokens de entrada, mas **a execução ficou muito mais lenta e houve falhas da Jev** na avaliação pequena feita.

**Se** você usar a Jev para podar/compactar contexto de um agente, **então** meça sempre latência end-to-end e taxa de falha, não só contagem de tokens — menos tokens de entrada não significa automaticamente um agente melhor ou mais rápido. Tenha sempre um fallback determinístico (ex.: o padrão "Fast JEV Compaction" cai de volta ao resumo padrão do host se a Jev falhar ou não conseguir remover o suficiente).

Um contraponto relacionado (relato do dev Theo): **se** você limpar histórico de decisões intermediárias (scores, `noul`s de checagem) durante a compactação, **então** você pode eliminar a trilha de auditoria do raciocínio do agente — limpar histórico de conversa é diferente de filtrar/pontuar itens individuais; preserve os artefatos de decisão mesmo quando remover o texto bruto. Fonte: [../../01 - Jev Use Cases.md, seção 5](../../study/curated/01%20-%20Jev%20Use%20Cases.md).

## 4. Não use para raciocínio financeiro multi-fonte de alto risco (caso day-trading)

Tentativas documentadas de usar a Jev para sinais de Bitcoin/ações (incluindo o protótipo "JEV Trader" de paper trading) renderam **resultados ruins**, porque a Jev **não faz raciocínio multi-fonte nem análise macroeconômica** — ela só julga o `state` estreito que você fornece, sem sintetizar notícias, dados macro ou histórico de mercado amplo por conta própria. O próprio experimento foi descrito como **não validado, não pronto para dinheiro real e não é conselho financeiro**.

**Se** a decisão exigir síntese de múltiplas fontes não estruturadas e julgamento aberto de alto risco (trading, decisões legais/médicas de impacto direto), **então** não delegue a decisão final à Jev — use-a no máximo como um sinal de entrada barato e rápido, e mantenha o julgamento de alto risco com um LLM de raciocínio ou um humano. Fonte: [../../01 - Jev Use Cases.md, seção 6](../../study/curated/01%20-%20Jev%20Use%20Cases.md).

## 5. Um score/confidence alto não é permissão de segurança

**Se** você usar a Jev para julgar se uma tool call é apropriada em contexto (ex.: "esse reset de banco de dados foi pedido pelo usuário?"), **então** não use essa probabilidade como único gate de execução — aprovação por probabilidade não deve substituir as regras de permissão reais da aplicação. A própria documentação da TypeSafe alerta que a Jev pode ser influenciada por conteúdo adversarial dentro do próprio `state` — combine sempre `confidence` alto com checagens determinísticas de negócio antes de ações sensíveis (financeiras, destrutivas, irreversíveis). Fonte: [../../01 - Jev Use Cases.md, seção 5](../../study/curated/01%20-%20Jev%20Use%20Cases.md), [../../02 - Jev Model Thesis.md](../../study/curated/02%20-%20Jev%20Model%20Thesis.md).

## 6. Context rot — `state` grande com detalhe irrelevante degrada a decisão

**Se** você despejar todo o histórico/documento bruto no `state` "por segurança", **então** a qualidade da decisão cai — a documentação oficial documenta degradação de desempenho com `state` grande e cheio de detalhe irrelevante ("context rot"). Decomponha o `state` para conter só o que é relevante àquela pergunta específica; use múltiplas perguntas atômicas em vez de um `state` gigante com uma pergunta ampla. Fonte: [../../02 - Jev Model Thesis.md](../../study/curated/02%20-%20Jev%20Model%20Thesis.md).

## 7. Fraquezas conhecidas de raciocínio numérico/temporal

**Se** a decisão depender de matemática, contagem, precisão numérica ou comparação de datas, **então** não peça esse cálculo à Jev diretamente — ela tende a comparar datas como texto em vez de quantidade ordenada, e é fraca em aritmética/contagem. Faça a Jev extrair os componentes estruturados (ex.: o cookbook Date Extraction usa 7 perguntas `choice` — modo, mês, dia, ano, âncora — e resolve a data final em código) e deixe todo cálculo determinístico fora do modelo. Fonte: [study/sources/model-jaggedness-jev-1-13.md](../../study/sources/model-jaggedness-jev-1-13.md).

## 8. Múltiplos saltos de indireta e instruções contraditórias

**Se** uma pergunta exigir vários saltos de inferência indireta (A implica B implica C) ou se `instructions` e `criteria` se contradisserem, **então** espere perda de acurácia e confusão do modelo. Quebre a cadeia de inferência em perguntas separadas e resolva a composição em código (ver [references/patterns.md](./patterns.md), padrão Composite Scoring); revise sempre `instructions`/`criteria` em busca de contradições antes de deployar. Fonte: [study/sources/model-jaggedness-jev-1-13.md](../../study/sources/model-jaggedness-jev-1-13.md).

## 9. Não peça texto livre

**Se** você precisar de uma explicação, resumo, ou qualquer saída em linguagem natural aberta, **então** a Jev não é a ferramenta certa — ela não gera texto livre de forma confiável. Use-a só para o julgamento tipado (`choice`/`score`/`noul`) e delegue qualquer geração de texto para um LLM generativo. Fonte: [../../02 - Jev Model Thesis.md](../../study/curated/02%20-%20Jev%20Model%20Thesis.md).

## 10. Números de vídeo são amostras pequenas ou estimativas

**Se** você basear uma decisão de arquitetura num número de vídeo (70% de economia em 12 prompts, Opus ~30 s contra Jev ~5 s em 14 testes, ~10x menos tokens num review), **então** trate-o como direção, não como garantia: são amostras pequenas medidas por quem apresentou, ou estimativas calculadas no próprio vídeo. Valide com um golden dataset seu (inputs reais e respostas corretas) comparando Jev e o modelo que ela substituiria em acurácia, custo e velocidade antes de ir para produção.

Uma divergência concreta já encontrada: o vídeo A diz que `score` aceita "11 níveis (0–10)"; a documentação oficial diz **até 10 níveis** ([primitives-score](../../study/sources/primitives-score.md)). **Vale a oficial** — desenhe rubricas de 2 a 10 níveis descritos. O resumo automático dos vídeos também usa nomes de modelo inconsistentes entre si; cite como "segundo o vídeo", sem normalizar. Fonte: [coding-agents.md](./coding-agents.md), vídeos [A](../../study/sources-youtube/Jev%20_%20Claude%20Code_%20Architecting%20the%20Ultimate%20Low-Cost%20Agentic%20Coding%20Loop.md) e [B](../../study/sources-youtube/Jev_%20Revolutionizing%20Claude%20Code%20and%20Agentic%20Workflows%20with%20System%201%20AI.md).

## 11. Flags de linter e review qualitativo são pistas, não veredito

**Se** você usar a Jev como linter qualitativo ou triagem de review, **então** trate cada flag como pista para revisão, não como veredito. Falsos positivos existem e o volume pode ser grande: no exemplo do vídeo A, a lista curta de um único codebase chegou a ~1.700 comentários para revisar. Passe a lista por um modelo barato ou por um humano antes de agir, meça a precisão numa amostra rotulada por você e ajuste a rubrica (`instructions`/`criteria`) quando o falso positivo for alto. A mesma cautela vale para classificadores de histórico como o Commit Miner. Fonte: [../../01 - Jev Use Cases.md](../../study/curated/01%20-%20Jev%20Use%20Cases.md), [coding-agents.md](./coding-agents.md).

## 12. Confidence alto não é gate único nos loops de coding agent

**Se** o veredito da Jev (verificação de diff, review, roteamento de skill ou de modelo) for decidir merge, deploy ou uma ação destrutiva, **então** mantenha o gate determinístico (testes, permissões, revisão humana) — é a mesma regra da seção 5, aplicada aos usos do playbook: um `weakened_test` baixo não prova que o teste continua bom, e um `noul` de fraude em 94% não substitui a regra de negócio. O vídeo A cita mandar achados graves de segurança para modelos que evitam recusas; **não faça isso**, contornar refusals é risco de segurança e de termos de uso — use o fluxo normal de segurança. Fonte: [coding-agents.md](./coding-agents.md), vídeo [A](../../study/sources-youtube/Jev%20_%20Claude%20Code_%20Architecting%20the%20Ultimate%20Low-Cost%20Agentic%20Coding%20Loop.md).