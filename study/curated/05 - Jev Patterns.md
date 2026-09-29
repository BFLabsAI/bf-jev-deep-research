---
title: Jev — Padrões e Cookbooks
description: Padrões de composição e receitas práticas para construir sistemas com a Jev, a partir dos primitivos choice/score/noul.
tags:
  - Jev
  - TypeSafe AI
  - Patterns
  - Cookbook
  - System One Model
---
# Jev — Padrões e Cookbooks

## 1. Introdução: por que padrões de composição importam

A Jev é um [System One Model](../sources/blog-introducing-system-one-and-jev.md): um modelo de decisão rápido e reflexo que recebe um `state` (contexto) mais um conjunto de perguntas estruturadas e devolve, para cada pergunta, um de três tipos de resposta — `choice` (escolha entre opções, com probabilidade por opção), `score` (nota numa escala definida por critérios) ou `noul` (probabilidade 0–1 de que uma afirmação seja verdadeira). Ela nunca devolve texto livre.

Esse contrato deliberadamente estreito é a fonte da força da Jev (latência de 70–500ms, previsibilidade, baixo custo — $42/bilhão de tokens de input, output grátis), mas também significa que nenhuma decisão de negócio complexa é resolvida por uma única chamada isolada. Uma decisão real — "esse chamado de suporte deve escalar?", "essas duas entidades são o mesmo produto?", "essa mensagem deve ser bloqueada?" — quase sempre depende de combinar várias respostas atômicas (`choice`/`score`/`noul`) com lógica determinística em código.

É exatamente aí que entram os **padrões de composição**: formas repetíveis de organizar perguntas, thresholds e ramificações de código em torno dos primitivos da Jev, transformando respostas atômicas em decisões de sistema completas. A documentação oficial da TypeSafe descreve isso assim: "Learning to think in terms of discrete, atomic decisions that compose into complex system behavior is a key skill for getting the most out of TypeSafe" ([Patterns — índice](../sources/patterns-index.md)).

Este documento cobre os **4 padrões centrais** documentados pela TypeSafe (mais **2 padrões de comunidade**, rotulados como tal), os **demos** que os ilustram em código real, e um catálogo de **18 cookbooks** — receitas prontas que aplicam esses padrões a problemas concretos (triagem, extração, guardrails, ranking, RAG, etc).

| Padrão | O que faz | Benefícios |
| --- | --- | --- |
| Speculative Fan-Out | Envia várias perguntas (inclusive especulativas) numa única chamada e deixa o código decidir o que é relevante | Custo, Velocidade |
| Confidence-Gated Routing | Usa a confiança como segundo eixo de decisão para sistemas mais seguros | Confiabilidade, Segurança |
| Composite Scoring | Combina várias dimensões de análise num único score | Custo, Confiabilidade, Velocidade |
| Intent Routing | Classifica a intenção do usuário e roteia para o handler apropriado | Custo, Velocidade |
| System 2 calibra System 1 *(padrão de comunidade)* | Um modelo lento revisa o log de decisões da Jev e reescreve critérios, exemplos e thresholds | Confiabilidade ao longo do tempo |
| Reflex layer / cascata de screening *(padrão de comunidade)* | Centenas de micro-perguntas em paralelo; só os itens de maior severidade sobem para o modelo frontier | Custo, Velocidade |

Fonte dos 4 primeiros padrões: [Patterns — índice](../sources/patterns-index.md). Os dois últimos (seções 2.5 e 2.6) **não** fazem parte dos padrões oficiais: vêm de relatos de comunidade em vídeo — [vídeo A](../sources-youtube/Jev%20_%20Claude%20Code_%20Architecting%20the%20Ultimate%20Low-Cost%20Agentic%20Coding%20Loop.md) e [vídeo B](../sources-youtube/Jev_%20Revolutionizing%20Claude%20Code%20and%20Agentic%20Workflows%20with%20System%201%20AI.md) — e por isso cada dado deles leva um rótulo de evidência: **[Oficial]**, **[Reportado em vídeo]** ou **[Estimativa do apresentador]**.

## 2. Padrões de composição: 4 oficiais e 2 de comunidade

### 2.1 Speculative Fan-Out

**Problema que resolve:** evitar múltiplas idas e vindas (round-trips) quando uma decisão depende de perguntas condicionais — por exemplo, "qual a severidade do bug?" só importa se a categoria for `bug_report`. Perguntar sequencialmente (primeiro a categoria, depois a severidade em outra chamada) multiplica latência e custo.

**Como funciona:** como a Jev avalia todas as perguntas de uma chamada em paralelo, o custo marginal de adicionar mais perguntas é baixo. A recomendação é enviar **todas** as perguntas que o sistema pode precisar — inclusive as "especulativas", que só farão sentido dependendo da resposta de outra pergunta — numa única chamada, e deixar o código decidir depois o que é relevante e o que deve ser descartado ([Speculative Fan-Out](../sources/patterns-fan-out.md)).

