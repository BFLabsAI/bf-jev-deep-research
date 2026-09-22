# Contribuindo

Obrigado pelo interesse em melhorar este material sobre a Jev / TypeSafe AI.

## O que é bem-vindo

- **Correções factuais**: se algo em `study/curated/` ou `skill/` não bate com a fonte verbatim em `study/sources/`, ou com a documentação oficial atual em [docs.typesafe.ai](https://docs.typesafe.ai), abra uma issue ou PR apontando a divergência.
- **Novas fontes**: se a TypeSafe AI publicar documentação nova relevante, ou surgir um caso de uso real bem documentado, um PR adicionando a fonte (verbatim, com citação) + a atualização correspondente no documento de síntese é bem-vindo.
- **Melhorias na skill**: ajustes na `description` (gatilhos) do `skill/SKILL.md`, ou correções nos exemplos de código em `skill/references/`.
- **Correções nos instaladores**: `scripts/setup-bf-jev-deep-research.sh` e `.ps1` — especialmente relatos de uso real em Windows/Linux, já que o `.ps1` tem cobertura de teste manual menor que o `.sh`.

## O que evitar

- Não traduza os termos técnicos de produto/API (`Jev`, `choice`, `score`, `noul`, `RLCD`, etc.) — ver a nota de terminologia no `skill/SKILL.md`.
- Não adicione uma afirmação factual sem uma fonte local citável em `study/sources/` ou `study/sources-youtube/` (regra de *grounding* deste repositório — nunca uma URL solta como única evidência).
- Não edite `study/sources/` ou `study/sources-youtube/` além de correções de formatação — esse conteúdo é preservado verbatim de terceiros; se a fonte original mudou, adicione uma nova versão datada em vez de sobrescrever silenciosamente.

## Antes de abrir o PR

Rode o verificador de links (o mesmo que roda em CI):

```bash
python3 scripts/check-links.py
```

Ele precisa sair com `Tudo certo — nenhum link quebrado.` antes do PR ser aceito.

## Testando os instaladores localmente

Você pode apontar o instalador para o seu clone local em vez do GitHub, para testar mudanças antes de commitar:

```bash
sed "s#https://github.com/BFLabsAI/bf-jev-deep-research.git#$(pwd)#" scripts/setup-bf-jev-deep-research.sh > /tmp/test-install.sh
bash /tmp/test-install.sh /tmp/algum-diretorio-de-teste
```
