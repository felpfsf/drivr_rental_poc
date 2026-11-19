# DrivR — Flutter Monorepo + Microfrontends + SDUI

POC de um aplicativo de aluguel de veículos feita em **Flutter**, organizada em **monorepo com Melos**. O projeto explora modularização por funcionalidades (MFEs), navegação centralizada, comunicação HTTP com **Dio**, backend simulado com **Mockoon** e uma infraestrutura de **Server-Driven UI (SDUI)** reutilizável.

> **Escopo:** projeto de estudo. Os MFEs são pacotes Flutter integrados em tempo de compilação; não possuem deploy independente. A autenticação e as reservas são simuladas — não use dados reais.

## Pré-requisitos

- Flutter instalado e configurado (`flutter doctor`).
- Dart compatível com os Dart Pub Workspaces e a versão do Melos usada no projeto (na configuração inicial, **Dart 3.9+**).
- Melos instalado: `dart pub global activate melos`.
- [Mockoon Desktop](https://mockoon.com/) para executar a API simulada.
- Emulador Android, simulador iOS ou dispositivo configurado para Flutter.

## Executando o projeto

1. **Abra a pasta raiz do monorepo** no VS Code ou terminal.
2. Instale/resolva as dependências do workspace:

   ```bash
   melos bootstrap
   ```

3. **Inicie o Mockoon** com o ambiente `Drivr API` na porta `3000` e as rotas descritas abaixo. Se houver um arquivo de ambiente exportado em `mocks/mockoon/`, importe-o no Mockoon; caso contrário, configure as rotas manualmente. Para testar:

   ```bash
   curl http://localhost:3000/cars
   ```

4. Execute o Shell (único aplicativo executável):

   **iOS Simulator / macOS:**

   ```bash
   cd apps/shell_app
   flutter run --dart-define=API_BASE_URL=http://localhost:3000
   ```

   **Android Emulator:**

   ```bash
   cd apps/shell_app
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
   ```

   **Dispositivo físico:** substitua o host pelo IP local da máquina que executa o Mockoon e confirme que ambos estão na mesma rede, com acesso à porta `3000`.

### VS Code (`.vscode/launch.json`)

Abra **Run and Debug**, selecione a plataforma e pressione **F5**:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "DrivR Rental (iOS)",
      "request": "launch",
      "type": "dart",
      "program": "${workspaceFolder}/apps/shell_app/lib/main.dart",
      "cwd": "${workspaceFolder}/apps/shell_app",
      "flutterMode": "debug",
      "toolArgs": ["--dart-define=API_BASE_URL=http://localhost:3000"]
    },
    {
      "name": "DrivR Rental (Android)",
      "request": "launch",
      "type": "dart",
      "program": "${workspaceFolder}/apps/shell_app/lib/main.dart",
      "cwd": "${workspaceFolder}/apps/shell_app",
      "flutterMode": "debug",
      "toolArgs": ["--dart-define=API_BASE_URL=http://10.0.2.2:3000"]
    }
  ]
}
```

> Alterações em `--dart-define` exigem **reiniciar a execução**: hot reload não atualiza esses valores. Como o Mockoon usa HTTP local, o projeto também precisa permitir tráfego HTTP **somente no ambiente de desenvolvimento** (Android/iOS).

## Estrutura do monorepo

```text
.
├── apps/
│   └── shell_app/                 # Bootstrap, go_router, sessão e composição
├── packages/
│   ├── core/                      # ApiClient (Dio), erros e infraestrutura
│   ├── design_system/             # Tema, tokens e componentes compartilhados
│   ├── sdui_engine/               # Modelos, parser, registry e renderer recursivo
│   └── features/
│       ├── catalog_mfe/           # Listagem, detalhes e seção SDUI da Home
│       ├── booking_mfe/           # Datas, orçamento e confirmação de reserva
│       └── account_mfe/           # Login, cadastro mockado e perfil
├── mocks/
│   └── mockoon/                   # Local previsto para export do ambiente
└── pubspec.yaml                   # Dart workspace + configuração Melos
```

### Contratos e dependências

- **Shell**: instancia/injeta repositories, controla `go_router`, sessão e navegação entre MFEs.
- **MFEs**: expõem widgets e callbacks públicos. Não importam implementações internas de outros MFEs.
- **Core**: disponibiliza `ApiClient` baseado em Dio. Repositories ficam no MFE de cada domínio.
- **Design System**: fornece `AppTheme`, tokens e componentes genéricos.
- **SDUI Engine**: interpreta documentos versionados, valida limites e renderiza apenas componentes registrados; não conhece regras de negócio.
- **Catalog**: registra componentes específicos e resolve a ação `open_car` por `onCarSelected(carId)`; o Shell decide a rota.

**Fluxo principal:** catálogo → detalhes → período → orçamento → autenticação, se necessária → `POST /bookings` → confirmação.

## API simulada (Mockoon)

| Método | Rota | Uso |
|---|---|---|
| `GET` | `/cars` | Lista de veículos (Data Bucket/CRUD) |
| `GET` | `/cars/:id` | Detalhes de um veículo |
| `GET` | `/catalog/home-layout` | Documento SDUI da Home (schema v1/v2) |
| `POST` | `/bookings/quote` | Cotação com `carId`, `startDate`, `endDate`, `days` |
| `POST` | `/bookings` | Confirmação simulada; requer Bearer token |
| `POST` | `/auth/login` | Login fictício |
| `POST` | `/auth/register` | Cadastro fictício, sem persistência |
| `GET` | `/users/me` | Perfil fictício; requer Bearer token |

**Credenciais apenas de demonstração:**

```text
E-mail: demo@drivr.local
Senha: 123456
Token retornado: drivr-demo-token
```

Exemplo para testar a criação de reserva:

```bash
curl -i -X POST http://localhost:3000/bookings \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer drivr-demo-token' \
  -d '{"carId":"car-001","startDate":"2026-11-20","endDate":"2026-11-22"}'