```mermaid
flowchart TD
    A[Ticket de suporte] --> B["1 chamada à Jev:\ncategory (choice)\nbug_severity (score)\nhas_reproducible_steps (noul)\nrefund_requested (noul)\nfrustration (score)"]
    B --> C{category.choice}
    C -->|bug_report| D{bug_severity > 1.5\ne repro > 0.6?}
    D -->|sim| E[Escalar para engenharia]
    D -->|não| F[Backlog de bugs]
    C -->|billing| G{refund.noul > 0.7?}
    G -->|sim| H[Rotear p/ billing + flag reembolso]
    G -->|não| I[Rotear p/ billing]
    C -->|feature_request| J[Registrar feature request]
    B --> K{frustration > 1.5?}
    K -->|sim| L[Priorizar resposta]
```

Exemplo de código (triagem de tickets de suporte), reproduzido da fonte:

```python
category = response.answers["category"]
bug_severity = response.answers["bug_severity"]
bug_repro = response.answers["has_reproducible_steps"]
refund = response.answers["refund_requested"]
frustration = response.answers["frustration"]

if category.choice == "bug_report":
    if bug_severity.score > 1.5 and bug_repro.noul > 0.6:
        escalate_to_engineering(ticket_id, severity="high")
    else:
        add_to_bug_backlog(ticket_id)

elif category.choice == "billing":
    if refund.noul > 0.7:
        route_to_billing_with_flag(ticket_id, refund_likely=True)
    else:
        route_to_billing(ticket_id)

elif category.choice == "feature_request":
    log_feature_request(ticket_id)

if frustration.score > 1.5:
    flag_for_priority_response(ticket_id)
```

Fonte: [Speculative Fan-Out](../sources/patterns-fan-out.md).

### 2.2 Confidence-Gated Routing

**Problema que resolve:** ações com consequências muito diferentes (consultar um saldo vs. aprovar uma transferência) não deveriam exigir o mesmo nível de certeza do modelo. Usar um único threshold de confiança para tudo é arriscado — ou fica permissivo demais para ações críticas, ou trava demais ações triviais.

**Como funciona:** a resposta da Jev diz **o quê** (a escolha em si); a confiança diz **se** deve agir com base nela. O padrão consiste em definir thresholds de confiança diferentes por ação, proporcionais ao risco de cada uma ([Confidence-Gated Routing](../sources/patterns-confidence-routing.md)).

No exemplo de comandos de voz bancários:
- Confiança abaixo de 0.6 → escalar para atendimento humano (piso genérico para incerteza real)
- `check_balance` com confiança ≥ 0.6 → mostrar saldo diretamente (ação de baixo risco)
- `approve_transfer` entre 0.6 e 0.85 → pedir confirmação ao usuário
- `approve_transfer` acima de 0.85 → processar automaticamente (ação de alto risco exige mais certeza)

```mermaid
flowchart TD
    A[Comando de voz] --> B["Jev: intent (choice)\ncheck_balance / approve_transfer / other"]
    B --> C{confidence < 0.6?}
    C -->|sim| D[Escalar p/ atendimento humano]
    C -->|não| E{intent}
    E -->|check_balance| F[Mostrar saldo diretamente]
    E -->|approve_transfer| G{confidence}
    G -->|0.6 – 0.85| H[Pedir confirmação ao usuário]
    G -->|> 0.85| I[Processar automaticamente]
```

Fonte: [Confidence-Gated Routing](../sources/patterns-confidence-routing.md).

### 2.3 Composite Scoring

**Problema que resolve:** julgamentos complexos e multidimensionais (por exemplo, avaliar um currículo para uma vaga) não devem ser reduzidos a um único julgamento monolítico do modelo — isso torna o resultado opaco e impossível de recalibrar sem reprocessar tudo.

**Como funciona:** quebrar o julgamento em dimensões atômicas e independentes, pedir um `score` para cada uma, e combinar os scores com **pesos controlados em código** — não pelo modelo. Isso dá transparência total: se os melhores candidatos não fazem sentido, basta ajustar os pesos, sem perder a granularidade de cada dimensão ([Composite Scoring](../sources/patterns-composite-scoring.md)).

No exemplo de triagem de currículos para vagas de engenharia, quatro dimensões são avaliadas em paralelo (escala 0–4, depois normalizada para 0–1):

| Dimensão | Peso — Senior IC | Peso — Engineering Manager |
| --- | --- | --- |
| Profundidade em Python | 40% | 15% |
| Liderança de equipe | 10% | 40% |
| Design de sistemas | 40% | 20% |
| Capacidade generalista | 10% | 25% |

