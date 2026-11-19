# SDUI Engine

Engine Flutter compartilhado para interpretar documentos de Server-Driven UI
(SDUI) como árvores de widgets. O backend fornece dados e identificadores de
ações; a aplicação só renderiza tipos de componentes e ações explicitamente
registrados. O Engine não executa código remoto, não conhece rotas e não
implementa regras de domínio.

## Estrutura e API pública

O barrel [sdui_engine.dart](lib/sdui_engine.dart) exporta:

- [Modelos](lib/src/models/sdui_document.dart): `SduiDocument`, `SduiNode` e
  `SduiAction`.
- [Parser](lib/src/parser/sdui_parser.dart): `SduiParser.parse`.
- [Registry](lib/src/registry/sdui_registry.dart): `SduiRegistry`,
  `SduiBlockBuilder` e `SduiNodeValidator`.
- [Componentes padrão](lib/src/registry/standard_components.dart):
  `createStandardSduiRegistry`.
- [Renderer](lib/src/renderer/sdui_renderer.dart): `SduiRenderer` e
  `SduiActionResolver`.

## Contrato de documento

O parser recebe um `Map<String, dynamic>` com `schemaVersion` inteiro e
`blocks` como lista. Cada node reconhecido tem `type` não vazio, `props`
opcionalmente como objeto, `children` opcionalmente como lista e `action`
opcionalmente como objeto com `type` não vazio.

```json
{
  "schemaVersion": 2,
  "blocks": [
    {
      "type": "button",
      "props": {"label": "Ver veículo"},
      "action": {"type": "open_car", "carId": "car-001"}
    }
  ]
}
```

`SduiParser.parse` devolve um `SduiDocument` e nodes compostos por listas e
maps não modificáveis. A ação preserva o objeto recebido em `SduiAction.params`
(incluindo `type`), permitindo ao MFE interpretar parâmetros específicos do
domínio.

### Parse e limites estruturais

- Payload sem `schemaVersion` inteiro ou sem `blocks` lista lança
  `FormatException`.
- `children` presente com valor que não seja lista lança `FormatException`.
- Nodes que não sejam map, tenham `type` ausente ou tenham `type` vazio são
  ignorados, não lançam erro.
- `props` ausente ou que não seja map vira um map vazio. Uma `action` inválida
  ou sem `type` não vazio é ignorada.
- A profundidade máxima é 5 níveis: o block de topo começa no nível zero.
  Mais profundidade lança `FormatException`.
- No máximo 50 nodes tipados são aceitos; exceder o limite lança
  `FormatException`.

Esses limites não equivalem a um limite de tamanho em bytes do payload, nem
validam os tipos e tamanhos de todas as propriedades. A validação de
propriedades é feita no registry.

## Component Registry e validação

Um `SduiRegistry` associa cada nome de `type` a um
`SduiBlockBuilder(context, node, children, onAction)`. Opcionalmente, associa
o mesmo type a um `SduiNodeValidator`, que retorna `null` quando o node é
válido ou uma mensagem de diagnóstico quando deve ser rejeitado.

`withComponents` e `withValidators` retornam novos registries imutáveis,
mesclando as entradas com as existentes. Uma entrada personalizada com o
mesmo nome substitui a anterior.

`createStandardSduiRegistry()` registra:

| Type | Contrato implementado |
|---|---|
| `column` | Exige ao menos um filho; `spacing` opcional aceita `xs`, `sm`, `md`, `lg`, `xl` |
| `row` | Exige de 1 a 3 filhos; `spacing` opcional aceita os mesmos tokens |
| `text` | Exige `value` string não vazia, com até 180 caracteres; `style` seleciona `heading`, `caption` ou o estilo de corpo padrão |
| `button` | Exige `label` string não vazia, com até 48 caracteres |
| `spacer` | `size` opcional aceita os tokens de espaçamento acima |

