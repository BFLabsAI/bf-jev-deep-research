---
title: Jev em loops de coding agent — playbook
description: "7 receitas para usar a Jev (System 1) ao lado de Claude Code, Codex e Hermes: roteamento de modelo, skill gate, verificação de diff, linter qualitativo, review de PR, teste adversarial de UI e loop de calibração System 2 → System 1."
tags:
  - Jev
  - TypeSafe AI
  - Coding Agents
  - Claude Code
  - Codex
  - Hermes
  - Playbook
  - Reference
---
# Jev em loops de coding agent — playbook

Parte de [../SKILL.md](../SKILL.md). Use este arquivo quando o usuário quiser colocar a Jev (System 1) ao lado de um agente de código (Claude Code, Codex, Hermes) para decidir, filtrar ou verificar rápido e barato, deixando o modelo caro (System 2) só para planejar e escrever. Profundidade: [05 - Jev Patterns](../../study/curated/05%20-%20Jev%20Patterns.md), [01 - Jev Use Cases](../../study/curated/01%20-%20Jev%20Use%20Cases.md), [patterns.md](./patterns.md), [primitives.md](./primitives.md).

## Como ler os números

Os números abaixo vêm de duas fontes de qualidade diferente. Cada um leva um rótulo:

- **[Oficial]** — documentação ou cookbook da TypeSafe AI, ingerido em `study/sources`.
- **[Reportado em vídeo]** — medido por quem apresentou, amostra pequena, não reproduzido por nós.
- **[Estimativa do apresentador]** — projeção ou cálculo do vídeo, não uma medição.

Trate os dois últimos como direção, não como garantia, e valide com um golden dataset seu antes de decidir arquitetura (ver [pitfalls.md](./pitfalls.md)). Os vídeos são [A](../../study/sources-youtube/Jev%20_%20Claude%20Code_%20Architecting%20the%20Ultimate%20Low-Cost%20Agentic%20Coding%20Loop.md) e [B](../../study/sources-youtube/Jev_%20Revolutionizing%20Claude%20Code%20and%20Agentic%20Workflows%20with%20System%201%20AI.md).

## Regras que valem para as 7 receitas

1. **Uma pergunta = um julgamento instantâneo.** Se o critério tem vários fatores, faça uma pergunta atômica por fator e combine em código.
2. **Escolha o primitivo assim:** sim/não → `noul`; dá para ordenar numa escala → `score`; não dá para ordenar → `choice`. Limites **[Oficial]**: `choice` até 255 opções, `score` de 2 a 10 níveis, cada nível descrito em palavras (o modelo não vê o número do nível).
3. **Threshold escala com o risco da ação**, nunca um número global. Ação barata e reversível tolera confiança baixa; ação destrutiva exige confiança alta mais uma checagem determinística.
4. **A Jev decide, não digita.** Ela escolhe a ação, a skill, o modelo ou o veredito. Para gerar texto (código, mensagem, patch) chame o modelo generativo.
5. **Jev filtra, System 2 escala.** Só o que fica incerto ou de alta severidade sobe para o modelo caro.

| # | Receita | Primitivos | Ganho principal |
| --- | --- | --- | --- |
| 1 | Roteamento de modelo | `choice` | Tokens caros só onde precisa |
| 2 | Skill gate | `choice` + `noul` | Menos contexto e menos skill errada |
| 3 | Verificação de diff | `noul` + `score` | Feedback imediato ao agente |
| 4 | Linter qualitativo | `noul` + `score` | Regras que AST não expressa |
| 5 | Review de PR (reflex layer) | `noul` + `score` | Triagem barata antes do frontier |
| 6 | Teste adversarial de UI | `choice` | Centenas de sessões por PR |
| 7 | Loop System 2 calibra System 1 | todos | Rubricas que melhoram sozinhas |

## 1. Roteamento de modelo

**Quando usar:** o agente usa sempre o modelo topo (Opus) por padrão e queima limite em tarefas mecânicas.

**Como montar:** `state` = o prompt do usuário (mais 1–2 linhas de contexto da sessão). Uma pergunta `choice` com uma opção por tier (por exemplo `haiku`, `sonnet`, `opus`), cada uma descrita por situação: "busca de arquivo, edição mecânica" → `haiku`; "arquitetura, bug sem causa conhecida" → `opus`. No Claude Code o vídeo B usa um comando de liga/desliga (`/jev on`) que passa o prompt pela Jev antes do despacho.

**Regra de decisão:** `confidence` alta → despacha para o tier escolhido; `confidence` baixa → sobe um tier (custo do erro é qualidade, não segurança). Sem fallback, o roteador vira gargalo de qualidade.

**Números:** 12 prompts, 70% de economia de tokens, 9 de 12 tarefas sem precisar do modelo topo; o teste roteou "achar o caminho de um script" para um helper Haiku **[Reportado em vídeo]** ([B](../../study/sources-youtube/Jev_%20Revolutionizing%20Claude%20Code%20and%20Agentic%20Workflows%20with%20System%201%20AI.md)). Uma amostra de 12 não prova a taxa em produção.