```mermaid
flowchart LR
    A[Currículo] --> B["Jev: 4 scores em paralelo\npython_depth\nteam_leadership\nsystem_design\ngeneralist"]
    B --> C[Normalizar cada score /4]
    C --> D{Perfil da vaga}
    D -->|Senior IC| E["score final = 0.4·python + 0.1·lideranca\n+ 0.4·design + 0.1·generalista"]
    D -->|Eng. Manager| F["score final = 0.15·python + 0.4·lideranca\n+ 0.2·design + 0.25·generalista"]
    E --> G[Ranking de candidatos]
    F --> G
```

Fonte: [Composite Scoring](../sources/patterns-composite-scoring.md).

### 2.4 Intent Routing

**Problema que resolve:** processar toda requisição por um handler caro (LLM generativa completa, ou humano) desperdiça custo e velocidade em casos que poderiam ser resolvidos de forma mais barata e determinística.

**Como funciona:** a Jev funciona como uma camada de classificação **antes** de qualquer handler — ela decide qual é a melhor forma de resolver a requisição: lógica determinística, uma LLM especialista, ou um humano. No exemplo de atendimento ao cliente, duas perguntas são avaliadas em paralelo: `intent` (choice: order status / dúvida de produto / troca-devolução / reclamação) e `complexity` (score) ([Intent Routing](../sources/patterns-intent-routing.md)).

Lógica de roteamento:
- Confiança de intenção abaixo de 0.5 → agente humano
- `order status` → consulta determinística ao banco de dados
- Dúvidas de produto / trocas → LLM especialista com contexto relevante
- Reclamações → score de complexidade + confiança decidem entre LLM ou humano

```mermaid
flowchart TD
    A[Mensagem do cliente] --> B["Jev: intent (choice) + complexity (score)"]
    B --> C{"confidence(intent) < 0.5?"}
    C -->|sim| D[Agente humano]
    C -->|não| E{intent}
    E -->|order_status| F[Consulta determinística ao BD]
    E -->|product_question / return| G[LLM especialista + contexto]
    E -->|complaint| H{complexity + confidence}
    H -->|baixa complexidade| I[LLM]
    H -->|alta complexidade| J[Humano]
```

Fonte: [Intent Routing](../sources/patterns-intent-routing.md).

### 2.5 System 2 calibra System 1 (loop de calibração) — padrão de comunidade

> **Evidência:** este padrão não está na documentação oficial. Vem de relatos em vídeo ([vídeo A](../sources-youtube/Jev%20_%20Claude%20Code_%20Architecting%20the%20Ultimate%20Low-Cost%20Agentic%20Coding%20Loop.md), [vídeo B](../sources-youtube/Jev_%20Revolutionizing%20Claude%20Code%20and%20Agentic%20Workflows%20with%20System%201%20AI.md)) e os exemplos abaixo são demos, não benchmarks. **[Reportado em vídeo]**

**Problema que resolve:** decisões contínuas ligadas a um `if` dependem de critérios, exemplos e thresholds que, no começo, são um palpite informado e depois envelhecem quando o contexto muda. Recalibrar à mão não escala, e pedir a um modelo lento para decidir cada item anula o motivo de usar a Jev.

**Como funciona:** dois laços com velocidades diferentes. No laço rápido (System 1), a Jev avalia cada evento com `noul`, `choice` ou `score`, o código aplica os thresholds e cada decisão é gravada junto com o resultado observado. No laço lento (System 2), periodicamente ou depois de um contratempo, um modelo generativo lê esse log, encontra os erros e reescreve `criteria`, exemplos e thresholds, que entram na próxima versão das perguntas. O vídeo B resume a recomendação prática no mesmo sentido: a melhor forma de usar a Jev hoje é combiná-la com um modelo de System 2. **[Reportado em vídeo]**

```mermaid
flowchart TD
    A[Evento ou estado atual] --> B["Jev avalia com noul choice score"]
    B --> C{Threshold no codigo}
    C -->|acima| D[Executa a acao]
    C -->|abaixo| E[Fila de revisao ou acao padrao]
    D --> F[Log de decisao e resultado]
    E --> F
    F --> G["Modelo System 2 revisa o log periodicamente"]
    G --> H["Reescreve criterios exemplos e thresholds"]
    H --> B
```

| Exemplo | System 2 (lento) | System 1 (Jev) | Evidência |
| --- | --- | --- | --- |
| Minecraft | GPT define a estratégia (abrigo antes da noite, mineração quando houver ferramentas e comida) e revisa a cada ~2 minutos ou após um revés como a morte do personagem; o jogo pausa enquanto ele avalia | Jev executa a tática (coletar madeira, craftar fornalha, fugir de creepers, trocar de tarefa conforme o estado); um controller executa a entrada física | **[Reportado em vídeo]** demo do vídeo A: o conjunto chegou ao Nether com uma picareta de diamante |
| Trading bot | Revisa periodicamente decisões e resultados e reescreve critérios, exemplos ou thresholds | `noul` simples enviado à API; `if` executa compra ou venda | **[Reportado em vídeo]** o próprio vídeo chama de exemplo ilustrativo; não é estratégia validada (ver a seção de trading do [catálogo de casos de uso](./01%20-%20Jev%20Use%20Cases.md)) |
| Rubricas de linter e de teste de UI | Avalia as detecções da Jev, refina as rubricas e escolhas e deixa a Jev rodar novas passadas | Jev roda as perguntas sobre código ou sobre o resultado do browser | **[Reportado em vídeo]** vídeo A |

