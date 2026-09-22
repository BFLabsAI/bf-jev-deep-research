---
título: Python SDK — Usage Guide
fonte: https://docs.typesafe.ai/sdk/python/usage.md
plataforma: TypeSafe AI Docs
data: 22/09/2026
idioma: en
tags:
  - Jev
  - TypeSafe AI
  - SDK
title: TypeSafe Python SDK — Guia de Uso
description: "Guia de uso detalhado do SDK Python: chamadas sync/async, tipagem com Pydantic, seleção de modelo, gateways alternativos, retries e tratamento de erros."
---
# Python SDK — Guia de Uso

## Chamando a API System One — Async

```python
import asyncio

from typesafe_sdk import AsyncTypeSafeClient, Choice, Noul, Score


async def main() -> None:
    async with AsyncTypeSafeClient() as client:
        result = await client.system_one(
            "I was charged twice. Please help ASAP.",
            {
                "billing": Noul(instructions="Is this about billing?"),
                "tone": Choice(
                    instructions="What is the tone?",
                    criteria={"calm": None, "angry": None},
                ),
                "urgency": Score(
                    instructions="How urgent is this?",
                    criteria=["low", "medium", "high"],
                ),
            },
        )
        print(
            result.nouls["billing"].noul,
            result.choices["tone"].choice,
            result.scores["urgency"].score,
        )


asyncio.run(main())
```

## Chamando a API System One — Sync

```python
from typesafe_sdk import Choice, Noul, Score, TypeSafeClient

client = TypeSafeClient()
state = "I was charged twice. Please help ASAP."
questions = {
    "billing": Noul(instructions="Is this about billing?"),
    "tone": Choice(
        instructions="What is the tone?", criteria={"calm": None, "angry": None}
    ),
    "urgency": Score(
        instructions="How urgent is this?", criteria=["low", "medium", "high"]
    ),
}
result = client.system_one(state, questions)
print(
    result.nouls["billing"].noul,
    result.choices["tone"].choice,
    result.scores["urgency"].score,
)
```

## Tipagem (Type Safety)

Desenvolvedores podem definir modelos Pydantic customizados para estruturar as respostas da API, permitindo validação tipada. Segundo a documentação: "It is possible to provide a response model to `system_one` to make using the response more *type-safe*."

```python
from typesafe_sdk import Noul, NoulAnswer, SystemOneResponse, TypeSafeClient


class BillingResponse(SystemOneResponse):
    billing: NoulAnswer


with TypeSafeClient() as client:
    result = client.system_one(
        "I was charged twice.",
        {"billing": Noul(instructions="Is this about billing?")},
        response_model=BillingResponse,
    )
    assert 0 <= result.billing.noul <= 1
    assert result.billing == result.nouls["billing"]
    print(result.request_id)
```

Também é possível usar tipos de resposta customizados com Pydantic puro (`BaseModel`), sem herdar de `SystemOneResponse`.

## Seleção de modelo

O SDK permite configurar o modelo na inicialização do cliente ou listar opções disponíveis via `TypeSafeClient().models.list()`.

```python
client = TypeSafeClient(model="jev")
```

## Integração com gateways alternativos

O SDK funciona com APIs alternativas como OpenRouter e Vercel AI Gateway, desde que sigam a especificação OpenAPI da TypeSafe (via parâmetro `base_url`).

```python
import os

from typesafe_sdk import Noul, TypeSafeClient

with TypeSafeClient(
    api_key=os.environ["OPENROUTER_API_KEY"],
    base_url="https://openrouter.ai/api",
    model="~typesafe/jev-latest",
) as client:
    result = client.system_one(
        "I was charged twice.",
        {"billing": Noul(instructions="Is this about billing?")},
    )
    print(result.nouls["billing"].noul)
```

## Resiliência (retries)

Políticas de retry customizadas suportam número máximo de tentativas, tempo de backoff e timeout configuráveis, tanto no cliente quanto por chamada individual.

```python
from typesafe_sdk import RetryPolicy, TypeSafeClient

client = TypeSafeClient(retry=RetryPolicy(max_retries=3, backoff_max=0.2, timeout=1.0))
```

A validação da API key ocorre na criação do cliente, antes de qualquer chamada de rede.

## Tratamento de erros

O SDK levanta exceções `TypeSafeAPIError` com status code e request ID para depuração.

```python
from typesafe_sdk import TypeSafeAPIError

try:
    client.system_one(state, questions)
except TypeSafeAPIError as error:
    print(error.status, error.request_id)
```

## Logging

Logging em nível debug/info disponível via módulo `logging` padrão do Python, com redação automática de headers sensíveis.

```python
import logging

logging.getLogger("typesafe_sdk").setLevel(logging.DEBUG)
```

## Compatibilidade futura (forward compatibility)

Campos adicionais da API podem ser enviados via `extra_body`; dicionários de perguntas "raw" suportam campos desconhecidos; e `raw_http_response` dá acesso à resposta completa da API.

```python
from typesafe_sdk import Noul, TypeSafeClient

with TypeSafeClient() as client:
    client.system_one(
        "I was charged twice.",
        {"billing": Noul(instructions="About billing?")},
        extra_body={"beam_width": 4},
    )
```

## Configuração

Variáveis de ambiente controlam API keys, base URLs, modelos padrão e níveis de logging. O SDK remove espaços em branco das API keys e valida seu formato antes das requisições.