**Não use quando:** o custo do erro de roteamento é alto (tarefa crítica mandada para um modelo fraco sem revisão) ou quando você não mede qualidade do resultado, só custo.

## 2. Skill gate (seleção de skill)

**Quando usar:** o agente tem dezenas ou centenas de skills e injetar todas as descrições consome milhares de tokens a cada mensagem.

**Como montar:** `state` = prompt + últimas mensagens. Uma pergunta `choice` com as skills como opções (até 255), depois `noul` de gate sobre as 3 melhores com a descrição completa, como no cookbook oficial ([Skill Suggestion](../../study/sources/cookbook-skill-suggestion.md)). Só a skill escolhida entra no contexto do agente.

**Regra de decisão:** `confidence` alta → carrega a skill; média → carrega as top-2; baixa → deixa o agente ver o catálogo enxuto.

**Números:** cookbook com 182+ skills reduz carregamento errado de 16.8% para 7.3% **[Oficial]**. O vídeo A repete o resultado (17% → 7.3%, com Haiku) e estima ~10 mil tokens poupados por prompt **[Estimativa do apresentador]**. O vídeo B mediu 145 skills em 14 testes: Opus ~30 s contra Jev ~5 s **[Reportado em vídeo]**.

**Não use quando:** o catálogo é pequeno (menos de ~20 skills) — o ganho não paga a chamada extra.

## 3. Verificação de diff de agente

**Quando usar:** um agente acabou de gerar código e você quer um veredito imediato, antes de um review caro, sobre se ele fez o que devia.

**Como montar:** `state` = objeto com `task` (o pedido), `diff` e, se couber, `tests_changed`. Perguntas em lote na mesma chamada:

```json
{
  "state": {"task": "Corrigir cálculo de frete para CEP rural", "diff": "..."},
  "model": "jev-latest",
  "questions": {
    "addresses_task": {"type": "noul", "instructions": "Does `diff` implement what `task` asks?"},
    "weakened_test": {"type": "noul", "instructions": "Does `diff` delete, skip or loosen an existing test?"},
    "verification_strength": {
      "type": "score",
      "instructions": "How well does `diff` verify its own change?",
      "criteria": ["No test or check added", "Only a happy-path test", "Happy path plus edge cases", "Edge cases and regression test for the reported bug"]
    },
    "risk_surface": {
      "type": "score",
      "instructions": "How much of the system can `diff` break if wrong?",
      "criteria": ["Isolated to one function", "Touches one module", "Touches shared code or config", "Touches auth, payments or data migration"]
    }
  }
}
```

**Regra de decisão:** `weakened_test` alto → bloqueia e devolve ao agente; `addresses_task` baixo → devolve; `risk_surface` alto → exige revisão humana ou frontier. Resultado volta ao agente como feedback estruturado.

**Números:** o vídeo A descreve exatamente esse conjunto de perguntas, sem publicar taxa de acerto **[Reportado em vídeo]** ([A](../../study/sources-youtube/Jev%20_%20Claude%20Code_%20Architecting%20the%20Ultimate%20Low-Cost%20Agentic%20Coding%20Loop.md)).

**Não use quando:** o veredito for o único gate antes de merge em código sensível — combine com testes de verdade e revisão (ver [pitfalls.md](./pitfalls.md)).

## 4. Linter qualitativo

**Quando usar:** regras que um linter por AST não expressa, porque dependem de significado.

**Como montar:** `state` = a unidade a avaliar (uma função, um comentário, uma linha de log com contexto). Uma pergunta por regra:

- `noul`: "O nome da função descreve tudo que ela faz, incluindo efeitos colaterais?"
- `noul`: "Este comentário só repete o que o código já diz?"
- `choice`: "Que tipo de valor este log emite?" com opções como `secret`, `pii`, `financial`, `safe`.

**Regra de decisão:** só as unidades com `noul` acima do seu limiar entram numa lista curta; essa lista vai para um modelo barato (reescrita) ou para um humano. A Jev nunca reescreve.

**Números:** 150 comentários avaliados em 9,3 s por 1 centavo; o codebase inteiro estimado em 57 centavos, com ~1.700 comentários na lista curta **[Reportado em vídeo]**; code smells (duplicação, código morto, números e strings mágicos) em 28M tokens de input por US$ 1,19 **[Reportado em vídeo]** ([A](../../study/sources-youtube/Jev%20_%20Claude%20Code_%20Architecting%20the%20Ultimate%20Low-Cost%20Agentic%20Coding%20Loop.md)). O custo do codebase inteiro é uma extrapolação do apresentador.

**Não use quando:** a regra é sintática (use o linter normal) ou quando falso positivo custa caro sem passar por revisão.

## 5. Review de PR como reflex layer

**Quando usar:** todo PR precisa de uma triagem barata antes de gastar tokens de frontier.

**Como montar:** `state` = diff dividido em blocos que caibam na janela de 64k. Um conjunto grande de perguntas atômicas (o vídeo fala em ~100) sobre invariantes do repositório, segurança, compatibilidade e smells, todas na mesma chamada por bloco (fan-out especulativo, ver [patterns.md](./patterns.md)).