No Minecraft, as entradas da Jev eram as metas intermediárias, o estado atual (vida, fome, hora do dia, progresso da mineração), o histórico recente de eventos e uma lista de múltipla escolha com as tarefas disponíveis, ou seja, uma pergunta `choice` sobre um `state` estruturado. **[Reportado em vídeo]**

Esqueleto ilustrativo do laço (não vem da documentação oficial; `strong_model_review` é um nome hipotético para a chamada ao modelo lento):

```python
# Laço rápido: decide e registra
answer = ts.system_one(state=event, questions=QUESTIONS, model=MODEL).answers["should_act"]
acted = answer.noul >= ACT_THRESHOLD
decision_log.append({"state": event, "noul": answer.noul, "acted": acted, "outcome": None})

# Laço lento: revisa o log e devolve novas versões de criterios e thresholds
new_config = strong_model_review(decision_log, QUESTIONS, ACT_THRESHOLD)
```

**Quando NÃO usar:**

- Sem um log de decisões e resultados, o System 2 não tem o que revisar. Guarde sempre o log.
- Quando o resultado só aparece muito depois, ou nunca, não há verdade observável para calibrar.
- Em decisões financeiras ou irreversíveis: recalibrar em produção sem validação é arriscado. O exemplo de trading é ilustrativo.
- Nunca promova critérios reescritos pelo modelo lento sem testá-los antes contra um conjunto de casos com resposta conhecida (golden dataset). Reescrever thresholds sem essa checagem pode piorar o sistema.

### 2.6 Reflex layer / cascata de screening — padrão de comunidade

> **Evidência:** aplicação de comunidade de estruturas que a documentação oficial já tem em outros contextos (cascata de custo e guardrails). Os números vêm do [vídeo A](../sources-youtube/Jev%20_%20Claude%20Code_%20Architecting%20the%20Ultimate%20Low-Cost%20Agentic%20Coding%20Loop.md) e são de demos, não de um benchmark controlado.

**Problema que resolve:** revisar tudo com um modelo frontier é caro e lento, seja um diff de PR, uma codebase inteira, um lote de comentários ou a saída de um agente. Quase todos os itens são irrelevantes; o custo está em olhar para todos com o modelo caro.

**Como funciona:** uma camada reflexo avalia cada item com dezenas ou centenas de micro-perguntas atômicas em paralelo, `noul` para invariantes e riscos e `score` para severidade ou força de verificação. O código agrega as respostas, aplica thresholds (como no [Confidence-Gated Routing](../sources/patterns-confidence-routing.md)) e só sobem para o modelo frontier ou para um humano os itens de maior severidade ou de `confidence` baixa. É a mesma estrutura de cascata de custo do cookbook [SDE Cascade](../sources/cookbook-sde-cascade.md) (modelo barato extrai, a Jev verifica campo a campo com `noul`, só os suspeitos escalam) e da triagem do cookbook [LLM Guardrails](../sources/cookbook-llm-guardrails.md) (uma chamada com vários `noul` de risco mais um `score` de severidade), aplicada aqui a revisão de código em vez de extração ou moderação. Para nomear as perguntas, vale reaproveitar a convenção `campo::risco` do SDE Cascade (`questions[f"{name}::hallucinated"]`), por exemplo `diff::weakened_test`. Isso é uma sugestão de uso, não parte do cookbook.

```mermaid
flowchart LR
    A["Diff, PR, codebase ou lote"] --> B["Jev: micro-perguntas em paralelo"]
    B --> C{Alguma sinalizada acima do threshold?}
    C -->|nao| D[Segue sem revisao cara]
    C -->|sim| E["Severidade em score"]
    E --> F{Severidade alta ou confidence baixa?}
    F -->|sim| G["Modelo frontier ou humano revisa"]
    F -->|nao| H[Registra como pista de baixa prioridade]
```

