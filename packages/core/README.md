# Core

Pacote Flutter de infraestrutura HTTP compartilhada. Atualmente expõe um
wrapper pequeno sobre Dio (`ApiClient`) e uma exceção comum (`ApiException`).
Não contém repositories de domínio, modelos de Catalog/Booking/Account ou
regras de negócio.

## Estrutura e API pública

O barrel [core.dart](lib/core.dart) exporta:

- [`ApiClient`](lib/src/network/api_client.dart): chamadas GET/POST,
  configuração do Dio e tradução de falhas de transporte.
- [`ApiException`](lib/src/network/api_exception.dart): `statusCode` e
  `message` para erros convertidos pelo cliente.

O pacote depende de Dio. Por padrão, `ApiClient` cria o próprio `Dio` com a
base URL informada, remove barras finais dessa URL e configura timeouts de
conexão, envio e recebimento de 10 segundos, JSON como `contentType` e
`responseType`.

## Utilização

Os métodos disponíveis são `get(String path)` e
`post(String path, Map<String, dynamic> body)`. Ambos retornam `dynamic`;
o repository de cada domínio é responsável por validar e converter a resposta.

```dart
import 'package:core/core.dart';

final api = ApiClient(baseUrl: 'http://localhost:3000');

try {
  final response = await api.get('/cars');
  // O repository consumidor valida e converte response.
} on ApiException catch (error) {
  print('${error.statusCode}: ${error.message}');
} finally {
  api.close();
}
```

Também é possível passar uma instância de `Dio` e um provider opcional de
token:

```dart
final api = ApiClient(
  baseUrl: 'http://localhost:3000',
  tokenProvider: () => currentAccessToken,
);
```

Quando há `tokenProvider`, um interceptor o consulta em cada request. Um
token não nulo e não vazio é enviado como `Authorization: Bearer <token>`,
exceto em paths que começam com `/auth/`. A implementação não persiste nem
renova tokens. Se um `Dio` for injetado, suas opções — incluindo a base URL —
já são de responsabilidade de quem o criou; o interceptor de token ainda pode
ser instalado.

O método `close()` fecha o Dio associado com `force: true`. Se o cliente foi
injetado e é compartilhado, o chamador deve coordenar esse ciclo de vida.
No app atual, o Shell cria e fecha o `ApiClient` compartilhado.

## Erros

`DioException` é traduzida para `ApiException`:

- Com resposta HTTP, `statusCode` é o status recebido e `message` usa
  `response.data['message']` quando esse valor é uma string; caso contrário,
  usa `Erro na comunicação com a API`.
- Sem resposta, `statusCode` é `0`. Timeouts, erro de conexão e cancelamento
  recebem mensagens específicas; outros tipos recebem
  `Erro inesperado de comunicação`.

Exceções que não sejam `DioException` não são transformadas pelo cliente.
`ApiException.toString()` retorna `HTTP <statusCode>: <message>`.

## Integração no monorepo

O Shell cria um `ApiClient` com `API_BASE_URL` e injeta-o em
`HttpCatalogRepository`, `HttpBookingRepository`, `HttpAccountRepository` e
`HttpAccountSduiRepository`. Os endpoints e a interpretação de cada payload
permanecem nos respectivos MFEs:

- [Catalog](../features/catalog_mfe/README.md)
- [Booking](../features/booking_mfe/README.md)
- [Account](../features/account_mfe/README.md)

## Limites e testes

Core não deve assumir rotas de um domínio, converter respostas em modelos de
feature, decidir navegação ou manter estado de sessão. Essas responsabilidades
pertencem aos repositories e ao Shell, respectivamente. Core também não expõe
PUT/DELETE nem um tipo genérico de resultado; qualquer evolução deve preservar
o tratamento explícito de falhas.

Os testes do cliente estão em
[test/api_client_test.dart](test/api_client_test.dart) e cobrem uma resposta
de sucesso e a conversão de erro HTTP. [test/core_test.dart](test/core_test.dart)
é atualmente um teste placeholder.
