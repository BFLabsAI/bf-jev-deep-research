---
title: Jev — Fundamentos da TypeSafe AI
description: Quem é a TypeSafe AI, a família de modelos Jev, primeiros passos práticos, integração com agentes de código, agent skill e notas legais.
tags:
  - Jev
  - TypeSafe AI
  - Quickstart
  - Coding Agents
  - Agent Skill
  - Fundamentals
---
# Jev — Fundamentos da TypeSafe AI

Este documento cobre os fundamentos práticos e institucionais da Jev: quem é a TypeSafe AI como empresa, a família de modelos, como começar a usar na prática, como integrar em agentes de código, o conceito de "agent skill" e o essencial sobre termos legais.

> Nota de fontes: as páginas web abaixo foram coletadas via fetch em 22/09/2026 e os documentos-fonte locais (seção de Referências) foram atualizados para conter o texto verbatim das páginas originais (incluindo links, tabelas e blocos de código). As afirmações abaixo citam diretamente esse conteúdo.

## 1. Quem é a TypeSafe AI

### Manifesto e missão

A TypeSafe AI descreve sua missão como tornar "a inteligência composável para catalisar uma explosão Cambriana de software inteligente" ([Manifesto](../sources/site-manifesto.md)). A tese central da empresa é que a inteligência geral já existe nos modelos atuais — o gargalo está na implementação, não na capacidade ([Manifesto](../sources/site-manifesto.md)).

O manifesto usa a analogia da "carruagem sem cavalo" (*horseless carriage*): os primeiros automóveis imitavam carruagens puxadas por cavalos ao invés de reimaginar o transporte desde os fundamentos. Da mesma forma, segundo a empresa, a IA atual é projetada como um "assistente prestativo, articulado e agradável", o que pressupõe envolvimento humano ao invés de operação autônoma de software ([Manifesto](../sources/site-manifesto.md)).

A visão da empresa é tornar a IA "um primitivo que qualquer programador pode invocar para julgamento semântico e decisões", operando ao lado do código tradicional — comparando isso a como bancos de dados se tornaram infraestrutura confiável (o Google foi construído sobre bancos de dados; a Stripe emergiu de protocolos de internet) ([Manifesto](../sources/site-manifesto.md)).

Sobre segurança, a tese é que ela é o que permite o empilhamento (*layering*): componentes confiáveis podem rodar sem supervisão, e podem ser aninhados profundamente dentro de sistemas maiores, permitindo que "primitivos pequenos e legíveis evoluam com segurança para sistemas complexos e confiáveis" ([Manifesto](../sources/site-manifesto.md)).

O plano declarado em três passos é:

1. Entregar IA composável nativa de máquina com máxima eficiência de inteligência por dólar.
2. Construir confiabilidade suficiente para transformação econômica via automação.
3. Criar abstrações de inteligência estáveis e empilháveis que permitam emergência colaborativa.

A frase de encerramento do manifesto resume a postura da empresa: "We're building prod, not God" — "Estamos construindo produção, não Deus" ([Manifesto](../sources/site-manifesto.md)).

### Time fundador e contexto histórico

A liderança da TypeSafe AI é composta por três cofundadores ([Team](../sources/site-team.md)):

- **Diogo Almeida — CEO.** "Diogo co-invented RLHF and InstructGPT, the methods that lead to ChatGPT and GPT4. Previously, he was at Google Brain." ([Team](../sources/site-team.md)) Isso conecta diretamente a origem da TypeSafe à arquitetura de alinhamento por trás do ChatGPT.
- **Sasha Sheng — COO.** "Ex-research engineer from Meta/FAIR where she worked on the News Feed, AI Experiences, and AI Research. An avid builder, she has organized many hackathons and published work at NeurIPS and ECCV." ([Team](../sources/site-team.md))
- **Erik Gafni — CTO.** "Repeat founder (Ravel, multi-modal AI for dna-sequencing), an early employee at two unicorns (Invitae and Freenome), and an inventor with numerous publications and patents. He specializes in building production AI systems." ([Team](../sources/site-team.md))