| Aplicação | Micro-perguntas | Dados reportados | Evidência |
| --- | --- | --- | --- |
| Qualidade de comentários | O comentário é preciso e útil? (`// multiply the value by two` é preciso mas redundante) | 150 comentários em 9,3 s por cerca de 1 centavo | **[Reportado em vídeo]** |
| Idem, codebase inteira | Mesmas perguntas | Custo estimado de 57 centavos e ~1.700 comentários candidatos a reescrita por agentes Haiku | **[Estimativa do apresentador]** |
| Linters qualitativos | O nome da função descreve tudo o que ela faz, incluindo efeitos colaterais? Que valor está sendo logado? (segredos ou dados financeiros viram erro, PII vira aviso) | Regras rodando a cada PR | **[Reportado em vídeo]** |
| Code smells | Código duplicado, código morto, números e strings mágicos | 28 milhões de tokens de input por US$ 1,19 | **[Reportado em vídeo]** |
| Review de PR | ~100 perguntas por diff, com os itens sinalizados repassados ao agente de código principal | Redução de ~10x nos tokens de review, estimada no próprio vídeo | perguntas: **[Reportado em vídeo]**; 10x: **[Estimativa do apresentador]** |
| Teste adversarial de UI | Sessões de browser em paralelo (Browser Use mais Jev) percorrem caminhos de borda e devolvem os erros ao modelo de código | Descrito como capacidade: dezenas de sessões, com o vídeo falando em centenas ou milhares por PR; nessa escala o custo de tokens fica desprezível e o gargalo vira o compute de sandbox | **[Reportado em vídeo]** sem benchmark |

Verificação do diff de um agente: a mesma chamada faz as perguntas em paralelo, e o código decide o que fazer com cada resposta.

| Pergunta (relatada no vídeo A) | Primitivo | Ação se sinalizada (sugestão de uso) |
| --- | --- | --- |
| O diff resolve a tarefa pedida? | `noul` | Devolver ao agente com o motivo |
| Algum teste foi enfraquecido? | `noul` | Bloquear e subir para revisão |
| Quão forte é a verificação feita? | `score` | Pedir mais verificação abaixo de um piso |
| Qual a superfície de risco da mudança? | `score` | Escalonar para modelo frontier ou humano nas faixas altas |

**Ressalvas obrigatórias:** os flags do screening são pistas para revisão, não veredito, e a probabilidade nunca deve ser o único gate de segurança. Um diff, um PR ou um comentário de código é conteúdo de terceiros dentro do `state`, e a própria documentação da TypeSafe lista a vulnerabilidade a conteúdo adversarial dentro do `state` entre as limitações conhecidas ([Jev 1.13 Jaggedness](../sources/model-jaggedness-jev-1-13.md)). Combine o screening com checagens determinísticas antes de qualquer ação sensível, e calibre os thresholds contra um golden dataset do seu projeto. **[Oficial]** para a limitação; a recomendação de combinar é nossa.

**Quando NÃO usar:**

- Com poucos itens, revisar direto com um modelo forte é mais simples e não justifica a camada extra.
- Quando o problema exige raciocínio de vários saltos ou análise entre arquivos: a Jev perde acurácia com múltiplos saltos de indireção (ver [Jev 1.13 Jaggedness](../sources/model-jaggedness-jev-1-13.md)); quebre em perguntas atômicas ou deixe para o modelo frontier.
- Quando um falso negativo é inaceitável e não há revisão a jusante: o screening reduz custo, não substitui o gate final.

## 3. Demos: padrões de uso real

A TypeSafe mantém uma seção de demos interativos ilustrando os padrões acima em aplicações completas ([Demos — índice](../sources/demos-index.md)).

### Smart Home Assistant Demo

O demo de assistente de casa inteligente é uma implementação viva do padrão **Speculative Fan-Out** combinado com fallback para uma LLM generativa. Para um pedido como *"Turn off all of the lights in the house"*, o sistema dispara em paralelo quatro perguntas — categoria do pedido, domínio-alvo, tipo de dispositivo e ação necessária — mesmo antes de confirmar quais são de fato relevantes; as respostas irrelevantes são descartadas depois, em código ([Smart Home Assistant Demo](../sources/demos-smart-home.md)).

O demo também evidencia dois refinamentos importantes sobre o padrão puro de fan-out:

- **Tratamento de pedidos compostos:** quando o sistema detecta múltiplas ações distintas num único pedido do usuário, uma LLM é usada para dividir o pedido em comandos individuais, que então são avaliados separadamente pela Jev.
- **Fallback conversacional:** para pedidos que são, na verdade, perguntas abertas de informação (não comandos), o sistema delega para uma LLM generativa — mantendo respostas determinísticas rápidas para comandos, mas preservando flexibilidade para o que não se encaixa no formato `choice`/`score`/`noul`.

Isso demonstra um ponto central da arquitetura de produção: a Jev **não substitui** LLMs generativas — ela atua como uma camada de decisão rápida e barata que resolve o caso comum determinísticamente, empurrando apenas os casos genuinamente abertos para um modelo mais caro.

O demo é implementado como uma aplicação Vite/React consumindo a API da TypeSafe.

## 4. Cookbooks

A TypeSafe documenta 18 cookbooks (receitas) que aplicam os primitivos e padrões acima a problemas concretos ([Cookbooks — índice](../sources/cookbook-index.md)).