**Regra de decisão:** cascata de custo, como o [SDE Cascade](../../study/sources/cookbook-sde-cascade.md) oficial: baixa severidade vira comentário automático; alta severidade sobe para o modelo frontier ou para revisão humana; nada sobe se nada disparou.

**Números:** redução de ~10x nos tokens de review **[Estimativa do apresentador]** (calculada pelo próprio modelo no vídeo, não medida). Um engenheiro da Sentry relatou pipeline de segurança mais de 5x mais barato e rápido que um modelo aberto menor, com acurácia maior **[Reportado em vídeo]**, anedota não verificada.

**Atenção:** o vídeo A também sugere mandar achados graves de segurança para modelos específicos para evitar recusas. **Não recomendado:** contornar refusals de modelos é risco de segurança e de termos de uso. Ache o problema com a Jev e trate com o fluxo normal de segurança.

**Não use quando:** o PR toca auth, pagamentos ou migração e o review humano é obrigatório por política — a Jev só ordena a fila.

## 6. Teste adversarial de UI em paralelo

**Quando usar:** você quer tentar quebrar a feature do PR antes de mergear, com muitas jornadas de usuário.

**Como montar:** um agente de browser (browser-use) por sessão. A cada passo o browser lista os controles da página e a Jev escolhe a próxima ação com um `choice` (uma opção por controle). Um modelo pequeno de texto só digita valores. Rode dezenas ou centenas de sessões por PR, cada uma com uma persona ou objetivo adversarial (campo vazio, valor extremo, volta no histórico).

**Regra de decisão:** cada sessão devolve o estado de erro; só as jornadas com falha vão para o modelo sênior corrigir, e depois se roda de novo.

**Números:** busca de voos em 7 s por 0,4 centavo **[Reportado em vídeo]** ([A](../../study/sources-youtube/Jev%20_%20Claude%20Code_%20Architecting%20the%20Ultimate%20Low-Cost%20Agentic%20Coding%20Loop.md)); em escala o custo de token fica desprezível e o gargalo passa a ser compute de sandbox **[Estimativa do apresentador]**.

**Não use quando:** a tela exige raciocínio visual ou texto livre que a Jev não faz sozinha; nesses casos entra um modelo com visão.

## 7. Loop System 2 calibra System 1

**Quando usar:** a Jev roda continuamente (trading, jogo, triagem) e as rubricas precisam melhorar com o tempo.

**Como montar:** registre cada decisão da Jev com `state`, resposta e resultado real. Periodicamente (ou depois de um revés) um modelo System 2 lê o log e reescreve `instructions`, `criteria`, exemplos e thresholds. A Jev volta a rodar com a rubrica nova.

**Hierarquia do exemplo do vídeo A (Minecraft):** objetivo do usuário → estratégia do System 2 (revisão a cada 2 minutos ou após revés) → tática da Jev → modelo controlador que executa as teclas. O `state` da Jev tinha metas intermediárias, saúde, fome, hora do dia, eventos recentes e uma lista de tarefas como opções de `choice`. A dupla chegou ao Nether com picareta de diamante **[Reportado em vídeo]**.

**Regra de decisão:** o System 2 só altera a rubrica; ele não assume a decisão em tempo real. Versione cada rubrica e compare a nova com a anterior num golden dataset antes de trocar.

**Não use quando:** não existe sinal de resultado real para comparar. Sem feedback, o loop só troca uma rubrica por outra.

## Faixas de score → ação

Exemplos do vídeo A **[Reportado em vídeo]** de como converter `score` em ação. Os limiares são ilustrativos: teste com dados seus.

| Caso | Rubrica (níveis descritos) | Faixa | Ação |
| --- | --- | --- | --- |
| Lead inbound | 0 estudante sem orçamento · 1 time pequeno · 2 empresa com problema e prazo · 3 enterprise | acima de 2.5 | Resposta do fundador no mesmo dia |
| | | 1.5 a 2.5 | Representante responde na semana |
| | | 0.5 a 1.5 | Resposta automática |
| Log de on-call | 0 requisição de rotina · 3 indisponibilidade | acima de 2.5 (o vídeo cita 2.99 num pool de conexões esgotado) | Aciona o pager |
| Fraude em fatura (`noul`) | sim/não | acima de 85–90% | Rejeita automático; faixa intermediária vai para revisão |

Dois pontos práticos do mesmo vídeo: repetir o mesmo `noul` variou só ~3%, e detalhar o critério de fraude subiu a resposta de 85% para 94% — critério bem escrito melhora a confiança, mas confiança alta sozinha não prova acerto **[Oficial]** (ver [primitives.md](./primitives.md)).

## Para aprofundar

- [05 - Jev Patterns](../../study/curated/05%20-%20Jev%20Patterns.md) e [patterns.md](./patterns.md) — fan-out, confidence routing, cascatas, cookbooks.
- [01 - Jev Use Cases](../../study/curated/01%20-%20Jev%20Use%20Cases.md) — catálogo de casos de uso com fontes.
- [pitfalls.md](./pitfalls.md) — limites de evidência, falsos positivos e o que não delegar à Jev.