```

A resposta de sucesso simulada usa `201 Created`, um `id` de reserva e `status: "confirmed"`. Também é possível configurar respostas de erro (`401`, `404`, `500`) e latência para testar a UI.

## Como funciona o SDUI

O endpoint `GET /catalog/home-layout` retorna uma árvore JSON de componentes. O `sdui_engine` faz o **parse**, aplica limites (**profundidade máxima de 5 níveis e até 50 nós**) e monta os widgets a partir de um **registry** permitido.

Componentes básicos: `column`, `row`, `text`, `spacer` e `button`. O Catalog acrescenta `section_title` e `promo_banner`, além de interpretar a ação `open_car`. Os schemas **v1 e v2** são aceitos; versões incompatíveis apresentam fallback.

Exemplo resumido:

```json
{
  "schemaVersion": 2,
  "blocks": [
    {
      "type": "column",
      "children": [
        {"type": "text", "props": {"value": "Conheça nossos carros", "style": "heading"}},
        {"type": "button", "props": {"label": "Ver Audi"},
         "action": {"type": "open_car", "carId": "car-001"}}
      ]
    }
  ]
}
```

**Limite intencional:** o backend configura conteúdo, ordem e componentes conhecidos; ele **não executa código Flutter nem controla rotas arbitrárias**. Se a seção SDUI falhar, a listagem tradicional de veículos continua funcionando.

## Qualidade e testes

Na raiz do repositório:

```bash
melos run analyze
melos run test
```

Testes importantes: navegação Catalog → Booking, regras de período/cotação, repositories e respostas HTTP simuladas, parser SDUI, registry, ação `open_car`, componentes desconhecidos e fallback de versão.

## Limitações conhecidas

- Autenticação e token apenas de demonstração; sessão em memória (reiniciar o app efetua logout).
- Cadastro e reservas não representam uma operação real e não têm persistência garantida.
- Preços, disponibilidade e pagamento não são validados por um backend de produção.
- Não há deploy independente dos MFEs, carregamento remoto de código nem recursos completos de SDUI para formulários/estado.
- O ambiente Mockoon precisa estar ativo para os fluxos que dependem da API.

## Referências

- [Flutter — documentação](https://docs.flutter.dev/)
- [Dart Pub Workspaces](https://dart.dev/tools/pub/workspaces)
- [Melos](https://melos.invertase.dev/)
- [Dio](https://pub.dev/packages/dio)
- [go_router](https://pub.dev/packages/go_router)
- [Mockoon](https://mockoon.com/docs/latest/)