| Cookbook | Problema que resolve | Primitivo(s) usado(s) | Ideia central |
| --- | --- | --- | --- |
| [Self-Consistency: Nouls](../sources/cookbook-consistency-noul.md) | Triagem de sinistros de seguro exige probabilidades confiáveis em decisões-limítrofes | `noul` | Rubrica de 14 perguntas repetida entre modelos; Jev tem variância muito menor (desvio-padrão médio 0.0102) que LLMs padrão, permitindo escalar só os casos realmente incertos (0.30–0.70) para revisão humana |
| [Self-Consistency: Choices](../sources/cookbook-consistency-choice.md) | Decisões de moderação de conteúdo "oscilam" entre chamadas repetidas ao mesmo post limítrofe | `choice` | Rubrica de 8 perguntas rodada 15x; com threshold de 0.60 a Jev atinge 99.2% de concordância de decisão, com 74.2% dos casos resolvidos automaticamente |
| [Parallel Questions](../sources/cookbook-parallel-questions.md) | Perguntas separadas sobre o mesmo documento multiplicam custo e latência | `noul`, `choice`, `score` | Agrupar todas as perguntas numa única chamada dá respostas idênticas às chamadas individuais, com 12.2x menos custo e 10x menos latência |
| [Re-ranking](../sources/cookbook-rerank.md) | Busca por palavra-chave (BM25) traz uma shortlist, mas a ordem de relevância real está errada | `noul` | BM25 filtra rápido para ~30 candidatos; Jev responde uma pergunta sim/não por par consulta-candidato, convertida em score 0–1 para reordenar — subiu top-1 accuracy de 5% para 18% |
| [Semantic Find](../sources/cookbook-semantic-find.md) | Buscar semanticamente dentro de um documento grande (até 255 linhas) e saber quando a resposta simplesmente não existe | `choice`, `noul` | Uma pergunta `choice` rankeia linhas por relevância; uma pergunta `noul` separada confirma se a resposta de fato existe no documento |
| [Autoformat (Structure Recovery)](../sources/cookbook-autoformat.md) | Texto colado perdeu formatação Markdown (quebras de linha erradas, sem cabeçalhos/listas) | `noul`, `choice` | Pipeline de 2 passagens: `noul` decide se linhas adjacentes devem ser unidas; `choice` classifica cada bloco final (título, parágrafo, lista, código, etc) |
| [Function Calling](../sources/cookbook-function-calling.md) | Converter linguagem natural em chamadas de função tipadas, com argumentos de conjunto fechado | `choice`, `noul` | Cada argumento vira uma pergunta com opções descritas em linguagem natural; a confiança reportada é a do argumento menos certo da chamada, não um produto de probabilidades |
| [Skill Suggestion](../sources/cookbook-skill-suggestion.md) | Agente com 182+ skills erra a seleção porque descrições truncadas parecem idênticas | `choice`, `noul` | Duas rodadas de progressive disclosure: `choice` amplo rankeia todas as skills e é filtrado por 3 `noul` de gate; top-3 são reavaliadas com descrição completa — reduz carregamentos errados de 16.8% para 7.3%. **Confirmação em vídeo:** o [vídeo A](../sources-youtube/Jev%20_%20Claude%20Code_%20Architecting%20the%20Ultimate%20Low-Cost%20Agentic%20Coding%20Loop.md) cita esse mesmo cookbook oficial (agente Hermes, 182 skills): erro de carregamento de 17% sem a Jev e 7.3% com as sugestões dela usando um modelo Haiku, além de ~10 mil tokens economizados por prompt **[Reportado em vídeo]**; o [vídeo B](../sources-youtube/Jev_%20Revolutionizing%20Claude%20Code%20and%20Agentic%20Workflows%20with%20System%201%20AI.md) mediu 145 skills do próprio workspace em 14 testes: Opus ~30 s contra Jev ~5 s **[Reportado em vídeo]** |
| [Entity Alignment](../sources/cookbook-entity-alignment.md) | Decidir se dois registros de fontes diferentes são o mesmo produto (merge, descartar, ou escalar) | `score`, `noul` | Um `score` de 3 níveis semânticos (diferente / relacionado / mesmo produto) resolve o julgamento principal; `noul`s por campo dão detalhe para curadoria humana |
| [Classifying RAG Passages](../sources/cookbook-classifying-rag-passages.md) | Passagens recuperadas num pipeline RAG trazem ruído, irrelevância ou contradição | `noul` | Estágio de classificação entre retrieval e geração: 4 perguntas `noul` (relevância, evidência utilizável, contradição, tentativa de prompt injection) decidem incluir, sinalizar como conflitante, ou excluir cada passagem |
| [Citation Check](../sources/cookbook-citation-check.md) | Verificar se citações geradas por LLM são reais e realmente suportam a afirmação feita | `choice` | Correspondência exata de string localiza a citação no texto-fonte; `choice` classifica a relação (supports / contradicts / says_nothing) — mapeada para verified / contradicted / unsupported / fabricated |
| [LLM Guardrails](../sources/cookbook-llm-guardrails.md) | Fronteiras de segurança de LLMs são inconsistentes entre modelos e vulneráveis a jailbreaks | `noul`, `score` | Uma única chamada avalia toda mensagem (entrada e saída): 4 `noul`s de risco (jailbreak, crime, conselho médico, automutilação) + 1 `score` de severidade (0–3); roteamento por thresholds configuráveis por política de produto |
| [SDE Cascade](../sources/cookbook-sde-cascade.md) | Extração estruturada de alta qualidade custa caro se sempre usar modelo forte de raciocínio | `noul` | Cascata de 3 estágios: modelo barato extrai → Jev verifica cada campo com `noul` de probabilidade de erro → só registros sinalizados escalam para modelo caro |
| [Date Extraction](../sources/cookbook-date-extraction.md) | Extrair e validar datas absolutas ("14 de agosto de 2027") e relativas ("próxima quinta") | `choice` | 7 perguntas `choice` por extração (modo, mês, dia, ano, âncora, dia da semana, deslocamento de semana); código resolve isso em data concreta + score de confiança |
| [Pre-parsed Value Extraction](../sources/cookbook-pre-parsed-value-extraction.md) | Extrair valores estruturados (e-mail, telefone, valores) sem risco de alucinação | `choice`, `noul` | Regex localiza candidatos primeiro; Jev só escolhe entre os spans encontrados pelo regex — o valor devolvido é sempre um span copiado, nunca inventado |
| [Hierarchical Classification](../sources/cookbook-hierarchical-classification.md) | Classificar documentos em taxonomias profundas (patentes, produtos, temas biomédicos) sem que um erro raso condene toda a árvore | `choice` | Beam search paralelo (K=3) usando média geométrica das probabilidades de aresta supera a seleção gulosa top-1 — 4/4 corretas vs. 2/4 nos testes |
| [Autoresearch Feature Discovery](../sources/cookbook-autoresearch-feature-discovery.md) | Converter texto não-estruturado (notas de degustação) em features numéricas para ML sem engenharia manual | `score`, `noul` | Loop iterativo: propõe perguntas → Jev responde numericamente → treina modelo supervisionado → usa os erros para refinar as perguntas; RMSE caiu de 2.15 para 1.77 em 5 rodadas |
| [Classification using Confidence](../sources/cookbook-classification-using-confidence.md) | Classificar relatórios em 75 categorias industriais sem forçar falsa precisão quando o modelo está incerto | `choice` | Confiança ≥ 0.9 → reporta a categoria específica; abaixo disso → reporta a categoria "pai", mais ampla — 80% de respostas úteis vs. 65% se sempre forçado ao nível mais específico |

