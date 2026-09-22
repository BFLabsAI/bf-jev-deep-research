# bf-jev-deep-research

Estudo aprofundado sobre a **Jev**, o primeiro "System One Model" da [TypeSafe AI](https://typesafe.ai) — empacotado como (1) uma **skill de agente** pronta para uso e (2) o **estudo bruto completo** que a sustenta, com todas as fontes verbatim e citações.

Isso não é um resumo de segunda mão. É o resultado de um processo de pesquisa em duas fases — mineração de 8 vídeos do YouTube sobre casos de uso reais + ingestão verbatim de toda a documentação oficial da TypeSafe AI — orquestrado por uma frota de subagentes de IA, com cada afirmação rastreável até a fonte original.

---

## Instalação

Existem dois modos de instalação. Nos dois, o instalador copia o pacote completo (skill + estudo bruto) para uma pasta `bf-jev-deep-research/` e ativa a skill no local onde seu agente (Claude Code, Cursor, Codex, etc.) vai encontrá-la — a diferença é só **onde** essa base fica:

| Modo | Onde fica `bf-jev-deep-research/` | Onde fica a skill ativa | Quando usar |
|---|---|---|---|
| **Por projeto** (padrão) | Na raiz do projeto atual | `<projeto>/agents/skills/` ou `<projeto>/.claude/skills/` | Estudo específico deste projeto, ou você quer poder versionar/compartilhar tudo junto no git do projeto. |
| **Global** (`--global` / `-Global`) | Em `$HOME/bf-jev-deep-research/` (uma vez só) | `$HOME/agents/skills/` ou `$HOME/.claude/skills/` | Skill disponível em **qualquer projeto seu** nesta máquina, sem reinstalar por projeto. |

**macOS / Linux / Git Bash / WSL — por projeto** (rode de dentro da pasta do projeto):

```bash
curl -fsSL https://raw.githubusercontent.com/BFLabsAI/bf-jev-deep-research/main/scripts/setup-bf-jev-deep-research.sh | bash
```

**macOS / Linux / Git Bash / WSL — global:**

```bash
curl -fsSL https://raw.githubusercontent.com/BFLabsAI/bf-jev-deep-research/main/scripts/setup-bf-jev-deep-research.sh | bash -s -- --global
```

**Windows (PowerShell nativo) — por projeto** (rode de dentro da pasta do projeto):

```powershell
iwr -useb https://raw.githubusercontent.com/BFLabsAI/bf-jev-deep-research/main/scripts/setup-bf-jev-deep-research.ps1 | iex
```

**Windows (PowerShell nativo) — global:**

```powershell
$script = iwr -useb https://raw.githubusercontent.com/BFLabsAI/bf-jev-deep-research/main/scripts/setup-bf-jev-deep-research.ps1
Invoke-Expression "& { $($script.Content) } -Global"
```

Pré-requisito nos três SOs: `git` no PATH (o instalador clona o pacote em vez de baixar um zip, para poder reinstalar/atualizar com o mesmo comando).

Para reinstalar ou atualizar, rode o mesmo comando de novo (com `--global`/`-Global` se foi assim que instalou da primeira vez). **Reinstalar não destrói nada silenciosamente**: se já existir uma instalação anterior (do pacote ou da skill), ela é renomeada para `<nome>.backup-<timestamp>` antes da nova cópia entrar — então se você tiver editado a skill instalada manualmente, essa edição fica preservada no backup. Só o backup mais recente é mantido; reinstalar de novo apaga o backup anterior (não é um histórico completo, é uma rede de segurança de uma reinstalação).

### O que o instalador decide por você, dentro da base escolhida (projeto ou `$HOME`)

| Situação na base | O que acontece |
|---|---|
| Não existe `agents/skills/` nem `.claude/skills/` | Cria `.claude/skills/jev-typesafe-expert/` com a skill. |
| Só existe `.claude/skills/` | Instala direto ali. |
| Existe `agents/skills/` (convenção de pasta de skills compartilhada entre múltiplos harnesses) | Instala a skill em `agents/skills/jev-typesafe-expert/` e cria um **link simbólico** (`symlink` no Mac/Linux, **junction** no Windows — junction não exige admin nem "Modo de desenvolvedor" ativado) em `.claude/skills/jev-typesafe-expert/` apontando para lá, evitando duplicar arquivos entre harnesses. |

Por que isso é decidido pelo instalador e não pela skill em si: a skill instalada referencia o estudo bruto em `bf-jev-deep-research/study/` usando um caminho relativo — e essa conta de "quantos níveis subir" só é constante porque skill e estudo sempre compartilham a mesma base (a raiz do projeto, ou `$HOME`). O instalador conhece essa base no momento da instalação e grava o caminho já correto; a skill nunca precisa "adivinhar" onde ela está.

---

## Estrutura do repositório

```
bf-jev-deep-research/
├── README.md                          # este arquivo
├── scripts/
│   ├── setup-bf-jev-deep-research.sh  # instalador Mac/Linux/Git-Bash/WSL
│   └── setup-bf-jev-deep-research.ps1 # instalador Windows nativo
├── skill/                             # a skill em si (formato SKILL.md)
│   ├── SKILL.md
│   └── references/
│       ├── primitives.md              # schemas completos de choice/score/noul/state
│       ├── patterns.md                # os 4 padrões de composição + cookbooks
│       ├── sdk-quickref.md            # cheat sheet dos SDKs Python/JS
│       └── pitfalls.md                # armadilhas conhecidas, com casos reais
└── study/                             # o estudo bruto completo (fonte de verdade)
    ├── curated/                       # 7 documentos de síntese, em português
    │   ├── 01 - Jev Use Cases.md
    │   ├── 02 - Jev Model Thesis.md
    │   ├── 03 - Jev State and Primitives.md
    │   ├── 04 - Jev Typesafe Foundations.md
    │   ├── 05 - Jev Patterns.md
    │   ├── 06 - Jev client Sdk's Overview.md
    │   └── 07 - Jev API Reference Overview.md
    ├── sources-youtube/                # 8 transcrições brutas (YouTube), fase 1
    └── sources/                        # ~60 páginas oficiais da TypeSafe AI, verbatim, fase 2
```

---

## O conceito do estudo

A Jev é um modelo de IA fundamentalmente diferente de um LLM generativo: em vez de gerar texto token a token, ela recebe um `state` (contexto) e um schema de perguntas estruturadas (`choice`, `score` ou `noul`) e devolve decisões tipadas com probabilidade calibrada — em 70–500ms, a uma fração do custo de um LLM frontier. A tese da TypeSafe AI é que boa parte do "trabalho" que hoje forçamos LLMs caros a fazer (classificar, rotear, pontuar, extrair, decidir sim/não) é na verdade um problema de **decisão rápida sob incerteza**, não de geração de linguagem — e que separar essas duas coisas é uma mudança estrutural na forma de construir automação com IA.

Este repositório nasceu de uma pergunta prática: *"o que exatamente dá para fazer com isso, e como faço direito?"* — e virou um estudo em duas camadas:

1. **O que a comunidade já está construindo** (`study/sources-youtube/` + `study/curated/01 - Jev Use Cases.md`): 8 vídeos analisando implementações reais — roteamento de e-mail, triagem de suporte, scoring de leads, automação de browser, compactação de contexto de agentes, linters semânticos, trading, etc. — categorizados em 7 domínios, com números e citações, não só a lista de features do fabricante.
2. **O que a TypeSafe AI realmente documenta** (`study/sources/` + `study/curated/02` a `07`): a tese oficial por trás do modelo (RLCD, System 1 vs. System 2), os primitivos técnicos (`choice`/`score`/`noul`/`state`), os padrões de composição recomendados, os SDKs e a referência de API — tudo isso extraído **verbatim** da documentação oficial (docs.typesafe.ai) e do blog de lançamento, não parafraseado de memória.

---

## A técnica: como esse material foi extraído e categorizado

O processo não foi "peça para um LLM resumir 8 vídeos e a doc oficial". Foi um pipeline de várias etapas, cada uma desenhada para um problema específico de fidelidade:

### Fase 1 — Categorização de casos de uso reais (a partir de transcrições)

1. Leitura completa das 8 transcrições de YouTube (não resumos — o texto inteiro).
2. Uma **frota de 8 subagentes rodando em paralelo**, cada um responsável por **uma categoria de domínio** (triagem de comunicação, vendas/leads, automação de browser, roteamento de modelo, gerência de contexto de agentes, SEO/conteúdo, mídia social/BI, ferramentas de dev/experimental) — cada agente lia as mesmas 8 transcrições já carregadas em contexto e extraía **só** os casos de uso do seu domínio, deduplicando menções repetidas entre vídeos e citando a fonte exata de cada um.
3. Consolidação manual das 8 seções num catálogo único (`01 - Jev Use Cases.md`), auditado para links quebrados.

O motivo de paralelizar por *categoria* (não por vídeo) é simples: um caso de uso como "roteamento de e-mail" aparece picado em pedaços em 4 vídeos diferentes — juntar por categoria produz uma seção coerente e sem repetição; juntar por vídeo produziria 8 listas redundantes.

### Fase 2 — Ingestão verbatim da documentação oficial

1. Descoberta da árvore completa da documentação via `docs.typesafe.ai/llms.txt` (~90 páginas).
2. Seleção das páginas relevantes por documento-alvo (thesis, primitives, foundations, patterns, SDKs, API reference) e **uma frota de 6 subagentes, cada um dono de exatamente um documento final** — para evitar o problema clássico de múltiplos agentes escrevendo no mesmo arquivo ao mesmo tempo. Cada agente buscava suas páginas, salvava o conteúdo bruto como fonte local citável (regra de *grounding*: nenhuma afirmação sem uma fonte que existe dentro do próprio repositório, nunca uma URL solta) e só então escrevia o documento de síntese, sempre em português.
3. **Correção de fidelidade**: o primeiro fetcher usado (`WebFetch`) se recusa, por política própria, a reproduzir certas páginas *verbatim* — ele devolve uma reconstrução parafraseada. Isso foi detectado, sinalizado explicitamente nos documentos afetados, e depois corrigido: um segundo fetcher (via `tavily`) foi usado para buscar o conteúdo real das ~17 páginas afetadas, e uma segunda rodada de subagentes comparou a versão parafraseada com a verbatim, corrigindo imprecisões factuais reais que a paráfrase tinha introduzido (nomes, contagens, exemplos de código aproximados em vez de reais) — documentado com exemplos concretos em cada documento afetado.
4. Auditoria final de integridade de link em todo o corpus (0 erros).

O ponto central da Fase 2 não é só "buscar a documentação" — é que **paráfrase automática de LLM introduz erros sutis silenciosamente**, e o processo aqui foi desenhado para detectar isso e corrigir com uma segunda fonte independente, em vez de confiar na primeira passada.

---

## Por que a skill sozinha não bastava

Uma "Agent Skill" precisa ser **enxuta** — ela é carregada no contexto do agente toda vez que dispara, então o corpo principal (`skill/SKILL.md`) é deliberadamente um manual de campo de referência rápida: quando usar Jev vs. LLM, cheat sheet dos 3 primitivos, regra de confiança, armadilhas, SDK quickstart. Isso é o que um agente precisa **na hora de agir**.

Mas uma skill condensada tem um custo: ela não carrega a evidência por trás de cada afirmação, nem cobre os casos de borda, os números de benchmark, ou as citações de origem. Se alguém (você, ou um agente lendo a skill) precisar verificar *de onde veio* uma afirmação, ou aprofundar num tópico que a skill só menciona de passagem, a skill sozinha não tem essa profundidade — e comprimir tudo isso para dentro dela destruiria a própria razão de ela ser rápida de carregar.

Por isso o pacote carrega os dois:
- **`skill/`** — o que agir. Curto, imperativo, sempre carregado quando dispara.
- **`study/`** — por que agir assim. Toda a pesquisa, com fontes verbatim, benchmarks, citações — carregado sob demanda quando a skill (ou você) precisar apontar para a evidência.

A skill instalada **referencia ativamente** a pasta `study/` (com os links já ajustados para a profundidade correta pelo instalador — ver seção de instalação acima) — ela não é um artefato isolado.

---

## Anatomia da skill (`skill/`)

- **`SKILL.md`** — frontmatter com `name` (`jev-typesafe-expert`) e `description` (os gatilhos — frases e situações concretas que devem fazer um agente carregar a skill, não um resumo do conteúdo). Corpo: o que é Jev/System One, quando usar vs. um LLM generativo, cheat sheet dos primitivos, regras de `state`, resumo dos padrões de composição, regra de confiança/calibração, armadilhas, SDK quickstart, preço/limites — e pointers para `study/curated/01` a `07` para quem quiser a versão completa de cada tópico.
- **`references/primitives.md`** — schemas reais (Python/JS) de `choice`, `score`, `noul` e `state`, cardinalidade alta, batching de perguntas.
- **`references/patterns.md`** — os 4 padrões de composição recomendados (fan-out especulativo, confidence-gated routing, composite scoring, intent routing), com diagramas e a tabela de cookbooks oficiais mais úteis como receita pronta.
- **`references/sdk-quickref.md`** — instalação, autenticação e exemplo mínimo por primitivo nos SDKs Python e JavaScript, tratamento de erros/retries.
- **`references/pitfalls.md`** — 9 armadilhas documentadas como regra acionável ("se X, então Y"), incluindo três casos reais: um mod de jogo que travava por falta de dados de obstáculo no `state`, um projeto de compactação de contexto que piorou o desempenho ao remover a trilha de raciocínio, e um experimento de day-trading que falhou por exigir do modelo um tipo de raciocínio multi-fonte que ele não foi desenhado para fazer.

**Nota de terminologia:** o `SKILL.md` instrui explicitamente para nunca traduzir os termos técnicos de produto/API (`Jev`, `choice`, `score`, `noul`, `RLCD`, etc.), mesmo escrevendo em português — são nomes próprios, e traduzi-los quebra a correspondência com a documentação oficial e o SDK.

---

## Manutenção

Depois de editar qualquer coisa em `skill/` ou `study/`, rode o verificador de links antes de commitar:

```bash
python3 scripts/check-links.py
```

Ele varre todo o repositório, resolve cada link markdown local contra o disco, e sai com código 1 se achar algum link quebrado (dá pra plugar como hook de pre-commit ou passo de CI).

---

## Licença

O código deste repositório (scripts de instalação, `SKILL.md`, guias de referência, README) está sob [MIT](./LICENSE). O material em `study/sources/` e `study/sources-youtube/` é conteúdo de terceiros preservado verbatim para fins de citação e pesquisa (documentação da TypeSafe AI e transcrições públicas do YouTube) e permanece propriedade de seus respectivos detentores — ver nota completa no arquivo [LICENSE](./LICENSE).

## Aviso

Este é um material de estudo pessoal sobre um produto de terceiros (TypeSafe AI / Jev), não documentação oficial, e não tem qualquer afiliação com a TypeSafe AI. Sempre confira `study/sources/` e `study/sources-youtube/` para o texto original antes de tomar decisões de arquitetura baseadas nele, e consulte [docs.typesafe.ai](https://docs.typesafe.ai) para o estado atual da documentação (produtos de IA em early access mudam rápido).
