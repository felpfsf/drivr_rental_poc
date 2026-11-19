# Catalog MFE

Feature de catálogo de veículos. Busca os carros e o layout dinâmico da Home,
mostra listagem e detalhes e comunica seleção de veículo ao Shell por
callbacks. O pacote não controla rotas entre features.

## Estrutura

- [catalog_mfe.dart](lib/catalog_mfe.dart): barrel público.
- [Model `DrivrRentalCar`](lib/src/models/drivr_rental_car.dart): dados do
  veículo e mapeamento do JSON.
- [CatalogRepository](lib/src/data/catalog_repository.dart):
  contrato e implementação HTTP.
- [CatalogPage](lib/src/presentation/catalog_page.dart): lista e slot SDUI.
- [CarDetailsPage](lib/src/presentation/car_details_page.dart): detalhes e
  chamada de início de reserva.
- [SDUI Catalog](lib/src/sdui/catalog_home_layout.dart) e
  [renderer específico](lib/src/sdui/catalog_sdui_renderer.dart).
- [Assets](assets/cars/): imagens locais mapeadas por ID de veículo.

## Repository e integração HTTP

O contrato `CatalogRepository` disponibiliza:

```dart
abstract interface class CatalogRepository {
  Future<List<DrivrRentalCar>> getCars();
  Future<DrivrRentalCar?> getCarById(String id);
  Future<CatalogHomeLayout> getHomeLayout();
}
```

`HttpCatalogRepository` recebe um `ApiClient` do [Core](../../core/README.md)
e chama:

| Método | Path | Conversão |
|---|---|---|
| `GET` | `/cars` | Lista de objetos convertida para `DrivrRentalCar` |
| `GET` | `/cars/{id}` | Um carro; `404` vira `null`, outros `ApiException` são propagados |
| `GET` | `/catalog/home-layout` | `CatalogHomeLayout.fromJson`, que usa `SduiParser` |

`DrivrRentalCar.fromJson` lê id, marca, modelo, preço diário, especificações e
descrição. Os IDs `car-001` a `car-004` selecionam imagens locais; IDs sem
mapeamento ficam sem `imageAsset` e usam o placeholder visual.

### Contratos de apresentação com o Shell

O barrel expõe `CatalogPage`, `CarDetailsPage`,
`CatalogRepository`, `HttpCatalogRepository` e `CatalogHomeLayout`.

- `CatalogPage` recebe `title`, `repository` e `onCarSelected(String carId)`.
- `CarDetailsPage` recebe `carId`, `repository`, `onBack()` e
  `onBookingRequested(String carId)`.

O Shell conecta `onCarSelected` a `/cars/:carId` e
`onBookingRequested` a `/bookings/new/:carId`. O MFE não importa nem chama
`GoRouter`; navegação para outra feature permanece no Shell.

**Observação sobre o barrel atual:** o tipo `DrivrRentalCar` aparece nos
retornos do contrato público `CatalogRepository`, mas não é reexportado por
`catalog_mfe.dart`. O modelo está em `src/models/drivr_rental_car.dart`;
consumidores que precisem nomear esse tipo hoje precisam importar esse path
interno.

## Fluxo e estados da UI

Ao iniciar, `CatalogPage` dispara em paralelo `getCars()` e `getHomeLayout()`.
O estado da lista principal é:

- loading: indicador de progresso;
- erro: mensagem e ação para repetir a chamada;
- sucesso vazio: “Nenhum veículo disponível”;
- sucesso com carros: lista de cards e `CatalogHomeSlot` na primeira posição.

O slot SDUI tem seu próprio loading e, em caso de falha de fetch ou ausência
de dados, mostra o texto estático “Explore nossos veículos disponíveis”.
Assim, uma falha de SDUI não substitui nem bloqueia a lista carregada.

`CarDetailsPage` busca o carro por id e exibe loading, erro com retry,
“Veículo não encontrado” ou os detalhes. O botão de período só aparece depois
de carregar um carro válido e chama `onBookingRequested(car.id)`.

## Integração com SDUI

`CatalogHomeLayout.fromJson` envolve `SduiDocument` e faz o parse do payload.
O `CatalogSduiRenderer` parte de `createStandardSduiRegistry()` e adiciona:

| Type Catalog | Props | Ação |
|---|---|---|
| `section_title` | `title` obrigatório (até 100 caracteres); `subtitle` opcional | Nenhuma |
| `promo_banner` | `title` obrigatório (até 100 caracteres); `description` e `buttonLabel` opcionais | Exibe CTA somente quando resolvida |

O renderer aceita os schemas 1 e 2 via `SduiRenderer`. A ação `open_car` exige
`carId` string não vazia e aciona `onCarSelected(carId)`; outras ações ou
parâmetros inválidos não navegam. Componente desconhecido ou props inválidas
são omitidos pelo Engine. Uma versão incompatível usa o fallback textual do
Catalog. Consulte [SDUI Engine](../../sdui_engine/README.md) para os limites
de parsing e segurança.

## Uso e extensão

O Shell fornece um repository ao construir a página:

```dart
CatalogPage(
  title: 'Carros',
  repository: catalogRepository,
  onCarSelected: (carId) => openCarDetails(carId),
);
```

Para adicionar um componente SDUI, estenda o registry local do Catalog,
valide suas props, implemente o builder e teste o componente/ação. Mantenha
ações específicas da feature no `CatalogSduiRenderer`; callbacks de navegação
continuam sendo entregues ao Shell.

Há dados locais em [mock_cars.dart](lib/src/data/mock_cars.dart), mas
`mockCars` e `findCarById` não são usados pelo repository HTTP nem pelas telas
atuais. Não há fallback automático da API para esses dados.

## Testes

- [catalog_mfe_test.dart](test/catalog_mfe_test.dart): comportamento da tela
  de detalhes com repository de teste.
- [catalog_sdui_renderer_test.dart](test/catalog_sdui_renderer_test.dart):
  componentes específicos, ação e fallback de versão.
- [catalog_sdui_tree_test.dart](test/catalog_sdui_tree_test.dart): árvore,
  ação, profundidade e quantidade máxima de nodes.