### Aprofundando: 5 cookbooks representativos

**SDE Cascade** ilustra o padrão de **cascata de custo**: em vez de escolher entre um modelo barato (rápido, mas impreciso) e um modelo caro (preciso, mas lento/custoso) para *toda* extração, o cookbook usa o modelo barato para extrair e a Jev para **verificar cada campo extraído** com uma pergunta `noul` de probabilidade de alucinação — só os campos sinalizados escalam para o modelo caro. O schema de extração e a pergunta de verificação (reproduzidos da fonte):

```json
{
  "properties": {
    "registration_open_date": {
      "description": "Date in mm/dd/yyyy format",
      "type": "string"
    }
  },
  "required": ["registration_open_date"]
}
```

```python
questions[f"{name}::hallucinated"] = Noul(
    instructions={...},
    criteria=NoulCriteria(
        true="the value is unsupported by source text",
        false="the value is supported by source text"
    )
)
```

**Skill Suggestion** resolve um problema muito próximo do que este próprio agente vive todos os dias: escolher a skill certa entre uma lista enorme, quando descrições truncadas tornam opções indistinguíveis. A solução usa **duas rodadas de progressive disclosure** — a primeira faz um `choice` amplo sobre todas as skills, gateado por 3 perguntas `noul`; a segunda reavalia só o top-3 com descrição completa:

```python
def suggest(request: str) -> tuple[str, ...]:
    wide = rank_wide(request)
    if wide["gate"] < GATE_THRESHOLD:
        return ()
    shortlist = tuple(name for name, _ in wide["ranked"][:SHORTLIST])
    result = rerank(request, shortlist, EXCERPT_CHARS)
    if max(result["fits"].values()) < FITS_THRESHOLD:
        return ()
    return (result["winner"],)
```

**LLM Guardrails** aplica **Confidence-Gated Routing** (padrão da seção 2.2) à moderação de segurança: uma única chamada com 4 `noul`s de risco + 1 `score` de severidade decide se a mensagem passa, vai para revisão, é bloqueada, ou aciona suporte — com thresholds diferentes por política de produto:

