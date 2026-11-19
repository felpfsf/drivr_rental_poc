# Booking MFE

Feature responsável pela seleção do período, obtenção do orçamento e
solicitação de uma reserva de demonstração. Recebe o id do veículo e
dependências por construtor; autenticação e navegação são delegadas ao Shell.
Não há cobrança ou pagamento.

## Estrutura e modelos

- [booking_mfe.dart](lib/booking_mfe.dart): barrel público.
- [booking_quote.dart](lib/src/domain/booking_quote.dart):
  `RentalPeriod` e `BookingQuote`.
- [booking_confirmation.dart](lib/src/domain/booking_confirmation.dart):
  `BookingConfirmation`.
- [booking_repository.dart](lib/src/data/booking_repository.dart):
  contrato e implementação HTTP.
- [booking_page.dart](lib/src/presentation/booking_page.dart): seleção,
  revisão e confirmação.

`RentalPeriod` rejeita períodos cuja quantidade de dias seja menor ou igual a
zero. A quantidade é inclusiva nas duas datas: datas iguais correspondem a
uma diária. O cálculo normaliza ano/mês/dia em UTC para ignorar o horário do
dia.

`BookingQuote` contém o período, `dailyRate` e `total`. O repository HTTP
aceita esses valores do endpoint de cotação; o widget não recalcula nem
valida que `total == dailyRate * days`. `BookingConfirmation` converte
`id`, `carId` e `status` do JSON.

**Observação sobre o barrel atual:** `BookingRepository` expõe métodos que
recebem `RentalPeriod` e retornam `BookingQuote`, mas
[booking_mfe.dart](lib/booking_mfe.dart) não reexporta esses tipos. Eles estão
em `src/domain/booking_quote.dart`; consumidores que precisem nomeá-los hoje
precisam importar esse path interno.

## Contrato do repository

`BookingRepository` define:

```dart
Future<BookingQuote> getQuote({
  required String carId,
  required RentalPeriod period,
});

Future<BookingConfirmation> createBooking({
  required String carId,
  required RentalPeriod period,
});
```

`HttpBookingRepository` usa o `ApiClient` compartilhado:

| Método | Path | Body |
|---|---|---|
| `POST` | `/bookings/quote` | `carId`, `startDate`, `endDate`, `days` |
| `POST` | `/bookings` | `carId`, `startDate`, `endDate` |

As datas são serializadas como `yyyy-MM-dd`. A resposta de cotação fornece
`dailyRate` e `total`; a resposta de criação é convertida em
`BookingConfirmation`. Erros do Core são propagados pelo repository.

Há também `mockQuoteFor` e uma tabela de preços em
[mock_quote.dart](lib/src/data/mock_quote.dart). Esse helper é usado pelo
teste unitário de cálculo, não é exposto pelo barrel e não é o repository
injetado pelo Shell.

## Fluxo da tela

`BookingPage` recebe `carId`, `repository`, `onClose` e
`ensureAuthenticated: Future<bool> Function()`. Seus estados são:

1. **Datas:** o seletor permite escolher de hoje até um ano adiante.
   `Confirmar período` chama `getQuote`; enquanto aguarda, o botão indica
   cálculo. Falha mostra uma mensagem e mantém a seleção.
2. **Revisão:** exibe datas, número inclusivo de diárias, diária e total
   recebidos do repository. `Alugar agora` inicia a confirmação.
3. **Confirmação:** chama `ensureAuthenticated`. Se retornar `false`, não
   chama `createBooking`. Se retornar `true`, envia a criação.
4. **Sucesso:** só ocorre quando a resposta tem `status == 'confirmed'`, id
   não vazio e `carId` correspondente. Exibe o código da reserva.

`BookingPage` não conhece `GoRouter` nem decide como o usuário autentica.
`onClose` também é apenas um callback. O Shell controla o fluxo de rotas e a
autenticação; veja [Shell App](../../../apps/shell_app/README.md).

O tratamento de falhas de criação converte status HTTP 401 e 409 em mensagens
específicas. Outros erros HTTP e respostas inválidas mostram uma mensagem
genérica. Falha de cotação também é apresentada por mensagem genérica; o
usuário pode tentar novamente.

## Regras e limites

- A contagem de datas é inclusiva e não usa horário para calcular dias.
- `BookingQuote` não valida valores negativos ou consistência do total.
- `mockQuoteFor` conhece somente os IDs e tarifas definidos em sua tabela.
- A confirmação da API é demonstrativa; não há pagamento, consulta de
  disponibilidade própria, armazenamento local de reservas ou histórico.
- O Shell injeta `HttpBookingRepository`; a autenticação requer que o
  `ApiClient` receba o token mantido pelo Shell.
- O MFE não implementa autorização de servidor. O backend de demonstração
  precisa aplicar esse contrato; consulte as observações do
  [ambiente Mockoon](../../../mocks/mockoon/README.md).

## Testes

- [booking_quote_test.dart](test/booking_quote_test.dart): contagem
  inclusiva, período invertido e cálculo do helper mock.
- [booking_repository_test.dart](test/booking_repository_test.dart):
  path, body e conversão de confirmação.
- [booking_mfe_test.dart](test/booking_mfe_test.dart): teste widget básico
  da informação do veículo.
