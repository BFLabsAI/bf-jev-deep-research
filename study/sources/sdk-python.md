---
título: Python SDK
fonte: https://docs.typesafe.ai/sdk/python.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - SDK
title: TypeSafe Python SDK — Documentação
description: "Página oficial de referência do SDK Python da TypeSafe AI: instalação, clientes sync/async e exemplo mínimo de chamada system_one."
---
# Python SDK

## Instalação

O SDK pode ser instalado via `uv add typesafe-sdk` ou `pip install typesafe-sdk`. É necessário configurar a variável de ambiente `TYPESAFE_API_KEY` antes de fazer chamadas.

```sh
uv add typesafe-sdk
```

```sh
pip install typesafe-sdk
```

## Funcionalidade principal

A documentação demonstra chamar a API do System One tanto de forma assíncrona quanto síncrona. O exemplo mostra o processamento de um ticket de suporte fazendo três tipos de perguntas:

- **Perguntas Noul**: avaliações binárias sim/não (ex.: "Este ticket é sobre cobrança?")
- **Perguntas Choice**: seleção entre múltiplas opções (ex.: tom do cliente)
- **Perguntas Score**: avaliação em uma escala (ex.: nível de urgência)

### Exemplo assíncrono

```python
from typesafe_sdk import AsyncTypeSafeClient, Choice, Noul, Score


async def main() -> None:
    async with AsyncTypeSafeClient() as client:
        response = await client.system_one(
            state={"document": "I was charged twice. Please fix this ASAP."},
            questions={
                "billing": Noul(instructions="Is this ticket about billing?"),
                "tone": Choice(
                    instructions="What is the customer's tone?",
                    criteria={"calm": None, "frustrated": None, "angry": None},
                ),
                "urgency": Score(
                    instructions="How urgent is this ticket?",
                    criteria=["can wait", "this week", "today"],
                ),
            },
        )

    print(response.nouls["billing"].noul)
    print(response.choices["tone"].choice)
    print(response.scores["urgency"].score)
```

### Exemplo síncrono

```python
from typesafe_sdk import Choice, Noul, Score, TypeSafeClient

with TypeSafeClient() as client:
    response = client.system_one(
        state={"document": "I was charged twice. Please fix this ASAP."},
        questions={
            "billing": Noul(instructions="Is this ticket about billing?"),
            "tone": Choice(
                instructions="What is the customer's tone?",
                criteria={"calm": None, "frustrated": None, "angry": None},
            ),
            "urgency": Score(
                instructions="How urgent is this ticket?",
                criteria=["can wait", "this week", "today"],
            ),
        },
    )

print(response.nouls["billing"].noul)
print(response.choices["tone"].choice)
print(response.scores["urgency"].score)
```

## Detalhes principais

O cliente assíncrono usa `AsyncTypeSafeClient`, enquanto a versão síncrona usa `TypeSafeClient`. Ambos aceitam um objeto `state` com os dados de entrada e um dicionário `questions` definindo quais análises executar. Os resultados são retornados em campos separados: `nouls`, `choices` e `scores`.

A documentação referencia o repositório GitHub e recomenda o guia de uso completo (ver [sdk-python-usage](./sdk-python-usage.md)) para mais detalhes.