A equipe descreve a si mesma como "a close-knit, flat team from OpenAI, Google Brain, Meta/FAIR, Stripe, Airbnb, Plaid, Docker, and more", trabalhando presencialmente cinco dias por semana no escritório em San Francisco (perto da estação Embarcadero), com salários competitivos, equity e benefícios ([Team](../sources/site-team.md)). Os valores declarados da empresa incluem "Positive-Sum Games with Long-Term People", "Thinking in Bets", "First Principles", "Prioritize Learning", "Passion" e "A working environment built for human beings" ([Team](../sources/site-team.md)), e a empresa está ativamente contratando para posições em aberto (https://jobs.ashbyhq.com/typesafe-ai).

Tanto a página do Manifesto quanto a página do Time trazem, no menu de navegação do site institucional (typesafe.ai), um botão **"Join Waitlist"** ao lado dos links para "Manifesto" e "Our Team" ([Manifesto](../sources/site-manifesto.md); [Team](../sources/site-team.md)). Isso confirma a existência de uma waitlist como ponto de entrada divulgado no site institucional — ver nota na seção 3.5 e a tabela da seção 7.

## 2. Visão geral da família de modelos

Segundo a página de modelos, a Jev é a oferta principal da TypeSafe e representa o primeiro System One Model. Todos os modelos usam o mesmo endpoint (`POST /v1/systemone`), sendo o campo `model` que determina qual modelo processa a requisição ([Models](../sources/models.md)).

| Item | Especificação |
| --- | --- |
| Modelo atual | Jev 1.13 (`jev-1.13.0`) |
| Preço | $42 por bilhão de tokens de input ($0,042 / milhão) — output gratuito |
| Rate limits | 250.000 tokens/segundo; 1.200 requisições/minuto (ajustando dinamicamente por alta demanda) |
| Janela de contexto | 64k tokens por requisição; 32k para `state` + a maior pergunta |
| Tipos de input | Somente texto (strings, objetos JSON, ou arrays de texto) |

Aliases de modelo, ambos apontando hoje para `jev-1.13.0` ([Models](../sources/models.md)):

| Alias | Finalidade |
| --- | --- |
| `jev-latest` | Release estável mais recente; padrão nos SDKs |
| `jev-preview` | Build mais recente (atualmente idêntico ao latest) |

As aliases mudam a cada novo release — a documentação recomenda fixar a versão específica (`jev-1.13.0`) se você já calibrou thresholds de confiança em produção ([Models](../sources/models.md)).

Os rate limits estão "adjusting dynamically" enquanto a TypeSafe atende um grande volume de demanda (inclusive por conta de futuros acordos de GPU); limites mais altos estão disponíveis em planos custom e enterprise mediante contato com `sales@typesafe.ai` ([Models](../sources/models.md)).

Ao invés de fine-tuning por conta, a Jev se adapta através da estrutura da própria requisição: conteúdo de domínio vai em `state`, regras de negócio em `instructions` e `criteria`, e julgamentos complexos são decompostos em múltiplas perguntas atômicas ([Models](../sources/models.md)). O inglês recebe otimização primária; outros idiomas (incluindo CJK) são suportados mas com desempenho menos confiável, sendo recomendado testar antes de confiar em produção ([Models](../sources/models.md)). Requisições de clientes não são usadas para treinamento do modelo ([Models](../sources/models.md); ver também a seção 6 sobre termos legais).

O endpoint `GET /v1/models` lista os modelos disponíveis com descrições e datas de lançamento, acessível via cURL, Python ou SDKs JavaScript ([Models](../sources/models.md)).

## 3. Primeiros passos práticos (Quickstart)

A documentação de introdução descreve a Jev como um modelo "construído para tomar decisões rápidas e estruturadas que o software pode usar diretamente" ([Introduction](../sources/introduction.md)), organizando as respostas em três primitivos:

| Tipo de pergunta | Objetivo | Retorna |
| --- | --- | --- |
| Choice | Choose an option from a list | `choice`, `probabilities`, `confidence` |
| Score | Score the state on a rubric | `score`, `probabilities`, `confidence` |
| Noul | Is this statement true? | `noul` (0–1) |

([Introduction](../sources/introduction.md)) Os três tipos podem ser combinados numa única chamada de API; cada pergunta é avaliada em paralelo e isoladamente contra o mesmo `state`, então adicionar perguntas quase não muda o tempo de resposta e não gera "context-rot" ([Introduction](../sources/introduction.md)).

A documentação de introdução também recomenda perguntas atômicas: cada pergunta deve ser um "gut-check" bem definido, do tipo julgamento que uma pessoa muito conhecedora do assunto conseguiria fazer em poucos segundos com o contexto certo. Julgamentos compostos devem ser decompostos em perguntas separadas e combinados por lógica no seu código (o exemplo da documentação: em vez de "avalie este pitch de startup", perguntar separadamente sobre tamanho de mercado, viabilidade técnica e diferenciação, e combinar os scores com sua própria fórmula) ([Introduction](../sources/introduction.md)).

O Quick Start apresenta quatro caminhos para começar, todos demonstrando o mesmo caso de uso: analisar um ticket de suporte quanto a urgência, departamento de roteamento e nível de frustração do cliente ([Quickstart](../sources/introduction-quickstart.md)).

### 3.1 Playground

É possível testar o sistema imediatamente fazendo login no Playground e enviando texto (`state`) junto com perguntas dos três tipos (Noul, Choice, Score) ([Quickstart](../sources/introduction-quickstart.md)).

### 3.2 API REST (autenticação e chamada direta)

O serviço oferece endpoints REST em:

```
https://api.typesafe.ai/v1/systemone
```

Para desenvolver é preciso primeiro obter uma **API key no dashboard** (https://console.typesafe.ai/keys), e então fazer requisições `POST` com um corpo JSON contendo os dados de estado (`state`) e as perguntas (`questions`) ([Quickstart](../sources/introduction-quickstart.md)):

```bash
curl -X POST https://api.typesafe.ai/v1/systemone \
  -H "Authorization: Bearer $TYPESAFE_API_KEY" \
  -H "Content-Type: application/json" \
  -d @- <<'EOF'
{
  "state": "Hi, I've been trying to connect my Stripe account for 3 days and the integration keeps failing. I'm losing sales. Please help ASAP.",
  "model": "jev-latest",
  "questions": {
    "urgency": {
      "type": "noul",
      "instructions": "Does this message express urgency?"
    }
  }
}
EOF
```

A resposta traz o campo `model` (a versão exata que respondeu, ex. `jev-1.13.0`), um objeto `answers` com uma entrada por pergunta (incluindo `choice`/`probabilities`/`confidence` para Choice, `score`/`legend`/`probabilities`/`confidence` para Score, e `noul` para Noul) e um objeto `usage` com `input_tokens`/`output_tokens` ([Quickstart](../sources/introduction-quickstart.md)).

### 3.3 SDK Python

Desenvolvedores podem instalar o pacote `typesafe-sdk`:

```bash
pip install typesafe-sdk
# ou
uv add typesafe-sdk
```

Requer Python 3.10+. O SDK usa automaticamente a variável de ambiente `TYPESAFE_API_KEY` para autenticação e usa por padrão o modelo `jev-latest`, simplificando a implementação em relação a chamadas de API cruas ([Quickstart](../sources/introduction-quickstart.md)):

```bash
export TYPESAFE_API_KEY="sua-chave-aqui"
```

### 3.4 Integração via agente (Agent Integration)

A skill da TypeSafe pode ser instalada no Claude Code ou em outros agentes via comandos de plugin marketplace ou via `npx`, permitindo que agentes de código aproveitem as capacidades da TypeSafe ao construir aplicações que precisam avaliar documentos em múltiplas dimensões ([Quickstart](../sources/introduction-quickstart.md); ver seção 5 abaixo para detalhes de instalação).

### 3.5 Waitlist / Vercel AI Gateway / OpenRouter

As páginas de introdução, quickstart, models, coding-agents, agent-skill e legal não descrevem waitlist nem gateways como caminhos de acesso à API. Já o site institucional confirma a waitlist: tanto a página do Manifesto quanto a do Time exibem um botão **"Join Waitlist"** no menu de navegação ([Manifesto](../sources/site-manifesto.md); [Team](../sources/site-team.md)) — ou seja, existe uma waitlist divulgada publicamente, mas nenhuma fonte coletada descreve o que ela dá acesso a (conta na plataforma? modelo específico? tier enterprise?) nem como ela se relaciona com o fluxo de dashboard + API key do Quickstart. Quanto a gateways, o guia de uso do SDK Python documenta que o SDK funciona com APIs alternativas como OpenRouter e Vercel AI Gateway, desde que sigam a especificação OpenAPI da TypeSafe, apontando o cliente para elas com o parâmetro `base_url`; o exemplo oficial usa OpenRouter com `base_url="https://openrouter.ai/api"` e `model="~typesafe/jev-latest"` ([Python SDK — Usage Guide](../sources/sdk-python-usage.md)). A documentação consultada não detalha preço, limites ou disponibilidade por esses gateways.

## 4. Integração com agentes de código (coding agents)

A documentação é enfática: a Jev **não é** um substituto para os modelos que alimentam agentes de código como Claude Code ou Cursor. Ela não gera texto, não escreve código e não conduz conversas — funciona como um "System One model" que processa entradas estruturadas e retorna saídas tipadas ([Coding Agents](../sources/introduction-coding-agents.md)).

O sistema aceita um `state` e perguntas tipadas, devolvendo:

> "A `choice` from a list of options, with per-option probabilities. A `score` on a rubric you define. A `noul` (0–1) for a true/false statement." ([Coding Agents](../sources/introduction-coding-agents.md))

A recomendação de uso é dentro de aplicações, para tarefas específicas como: roteamento de requisições, pontuação de conteúdo contra uma rubrica, validação de afirmações, ou substituição de prompts frágeis de extração de JSON ([Coding Agents](../sources/introduction-coding-agents.md)).

Para times que já usam um coding agent (Claude Code, Codex, etc.) no dia a dia, a orientação prática é: **use seu agente de código normalmente para escrever software, e chame a Jev separadamente, de dentro da aplicação, para as decisões estruturadas** ([Coding Agents](../sources/introduction-coding-agents.md)). Para começar essa integração, a página sugere instalar a agent skill da TypeSafe, ou explorar o Quick Start, a documentação de patterns e o playground ([Coding Agents](../sources/introduction-coding-agents.md)).

## 5. O conceito de "agent skill"

A TypeSafe distribui uma **agent skill** — descrita como uma "skill plug-and-play para Claude Code, Codex e outros ambientes de agente" — que equipa agentes de código de IA com conhecimento abrangente sobre a API da TypeSafe, para que o próprio agente (não só o humano) saiba usar a Jev corretamente ([Agent Skill](../sources/agent-skill.md)).

### Métodos de instalação

Três caminhos são oferecidos ([Agent Skill](../sources/agent-skill.md)):

1. **Claude Code** — configuração em duas etapas via marketplace de plugins.
2. **Outros agentes** — instalação baseada em NPM com seleção de agente.
3. **Manual** — cópia direta do repositório GitHub.

A documentação recomenda escolher apenas um método por vez, para "evitar cópias duplicadas" ([Agent Skill](../sources/agent-skill.md)).

### Primeiros prompts recomendados

Depois de instalada, a skill sugere três abordagens de uso inicial ([Agent Skill](../sources/agent-skill.md)):

- **Exploração** — pedir ao agente para identificar onde a TypeSafe poderia resolver padrões de código frágeis (ex.: prompts de extração de JSON que quebram com frequência).
- **Experimentação** — rodar queries de teste usando uma API key para validar abordagens antes de integrar em produção.
- **Pattern Matching** — referenciar cookbooks específicos da documentação para refatorar código existente.

### Princípio de desenvolvimento colaborativo

A documentação enfatiza que perguntas e thresholds (limiares de confiança) devem ficar centralizados e visíveis: "Put the constants (questions and thresholds) in a single place so they're easy to review. Agents aren't great at writing questions, so expect to edit collaboratively with them." ([Agent Skill](../sources/agent-skill.md)) — ou seja, o agente pode rascunhar as perguntas feitas à Jev, mas um humano deve revisá-las e refiná-las colaborativamente, já que agentes não são especialmente bons em escrever boas perguntas atômicas por conta própria.

### Troubleshooting

Problemas comuns citados incluem skills inativas, problemas de roteamento e versões desatualizadas da skill instalada. A recomendação central de revisão humana é: "The most important thing for humans to review is the questions and any threshold constants used in your TypeSafe code." ([Agent Skill](../sources/agent-skill.md))

## 6. Nota breve sobre termos legais

Antes de usar a Jev em produção, um desenvolvedor deve saber que a TypeSafe disponibiliza três documentos legais principais ([Legal](../sources/legal.md)):

- **Data Processing Agreement (DPA)** — como a TypeSafe processa dados do cliente em seu nome, incluindo retenção de dados.
- **Master Customer Agreement** — os termos gerais que se aplicam à conta TypeSafe.
- **Privacy Policy** — quais dados são coletados e como são usados, incluindo o compromisso de **não treinar modelos com dados de usuários**.

O ponto mais relevante para decisão de adoção em produção: a empresa afirma explicitamente que **não utiliza informações de clientes para treinar seus modelos de IA** ([Legal](../sources/legal.md); reforçado também em [Models](../sources/models.md)). Clientes enterprise podem ainda solicitar arranjos de **retenção zero de dados** (zero data retention) entrando em contato com `privacy@typesafe.ai` ([Legal](../sources/legal.md)).

## 7. Canais de acesso

O canal de acesso completamente documentado nas fontes técnicas é o direto (dashboard + API key / Playground / SDK). O site institucional confirma também a existência de uma waitlist (botão "Join Waitlist" no menu), mas sem detalhar seu funcionamento. A documentação do SDK Python descreve ainda o uso de gateways alternativos (OpenRouter e Vercel AI Gateway) via `base_url`.

| Canal | Como funciona | Prós | Contras |
| --- | --- | --- | --- |
| Acesso direto (dashboard + API key) | Login no dashboard da TypeSafe, geração de API key, chamadas diretas a `https://api.typesafe.ai/v1/systemone` ou via `typesafe-sdk` ([Quickstart](../sources/introduction-quickstart.md)) | Controle total sobre `state`/`questions`; acesso ao Playground para prototipagem rápida | Requer gerenciar a própria chave e billing diretamente com a TypeSafe |
| Playground | Interface web para enviar `state` + perguntas sem escrever código, em https://console.typesafe.ai/playground ([Quickstart](../sources/introduction-quickstart.md)) | Zero setup, ótimo para validar perguntas antes de integrar | Não serve para uso em produção |
| Waitlist (site institucional) | Botão "Join Waitlist" no menu de navegação de typesafe.ai ([Manifesto](../sources/site-manifesto.md); [Team](../sources/site-team.md)) | Confirma que existe um funil de entrada divulgado publicamente além do dashboard | O que a waitlist libera (conta, tier, modelo específico) não é descrito em nenhuma fonte coletada — não confirmado |
| Vercel AI Gateway | Citado na doc do SDK Python como API alternativa compatível, usada com o parâmetro `base_url` ([Python SDK — Usage Guide](../sources/sdk-python-usage.md)) | Permite usar o SDK da TypeSafe por um gateway já adotado | A doc consultada não detalha preço, limites ou disponibilidade por esse caminho |
| OpenRouter | Exemplo oficial na doc do SDK Python: `base_url="https://openrouter.ai/api"` com `model="~typesafe/jev-latest"` ([Python SDK — Usage Guide](../sources/sdk-python-usage.md)) | Permite usar o SDK da TypeSafe por um gateway já adotado | A doc consultada não detalha preço, limites ou disponibilidade por esse caminho |

## 8. Referências

- [Introduction — TypeSafe Docs](../sources/introduction.md)
- [Quickstart — TypeSafe Docs](../sources/introduction-quickstart.md)
- [Jev with Coding Agents — TypeSafe Docs](../sources/introduction-coding-agents.md)
- [Agent Skill — TypeSafe Docs](../sources/agent-skill.md)
- [Legal — TypeSafe Docs](../sources/legal.md)
- [Manifesto — TypeSafe AI Website](../sources/site-manifesto.md)
- [Team — TypeSafe AI Website](../sources/site-team.md)
- [Models — TypeSafe Docs](../sources/models.md)