```python
def guard(text: str, side: str, policy_name: str = DEFAULT_POLICY) -> str:
    """Screen a message and route it under a named application policy."""
    result = screen(text, side)
    return route(result["nouls"], result["severity"], POLICIES[policy_name])
```

**Hierarchical Classification** mostra que **Speculative Fan-Out** também se aplica dentro de uma árvore de decisão: em vez de escolher gulosamente (top-1) em cada nível da taxonomia, o cookbook avalia múltiplos caminhos em paralelo (beam search K=3), pontuando cada caminho pela média geométrica das probabilidades de aresta — o que corrige decisões ambíguas tomadas cedo demais. Resultado: 4/4 classificações corretas contra 2/4 do método guloso.

**Pre-parsed Value Extraction** combina regex determinístico com `choice` da Jev para eliminar alucinação por construção: o regex encontra os candidatos possíveis no texto, e a Jev **só pode escolher entre eles** — nunca inventa um valor novo:

```python
def pick(document: str, candidates: list[str], question: str) -> dict:
    criteria = {c: None for c in candidates} | {NONE: "None of these is the requested value."}
    answer = ts.system_one(
        state=document,
        questions={"pick": Choice(instructions=question, criteria=criteria)},
        model=TYPESAFE_MODEL,
    ).answers["pick"]
    return {"choice": answer.choice, "confidence": answer.confidence}
```

## 5. Referências

Todas as afirmações factuais acima foram fundamentadas nos seguintes documentos-fonte locais, ingeridos a partir da documentação oficial da TypeSafe:

- [Introducing System One Models & Jev](../sources/blog-introducing-system-one-and-jev.md)
- [Patterns — índice](../sources/patterns-index.md)
- [Speculative Fan-Out](../sources/patterns-fan-out.md)
- [Confidence-Gated Routing](../sources/patterns-confidence-routing.md)
- [Composite Scoring](../sources/patterns-composite-scoring.md)
- [Intent Routing](../sources/patterns-intent-routing.md)
- [Demos — índice](../sources/demos-index.md)
- [Smart Home Assistant Demo](../sources/demos-smart-home.md)
- [Cookbooks — índice](../sources/cookbook-index.md)
- [Self-Consistency: Nouls](../sources/cookbook-consistency-noul.md)
- [Self-Consistency: Choices](../sources/cookbook-consistency-choice.md)
- [Parallel Questions](../sources/cookbook-parallel-questions.md)
- [Re-ranking](../sources/cookbook-rerank.md)
- [Semantic Find](../sources/cookbook-semantic-find.md)
- [Autoformat (Structure Recovery)](../sources/cookbook-autoformat.md)
- [Function Calling](../sources/cookbook-function-calling.md)
- [Skill Suggestion](../sources/cookbook-skill-suggestion.md)
- [Entity Alignment](../sources/cookbook-entity-alignment.md)
- [Classifying RAG Passages](../sources/cookbook-classifying-rag-passages.md)
- [Citation Check](../sources/cookbook-citation-check.md)
- [LLM Guardrails](../sources/cookbook-llm-guardrails.md)
- [SDE Cascade](../sources/cookbook-sde-cascade.md)
- [Date Extraction](../sources/cookbook-date-extraction.md)
- [Pre-parsed Value Extraction](../sources/cookbook-pre-parsed-value-extraction.md)
- [Hierarchical Classification](../sources/cookbook-hierarchical-classification.md)
- [Autoresearch Feature Discovery](../sources/cookbook-autoresearch-feature-discovery.md)
- [Classification using Confidence](../sources/cookbook-classification-using-confidence.md)
- [Jev 1.13 Jaggedness](../sources/model-jaggedness-jev-1-13.md) (limitações conhecidas, citada nas seções 2.5 e 2.6)

Fontes de comunidade (não oficiais), usadas apenas nas seções 2.5 e 2.6 e na nota de Skill Suggestion:

- [Jev + Claude Code: Architecting the Ultimate Low-Cost Agentic Coding Loop](../sources-youtube/Jev%20_%20Claude%20Code_%20Architecting%20the%20Ultimate%20Low-Cost%20Agentic%20Coding%20Loop.md) (vídeo A)
- [Jev: Revolutionizing Claude Code and Agentic Workflows with System 1 AI](../sources-youtube/Jev_%20Revolutionizing%20Claude%20Code%20and%20Agentic%20Workflows%20with%20System%201%20AI.md) (vídeo B)

**Nota de honestidade:** todas as 26 URLs solicitadas (7 da Parte A + 19 da Parte B) foram acessadas com sucesso via WebFetch e ingeridas como documentos-fonte locais antes de serem citadas aqui. Nenhuma página retornou 404 ou vazio. Os cookbooks da Parte B foram capturados em versão resumida (título, problema, primitivo(s), ideia central e trecho de código/schema), conforme instruído, para não estourar o orçamento de contexto — não como texto integral verbatim.