Para `column`, `row` e `spacer`, um espaçamento omitido usa `md`. Os
componentes padrão são construídos com `Column`, `Row`, `Text`, `SizedBox` e
`AppButton` do workspace. No `row`, cada filho é colocado em `Expanded`.

Exemplo de extensão por um MFE:

```dart
final registry = createStandardSduiRegistry()
    .withComponents({
      'account_badge': (context, node, children, onAction) {
        final label = node.props['label'];
        return Text(label is String ? label : '');
      },
    })
    .withValidators({
      'account_badge': (node) {
        return node.props['label'] is String
            ? null
            : 'label precisa ser texto';
      },
    });
```

O builder continua responsável por tratar as propriedades com segurança; o
validator permite excluir o node antes da construção quando o contrato não é
atendido.

## Renderização, versões e ações

`SduiRenderer` percorre recursivamente os blocks e seus children. Para cada
node, procura o builder, executa o validator registrado, resolve a ação e
chama o builder com os widgets children válidos. O documento é apresentado
como uma `Column`.

`SduiParser` não rejeita versões de schema desconhecidas. A compatibilidade é
decidida pelo renderer: `supportedVersions` é `{1, 2}` por padrão. Se
`schemaVersion` não estiver nesse conjunto, o renderer retorna o widget
`fallback` passado pelo consumidor (por padrão, `SizedBox.shrink`) para o
documento inteiro.

`actionResolver` recebe um `SduiAction` e retorna um callback ou `null`. O
Engine não interpreta nomes como `open_car` nem dispara navegação. Se a ação
não for resolvida, o builder recebe `onAction == null`; o botão padrão fica
desabilitado. Um node com componente desconhecido ou propriedades rejeitadas
é ignorado, sem impedir a renderização dos demais nodes válidos.

Diagnósticos de schema incompatível, componente desconhecido, propriedades
inválidas ou ação não resolvida são enviados a `debugPrint` somente em
`kDebugMode`. O renderer não oferece um callback de telemetria nem captura
exceções lançadas por builders.

## Integração de um MFE

O MFE deve buscar e converter o documento, criar um registry com componentes
e validators próprios, e resolver somente ações que pertençam ao seu domínio:

```dart
final document = SduiParser.parse(json);

SduiRenderer(
  document: document,
  registry: createStandardSduiRegistry(),
  actionResolver: (action) {
    if (action.type == 'show_details') return onShowDetails;
    return null;
  },
  fallback: const SizedBox.shrink(),
);
```

No monorepo, [Catalog](../features/catalog_mfe/README.md) registra
`section_title` e `promo_banner`, resolvendo `open_car`. [Account](../features/account_mfe/README.md)
registra `account_benefits_banner` e resolve `show_benefit_details`. Nenhum
desses callbacks delega ao Engine a escolha de uma rota.

## Segurança e limitações

- O registry é uma allowlist: novos types só são renderizáveis depois de
  incluídos no app. Não há reflexão, execução de Dart remoto ou carregamento
  dinâmico de widgets.
- Actions são strings e parâmetros de dados; cada MFE deve validar os
  parâmetros e restringir os callbacks ao seu domínio. O Engine não é uma
  camada de autorização.
- Os limites estruturais reduzem árvores excessivas, mas não substituem
  limites de payload, validação de entrada HTTP ou validators de cada
  componente.
- Não há suporte genérico a formulários com estado, persistência de estado,
  navegação remota ou componentes de terceiros. Um novo componente exige uma
  atualização da aplicação que o registra.
- A resposta do servidor deve continuar sendo considerada entrada não
  confiável; builders não devem fazer casts sem validação nem expor rotas ou
  operações arbitrárias.

## Testes

[test/sdui_engine_test.dart](test/sdui_engine_test.dart) cobre parse, limite de
nodes, extensão do registry e resolução de ação. [test/sdui_validation_test.dart](test/sdui_validation_test.dart)
cobre propriedades inválidas, actions não resolvidas e validação de
espaçamento.
